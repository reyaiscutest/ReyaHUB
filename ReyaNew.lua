-- Reya Hub using WindUI (Work in progress)
-- Placeholder: full WindUI conversion will be added here.

-- ============================================
-- REYA HUB - WINDUI (CHLOE-STYLE FEATURES, NO KEY)
-- Converted to WindUI, tabs: Dashboard / Automation / Travel / Systems / Utility / Server
-- Author: Reya (ported by assistant)
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(1)

-- Libraries
local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not ok or not WindUI then
    error("Failed to load WindUI")
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Net module (sleitnick_net)
local net
pcall(function()
    net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
end)

-- Utility functions
local function safeInvoke(remote, ...)
    if not remote then return false end
    local ok, res = pcall(function() return remote:InvokeServer(...) end)
    return ok, res
end
local function safeFire(remote, ...)
    if not remote then return false end
    local ok = pcall(function() remote:FireServer(...) end)
    return ok
end
local function setClipboardIfAvailable(text)
    if setclipboard then pcall(setclipboard, text) end
end

-- Default globals / settings
_G.AutoFish = false
_G.ActiveFishing = false
_G.InstantDelay = 0.1
_G.FishingMethod = "Instant"

-- Chloe-style variables
_G.Instant = false            -- Chloe-style toggle name (kept for compatibility)
_G.CancelWaitTime = 2.5
_G.AutoFishingV2 = false
_G.V2_ClickCount = 75
_G.V2_ClickDelay = 0.01
_G.V2_WaitForFish = 4
_G.V2_NextCastDelay = 2

-- Other toggles
_G.AutoSell = false
_G.SellDelay = 20
_G.InfOxygen = false
_G.DelEffects = false
_G.DisableNotifs = true
_G.DisableCharEffect = false
_G.HideRodOnHand = false
_G.FrozenPlayer = false

-- Teleport positions (same as Reya list)
local TeleportLocations = {
    ["Ancient Jungle"] = CFrame.new(1221.084228515625, 6.624999523162842, -544.1521606445312),
    ["Coral Reefs"] = CFrame.new(-3262.536376953125, 2.499969244003296, 2216.586181640625),
    ["Crater Island"] = CFrame.new(986.1575317382812, 3.1964468955993652, 5146.69970703125),
    ["Kohana"] = CFrame.new(-656.1355590820312, 17.250059127807617, 448.951171875),
    ["Kohana Volcano"] = CFrame.new(-554.2496948242188, 18.236753463745117, 117.22779846191406),
    ["Sisyphus Statue"] = CFrame.new(-3731.935546875, -135.0744171142578, -1014.7938232421875),
    ["Treasure Room"] = CFrame.new(-3560.293212890625, -279.07421875, -1605.2633056640625),
    ["Mount Hallow"] = CFrame.new(2144.46728515625, 80.88066864013672, 3269.4921875),
    ["Tropical Grove"] = CFrame.new(-2091.44580078125, 6.268016815185547, 3699.8486328125),
    ["Crystal Cavern"] = CFrame.new(-1723.7686767578125, -450.00048828125, 7205.43701171875),
    ["Crystal Falls"] = CFrame.new(-1955.166748046875, -447.50048828125, 7419.4140625),
}

-- Basic helpers
local function MoveTo(cframe)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = cframe end
    end)
end
local function equipRod()
    pcall(function()
        if net and net:FindFirstChild("RE/EquipToolFromHotbar") then
            net:WaitForChild("RE/EquipToolFromHotbar"):FireServer(1)
        end
    end)
end
local function SellAll()
    pcall(function()
        if net and net:FindFirstChild("RF/SellAllItems") then
            net:WaitForChild("RF/SellAllItems"):InvokeServer()
        end
    end)
end

-- Instant reel
local function InstantReel()
    pcall(function()
        if net and net:FindFirstChild("RE/FishingCompleted") then
            net:WaitForChild("RE/FishingCompleted"):FireServer()
        end
    end)
end

local function CancelFishing()
    pcall(function()
        if net and net:FindFirstChild("RF/CancelFishingInputs") then
            net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
        elseif net and net.Functions and net.Functions.Cancel then
            pcall(function() net.Functions.Cancel:InvokeServer() end)
        end
    end)
end

-- ============================================
-- INSTANT FISH (Reya-style)
-- ============================================
task.spawn(function()
    while task.wait() do
        if _G.AutoFish and _G.FishingMethod == "Instant" then
            pcall(function()
                _G.ActiveFishing = true
                local timestamp = Workspace:GetServerTimeNow()
                equipRod()
                task.wait(0.1)
                if net and net:FindFirstChild("RF/ChargeFishingRod") then
                    net:WaitForChild("RF/ChargeFishingRod"):InvokeServer(timestamp)
                end
                local x = -0.7499996423721313 + (math.random(-500, 500) / 10000000)
                local y = 1 + (math.random(-500, 500) / 10000000)
                if net and net:FindFirstChild("RF/RequestFishingMinigameStarted") then
                    net:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(x, y)
                end
                task.wait(0.1)
                _G.ActiveFishing = false
            end)
        end
    end
end)

-- Auto reel when fish caught (instant)
pcall(function()
    if net and net:FindFirstChild("RE/ReplicateTextEffect") then
        net["RE/ReplicateTextEffect"].OnClientEvent:Connect(function(data)
            if _G.AutoFish and _G.ActiveFishing and data then
                local myHead = Character and Character:FindFirstChild("Head")
                if myHead and data.Container == myHead then
                    task.spawn(function()
                        for i=1,3 do
                            task.wait(_G.InstantDelay)
                            InstantReel()
                        end
                    end)
                end
            end
        end)
    end
end)

-- ============================================
-- CHLOE-STYLE BLATANT / AUTO-CANCEL (RunService + tick)
-- ============================================
local lastFishTime = 0
local hasFishingEffect = false
local waitingForFish = false

-- replicate text effect -> mark fish
pcall(function()
    if net and net:FindFirstChild("RE/ReplicateTextEffect") then
        net["RE/ReplicateTextEffect"].OnClientEvent:Connect(function(data)
            if not _G.Instant then return end
            if data then
                local head = Character and Character:FindFirstChild("Head")
                if head and data.Container == head then
                    lastFishTime = tick()
                    waitingForFish = true
                end
            end
        end)
    end
end)

-- play effect detection
pcall(function()
    if net and net:FindFirstChild("RE/PlayFishingEffect") then
        net["RE/PlayFishingEffect"].OnClientEvent:Connect(function(player, _, effectType)
            if player == LocalPlayer and effectType == 2 then
                hasFishingEffect = true
                lastFishTime = tick()
                waitingForFish = true
            end
        end)
    end
end)

-- RunService loop
RunService.Stepped:Connect(function()
    if not _G.Instant then return end
    local now = tick()
    -- complete after delay
    if waitingForFish and (now - lastFishTime) >= (_G.CancelWaitTime or 2.5) then
        pcall(function()
            if net and net:FindFirstChild("RE/FishingCompleted") then
                net:WaitForChild("RE/FishingCompleted"):FireServer()
            end
        end)
        waitingForFish = false
        lastFishTime = now
    end
    -- cancel if stuck
    if (now - lastFishTime) >= ((_G.CancelWaitTime or 2.5) + 0.5) then
        if not hasFishingEffect then
            CancelFishing()
        end
        waitingForFish = false
        hasFishingEffect = false
        lastFishTime = now
    end
end)

-- ============================================
-- AUTO SELL
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
-- AUTO FISH V2 (Chloe-style spam loop)
-- ============================================
local function StartAutoV2()
    if _G.AutoFishingV2 then return end
    _G.AutoFishingV2 = true
    task.spawn(function()
        while _G.AutoFishingV2 do
            pcall(function()
                -- cast
                if net and net:FindFirstChild("RF/ChargeFishingRod") then
                    net:WaitForChild("RF/ChargeFishingRod"):InvokeServer()
                end
                task.wait(1)
                -- start mini
                if net and net:FindFirstChild("RF/RequestFishingMinigameStarted") then
                    local x = -1.233184814453125 + math.random(-500,500)/10000000
                    local y = math.random(10,99)/100
                    net:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(x, y, Workspace:GetServerTimeNow())
                end
                task.wait( (_G.V2_WaitForFish or 4) )
                -- spam complete
                local tstart = tick()
                for i=1,(_G.V2_ClickCount or 75) do
                    if not _G.AutoFishingV2 then break end
                    if net and net:FindFirstChild("RE/FishingCompleted") then
                        net:WaitForChild("RE/FishingCompleted"):FireServer()
                    end
                    task.wait(_G.V2_ClickDelay or 0.01)
                    if tick() - tstart > 5 then break end
                end
                task.wait(_G.V2_NextCastDelay or 2)
            end)
            task.wait(0.1)
        end
    end)
end
local function StopAutoV2()
    _G.AutoFishingV2 = false
end

-- ============================================
-- Detector (stuck detection & reset)
-- ============================================
local Detector = {
    enabled = false,
    stuckThreshold = 15,
    lastBag = 0,
    fishingTimer = 0,
    savedCFrame = nil
}

local function getFishCountFallback()
    -- best-effort fallback; game-specific logic needed for accurate count
    return 0
end

task.spawn(function()
    while task.wait(0.1) do
        if Detector.enabled then
            Detector.fishingTimer = Detector.fishingTimer + 0.1
            local bag = getFishCountFallback()
            if bag <= (Detector.lastBag or 0) then
                if Detector.fishingTimer >= (Detector.stuckThreshold or 15) then
                    -- reset player
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then Detector.savedCFrame = hrp.CFrame end
                        end
                    end)
                    pcall(function() LocalPlayer.Character:BreakJoints() end)
                    local nc = LocalPlayer.CharacterAdded:Wait()
                    nc:WaitForChild("HumanoidRootPart").CFrame = Detector.savedCFrame or CFrame.new(0,5,0)
                    task.wait(0.1)
                    equipRod()
                    Detector.fishingTimer = 0
                    Detector.lastBag = getFishCountFallback()
                end
            else
                Detector.lastBag = bag
                Detector.fishingTimer = 0
            end
        end
    end
end)

-- ============================================
-- WindUI Window & Tabs (option 4: custom tabs)
-- ============================================
local Window = WindUI:CreateWindow({
    Title = "Reya HUB",
    Icon = "rbxassetid://80622869023191",
    Folder = "Reya_HUB",
    Size = UDim2.fromOffset(720, 520),
    Theme = "Indigo",
    KeySystem = false
})

local Tabs = {
    Dashboard = Window:Tab({ Title = "Dashboard", Icon = "home" }),
    Automation = Window:Tab({ Title = "Automation", Icon = "play" }),
    Travel = Window:Tab({ Title = "Travel", Icon = "map-pin" }),
    Systems = Window:Tab({ Title = "Systems", Icon = "settings" }),
    Utility = Window:Tab({ Title = "Utility", Icon = "tool" }),
    Server = Window:Tab({ Title = "Server", Icon = "server" })
}

-- DASHBOARD
Tabs.Dashboard:Section({ Title = "Welcome" })
Tabs.Dashboard:Paragraph({ Title = "Reya HUB", Desc = "WindUI port — Chloe-style features (no Chloe name)." })

-- show quick stats
local statsParagraph = Tabs.Dashboard:Paragraph({ Title = "Status", Desc = "Loading..." })
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local fps = 0
            if Workspace.GetRealPhysicsFPS then fps = math.floor(Workspace:GetRealPhysicsFPS()) end
            local ping = "N/A"
            pcall(function() ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() end)
            statsParagraph:SetDesc(string.format("FPS: %s
Ping: %s
AutoFish: %s
Blatant: %s", tostring(fps), tostring(ping), tostring(_G.AutoFish), tostring(_G.Instant)))
        end)
    end
end)

-- AUTOMATION TAB (fishing features)
Tabs.Automation:Section({ Title = "Fishing - Automation" })
Tabs.Automation:Toggle({ Title = "Auto Fish (Instant)", Desc = "Automatically catch fish (Instant)", Default = _G.AutoFish, Callback = function(val)
    _G.AutoFish = val
    if not val then CancelFishing() end
    WindUI:Notify({ Title = "AutoFish", Content = val and "Enabled" or "Disabled", Duration = 3 })
end })
Tabs.Automation:Slider({ Title = "Instant Reel Delay", Desc = "Delay between instant reels", Value = { Min = 0, Max = 5, Default = _G.InstantDelay }, Callback = function(v) _G.InstantDelay = v end })

Tabs.Automation:Divider()
Tabs.Automation:Section({ Title = "Blatant (Chloe-style)" })
Tabs.Automation:Toggle({ Title = "Enable Blatant (Chloe)", Desc = "Uses RunService + tick() style auto-complete/cancel", Default = _G.Instant, Callback = function(val)
    _G.Instant = val
    if not val then CancelFishing() end
    WindUI:Notify({ Title = "Blatant", Content = val and "Enabled" or "Disabled", Duration = 3 })
end })
Tabs.Automation:Slider({ Title = "Blatant Delay (s)", Desc = "Delay before auto-complete/cancel", Value = { Min = 1, Max = 6, Default = _G.CancelWaitTime }, Callback = function(v) _G.CancelWaitTime = v end })

Tabs.Automation:Divider()
Tabs.Automation:Section({ Title = "Auto Fishing V2 (Chloe)" })
Tabs.Automation:Toggle({ Title = "Auto Fish V2", Desc = "Chloe-style auto spam loop", Default = _G.AutoFishingV2, Callback = function(val)
    if val then StartAutoV2() else StopAutoV2() end
    WindUI:Notify({ Title = "AutoV2", Content = val and "Started" or "Stopped", Duration = 3 })
end })
Tabs.Automation:Slider({ Title = "V2 Click Count", Desc = "Number of spam clicks", Value = { Min = 1, Max = 200, Default = _G.V2_ClickCount }, Callback = function(v) _G.V2_ClickCount = v end })
Tabs.Automation:Slider({ Title = "V2 Click Delay", Desc = "Delay between spam clicks", Value = { Min = 0, Max = 0.5, Default = _G.V2_ClickDelay }, Callback = function(v) _G.V2_ClickDelay = v end })
Tabs.Automation:Slider({ Title = "V2 Wait For Fish", Desc = "How long to wait for bite", Value = { Min = 0.5, Max = 20, Default = _G.V2_WaitForFish }, Callback = function(v) _G.V2_WaitForFish = v end })
Tabs.Automation:Slider({ Title = "V2 Next Cast Delay", Desc = "Delay after cycle", Value = { Min = 0, Max = 10, Default = _G.V2_NextCastDelay }, Callback = function(v) _G.V2_NextCastDelay = v end })
Tabs.Automation:Button({ Title = "Equip Rod", Desc = "Equip fishing rod from hotbar slot 1", Callback = function() equipRod() WindUI:Notify({ Title = "Equip", Content = "Attempted to equip rod", Duration = 2 }) end })
Tabs.Automation:Button({ Title = "Cancel Fishing (Force)", Desc = "Invoke CancelFishing", Callback = function() CancelFishing() WindUI:Notify({ Title = "Cancel", Content = "Cancel invoked", Duration = 2 }) end })

-- AUTO SELL UI
Tabs.Automation:Divider()
Tabs.Automation:Section({ Title = "Auto Sell" })
Tabs.Automation:Toggle({ Title = "Auto Sell", Desc = "Automatically sell fish periodically", Default = _G.AutoSell, Callback = function(v) _G.AutoSell = v WindUI:Notify({ Title = "AutoSell", Content = v and "Enabled" or "Disabled", Duration = 3 }) end })
Tabs.Automation:Slider({ Title = "Sell Delay", Desc = "Seconds between sells", Value = { Min = 1, Max = 300, Default = _G.SellDelay }, Callback = function(v) _G.SellDelay = v end })
Tabs.Automation:Button({ Title = "Sell All Now", Desc = "Sell immediately", Callback = function() SellAll() WindUI:Notify({ Title = "Sell", Content = "Sell attempted", Duration = 2 }) end })

-- TRAVEL TAB
Tabs.Travel:Section({ Title = "Teleport Locations" })
local names = {}
for k,_ in pairs(TeleportLocations) do table.insert(names,k) end
table.sort(names)
local selected = names[1]
Tabs.Travel:Dropdown({ Title = "Location", Content = "Choose a place", Values = names, Callback = function(v) selected = v end })
Tabs.Travel:Button({ Title = "Teleport to Location", Desc = "Move to selected location", Callback = function() if selected and TeleportLocations[selected] then MoveTo(TeleportLocations[selected]) WindUI:Notify({ Title = "Teleported", Content = selected, Duration = 2 }) end end })

Tabs.Travel:Divider()
Tabs.Travel:Section({ Title = "Player Teleport" })
local function GetPlayerList()
    local t = {}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(t,p.Name) end end
    return #t>0 and t or {"No Players"}
end
local playerList = GetPlayerList()
local selPlayer = playerList[1]
Tabs.Travel:Dropdown({ Title = "Player", Values = playerList, Callback = function(v) selPlayer=v end })
Tabs.Travel:Button({ Title = "Teleport to Player", Callback = function()
    if selPlayer and selPlayer~="No Players" then
        local target = Players:FindFirstChild(selPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            MoveTo(target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0))
            WindUI:Notify({ Title = "Teleported", Content = "Moved to "..selPlayer, Duration = 2 })
        end
    end
end })
Tabs.Travel:Button({ Title = "Refresh Player List", Callback = function() playerList = GetPlayerList() WindUI:Notify({ Title = "Refreshed", Content = "Player list updated", Duration = 2 }) end })

-- SYSTEMS TAB
Tabs.Systems:Section({ Title = "Oxygen & Cutscenes" })
Tabs.Systems:Button({ Title = "Bypass Oxygen", Desc = "Destroy UpdateOxygen remote if exists", Callback = function()
    pcall(function() local upd = net and net:FindFirstChild("URE/UpdateOxygen") if upd then upd:Destroy() end end)
    WindUI:Notify({ Title = "Oxygen", Content = "Bypass attempted", Duration = 2 })
end })
Tabs.Systems:Toggle({ Title = "Infinite Oxygen", Desc = "Fire UpdateOxygen with large negative", Default = _G.InfOxygen, Callback = function(v)
    _G.InfOxygen = v
    if v then task.spawn(function() while _G.InfOxygen do pcall(function() if net and net:FindFirstChild("URE/UpdateOxygen") then net["URE/UpdateOxygen"]:FireServer(-999999) end end) task.wait(1) end end) end
end })

Tabs.Systems:Divider()
Tabs.Systems:Section({ Title = "Cutscene" })
Tabs.Systems:Toggle({ Title = "Auto Skip Cutscene", Desc = "Disable cutscene events", Default = true, Callback = function(v)
    if v then
        if net and net:FindFirstChild("RE/ReplicateCutscene") then net["RE/ReplicateCutscene"].OnClientEvent:Connect(function() end) end
        if net and net:FindFirstChild("RE/StopCutscene") then net["RE/StopCutscene"].OnClientEvent:Connect(function() end) end
        WindUI:Notify({ Title = "Cutscene", Content = "Auto-skip enabled", Duration = 2 })
    else
        WindUI:Notify({ Title = "Cutscene", Content = "Auto-skip disabled", Duration = 2 })
    end
end })

-- UTILITY TAB
Tabs.Utility:Section({ Title = "Visuals & Notifications" })
Tabs.Utility:Toggle({ Title = "Disable Notifications", Desc = "Disconnect common notification events", Default = _G.DisableNotifs, Callback = function(v)
    _G.DisableNotifs = v
    if v then
        pcall(function()
            local events = { net and net["RE/ObtainedNewFishNotification"], net and net["RE/TextNotification"], net and net["RE/ClaimNotification"] }
            for _,ev in ipairs(events) do if ev and ev.OnClientEvent then for _,c in ipairs(getconnections(ev.OnClientEvent)) do c:Disconnect() end end end
        end)
    end
end })

Tabs.Utility:Toggle({ Title = "Disable Character Effects", Desc = "Stop fishing effect events", Default = _G.DisableCharEffect, Callback = function(v)
    _G.DisableCharEffect = v
    if v then
        pcall(function()
            local events = { net and net["RE/PlayFishingEffect"], net and net["RE/ReplicateTextEffect"] }
            for _,ev in ipairs(events) do if ev and ev.OnClientEvent then for _,c in ipairs(getconnections(ev.OnClientEvent)) do c:Disconnect() end ev.OnClientEvent:Connect(function() end) end end
        end)
    end
end })

Tabs.Utility:Toggle({ Title = "Delete Fishing Effects (Particles)", Default = _G.DelEffects, Callback = function(v)
    _G.DelEffects = v
    if v then task.spawn(function() while _G.DelEffects do local cf = Workspace:FindFirstChild("CosmeticFolder") if cf then cf:Destroy() end task.wait(60) end end) end
end })

Tabs.Utility:Toggle({ Title = "Hide Rod On Hand", Default = _G.HideRodOnHand, Callback = function(v)
    _G.HideRodOnHand = v
    if v then task.spawn(function() while _G.HideRodOnHand do local chars = Workspace:FindFirstChild("Characters") if chars then for _,ch in ipairs(chars:GetChildren()) do local eq = ch:FindFirstChild("!!!EQUIPPED_TOOL!!!") if eq then eq:Destroy() end end end task.wait(1) end end) end
end })

Tabs.Utility:Toggle({ Title = "Freeze Player When Fishing", Default = _G.FrozenPlayer, Callback = function(v)
    _G.FrozenPlayer = v
    if v then
        task.spawn(function()
            local function isRodEquipped()
                local ok, Replion = pcall(function() return require(ReplicatedStorage.Packages.Replion) end)
                if not ok or not Replion then return false end
                local Data = Replion.Client:WaitReplion("Data")
                local equipped = Data and Data:Get("EquippedId")
                if not equipped then return false end
                local PlayerStatsUtility = require(ReplicatedStorage.Shared.PlayerStatsUtility)
                local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
                local item = PlayerStatsUtility:GetItemFromInventory(Data, function(p) return p.UUID == equipped end)
                if not item then return false end
                local itemData = ItemUtility:GetItemData(item.Id)
                return itemData and itemData.Data.Type == "Fishing Rods"
            end
            local function anchorChar(char, anchor)
                if char then for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.Anchored = anchor end end end
            end
            local function apply()
                local char = LocalPlayer.Character
                if not char then return end
                if isRodEquipped() then anchorChar(char, true) end
            end
            apply()
            LocalPlayer.CharacterAdded:Connect(function(c) task.wait(1) if _G.FrozenPlayer then apply() end end)
        end)
    else
        local char = LocalPlayer.Character
        if char then for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.Anchored = false end end end
    end
end })

-- SERVER TAB
Tabs.Server:Section({ Title = "Server Controls" })
Tabs.Server:Button({ Title = "Rejoin Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end })
Tabs.Server:Button({ Title = "Server Hop", Callback = function()
    local ok,mod = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/raw-scriptpastebin/FE/main/Server_Hop_Settings"))() end)
    if ok and mod then mod:Teleport(game.PlaceId) else WindUI:Notify({ Title = "ServerHop", Content = "Failed to load module", Duration = 3 }) end
end })
Tabs.Server:Paragraph({ Title = "Job ID", Desc = game.JobId })
Tabs.Server:Button({ Title = "Copy Job ID", Callback = function() setClipboardIfAvailable(game.JobId) WindUI:Notify({ Title = "Copied", Content = "Job ID copied to clipboard", Duration = 2 }) end })

-- AUTO REJOIN ON DISCONNECT (simple)
task.spawn(function()
    while task.wait(5) do
        if not LocalPlayer or not LocalPlayer:IsDescendantOf(game) then
            pcall(function() TeleportService:Teleport(game.PlaceId) end)
        end
    end
end)

TeleportService.TeleportInitFailed:Connect(function(player, result)
    if result == Enum.TeleportResult.Failure then pcall(function() TeleportService:Teleport(game.PlaceId) end) end
end)

-- Success notify
WindUI:Notify({ Title = "Reya HUB", Content = "Loaded (WindUI) - Press toggle key to open", Duration = 5 })

print("Reya HUB (WindUI) loaded - Tabs: Dashboard, Automation, Travel, Systems, Utility, Server")
("WindUI version building...")
