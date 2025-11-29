-- ============================================
-- REYA HUB - FLUENT UI VERSION (FIXED + CHLOE BLATANT)
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(1)

print("🔄 Loading Reya Hub...")

-- ============================================
-- LOAD FLUENT UI LIBRARY
-- ============================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
-- DEFAULT GLOBALS
-- ============================================
_G.AutoFish = false
_G.ActiveFishing = false
_G.FishingMethod = "Instant"
_G.InstantDelay = 0.1

-- Blatant (Chloe-style)
_G.Blatant = false
_G.BlatantDelay = 2.5  -- seconds, editable via UI

_G.BlatantCancelExtra = 0.5 -- small extra before cancel (internal)

_G.AutoSell = false
_G.SellDelay = 20

-- other toggles used in script
_G.InfOxygen = false
_G.DelEffects = false
_G.DisableNotifs = true
_G.DisableCharEffect = false
_G.IrRod = false
_G.FrozenPlayer = false

-- ============================================
-- FISHING FUNCTIONS
-- ============================================
local function InstantReel()
    pcall(function()
        net:WaitForChild("RE/FishingCompleted"):FireServer()
    end)
end

local function CancelFishing()
    pcall(function()
        -- try RF cancel (invoke server) if present
        if net:FindFirstChild("RF/CancelFishingInputs") then
            net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
        elseif net:FindFirstChild("Functions") and net.Functions.Cancel then
            -- compatibility fallback (if structure different)
            pcall(function() net.Functions.Cancel:InvokeServer() end)
        end
    end)
end

local function StopFish()
    _G.ActiveFishing = false
    CancelFishing()
end

-- Instant Fishing Loop (keeps Instant logic - unchanged)
task.spawn(function()
    while task.wait() do
        if _G.AutoFish and _G.FishingMethod == "Instant" then
            pcall(function()
                _G.ActiveFishing = true
                local timestamp = Workspace:GetServerTimeNow()
                
                equipRod()
                task.wait(0.1)
                
                -- Charge
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

-- Auto reel when fish caught (instant delay)
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
-- BLATANT FISHING (CHLOE STYLE) - NEW (CENTRALIZED)
-- ============================================
-- Design:
-- - uses RunService.Stepped + tick() timing like Chloe
-- - listens for ReplicateTextEffect to mark "bite"
-- - auto-complete (FireServer RE/FishingCompleted) after BlatantDelay
-- - auto-cancel (InvokeServer RF/CancelFishingInputs) if stuck long after last action
-- - Toggle + slider in UI control _G.Blatant and _G.BlatantDelay

do
    local lastFishTime = 0      -- last time a fish was detected (tick)
    local hasFishingEffect = false
    local isWaitingForFish = false

    -- When replicate text effect occurs (fish caught text anchored to head)
    local ok, replicator = pcall(function() return net:WaitForChild("RE/ReplicateTextEffect") end)
    if ok and replicator then
        replicator.OnClientEvent:Connect(function(data)
            if not _G.Blatant then return end
            if not data then return end
            local myHead = Character and Character:FindFirstChild("Head")
            if myHead and data.Container == myHead then
                lastFishTime = tick()
                isWaitingForFish = true
            end
        end)
    end

    -- Detect PlayFishingEffect (some scripts use this to signal effect)
    local playEffect = net:FindFirstChild("RE/PlayFishingEffect")
    if playEffect and typeof(playEffect) == "Instance" then
        playEffect.OnClientEvent:Connect(function(player, _, effectType)
            if player == LocalPlayer and effectType == 2 then
                hasFishingEffect = true
                lastFishTime = tick()
                isWaitingForFish = true
            end
        end)
    end

    -- RunService loop (Chloe-like)
    RunService.Stepped:Connect(function()
        if not _G.Blatant then return end

        local now = tick()
        -- If a bite was registered and we've waited >= delay, complete
        if isWaitingForFish and (now - lastFishTime) >= (_G.BlatantDelay or 2.5) then
            -- Complete (reel)
            pcall(function()
                if net:FindFirstChild("RE/FishingCompleted") then
                    net:WaitForChild("RE/FishingCompleted"):FireServer()
                end
            end)
            -- reset waiting state, update lastFishTime to avoid immediate re-trigger
            isWaitingForFish = false
            lastFishTime = now
        end

        -- If no effect and we've passed cancel threshold, cancel fishing (stuck)
        if (now - lastFishTime) >= ((_G.BlatantDelay or 2.5) + (_G.BlatantCancelExtra or 0.5)) then
            -- Cancel
            CancelFishing()
            -- update lastFishTime so we don't spam cancels
            lastFishTime = now
            isWaitingForFish = false
            hasFishingEffect = false
        end
    end)

    -- Provide UI elements (these will be created later when Tabs exist; we wire callbacks where UI already creates them)
end

-- ============================================
-- AUTO SELL FUNCTION
-- ============================================
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
    MinimizeKey = Enum.KeyCode.K
})

print("✅ Press K to show/hide menu!")

-- ============================================
-- TABS
-- ============================================
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
    Content = "Fish It automation script with multiple features.\n\nVersion: 1.0\nAuthor: Reya\n\n⌨️ Press K to toggle UI"
})

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
            -- try to get physics fps; fall back
            local fps = 0
            if Workspace.GetRealPhysicsFPS then
                fps = math.floor(Workspace:GetRealPhysicsFPS())
            else
                fps = math.floor(1 / (task.wait() or 0.016))
            end
            FPSLabel:SetDesc("FPS: " .. tostring(fps))
            
            local ping = "N/A"
            pcall(function()
                ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            end)
            PingLabel:SetDesc("Ping: " .. tostring(ping))
        end)
    end
end)

-- ============================================
-- FISHING TAB
-- ============================================
Tabs.Fishing:AddParagraph({
    Title = "Auto Fishing",
    Content = "Instant fishing - fastest method"
})

local DelaySlider = Tabs.Fishing:AddSlider("InstantDelay", {
    Title = "Reel Delay",
    Description = "Delay between reels (seconds)",
    Default = _G.InstantDelay,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(value)
        _G.InstantDelay = value
    end
})

local AutoFishToggle = Tabs.Fishing:AddToggle("AutoFish", {
    Title = "Auto Fish (Instant)",
    Description = "Automatically catch fish instantly",
    Default = false,
    Callback = function(state)
        _G.AutoFish = state
        if not state then
            StopFish()
        end
        Fluent:Notify({
            Title = "Auto Fish",
            Content = state and "Enabled" or "Disabled",
            Duration = 3
        })
    end
})

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

-- BLATANT SECTION (UI elements integrate with new centralized system)
Tabs.Fishing:AddParagraph({
    Title = "Blatant Fishing",
    Content = "⚠️ Chloe-style blatant: uses RunService + tick() timing.\nAuto-complete & auto-cancel when stuck."
})

local BlatantDelaySlider = Tabs.Fishing:AddSlider("BlatantDelay", {
    Title = "Blatant Delay",
    Description = "Cancel / complete delay when waiting for fish (seconds)",
    Default = _G.BlatantDelay,
    Min = 1,
    Max = 6,
    Rounding = 1,
    Callback = function(value)
        _G.BlatantDelay = value
    end
})

local BlatantToggle = Tabs.Fishing:AddToggle("Blatant", {
    Title = "Enable Blatant Fishing",
    Description = "Advanced fishing with auto-complete & auto-cancel (Chloe Style)",
    Default = false,
    Callback = function(state)
        _G.Blatant = state
        if not state then
            -- ensure cancel called once when disabling
            CancelFishing()
        end
        Fluent:Notify({
            Title = "Blatant Fishing",
            Content = state and "Enabled (Chloe Style)" or "Disabled",
            Duration = 3
        })
    end
})

-- AUTO SELL SECTION
Tabs.Fishing:AddParagraph({
    Title = "Auto Sell",
    Content = "Automatically sell all fish"
})

local SellDelaySlider = Tabs.Fishing:AddSlider("SellDelay", {
    Title = "Sell Delay",
    Description = "Delay between sells (seconds)",
    Default = _G.SellDelay,
    Min = 1,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        _G.SellDelay = value
    end
})

local AutoSellToggle = Tabs.Fishing:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Description = "Automatically sell all fish",
    Default = false,
    Callback = function(state)
        _G.AutoSell = state
        Fluent:Notify({
            Title = "Auto Sell",
            Content = state and "Enabled" or "Disabled",
            Duration = 3
        })
    end
})

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
    Multi = false,
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

-- PLAYER TELEPORT
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
    Multi = false,
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
Tabs.Misc:AddParagraph({
    Title = "Oxygen Features",
    Content = "Control oxygen underwater"
})

Tabs.Misc:AddButton({
    Title = "Bypass Oxygen",
    Description = "Remove oxygen limit",
    Callback = function()
        pcall(function()
            local upd = net:FindFirstChild("URE/UpdateOxygen")
            if upd then upd:Destroy() end
        end)
        Fluent:Notify({
            Title = "Success",
            Content = "Oxygen bypass activated!",
            Duration = 3
        })
    end
})

Tabs.Misc:AddToggle("InfOxygen", {
    Title = "Infinite Oxygen",
    Description = "Never run out of oxygen",
    Default = false,
    Callback = function(state)
        _G.InfOxygen = state
        if state then
            task.spawn(function()
                while _G.InfOxygen do
                    pcall(function()
                        if net:FindFirstChild("URE/UpdateOxygen") then
                            net:WaitForChild("URE/UpdateOxygen"):FireServer(-999999)
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- UTILITIES
Tabs.Misc:AddParagraph({
    Title = "Utilities",
    Content = "General utility features"
})

Tabs.Misc:AddToggle("BypassRadar", {
    Title = "Bypass Radar",
    Description = "Bypass fishing radar detection",
    Default = false,
    Callback = function(state)
        pcall(function()
            if net:FindFirstChild("RF/UpdateFishingRadar") then
                net:WaitForChild("RF/UpdateFishingRadar"):InvokeServer(state)
            end
        end)
    end
})

-- Cutscene Controller
local CutsceneController
local oldPlay, oldStop

pcall(function()
    if ReplicatedStorage:FindFirstChild("Controllers") and ReplicatedStorage.Controllers:FindFirstChild("CutsceneController") then
        CutsceneController = require(ReplicatedStorage.Controllers.CutsceneController)
        oldPlay = CutsceneController.Play
        oldStop = CutsceneController.Stop
    end
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

Tabs.Misc:AddToggle("SkipCutscene", {
    Title = "Auto Skip Cutscene",
    Description = "Automatically skip all cutscenes",
    Default = true,
    Callback = function(state)
        if state then
            DisableCutscenes()
        else
            EnableCutscenes()
        end
    end
})

-- Initialize cutscene skip
DisableCutscenes()

-- BOOST PLAYER
Tabs.Misc:AddParagraph({
    Title = "Boost Player",
    Content = "Performance and visual enhancements"
})

Tabs.Misc:AddToggle("DisableNotifs", {
    Title = "Disable Notifications",
    Description = "Block fish/event notifications",
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
                    if event and event.OnClientEvent then
                        for _, connection in ipairs(getconnections(event.OnClientEvent)) do
                            connection:Disconnect()
                        end
                    end
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("DisableCharEffect", {
    Title = "Disable Character Effects",
    Description = "Remove fishing effects on character",
    Default = false,
    Callback = function(state)
        _G.DisableCharEffect = state
        if state then
            pcall(function()
                for _, event in ipairs({
                    net["RE/PlayFishingEffect"],
                    net["RE/ReplicateTextEffect"]
                }) do
                    if event and event.OnClientEvent then
                        for _, connection in ipairs(getconnections(event.OnClientEvent)) do
                            connection:Disconnect()
                        end
                        event.OnClientEvent:Connect(function() end)
                    end
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("DeleteFishingEffects", {
    Title = "Delete Fishing Effects",
    Description = "Remove fishing effect particles",
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

Tabs.Misc:AddToggle("HideRodOnHand", {
    Title = "Hide Rod On Hand",
    Description = "Make rods invisible (you + others)",
    Default = false,
    Callback = function(state)
        _G.IrRod = state
        if state then
            task.spawn(function()
                while _G.IrRod do
                    local charactersFolder = Workspace:FindFirstChild("Characters")
                    if charactersFolder then
                        for _, character in ipairs(charactersFolder:GetChildren()) do
                            local equippedTool = character:FindFirstChild("!!!EQUIPPED_TOOL!!!")
                            if equippedTool then
                                equippedTool:Destroy()
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- FREEZE PLAYER
Tabs.Misc:AddParagraph({
    Title = "Freeze Player",
    Content = "Freeze character when fishing"
})

Tabs.Misc:AddToggle("FreezePlayer", {
    Title = "Freeze Player",
    Description = "Freeze when rod is equipped (no animation)",
    Default = false,
    Callback = function(state)
        _G.FrozenPlayer = state
        
        local function IsRodEquipped()
            local success, Replion = pcall(function() return require(ReplicatedStorage.Packages.Replion) end)
            if not success or not Replion then return false end
            local Data = Replion.Client:WaitReplion("Data")
            local equipped = Data and Data:Get("EquippedId")
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
        
        local function EquipRod()
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
                EquipRod()
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
    Content = "Successfully loaded! Press K to toggle UI\nHappy fishing! 🎣",
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
print("  • Blatant Fishing (Chloe Style)")
print("  • Auto Sell")
print("  • 12+ Teleport Locations")
print("  • Player Teleport")
print("  • Oxygen Bypass + Infinite")
print("  • Skip Cutscenes")
print("  • Disable Notifications")
print("  • Freeze Player")
print("  • Hide Effects & Rods")
print("  • Server Hop & Rejoin")
print("╠═══════════════════════════════════════╣")
print("⌨️  Press K to toggle UI")
print("╚═══════════════════════════════════════╝")
