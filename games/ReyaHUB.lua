-- Fish It Hub - Complete Script
-- Features: Instant Fishing, Blatant Fishing, Teleport

-- ============================================
-- SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Network References
local Net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local FishingController = require(ReplicatedStorage.Controllers.FishingController)

-- Remote Functions & Events
local ChargeRod = Net["RF/ChargeFishingRod"]
local StartMini = Net["RF/RequestFishingMinigameStarted"]
local FishDone = Net["RE/FishingCompleted"]
local CancelFishing = Net["RF/CancelFishingInputs"]
local EquipRod = Net["RE/EquipToolFromHotbar"]

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
function getFishCount()
    local bagLabel = LocalPlayer.PlayerGui:WaitForChild("Inventory")
        :WaitForChild("Main"):WaitForChild("Top")
        :WaitForChild("Options"):WaitForChild("Fish")
        :WaitForChild("Label"):WaitForChild("BagSize")
    return tonumber((bagLabel.Text or "0/???"):match("(%d+)/")) or 0
end

-- ============================================
-- INSTANT FISHING MODULE
-- ============================================
local InstantFishing = {
    Enabled = false,
    CanFish = true,
    InstantCount = 0
}

function StartInstantFishing()
    InstantFishing.Enabled = true
    InstantFishing.InstantCount = getFishCount()
    
    task.spawn(function()
        while InstantFishing.Enabled do
            if InstantFishing.CanFish then
                InstantFishing.CanFish = false
                
                local serverTime = Workspace:GetServerTimeNow()
                
                if pcall(function()
                    return ChargeRod:InvokeServer(serverTime)
                end) then
                    StartMini:InvokeServer(-1, 0.999)
                    
                    local initialCount = getFishCount()
                    local startTime = tick()
                    
                    repeat
                        FishDone:FireServer()
                        task.wait(0.1)
                    until initialCount < getFishCount() or tick() - startTime >= 5
                    
                    local newCount = getFishCount()
                    if InstantFishing.InstantCount < newCount then
                        InstantFishing.InstantCount = newCount
                    end
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
-- BLATANT FISHING MODULE
-- ============================================
local BlatantFishing = {
    Enabled = false,
    CancelWaitTime = 3,
    ResetTimer = 0.5,
    LastFishTime = 0,
    LastCancelTime = 0,
    HasFishingEffect = false,
    FishConnected = false
}

-- Hook Fish Caught Event
if not BlatantFishing.FishConnected then
    local OriginalFishCaught = FishingController.FishCaught
    function FishingController.FishCaught(...)
        if BlatantFishing.Enabled then
            BlatantFishing.LastFishTime = tick()
        end
        return OriginalFishCaught(...)
    end
    BlatantFishing.FishConnected = true
end

-- Monitor Fishing Effects
local PlayFishEffect = Net["RE/PlayFishingEffect"]
if typeof(PlayFishEffect) == "Instance" and PlayFishEffect:IsA("RemoteEvent") then
    PlayFishEffect.OnClientEvent:Connect(function(player, _, effectType)
        if player == LocalPlayer and effectType == 2 then
            BlatantFishing.HasFishingEffect = true
        end
    end)
end

function StartBlatantFishing()
    BlatantFishing.Enabled = true
    
    -- Initial Bug Trigger
    task.spawn(function()
        repeat task.wait(0.1) until BlatantFishing.Enabled
        
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        task.wait(0.1)
        
        if char:FindFirstChild("!!!FISHING_VIEW_MODEL!!!") then
            pcall(function()
                EquipRod:FireServer(1)
            end)
        end
        
        task.wait(0.1)
        local cosmeticFolder = Workspace:FindFirstChild("CosmeticFolder")
        if cosmeticFolder and not cosmeticFolder:FindFirstChild(tostring(LocalPlayer.UserId)) then
            pcall(function()
                ChargeRod:InvokeServer(2)
                StartMini:InvokeServer(-1.25, 1)
            end)
        end
    end)
    
    -- Continuous Fishing
    task.spawn(function()
        while BlatantFishing.Enabled do
            task.wait(0.2)
            pcall(function()
                FishDone:FireServer()
            end)
        end
    end)
    
    -- Auto Cancel on Stuck
    task.spawn(function()
        while BlatantFishing.Enabled do
            task.wait(BlatantFishing.CancelWaitTime)
            
            local currentTime = tick()
            if not BlatantFishing.HasFishingEffect and 
               currentTime - BlatantFishing.LastFishTime > BlatantFishing.CancelWaitTime - BlatantFishing.ResetTimer then
                pcall(function()
                    CancelFishing:InvokeServer()
                end)
                BlatantFishing.LastCancelTime = currentTime
            end
            
            BlatantFishing.HasFishingEffect = false
        end
    end)
end

function StopBlatantFishing()
    BlatantFishing.Enabled = false
    pcall(function()
        CancelFishing:InvokeServer()
    end)
end

function SetBlatantDelay(delay)
    local numDelay = tonumber(delay)
    if numDelay and numDelay > 0 then
        BlatantFishing.CancelWaitTime = numDelay
    end
end

-- ============================================
-- TELEPORT MODULE
-- ============================================
local TeleportLocations = {
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Crater Island Ground"] = Vector3.new(1079.57, 3.64, 5080.35),
    ["Coral Reefs SPOT 1"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Coral Reefs SPOT 2"] = Vector3.new(-3270.86, 2.5, 2228.1),
    ["Coral Reefs SPOT 3"] = Vector3.new(-3136.1, 2.61, 2126.11),
    ["Lost Shore"] = Vector3.new(-3737.97, 5.43, -854.68),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Kohana SPOT 1"] = Vector3.new(-367.77, 6.75, 521.91),
    ["Kohana SPOT 2"] = Vector3.new(-623.96, 19.25, 419.36),
    ["Stingray Shores"] = Vector3.new(44.41, 28.83, 3048.93),
    ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    ["Tropical Grove Cave 1"] = Vector3.new(-2151, 3, 3671),
    ["Tropical Grove Cave 2"] = Vector3.new(-2018, 5, 3756),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Secret Temple"] = Vector3.new(1475, -22, -632),
    ["Underground Cellar"] = Vector3.new(2136, -91, -699),
    ["Mount Hallow"] = Vector3.new(2123, 80, 3265),
    ["Hallow Bay"] = Vector3.new(1730, 8, 3046),
}

function TeleportToLocation(locationName)
    local position = TeleportLocations[locationName]
    if position then
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            hrp.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
            return true
        end
    end
    return false
end

function TeleportToPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    
    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        
        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
            return true
        end
    end
    return false
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
-- WINDUI INTEGRATION
-- ============================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSDOORS/main/Libs/Wind/source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Fish It Hub",
    Icon = "rbxassetid://10723415766",
    Author = "Your Name",
    Folder = "FishItHub",
    Size = UDim2.fromOffset(500, 600),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Theme = "Dark",
    DisableDragging = false,
    ShowIcon = true,
    CloseCallback = function()
        print("Window Closed")
    end
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
    Description = "Auto catch fish instantly (Recommended)",
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
    Description = "Set delay for blatant fishing (seconds)",
    Flag = "BlatantDelay",
    Min = 1,
    Max = 10,
    Default = 3,
    Decimals = 1,
    Callback = function(value)
        SetBlatantDelay(value)
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

-- Convert locations to array for dropdown
local locationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = nil

LocationSection:CreateDropdown({
    Name = "Select Location",
    Description = "Choose a location to teleport",
    Options = locationNames,
    Default = locationNames[1],
    Flag = "LocationDropdown",
    Callback = function(selected)
        selectedLocation = selected
    end
})

LocationSection:CreateButton({
    Name = "Teleport",
    Description = "Teleport to selected location",
    Callback = function()
        if selectedLocation then
            if TeleportToLocation(selectedLocation) then
                Window:Notify({
                    Title = "Success",
                    Content = "Teleported to " .. selectedLocation,
                    Duration = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Content = "Failed to teleport",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Error",
                Content = "Please select a location first",
                Duration = 3
            })
        end
    end
})

local PlayerSection = TeleportTab:CreateSection({
    Name = "Teleport to Player"
})

local playerList = GetPlayerList()
local selectedPlayer = nil

local PlayerDropdown = PlayerSection:CreateDropdown({
    Name = "Select Player",
    Description = "Choose a player to teleport",
    Options = playerList,
    Default = playerList[1] or "No Players",
    Flag = "PlayerDropdown",
    Callback = function(selected)
        selectedPlayer = selected
    end
})

PlayerSection:CreateButton({
    Name = "Refresh Player List",
    Description = "Update the list of players",
    Callback = function()
        playerList = GetPlayerList()
        PlayerDropdown:SetOptions(playerList)
        Window:Notify({
            Title = "Success",
            Content = "Player list refreshed",
            Duration = 2
        })
    end
})

PlayerSection:CreateButton({
    Name = "Teleport",
    Description = "Teleport to selected player",
    Callback = function()
        if selectedPlayer then
            if TeleportToPlayer(selectedPlayer) then
                Window:Notify({
                    Title = "Success",
                    Content = "Teleported to " .. selectedPlayer,
                    Duration = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Content = "Failed to teleport to player",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "Error",
                Content = "Please select a player first",
                Duration = 3
            })
        end
    end
})

-- ============================================
-- CREDITS TAB
-- ============================================
local CreditsTab = Window:CreateTab({
    Name = "Credits",
    Icon = "rbxassetid://10723407389",
    Visible = true
})

local CreditsSection = CreditsTab:CreateSection({
    Name = "Information"
})

CreditsSection:CreateLabel({
    Text = "Fish It Hub v1.0",
    Color = Color3.fromRGB(255, 255, 255)
})

CreditsSection:CreateLabel({
    Text = "Created by: Your Name",
    Color = Color3.fromRGB(200, 200, 200)
})

CreditsSection:CreateDivider()

CreditsSection:CreateLabel({
    Text = "Features:",
    Color = Color3.fromRGB(255, 255, 255)
})

CreditsSection:CreateLabel({
    Text = "• Instant Fishing",
    Color = Color3.fromRGB(150, 150, 150)
})

CreditsSection:CreateLabel({
    Text = "• Blatant Fishing",
    Color = Color3.fromRGB(150, 150, 150)
})

CreditsSection:CreateLabel({
    Text = "• Location Teleport",
    Color = Color3.fromRGB(150, 150, 150)
})

CreditsSection:CreateLabel({
    Text = "• Player Teleport",
    Color = Color3.fromRGB(150, 150, 150)
})

-- ============================================
-- INITIALIZATION
-- ============================================
Window:Notify({
    Title = "Fish It Hub",
    Content = "Hub loaded successfully!",
    Duration = 5
})

print("Fish It Hub loaded successfully!")
print("Features: Instant Fishing, Blatant Fishing, Teleport")
