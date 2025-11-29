-- ============================================
-- REYA HUB - NO KEY SYSTEM (FIXED)
-- Completely bypass key system
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ============================================
-- LOAD WINDUI
-- ============================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ============================================
-- SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

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

-- Auto reel
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
-- AUTO SELL
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
-- CREATE WINDOW - TRY MULTIPLE METHODS
-- ============================================
local Window

-- Method 1: No KeySystem at all
local success1 = pcall(function()
    Window = WindUI:CreateWindow({
        Title = "Reya Hub",
        Icon = "fish",
        Author = "Reya",
        Folder = "ReyaHub",
        Size = UDim2.fromOffset(550, 650),
        SideBarWidth = 170,
        HasOutline = true,
        Transparent = false,
        Theme = "Dark",
        ShowUserInfo = true
    })
end)

-- Method 2: KeySystem = false
if not success1 or not Window then
    local success2 = pcall(function()
        Window = WindUI:CreateWindow({
            Title = "Reya Hub",
            Icon = "fish",
            Author = "Reya",
            Folder = "ReyaHub",
            Size = UDim2.fromOffset(550, 650),
            KeySystem = false,
            SideBarWidth = 170,
            HasOutline = true,
            Transparent = false,
            Theme = "Dark",
            ShowUserInfo = true
        })
    end)
end

-- Method 3: KeySystem with Enabled = false
if not Window then
    local success3 = pcall(function()
        Window = WindUI:CreateWindow({
            Title = "Reya Hub",
            Icon = "fish",
            Author = "Reya",
            Folder = "ReyaHub",
            Size = UDim2.fromOffset(550, 650),
            KeySystem = {
                Enabled = false
            },
            SideBarWidth = 170,
            HasOutline = true,
            Transparent = false,
            Theme = "Dark",
            ShowUserInfo = true
        })
    end)
end

-- Method 4: KeySystem with blank key (auto-accept)
if not Window then
    Window = WindUI:CreateWindow({
        Title = "Reya Hub",
        Icon = "fish",
        Author = "Reya",
        Folder = "ReyaHub",
        Size = UDim2.fromOffset(550, 650),
        KeySystem = {
            Key = "nokey",
            Note = "No key needed - Type anything",
            SaveKey = true,
            Keys = {"", "nokey", "free"},
            GrabKeyFromSite = false
        },
        SideBarWidth = 170,
        HasOutline = true,
        Transparent = false,
        Theme = "Dark",
        ShowUserInfo = true
    })
    
    -- Auto submit if key window appears
    task.spawn(function()
        task.wait(0.5)
        -- Try to find and click submit button
        for _, gui in pairs(game:GetService("CoreGui"):GetDescendants()) do
            if gui:IsA("TextButton") and (gui.Text:lower():find("submit") or gui.Text:lower():find("enter")) then
                for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                    connection:Fire()
                end
            end
        end
    end)
end

if not Window then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Failed to create window",
        Duration = 10
    })
    return
end

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

AutoFishingSection:Slider({
    Name = "Instant Delay",
    Description = "Delay between reels",
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

local AutoSellSection = FishingTab:Section({
    Name = "Auto Sell",
    Side = "Right"
})

AutoSellSection:Slider({
    Name = "Sell Delay",
    Description = "Delay between sells",
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
    Description = "Choose destination",
    Options = locationNames,
    Default = locationNames[1],
    Callback = function(value)
        selectedLocation = value
    end
})

LocationSection:Button({
    Name = "Teleport",
    Description = "Go to location",
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
            net["URE/UpdateOxygen"]:Destroy()
        end)
        Window:Notification({
            Title = "Success",
            Description = "Oxygen bypass activated!",
            Duration = 3
        })
    end
})

-- ============================================
-- SUCCESS
-- ============================================
Window:Notification({
    Title = "Reya Hub",
    Description = "Hub loaded successfully! 🎣",
    Duration = 5
})

print("════════════════════════════════════════")
print("✅ REYA HUB LOADED!")
print("════════════════════════════════════════")
print("PlaceID:", game.PlaceId)
print("Player:", LocalPlayer.Name)
print("════════════════════════════════════════")
