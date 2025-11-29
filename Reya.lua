-- ============================================
-- Reya HUB - WINDUI (CORRECT VERSION)
-- Using: https://github.com/Footagesus/WindUI
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- SAFE NOTIFICATION
-- ============================================
local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

-- ============================================
-- LOAD GAME COMPONENTS
-- ============================================
Notify("Loading...", "Loading game components...", 3)

local Net, ChargeRod, StartMini, FishDone, CancelFishing, EquipRod

pcall(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "net" and v:IsA("Folder") then
            Net = v
            break
        end
    end
    
    if Net then
        ChargeRod = Net:FindFirstChild("RF/ChargeFishingRod")
        StartMini = Net:FindFirstChild("RF/RequestFishingMinigameStarted")
        FishDone = Net:FindFirstChild("RE/FishingCompleted")
        CancelFishing = Net:FindFirstChild("RF/CancelFishingInputs")
        EquipRod = Net:FindFirstChild("RE/EquipToolFromHotbar")
    end
end)

if not (ChargeRod and StartMini and FishDone) then
    Notify("Error", "Required game components not found", 10)
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
-- FISHING MODULES
-- ============================================
local InstantFishing = {Enabled = false, CanFish = true}
local BlatantFishing = {Enabled = false, CancelWaitTime = 3, LastFishTime = 0}

function StartInstantFishing()
    InstantFishing.Enabled = true
    task.spawn(function()
        while InstantFishing.Enabled do
            if InstantFishing.CanFish then
                InstantFishing.CanFish = false
                pcall(function()
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
                InstantFishing.CanFish = true
            end
            task.wait(0.1)
        end
    end)
end

function StopInstantFishing()
    InstantFishing.Enabled = false
end

function StartBlatantFishing()
    BlatantFishing.Enabled = true
    task.spawn(function()
        while BlatantFishing.Enabled do
            pcall(function() FishDone:FireServer() end)
            task.wait(0.2)
        end
    end)
    task.spawn(function()
        while BlatantFishing.Enabled do
            task.wait(BlatantFishing.CancelWaitTime)
            if tick() - BlatantFishing.LastFishTime > BlatantFishing.CancelWaitTime then
                pcall(function()
                    if CancelFishing then CancelFishing:InvokeServer() end
                end)
            end
        end
    end)
end

function StopBlatantFishing()
    BlatantFishing.Enabled = false
    pcall(function()
        if CancelFishing then CancelFishing:InvokeServer() end
    end)
end

-- ============================================
-- TELEPORT
-- ============================================
local TeleportLocations = {
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    ["Crater Island"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Coral Reefs"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Mount Hallow"] = Vector3.new(2123, 80, 3265),
}

local function TeleportTo(position)
    pcall(function()
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        end
    end)
end

local function GetPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

-- ============================================
-- LOAD WINDUI (CORRECT VERSION)
-- ============================================
Notify("Loading UI...", "Loading WindUI library...", 3)

local WindUI
local loadSuccess = false

-- Try multiple URLs
local urls = {
    "https://raw.githubusercontent.com/reyaiscutest/ReyaHUB/main/Reya.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"
}

for _, url in ipairs(urls) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success and result then
        WindUI = result
        loadSuccess = true
        print("[Fish It Hub] Loaded WindUI from:", url)
        break
    else
        warn("[Fish It Hub] Failed to load from:", url)
    end
end

if not loadSuccess or not WindUI then
    Notify("Error", "Failed to load WindUI\nUsing fallback UI", 10)
    -- Load custom UI fallback here if needed
    return
end

-- ============================================
-- CREATE WINDOW
-- ============================================
local Window = WindUI:CreateWindow({
    Title = "Fish It Hub",
    Icon = "fish",
    Author = "Your Name",
    Folder = "FishItHub",
    Size = UDim2.fromOffset(550, 650),
    KeySystem = {
        Key = "",
        Note = "No key needed",
        SaveKey = false,
        Keys = {},
        GrabKeyFromSite = false,
        Actions = {
            [1] = {
                Text = "Open Discord",
                Link = ""
            }
        }
    },
    SideBarWidth = 170,
    HasOutline = true,
    Transparent = false,
    Theme = "Dark",
    ShowUserInfo = true,
    Crosshair = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255)
    }
})

-- ============================================
-- FISHING TAB
-- ============================================
local FishingTab = Window:Tab({
    Name = "Fishing",
    Icon = "fish",
    Color = Color3.fromRGB(0, 170, 255)
})

local FishingSection = FishingTab:Section({
    Name = "Fishing Features",
    Side = "Left"
})

FishingSection:Toggle({
    Name = "Instant Fishing",
    Description = "Catch fish instantly (Recommended)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            StartInstantFishing()
            Window:Notification({
                Title = "Enabled",
                Description = "Instant Fishing activated!",
                Duration = 3
            })
        else
            StopInstantFishing()
            Window:Notification({
                Title = "Disabled",
                Description = "Instant Fishing stopped",
                Duration = 3
            })
        end
    end
})

FishingSection:Divider()

FishingSection:Toggle({
    Name = "Blatant Fishing",
    Description = "Fast fishing with animation",
    Default = false,
    Callback = function(enabled)
        if enabled then
            StartBlatantFishing()
            Window:Notification({
                Title = "Enabled",
                Description = "Blatant Fishing activated!",
                Duration = 3
            })
        else
            StopBlatantFishing()
            Window:Notification({
                Title = "Disabled",
                Description = "Blatant Fishing stopped",
                Duration = 3
            })
        end
    end
})

FishingSection:Slider({
    Name = "Blatant Delay",
    Description = "Adjust delay (seconds)",
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
local TeleportTab = Window:Tab({
    Name = "Teleport",
    Icon = "map-pin",
    Color = Color3.fromRGB(255, 150, 0)
})

local LocationSection = TeleportTab:Section({
    Name = "Teleport to Location",
    Side = "Left"
})

local locationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = locationNames[1]

LocationSection:Dropdown({
    Name = "Select Location",
    Description = "Choose a location to teleport",
    Options = locationNames,
    Default = locationNames[1],
    Callback = function(value)
        selectedLocation = value
    end
})

LocationSection:Button({
    Name = "Teleport",
    Description = "Go to selected location",
    Callback = function()
        if selectedLocation and TeleportLocations[selectedLocation] then
            TeleportTo(TeleportLocations[selectedLocation])
            Window:Notification({
                Title = "Teleported",
                Description = "Moved to " .. selectedLocation,
                Duration = 3
            })
        end
    end
})

-- Player Teleport Section
local PlayerSection = TeleportTab:Section({
    Name = "Teleport to Player",
    Side = "Right"
})

local playerList = GetPlayerList()
local selectedPlayer = playerList[1]

local PlayerDropdown = PlayerSection:Dropdown({
    Name = "Select Player",
    Options = playerList,
    Default = playerList[1] or "No Players",
    Callback = function(value)
        selectedPlayer = value
    end
})

PlayerSection:Button({
    Name = "Refresh Players",
    Callback = function()
        playerList = GetPlayerList()
        -- Update dropdown (WindUI specific method)
        Window:Notification({
            Title = "Refreshed",
            Description = "Player list updated",
            Duration = 2
        })
    end
})

PlayerSection:Button({
    Name = "Teleport",
    Callback = function()
        if selectedPlayer then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and myHRP then
                    myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
                    Window:Notification({
                        Title = "Teleported",
                        Description = "Moved to " .. selectedPlayer,
                        Duration = 3
                    })
                end
            end
        end
    end
})

-- ============================================
-- CREDITS TAB
-- ============================================
local CreditsTab = Window:Tab({
    Name = "Credits",
    Icon = "info",
    Color = Color3.fromRGB(150, 150, 150)
})

local CreditsSection = CreditsTab:Section({
    Name = "Information",
    Side = "Left"
})

CreditsSection:Label({
    Name = "Fish It Hub v1.0",
    Description = "Created by: Your Name"
})

CreditsSection:Divider()

CreditsSection:Paragraph({
    Name = "Features",
    Description = [[
• Instant Fishing - No animation
• Blatant Fishing - With animation
• Location Teleport - 9+ spots
• Player Teleport
• Clean WindUI interface
    ]]
})

-- ============================================
-- SUCCESS
-- ============================================
Window:Notification({
    Title = "Reya Hub",
    Description = "Hub loaded successfully!\nEnjoy fishing! 🎣",
    Duration = 5
})

Notify("✅ Success!", "Fish It Hub loaded successfully!", 5)

print("════════════════════════════════════════")
print("✅ Reya HUB LOADED!")
print("════════════════════════════════════════")
print("PlaceID:", game.PlaceId)
print("Player:", LocalPlayer.Name)
print("Features: Instant Fishing, Blatant Fishing, Teleport")
print("════════════════════════════════════════")
