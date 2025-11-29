-- ============================================
-- REYA HUB - FIXED BLATANT FISHING
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(1)

print("🔄 Loading Reya Hub...")

-- ============================================
-- LOAD UI LIBRARY (SAME AS CHLOE)
-- ============================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))():Window({
    Title = "Reya Hub |",
    Footer = "Fish It",
    Image = "132435516080103",
    Color = Color3.fromRGB(0, 208, 255),
    Theme = 9542022979,
    Version = 1
})

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
-- FISHING VARIABLES
-- ============================================
_G.AutoFish = false
_G.Instant = false
_G.InstantDelay = 0.1
_G.CancelWaitTime = 3
_G.ResetTimer = 0.5

local ActiveFishing = false
local lastFishTime = 0
local hasFishingEffect = false
local lastCancelTime = 0

-- ============================================
-- INSTANT FISHING
-- ============================================
local function InstantReel()
    pcall(function()
        net:WaitForChild("RE/FishingCompleted"):FireServer()
    end)
end

local function StopFish()
    ActiveFishing = false
    pcall(function()
        net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
    end)
end

-- Instant Fishing Loop
task.spawn(function()
    while task.wait() do
        if _G.AutoFish then
            pcall(function()
                ActiveFishing = true
                local timestamp = Workspace:GetServerTimeNow()
                
                equipRod()
                task.wait(0.1)
                
                net:WaitForChild("RF/ChargeFishingRod"):InvokeServer(timestamp)
                
                local x = -0.7499996423721313 + (math.random(-500, 500) / 10000000)
                local y = 1 + (math.random(-500, 500) / 10000000)
                
                net:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(x, y)
                
                task.wait(0.1)
                ActiveFishing = false
            end)
        end
    end
end)

-- Auto reel when fish caught
net["RE/ReplicateTextEffect"].OnClientEvent:Connect(function(data)
    if _G.AutoFish and ActiveFishing and data then
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
-- BLATANT FISHING (EXACT SAME AS CHLOE)
-- ============================================

-- Monitor fishing effect
local playEffectEvent = net:FindFirstChild("RE/PlayFishingEffect")
if playEffectEvent then
    playEffectEvent.OnClientEvent:Connect(function(player, _, effectType)
        if player == LocalPlayer and effectType == 2 then
            hasFishingEffect = true
        end
    end)
end

-- Monitor fish caught
net["RE/ReplicateTextEffect"].OnClientEvent:Connect(function(data)
    if _G.Instant and data then
        local myHead = Character and Character:FindFirstChild("Head")
        if myHead and data.Container == myHead then
            lastFishTime = tick()
        end
    end
end)

-- Blatant auto complete loop
task.spawn(function()
    while task.wait(0.2) do
        if _G.Instant then
            pcall(function()
                net:WaitForChild("RE/FishingCompleted"):FireServer()
            end)
        end
    end
end)

-- Blatant auto cancel when stuck (EXACT SAME AS CHLOE)
task.spawn(function()
    while true do
        repeat
            task.wait(_G.CancelWaitTime)
        until _G.Instant
        
        local currentTime = tick()
        if not hasFishingEffect and currentTime - lastFishTime > _G.CancelWaitTime - _G.ResetTimer then
            pcall(function()
                net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
            end)
            lastCancelTime = currentTime
        end
        hasFishingEffect = false
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
-- CREATE TABS
-- ============================================
local Tabs = {
    Info = Library:AddTab({ Name = "Info", Icon = "player" }),
    Fishing = Library:AddTab({ Name = "Fishing", Icon = "rbxassetid://97167558235554" }),
    Teleport = Library:AddTab({ Name = "Teleport", Icon = "rbxassetid://18648122722" }),
    Misc = Library:AddTab({ Name = "Misc", Icon = "rbxassetid://6034509993" }),
    Server = Library:AddTab({ Name = "Server", Icon = "server" })
}

-- ============================================
-- INFO TAB
-- ============================================
local InfoSection = Tabs.Info:AddSection("Welcome")

Tabs.Info:AddParagraph({
    Title = "Reya Hub v1.0",
    Content = "Fish It Automation Hub\n\nPress K to toggle UI\n\nMade by Reya"
})

local StatsSection = Tabs.Info:AddSection("Statistics")

local FPSLabel = Tabs.Info:AddLabel("FPS: 0")
local PingLabel = Tabs.Info:AddLabel("Ping: 0 ms")

-- Update stats
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local fps = math.floor(Workspace:GetRealPhysicsFPS())
            FPSLabel:Set("FPS: " .. tostring(fps))
            
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            PingLabel:Set("Ping: " .. ping)
        end)
    end
end)

-- ============================================
-- FISHING TAB
-- ============================================
local FishingSection = Tabs.Fishing:AddSection("Fishing Features")

Tabs.Fishing:AddToggle({
    Title = "Auto Fish (Instant)",
    Content = "Fastest fishing method",
    Default = false,
    Callback = function(state)
        _G.AutoFish = state
        if not state then
            StopFish()
        end
        Library:Notify({
            Title = "Auto Fish",
            Content = state and "Enabled" or "Disabled",
            Duration = 3
        })
    end
})

Tabs.Fishing:AddSlider({
    Title = "Instant Delay",
    Default = 0.1,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(value)
        _G.InstantDelay = value
    end
})

Tabs.Fishing:AddButton({
    Title = "Equip Rod",
    Callback = function()
        equipRod()
        Library:Notify({
            Title = "Success",
            Content = "Rod equipped",
            Duration = 2
        })
    end
})

-- BLATANT SECTION
local BlatantSection = Tabs.Fishing:AddSection("Blatant Fishing")

Tabs.Fishing:AddParagraph({
    Title = "How to use Blatant?",
    Content = "\r\n<font color=\"rgb(0,170,255)\"><b>ONLY WORKS ON HIGH SPEED RODS!</b></font>\r\n- [ Settings ] -\r\n<font color=\"rgb(0,170,255)\"><b>1. Ghostfin Rod</b></font>\r\nUse Delay 2.2 - 3.0\r\n<font color=\"rgb(0,170,255)\"><b>2. Element Rod</b></font>\r\nUse Delay 1.8 - 2.2\r\n"
})

Tabs.Fishing:AddInput({
    Title = "Blatant Delay",
    Value = tostring(_G.CancelWaitTime),
    Placeholder = "Enter delay time...",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            _G.CancelWaitTime = num
        end
    end
})

Tabs.Fishing:AddToggle({
    Title = "Blatant Fishing",
    Content = "Advanced fishing with auto-cancel",
    Default = false,
    Callback = function(state)
        _G.Instant = state
        if not state then
            pcall(function()
                net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
            end)
        end
        Library:Notify({
            Title = "Blatant Fishing",
            Content = state and "Enabled!" or "Disabled",
            Duration = 3
        })
    end
})

-- AUTO SELL
local SellSection = Tabs.Fishing:AddSection("Auto Sell")

Tabs.Fishing:AddSlider({
    Title = "Sell Delay (seconds)",
    Default = 20,
    Min = 1,
    Max = 60,
    Rounding = 0,
    Callback = function(value)
        _G.SellDelay = value
    end
})

Tabs.Fishing:AddToggle({
    Title = "Auto Sell",
    Content = "Automatically sell all fish",
    Default = false,
    Callback = function(state)
        _G.AutoSell = state
        Library:Notify({
            Title = "Auto Sell",
            Content = state and "Enabled" or "Disabled",
            Duration = 3
        })
    end
})

Tabs.Fishing:AddButton({
    Title = "Sell All Now",
    Callback = function()
        SellAll()
        Library:Notify({
            Title = "Success",
            Content = "All fish sold",
            Duration = 2
        })
    end
})

-- ============================================
-- TELEPORT TAB
-- ============================================
local TeleportSection = Tabs.Teleport:AddSection("Location Teleport")

local locationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = locationNames[1]

Tabs.Teleport:AddDropdown({
    Title = "Select Location",
    Options = locationNames,
    Default = locationNames[1],
    Callback = function(value)
        selectedLocation = value
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport",
    Callback = function()
        if selectedLocation and TeleportLocations[selectedLocation] then
            MoveTo(TeleportLocations[selectedLocation])
            Library:Notify({
                Title = "Teleported",
                Content = "Moved to " .. selectedLocation,
                Duration = 3
            })
        end
    end
})

-- PLAYER TELEPORT
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

Tabs.Teleport:AddDropdown({
    Title = "Select Player",
    Options = playerList,
    Default = playerList[1],
    Callback = function(value)
        selectedPlayer = value
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Player",
    Callback = function()
        if selectedPlayer and selectedPlayer ~= "No Players" then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    MoveTo(targetHRP.CFrame + Vector3.new(0, 3, 0))
                    Library:Notify({
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
    Callback = function()
        playerList = GetPlayerList()
        Library:Notify({
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
    Callback = function()
        pcall(function()
            net["URE/UpdateOxygen"]:Destroy()
        end)
        Library:Notify({
            Title = "Success",
            Content = "Oxygen bypass activated!",
            Duration = 3
        })
    end
})

Tabs.Misc:AddToggle({
    Title = "Infinite Oxygen",
    Default = false,
    Callback = function(state)
        _G.InfOxygen = state
        if state then
            task.spawn(function()
                while _G.InfOxygen do
                    pcall(function()
                        net:WaitForChild("URE/UpdateOxygen"):FireServer(-999999)
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- UTILITIES
local UtilitySection = Tabs.Misc:AddSection("Utilities")

Tabs.Misc:AddToggle({
    Title = "Bypass Radar",
    Default = false,
    Callback = function(state)
        pcall(function()
            net:WaitForChild("RF/UpdateFishingRadar"):InvokeServer(state)
        end)
    end
})

-- Cutscene Controller
local CutsceneController
local oldPlay, oldStop

pcall(function()
    CutsceneController = require(ReplicatedStorage.Controllers.CutsceneController)
    oldPlay = CutsceneController.Play
    oldStop = CutsceneController.Stop
end)

local function DisableCutscenes()
    if net:FindFirstChild("RE/ReplicateCutscene") then
        net["RE/ReplicateCutscene"].OnClientEvent:Connect(function() end)
    end
    if net:FindFirstChild("RE/StopCutscene") then
        net["RE/StopCutscene"].OnClientEvent:Connect(function() end)
    end
    if CutsceneController then
        CutsceneController.Play = function() end
        CutsceneController.Stop = function() end
    end
end

local function EnableCutscenes()
    if CutsceneController and oldPlay and oldStop then
        CutsceneController.Play = oldPlay
        CutsceneController.Stop = oldStop
    end
end

Tabs.Misc:AddToggle({
    Title = "Auto Skip Cutscene",
    Default = true,
    Callback = function(state)
        if state then
            DisableCutscenes()
        else
            EnableCutscenes()
        end
    end
})

DisableCutscenes()

-- BOOST PLAYER
local BoostSection = Tabs.Misc:AddSection("Boost Player")

Tabs.Misc:AddToggle({
    Title = "Disable Notifications",
    Default = true,
    Callback = function(state)
        _G.DisableNotifs = state
        if state then
            pcall(function()
                for _, event in ipairs({
                    net["RE/ObtainedNewFishNotification"],
                    net["RE/TextNotification"],
                    net["RE/ClaimNotification"]
                }) do
                    for _, connection in ipairs(getconnections(event.OnClientEvent)) do
                        connection:Disconnect()
                    end
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle({
    Title = "Disable Char Effects",
    Default = false,
    Callback = function(state)
        _G.DisableCharEffect = state
        if state then
            pcall(function()
                for _, event in ipairs({
                    net["RE/PlayFishingEffect"],
                    net["RE/ReplicateTextEffect"]
                }) do
                    for _, connection in ipairs(getconnections(event.OnClientEvent)) do
                        connection:Disconnect()
                    end
                    event.OnClientEvent:Connect(function() end)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle({
    Title = "Delete Fishing Effects",
    Default = false,
    Callback = function(state)
        _G.DelEffects = state
        if state then
            task.spawn(function()
                while _G.DelEffects do
                    local cosmeticFolder = Workspace:FindFirstChild("CosmeticFolder")
                    if cosmeticFolder then
                        cosmeticFolder:Destroy()
                    end
                    task.wait(60)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle({
    Title = "Hide Rod On Hand",
    Default = false,
    Callback = function(state)
        _G.IrRod = state
        if state then
            task.spawn(function()
                while _G.IrRod do
                    for _, character in ipairs(Workspace.Characters:GetChildren()) do
                        local equippedTool = character:FindFirstChild("!!!EQUIPPED_TOOL!!!")
                        if equippedTool then
                            equippedTool:Destroy()
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- FREEZE PLAYER
local FreezeSection = Tabs.Misc:AddSection("Freeze Player")

Tabs.Misc:AddToggle({
    Title = "Freeze Player with Rod",
    Content = "Freeze when rod equipped",
    Default = false,
    Callback = function(state)
        _G.FrozenPlayer = state
        
        local function IsRodEquipped()
            local Replion = require(ReplicatedStorage.Packages.Replion)
            local Data = Replion.Client:WaitReplion("Data")
            local equipped = Data:Get("EquippedId")
            if not equipped then return false end
            
            local PlayerStatsUtility = require(ReplicatedStorage.Shared.PlayerStatsUtility)
            local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
            
            local item = PlayerStatsUtility:GetItemFromInventory(Data, function(p)
                return p.UUID == equipped
            end)
            
            if not item then return false end
            local itemData = ItemUtility:GetItemData(item.Id)
            return itemData and itemData.Data.Type == "Fishing Rods"
        end
        
        local function EquipRodIfNeeded()
            if not IsRodEquipped() then
                net:WaitForChild("RE/EquipToolFromHotbar"):FireServer(1)
                task.wait(0.5)
            end
        end
        
        local function AnchorCharacter(char, anchored)
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = anchored
                    end
                end
            end
        end
        
        local function ApplyFreeze(char)
            if _G.FrozenPlayer then
                EquipRodIfNeeded()
                if IsRodEquipped() then
                    AnchorCharacter(char, true)
                end
            else
                AnchorCharacter(char, false)
            end
        end
        
        ApplyFreeze(LocalPlayer.Character)
        
        LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(1)
            ApplyFreeze(char)
        end)
    end
})

-- ============================================
-- SERVER TAB
-- ============================================
local ServerSection = Tabs.Server:AddSection("Server Controls")

Tabs.Server:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

Tabs.Server:AddButton({
    Title = "Server Hop",
    Callback = function()
        local success = pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/raw-scriptpastebin/FE/main/Server_Hop_Settings"))()
            module:Teleport(game.PlaceId)
        end)
        
        if not success then
            Library:Notify({
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
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Library:Notify({
                Title = "Copied",
                Content = "Job ID copied",
                Duration = 3
            })
        end
    end
})

-- ============================================
-- AUTO REJOIN
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
Library:Notify({
    Title = "Reya Hub",
    Content = "Successfully loaded! Press K to toggle\nHappy fishing! 🎣",
    Duration = 5
})

print("╔═══════════════════════════════════════╗")
print("✅ REYA HUB LOADED!")
print("╠═══════════════════════════════════════╣")
print("Player:", LocalPlayer.Name)
print("PlaceID:", game.PlaceId)
print("╠═══════════════════════════════════════╣")
print("Features:")
print("  • Instant Fishing")
print("  • Blatant Fishing (Fixed!)")
print("  • Auto Sell")
print("  • 12+ Teleport Locations")
print("  • Player Teleport")
print("  • All Misc Features")
print("  • Server Controls")
print("╠═══════════════════════════════════════╣")
print("⌨️  Press K to toggle UI")
print("╚═══════════════════════════════════════╝")
