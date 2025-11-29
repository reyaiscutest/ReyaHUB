-- ============================================
-- REYA HUB - FIXED VERSION
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(1)

print("🔄 Loading Reya Hub...")

-- ============================================
-- LOAD FLUENT UI LIBRARY
-- ============================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ============================================
-- SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- GAME MODULES
-- ============================================
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function MoveTo(cframe)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = cframe
        end
    end)
end

local function equipRod()
    pcall(function()
        net:WaitForChild("RE/EquipToolFromHotbar"):FireServer(1)
    end)
end

local function SellAll()
    pcall(function()
        net:WaitForChild("RF/SellAllItems"):InvokeServer()
    end)
end

-- ============================================
-- FISHING FUNCTIONS
-- ============================================
_G.AutoFish = false
_G.ActiveFishing = false
_G.FishingMethod = "Instant"
_G.InstantDelay = 0.1

local function InstantReel()
    pcall(function()
        net:WaitForChild("RE/FishingCompleted"):FireServer()
    end)
end

local function StopFish()
    _G.ActiveFishing = false
    pcall(function()
        net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
    end)
end

-- Instant Fishing Loop
task.spawn(function()
    while task.wait() do
        if _G.AutoFish and _G.FishingMethod == "Instant" then
            pcall(function()
                _G.ActiveFishing = true
                local timestamp = Workspace:GetServerTimeNow()
                
                equipRod()
                task.wait(0.1)
                
                net:WaitForChild("RF/ChargeFishingRod"):InvokeServer(timestamp)
                
                local x = -0.7499996423721313 + (math.random(-500, 500) / 10000000)
                local y = 1 + (math.random(-500, 500) / 10000000)
                
                net:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(x, y)
                
                task.wait(0.1)
                _G.ActiveFishing = false
            end)
        end
    end
end)

-- Auto reel when fish caught
net["RE/ReplicateTextEffect"].OnClientEvent:Connect(function(data)
    if _G.AutoFish and _G.ActiveFishing and data then
        local myHead = Character and Character:FindFirstChild("Head")
        if myHead and data.Container == myHead then
            task.spawn(function()
                for i = 1, 3 do
                    task.wait(_G.InstantDelay)
                    InstantReel()
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO SELL FUNCTION
-- ============================================
_G.AutoSell = false
_G.SellDelay = 20

task.spawn(function()
    while task.wait() do
        if _G.AutoSell then
            pcall(function()
                SellAll()
                task.wait(_G.SellDelay)
            end)
        end
    end
end)

-- ============================================
-- TELEPORT LOCATIONS
-- ============================================
local TeleportLocations = {
    ["Ancient Jungle"] = CFrame.new(1221.084228515625, 6.624999523162842, -544.1521606445312),
    ["Coral Reefs"] = CFrame.new(-3262.536376953125, 2.499969244003296, 2216.586181640625),
    ["Crater Island"] = CFrame.new(986.1575317382812, 3.1964468955993652, 5146.69970703125),
    ["Esoteric Depths"] = CFrame.new(983311.6767578125, -1302.8548583984375, 1394.7261962890625),
    ["Kohana"] = CFrame.new(-656.1355590820312, 17.250059127807617, 448.951171875),
    ["Kohana Volcano"] = CFrame.new(-554.2496948242188, 18.236753463745117, 117.22779846191406),
    ["Sisyphus Statue"] = CFrame.new(-3731.935546875, -135.0744171142578, -1014.7938232421875),
    ["Treasure Room"] = CFrame.new(-3560.293212890625, -279.07421875, -1605.2633056640625),
    ["Mount Hallow"] = CFrame.new(2144.46728515625, 80.88066864013672, 3269.4921875),
    ["Tropical Grove"] = CFrame.new(-2091.44580078125, 6.268016815185547, 3699.8486328125),
    ["Crystal Cavern"] = CFrame.new(-1723.7686767578125, -450.00048828125, 7205.43701171875),
    ["Crystal Falls"] = CFrame.new(-1955.166748046875, -447.50048828125, 7419.4140625),
}

-- ============================================
-- CREATE WINDOW
-- ============================================
local Window = Fluent:CreateWindow({
    Title = "Reya Hub",
    SubTitle = "Fish It Automation",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Server = Window:AddTab({ Title = "Server", Icon = "server" })
}

-- ============================================
-- HOME TAB
-- ============================================
Tabs.Home:AddParagraph({
    Title = "Welcome to Reya Hub!",
    Content = "Fish It automation script with multiple features.\n\nVersion: 1.0\nAuthor: Reya"
})

local StatsSection = Tabs.Home:AddSection("Statistics")

local FPSLabel = Tabs.Home:AddParagraph({
    Title = "FPS",
    Content = "0"
})

local PingLabel = Tabs.Home:AddParagraph({
    Title = "Ping",
    Content = "0 ms"
})

-- Update stats
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local fps = math.floor(Workspace:GetRealPhysicsFPS())
            FPSLabel:SetDesc("FPS: " .. tostring(fps))
            
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            PingLabel:SetDesc("Ping: " .. ping)
        end)
    end
end)

-- ============================================
-- FISHING TAB
-- ============================================
local FishingSection = Tabs.Fishing:AddSection("Auto Fishing")

local AutoFishToggle = Tabs.Fishing:AddToggle("AutoFish", {
    Title = "Auto Fish",
    Description = "Automatically catch fish",
    Default = false
})

AutoFishToggle:OnChanged(function(state)
    _G.AutoFish = state
    if not state then
        StopFish()
    end
    Fluent:Notify({
        Title = "Auto Fish",
        Content = state and "Enabled" or "Disabled",
        Duration = 3
    })
end)

local DelaySlider = Tabs.Fishing:AddSlider("InstantDelay", {
    Title = "Reel Delay",
    Description = "Delay between reels (seconds)",
    Default = 0.1,
    Min = 0,
    Max = 5,
    Rounding = 1
})

DelaySlider:OnChanged(function(value)
    _G.InstantDelay = value
end)

Tabs.Fishing:AddButton({
    Title = "Equip Rod",
    Description = "Equip fishing rod from hotbar",
    Callback = function()
        equipRod()
        Fluent:Notify({
            Title = "Success",
            Content = "Fishing rod equipped",
            Duration = 2
        })
    end
})

local SellSection = Tabs.Fishing:AddSection("Auto Sell")

local AutoSellToggle = Tabs.Fishing:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Description = "Automatically sell all fish",
    Default = false
})

AutoSellToggle:OnChanged(function(state)
    _G.AutoSell = state
    Fluent:Notify({
        Title = "Auto Sell",
        Content = state and "Enabled" or "Disabled",
        Duration = 3
    })
end)

local SellDelaySlider = Tabs.Fishing:AddSlider("SellDelay", {
    Title = "Sell Delay",
    Description = "Delay between sells (seconds)",
    Default = 20,
    Min = 1,
    Max = 60,
    Rounding = 0
})

SellDelaySlider:OnChanged(function(value)
    _G.SellDelay = value
end)

Tabs.Fishing:AddButton({
    Title = "Sell All Now",
    Description = "Manually sell all fish",
    Callback = function()
        SellAll()
        Fluent:Notify({
            Title = "Success",
            Content = "All fish sold",
            Duration = 2
        })
    end
})

-- ============================================
-- TELEPORT TAB
-- ============================================
local LocationSection = Tabs.Teleport:AddSection("Location Teleport")

local locationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = locationNames[1]

local LocationDropdown = Tabs.Teleport:AddDropdown("Location", {
    Title = "Select Location",
    Values = locationNames,
    Default = locationNames[1],
    Callback = function(value)
        selectedLocation = value
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Location",
    Description = "Go to selected location",
    Callback = function()
        if selectedLocation and TeleportLocations[selectedLocation] then
            MoveTo(TeleportLocations[selectedLocation])
            Fluent:Notify({
                Title = "Teleported",
                Content = "Moved to " .. selectedLocation,
                Duration = 3
            })
        end
    end
})

local PlayerSection = Tabs.Teleport:AddSection("Player Teleport")

local function GetPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return #list > 0 and list or {"No Players"}
end

local playerList = GetPlayerList()
local selectedPlayer = playerList[1]

local PlayerDropdown = Tabs.Teleport:AddDropdown("Player", {
    Title = "Select Player",
    Values = playerList,
    Default = playerList[1],
    Callback = function(value)
        selectedPlayer = value
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Player",
    Description = "Go to selected player",
    Callback = function()
        if selectedPlayer and selectedPlayer ~= "No Players" then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    MoveTo(targetHRP.CFrame + Vector3.new(0, 3, 0))
                    Fluent:Notify({
                        Title = "Teleported",
                        Content = "Moved to " .. selectedPlayer,
                        Duration = 3
                    })
                end
            end
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Refresh Player List",
    Description = "Update player list",
    Callback = function()
        playerList = GetPlayerList()
        PlayerDropdown:SetValues(playerList)
        Fluent:Notify({
            Title = "Refreshed",
            Content = "Player list updated",
            Duration = 2
        })
    end
})

-- ============================================
-- MISC TAB
-- ============================================
local OxygenSection = Tabs.Misc:AddSection("Oxygen")

Tabs.Misc:AddButton({
    Title = "Bypass Oxygen",
    Description = "Remove oxygen limit underwater",
    Callback = function()
        pcall(function()
            net["URE/UpdateOxygen"]:Destroy()
        end)
        Fluent:Notify({
            Title = "Success",
            Content = "Oxygen bypass activated!",
            Duration = 3
        })
    end
})

-- ============================================
-- SERVER TAB
-- ============================================
local ServerSection = Tabs.Server:AddSection("Server Controls")

Tabs.Server:AddButton({
    Title = "Rejoin Server",
    Description = "Rejoin current server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

Tabs.Server:AddButton({
    Title = "Server Hop",
    Description = "Join a different server",
    Callback = function()
        local success = pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/raw-scriptpastebin/FE/main/Server_Hop_Settings"))()
            module:Teleport(game.PlaceId)
        end)
        
        if not success then
            Fluent:Notify({
                Title = "Error",
                Content = "Server hop failed",
                Duration = 3
            })
        end
    end
})

local InfoSection = Tabs.Server:AddSection("Server Information")

Tabs.Server:AddParagraph({
    Title = "Job ID",
    Content = game.JobId
})

Tabs.Server:AddButton({
    Title = "Copy Job ID",
    Description = "Copy to clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Fluent:Notify({
                Title = "Copied",
                Content = "Job ID copied to clipboard",
                Duration = 3
            })
        end
    end
})

-- ============================================
-- AUTO REJOIN ON DISCONNECT
-- ============================================
task.spawn(function()
    while task.wait(5) do
        if not LocalPlayer or not LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(game.PlaceId)
        end
    end
end)

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult)
    if teleportResult == Enum.TeleportResult.Failure then
        TeleportService:Teleport(game.PlaceId)
    end
end)

-- ============================================
-- SUCCESS NOTIFICATION
-- ============================================
Fluent:Notify({
    Title = "Reya Hub",
    Content = "Successfully loaded! Happy fishing! 🎣",
    Duration = 5
})

print("╔═══════════════════════════════════════╗")
print("✅ REYA HUB LOADED!")
print("╠═══════════════════════════════════════╣")
print("Player:", LocalPlayer.Name)
print("PlaceID:", game.PlaceId)
print("╠═══════════════════════════════════════╣")
print("Features:")
print("  • Auto Fishing (Instant)")
print("  • Auto Sell")
print("  • 12+ Teleport Locations")
print("  • Player Teleport")
print("  • Oxygen Bypass")
print("  • Server Hop & Rejoin")
print("╚═══════════════════════════════════════╝")
