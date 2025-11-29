-- ============================================
-- REYA HUB - NO KEY VERSION (FINAL)
-- Based on Reelz Hub structure
-- WindUI KeySystem disabled globally
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ============================================
-- LOAD WINDUI
-- ============================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ====== FORCE DISABLE KEY SYSTEM (GLOBAL PATCH) ======
-- Some forks/versions require disabling through Config before CreateWindow
pcall(function()
    if type(WindUI) == "table" then
        WindUI.Config = WindUI.Config or {}
        WindUI.Config.KeySystem = WindUI.Config.KeySystem or {}
        WindUI.Config.KeySystem.Enabled = false

        -- Some builds reference WindUI.KeySystem directly
        WindUI.KeySystem = WindUI.KeySystem or {}
        WindUI.KeySystem.Enabled = false

        -- Ensure CreateWindow default param can't re-enable it
        local oldCreateWindow = WindUI.CreateWindow
        if type(oldCreateWindow) == "function" then
            WindUI.CreateWindow = function(self, config)
                config = config or {}
                config.KeySystem = config.KeySystem or {}
                config.KeySystem.Enabled = false
                return oldCreateWindow(self, config)
            end
        end
    end
end)

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
        if net:FindFirstChild("RF/CancelFishingInputs") then
            net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
        end
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
                
                if net:FindFirstChild("RF/ChargeFishingRod") then
                    net:WaitForChild("RF/ChargeFishingRod"):InvokeServer(timestamp)
                end
                
                local x = -0.7499996423721313 + (math.random(-500, 500) / 10000000)
                local y = 1 + (math.random(-500, 500) / 10000000)
                
                if net:FindFirstChild("RF/RequestFishingMinigameStarted") then
                    net:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(x, y)
                end
                
                task.wait(0.1)
                _G.ActiveFishing = false
            end)
        end
    end
end)

-- Auto reel when fish caught
if net:FindFirstChild("RE/ReplicateTextEffect") then
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
end

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
-- CREATE WINDOW (NO KEY SYSTEM - METHOD 2)
-- ============================================
local Window = WindUI:CreateWindow({
    Title = "Reya Hub",
    Icon = "fish",
    Author = "Reya",
    Folder = "ReyaHub",
    Size = UDim2.fromOffset(550, 650),
    KeySystem = {
        Enabled = false -- Explicitly disable (redundant but safe)
    },
    SideBarWidth = 170,
    HasOutline = true,
    Transparent = false,
    Theme = "Dark",
    ShowUserInfo = true
})

-- ============================================
-- INFO TAB
-- ============================================
local InfoTab = Window:Tab({
    Name = "Info",
    Icon = "info",
    Color = Color3.fromRGB(150, 150, 150)
})

local InfoSection = InfoTab:Section({
    Name = "Information",
    Side = "Left"
})

InfoSection:Label({
    Name = "Reya Hub v1.0",
    Description = "Fish It Automation Hub"
})

InfoSection:Divider()

local GameTimeParagraph = InfoSection:Paragraph({
    Name = "Game Time",
    Description = "Loading..."
})

local FpsParagraph = InfoSection:Paragraph({
    Name = "FPS",
    Description = "0"
})

local PingParagraph = InfoSection:Paragraph({
    Name = "Ping",
    Description = "0 ms"
})

-- Update stats
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local GameTime = math.floor(Workspace.DistributedGameTime + 0.5)
            local Hour = math.floor(GameTime / 3600) % 24
            local Minute = math.floor(GameTime / 60) % 60
            local Second = math.floor(GameTime) % 60
            
            GameTimeParagraph:SetDescription(string.format("%02d:%02d:%02d", Hour, Minute, Second))
            FpsParagraph:SetDescription(tostring(math.floor(Workspace:GetRealPhysicsFPS())))
            
            local success, ping = pcall(function()
                return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            end)
            if success and ping then
                PingParagraph:SetDescription(ping)
            end
        end)
    end
end)

-- ============================================
-- FISHING TAB
-- ============================================
local FishingTab = Window:Tab({
    Name = "Fishing",
    Icon = "fish",
    Color = Color3.fromRGB(0, 170, 255)
})

local AutoFishingSection = FishingTab:Section({
    Name = "Auto Fishing",
    Side = "Left"
})

AutoFishingSection:Dropdown({
    Name = "Fishing Method",
    Description = "Choose fishing method",
    Options = {"Instant"},
    Default = "Instant",
    Callback = function(value)
        _G.FishingMethod = value
    end
})

AutoFishingSection:Slider({
    Name = "Instant Delay",
    Description = "Delay between reels (seconds)",
    Min = 0,
    Max = 5,
    Default = 0.1,
    Decimals = 1,
    Callback = function(value)
        _G.InstantDelay = value
    end
})

AutoFishingSection:Toggle({
    Name = "Auto Fish",
    Description = "Automatically catch fish",
    Default = false,
    Callback = function(state)
        _G.AutoFish = state
        if not state then
            StopFish()
        end
        
        Window:Notification({
            Title = state and "Enabled" or "Disabled",
            Description = "Auto Fishing " .. (state and "activated" or "stopped"),
            Duration = 3
        })
    end
})

-- ============================================
-- AUTO SELL SECTION
-- ============================================
local AutoSellSection = FishingTab:Section({
    Name = "Auto Sell",
    Side = "Right"
})

AutoSellSection:Slider({
    Name = "Sell Delay",
    Description = "Delay between sells (seconds)",
    Min = 1,
    Max = 60,
    Default = 20,
    Decimals = 0,
    Callback = function(value)
        _G.SellDelay = value
    end
})

AutoSellSection:Toggle({
    Name = "Auto Sell",
    Description = "Automatically sell all fish",
    Default = false,
    Callback = function(state)
        _G.AutoSell = state
        
        Window:Notification({
            Title = state and "Enabled" or "Disabled",
            Description = "Auto Sell " .. (state and "activated" or "stopped"),
            Duration = 3
        })
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
    Name = "Location Teleport",
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
    Description = "Choose teleport destination",
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
            MoveTo(TeleportLocations[selectedLocation])
            Window:Notification({
                Title = "Teleported",
                Description = "Moved to " .. selectedLocation,
                Duration = 3
            })
        end
    end
})

-- ============================================
-- PLAYER TELEPORT
-- ============================================
local PlayerSection = TeleportTab:Section({
    Name = "Player Teleport",
    Side = "Right"
})

local function GetPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

local playerList = GetPlayerList()
local selectedPlayer = playerList[1]

PlayerSection:Dropdown({
    Name = "Select Player",
    Options = playerList,
    Default = playerList[1] or "No Players",
    Callback = function(value)
        selectedPlayer = value
    end
})

PlayerSection:Button({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    MoveTo(targetHRP.CFrame + Vector3.new(0, 3, 0))
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
-- MISC TAB
-- ============================================
local MiscTab = Window:Tab({
    Name = "Misc",
    Icon = "settings",
    Color = Color3.fromRGB(200, 200, 200)
})

local OxygenSection = MiscTab:Section({
    Name = "Oxygen",
    Side = "Left"
})

OxygenSection:Button({
    Name = "Bypass Oxygen",
    Description = "Remove oxygen limit",
    Callback = function()
        pcall(function()
            -- we wrap in pcall and check existence to avoid runtime errors
            if net:FindFirstChild("URE/UpdateOxygen") then
                net["URE/UpdateOxygen"]:Destroy()
            end
        end)
        Window:Notification({
            Title = "Success",
            Description = "Oxygen bypass activated!",
            Duration = 3
        })
    end
})

-- ============================================
-- SERVER TAB
-- ============================================
local ServerTab = Window:Tab({
    Name = "Server",
    Icon = "server",
    Color = Color3.fromRGB(100, 100, 255)
})

local ServerSection = ServerTab:Section({
    Name = "Server Controls",
    Side = "Left"
})

ServerSection:Button({
    Name = "Rejoin Server",
    Description = "Rejoin current server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

ServerSection:Button({
    Name = "Server Hop",
    Description = "Join different server",
    Callback = function()
        local success = pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/raw-scriptpastebin/FE/main/Server_Hop_Settings"))()
            module:Teleport(game.PlaceId)
        end)
        
        if not success then
            Window:Notification({
                Title = "Error",
                Description = "Server hop failed",
                Duration = 3
            })
        end
    end
})

local JobIdSection = ServerTab:Section({
    Name = "Job ID",
    Side = "Right"
})

JobIdSection:Paragraph({
    Name = "Current Job ID",
    Description = game.JobId
})

JobIdSection:Button({
    Name = "Copy Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Window:Notification({
                Title = "Copied",
                Description = "Job ID copied to clipboard",
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
-- SUCCESS
-- ============================================
Window:Notification({
    Title = "Reya Hub",
    Description = "Hub loaded successfully!\nEnjoy fishing! 🎣",
    Duration = 5
})

print("════════════════════════════════════════")
print("✅ REYA HUB LOADED! (NO KEY VERSION)")
print("════════════════════════════════════════")
print("PlaceID:", game.PlaceId)
print("Player:", LocalPlayer.Name)
print("Features:")
print("  • Instant Fishing")
print("  • Auto Sell")
print("  • Location Teleport (12+ spots)")
print("  • Player Teleport")
print("  • Oxygen Bypass")
print("  • Server Controls")
print("════════════════════════════════════════")
