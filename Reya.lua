-- ============================================
-- FISH IT HUB - STANDALONE VERSION (FIXED)
-- No external dependencies, works standalone
-- ============================================

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ============================================
-- SERVICES & SAFE LOADING
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Safe notification function
local function SafeNotify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

-- ============================================
-- SAFE NETWORK LOADING
-- ============================================
local Net, FishingController, ChargeRod, StartMini, FishDone, CancelFishing, EquipRod

local function LoadNetworkComponents()
    local success, err = pcall(function()
        -- Try to load Net module
        local netPath = ReplicatedStorage:FindFirstChild("Packages")
        if netPath then
            netPath = netPath:FindFirstChild("_Index")
            if netPath then
                netPath = netPath:FindFirstChild("sleitnick_net@0.2.0")
                if netPath then
                    Net = netPath:FindFirstChild("net")
                end
            end
        end
        
        if not Net then
            -- Alternative path
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v.Name == "net" and v:IsA("Folder") then
                    Net = v
                    break
                end
            end
        end
        
        if Net then
            ChargeRod = Net:FindFirstChild("RF/ChargeFishingRod")
            StartMini = Net:FindFirstChild("RF/RequestFishingMinigameStarted")
            FishDone = Net:FindFirstChild("RE/FishingCompleted")
            CancelFishing = Net:FindFirstChild("RF/CancelFishingInputs")
            EquipRod = Net:FindFirstChild("RE/EquipToolFromHotbar")
        end
        
        -- Try to load FishingController
        local controllersPath = ReplicatedStorage:FindFirstChild("Controllers")
        if controllersPath then
            local fishingCtrl = controllersPath:FindFirstChild("FishingController")
            if fishingCtrl then
                FishingController = require(fishingCtrl)
            end
        end
    end)
    
    return success, err
end

SafeNotify("Loading...", "Loading network components...", 3)
local loadSuccess, loadError = LoadNetworkComponents()

if not loadSuccess then
    SafeNotify("Error", "Failed to load game modules\nGame might have updated", 10)
    warn("Load Error:", loadError)
    return
end

if not (ChargeRod and StartMini and FishDone) then
    SafeNotify("Error", "Required game functions not found\nGame might have updated", 10)
    warn("Missing components!")
    warn("ChargeRod:", ChargeRod ~= nil)
    warn("StartMini:", StartMini ~= nil)
    warn("FishDone:", FishDone ~= nil)
    return
end

-- ============================================
-- CHARACTER HANDLING
-- ============================================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)

if not HumanoidRootPart then
    SafeNotify("Error", "Character not loaded properly", 10)
    return
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function getFishCount()
    local success, count = pcall(function()
        local bagLabel = LocalPlayer.PlayerGui:WaitForChild("Inventory")
            :WaitForChild("Main"):WaitForChild("Top")
            :WaitForChild("Options"):WaitForChild("Fish")
            :WaitForChild("Label"):WaitForChild("BagSize")
        return tonumber((bagLabel.Text or "0/???"):match("(%d+)/")) or 0
    end)
    return success and count or 0
end

-- ============================================
-- INSTANT FISHING
-- ============================================
local InstantFishing = {
    Enabled = false,
    CanFish = true
}

function StartInstantFishing()
    InstantFishing.Enabled = true
    
    task.spawn(function()
        while InstantFishing.Enabled do
            if InstantFishing.CanFish then
                InstantFishing.CanFish = false
                
                local success = pcall(function()
                    local serverTime = Workspace:GetServerTimeNow()
                    ChargeRod:InvokeServer(serverTime)
                    task.wait(0.1)
                    StartMini:InvokeServer(-1, 0.999)
                    
                    local initialCount = getFishCount()
                    local startTime = tick()
                    
                    repeat
                        FishDone:FireServer()
                        task.wait(0.1)
                    until initialCount < getFishCount() or tick() - startTime >= 5
                end)
                
                if not success then
                    task.wait(1)
                end
                
                InstantFishing.CanFish = true
            end
            task.wait(0.1)
        end
    end)
end

function StopInstantFishing()
    InstantFishing.Enabled = false
end

-- ============================================
-- BLATANT FISHING
-- ============================================
local BlatantFishing = {
    Enabled = false,
    CancelWaitTime = 3,
    LastFishTime = 0,
    HasFishingEffect = false
}

-- Hook Fish Caught (Safe)
if FishingController then
    pcall(function()
        local OriginalFishCaught = FishingController.FishCaught
        function FishingController.FishCaught(...)
            if BlatantFishing.Enabled then
                BlatantFishing.LastFishTime = tick()
            end
            return OriginalFishCaught(...)
        end
    end)
end

-- Monitor Effects (Safe)
pcall(function()
    local PlayFishEffect = Net:FindFirstChild("RE/PlayFishingEffect")
    if PlayFishEffect and PlayFishEffect:IsA("RemoteEvent") then
        PlayFishEffect.OnClientEvent:Connect(function(player, _, effectType)
            if player == LocalPlayer and effectType == 2 then
                BlatantFishing.HasFishingEffect = true
            end
        end)
    end
end)

function StartBlatantFishing()
    BlatantFishing.Enabled = true
    
    -- Continuous Fishing
    task.spawn(function()
        while BlatantFishing.Enabled do
            pcall(function()
                FishDone:FireServer()
            end)
            task.wait(0.2)
        end
    end)
    
    -- Auto Cancel
    task.spawn(function()
        while BlatantFishing.Enabled do
            task.wait(BlatantFishing.CancelWaitTime)
            
            if not BlatantFishing.HasFishingEffect and 
               tick() - BlatantFishing.LastFishTime > BlatantFishing.CancelWaitTime then
                pcall(function()
                    if CancelFishing then
                        CancelFishing:InvokeServer()
                    end
                end)
            end
            
            BlatantFishing.HasFishingEffect = false
        end
    end)
end

function StopBlatantFishing()
    BlatantFishing.Enabled = false
    pcall(function()
        if CancelFishing then
            CancelFishing:InvokeServer()
        end
    end)
end

-- ============================================
-- TELEPORT
-- ============================================
local TeleportLocations = {
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Coral Reefs"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Mount Hallow"] = Vector3.new(2123, 80, 3265),
}

function TeleportToLocation(locationName)
    local position = TeleportLocations[locationName]
    if position then
        local success = pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
            end
        end)
        return success
    end
    return false
end

function TeleportToPlayer(playerName)
    local success = pcall(function()
        local targetPlayer = Players:FindFirstChild(playerName)
        if targetPlayer and targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
    return success
end

function GetPlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- ============================================
-- LOAD WINDUI
-- ============================================
SafeNotify("Loading UI...", "Loading WindUI library...", 3)

local WindUI
local loadUISuccess, loadUIError = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSDOORS/main/Libs/Wind/source.lua"))()
end)

if not loadUISuccess or not WindUI then
    SafeNotify("Error", "Failed to load UI library\nTry again later", 10)
    warn("WindUI Load Error:", loadUIError)
    return
end

-- ============================================
-- CREATE UI
-- ============================================
local Window = WindUI:CreateWindow({
    Title = "Fish It Hub",
    Icon = "rbxassetid://10723415766",
    Author = "Fixed Version",
    Folder = "FishItHub",
    Size = UDim2.fromOffset(500, 600),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Theme = "Dark",
    DisableDragging = false,
    ShowIcon = true
})

-- ============================================
-- FISHING TAB
-- ============================================
local FishingTab = Window:CreateTab({
    Name = "Fishing",
    Icon = "rbxassetid://10723424838",
    Visible = true
})

local FishingSection = FishingTab:CreateSection({
    Name = "Fishing Features"
})

FishingSection:CreateToggle({
    Name = "Instant Fishing",
    Description = "Catch fish instantly (Recommended)",
    Flag = "InstantFishing",
    Default = false,
    Callback = function(enabled)
        if enabled then
            StartInstantFishing()
        else
            StopInstantFishing()
        end
    end
})

FishingSection:CreateDivider()

FishingSection:CreateToggle({
    Name = "Blatant Fishing",
    Description = "Fast fishing with animation",
    Flag = "BlatantFishing",
    Default = false,
    Callback = function(enabled)
        if enabled then
            StartBlatantFishing()
        else
            StopBlatantFishing()
        end
    end
})

FishingSection:CreateSlider({
    Name = "Blatant Delay",
    Description = "Adjust delay (seconds)",
    Flag = "BlatantDelay",
    Min = 1,
    Max = 10,
    Default = 3,
    Decimals = 1,
    Callback = function(value)
        BlatantFishing.CancelWaitTime = value
    end
})

-- ============================================
-- TELEPORT TAB
-- ============================================
local TeleportTab = Window:CreateTab({
    Name = "Teleport",
    Icon = "rbxassetid://10723434711",
    Visible = true
})

local LocationSection = TeleportTab:CreateSection({
    Name = "Teleport to Location"
})

local locationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = nil

LocationSection:CreateDropdown({
    Name = "Select Location",
    Description = "Choose location",
    Options = locationNames,
    Default = locationNames[1],
    Flag = "LocationDropdown",
    Callback = function(selected)
        selectedLocation = selected
    end
})

LocationSection:CreateButton({
    Name = "Teleport",
    Description = "Go to selected location",
    Callback = function()
        if selectedLocation and TeleportToLocation(selectedLocation) then
            Window:Notify({
                Title = "Success",
                Content = "Teleported to " .. selectedLocation,
                Duration = 3
            })
        end
    end
})

local PlayerSection = TeleportTab:CreateSection({
    Name = "Teleport to Player"
})

local selectedPlayer = nil
local PlayerDropdown = PlayerSection:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    Default = "Select Player",
    Flag = "PlayerDropdown",
    Callback = function(selected)
        selectedPlayer = selected
    end
})

PlayerSection:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        PlayerDropdown:SetOptions(GetPlayerList())
        Window:Notify({
            Title = "Refreshed",
            Content = "Player list updated",
            Duration = 2
        })
    end
})

PlayerSection:CreateButton({
    Name = "Teleport",
    Callback = function()
        if selectedPlayer and TeleportToPlayer(selectedPlayer) then
            Window:Notify({
                Title = "Success",
                Content = "Teleported to " .. selectedPlayer,
                Duration = 3
            })
        end
    end
})

-- ============================================
-- SUCCESS
-- ============================================
SafeNotify("✅ Loaded!", "Fish It Hub ready!\nEnjoy fishing! 🎣", 5)
Window:Notify({
    Title = "Reya Hub",
    Content = "Hub loaded successfully!\nEnjoy! 🎣",
    Duration = 5
})

print("════════════════════════════════════")
print("✅ Reya HUB LOADED SUCCESSFULLY")
print("════════════════════════════════════")
print("PlaceID:", game.PlaceId)
print("Player:", LocalPlayer.Name)
print("Features: Instant Fishing, Blatant Fishing, Teleport")
print("════════════════════════════════════")
