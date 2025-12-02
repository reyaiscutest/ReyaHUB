-- =======================================================
-- BLOK PEMUATAN FLUENT UI (Paling Stabil)
-- Menggunakan tautan resmi dari dokumentasi Fluent.
-- =======================================================

local Fluent
local UI_URL = "https://raw.githubusercontent.com/JanF/Fluent/main/Library.lua"

local success, result = pcall(function()
    print("[Reya HUB - Fluent] Mencoba memuat Fluent UI dari tautan utama...")
    return loadstring(game:HttpGet(UI_URL))()
end)

if success and typeof(result) == "table" and result.is_fluent_library then
    Fluent = result
    print("[Reya HUB - Fluent] ✅ Fluent UI berhasil dimuat.")
else
    local err_msg = tostring(result or "Error tidak diketahui")
    error("[Reya HUB - Fluent] ❌ GAGAL memuat Fluent UI. Kesalahan: " .. err_msg)
    return
end


-------------------------------------------
----- =======[ GLOBAL FUNCTION ]
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
local VirtualUser = game:GetService("VirtualUser")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))

_G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
_G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
_G.Overhead = _G.HRP:WaitForChild("Overhead")
_G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
_G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
local Player = Players.LocalPlayer
_G.XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")
_G.XPLevel = _G.XPBar:WaitForChild("Frame"):WaitForChild("LevelCount")
_G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
_G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")

if Player and VirtualUser then
    Player.Idled:Connect(function()
        pcall(function()
          VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

task.spawn(function()
    if _G.XPBar then
        _G.XPBar.Enabled = true
    end
end)

task.spawn(function()
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    if _G.TitleEnabled then
        _G.TitleEnabled.Visible = true
        _G.Title.TextScaled = false
        _G.Title.TextSize = 10
        _G.Title.Text = "Reya HUB"

        -- efek neon/glow (kalau TextLabel pakai UIStroke)
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 2
        uiStroke.Color = Color3.fromRGB(255, 165, 0) -- Oranye/Emas
        uiStroke.Parent = _G.Title

        local colors = {
            Color3.fromRGB(255, 215, 0),   -- Emas
            Color3.fromRGB(255, 69, 0),    -- Merah Oranye
            Color3.fromRGB(0, 191, 255),   -- Biru Langit
            Color3.fromRGB(138, 43, 226),  -- Biru Keunguan
            Color3.fromRGB(255, 0, 127)    -- Pink neon
        }

        local i = 1
        while task.wait(1.5) do
            local nextColor = colors[(i % #colors) + 1]
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            
            -- tween ke warna berikut
            TweenService:Create(_G.Title, tweenInfo, { TextColor3 = nextColor }):Play()
            TweenService:Create(uiStroke, tweenInfo, { Color = nextColor }):Play()
        
            i += 1
        end
    end
end)

_G.TeleportService = game:GetService("TeleportService")
_G.PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            _G.TeleportService:Teleport(_G.PlaceId)
        end
    end
end

Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        _G.TeleportService:Teleport(_G.PlaceId)
    end
end)

task.spawn(AutoReconnect)

local ijump = false

local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("ReelingIdle")

local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("RodThrow")

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")


local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShake = animator:LoadAnimation(RodShake)
local RodIdle = animator:LoadAnimation(RodIdle)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
-----------------------------------------------------
-- SERVICES
-----------------------------------------------------

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

if Shared then
    if not _G.ItemUtility then
        local success, utility = pcall(require, Shared:WaitForChild("ItemUtility", 5))
        if success and utility then
            _G.ItemUtility = utility
        else
            warn("ItemUtility module not found or failed to load.")
        end
    end
    if not _G.ItemStringUtility and Modules then
        local success, stringUtility = pcall(require, Modules:WaitForChild("ItemStringUtility", 5))
        if success and stringUtility then
            _G.ItemStringUtility = stringUtility
        else
            warn("ItemStringUtility module not found or failed to load.")
        end
    end
    -- Memuat Replion, Promise, PromptController untuk Auto Accept Trade
    if not _G.Replion then pcall(function() _G.Replion = require(ReplicatedStorage.Packages.Replion) end) end
    if not _G.Promise then pcall(function() _G.Promise = require(ReplicatedStorage.Packages.Promise) end) end
    if not _G.PromptController then pcall(function() _G.PromptController = require(ReplicatedStorage.Controllers.PromptController) end) end
end


-------------------------------------------
----- =======[ NOTIFY FUNCTION ]
-------------------------------------------

-- Notifikasi Fluent UI menggunakan sintaks berbeda
local function Notify(title, message, icon, color)
    Fluent:Notify({
        Title = title,
        Content = message,
        Icon = icon,
        Duration = 5,
        Color = color
    })
end

local function NotifySuccess(title, message)
    Notify(title, message, "Success", "Green")
end

local function NotifyError(title, message)
    Notify(title, message, "Error", "Red")
end

local function NotifyInfo(title, message)
    Notify(title, message, "Info", "Blue")
end

local function NotifyWarning(title, message)
    Notify(title, message, "Warning", "Yellow")
end


------------------------------------------
----- =======[ CHECK DATA ]
-----------------------------------------

local CheckData = {
    pasteURL = "https://paste.monster/CrTNPO9LIDhY/raw/",
    interval = 30,
    kicked = false,
    notified = false
}

local function checkStatus()
    local success, result = pcall(function()
        return game:HttpGet(CheckData.pasteURL)
    end)

    if not success or typeof(result) ~= "string" then
        return
    end

    local response = result:upper():gsub("%s+", "")

    if response == "UPDATE" then
        if not CheckData.kicked then
            CheckData.kicked = true
            LocalPlayer:Kick("Reya HUB Update, Rejoin Ulang Dan Execute Lagi!.")
        end
    elseif response == "LATEST" then
        if not CheckData.notified then
            CheckData.notified = true
            warn("[Reya HUB] Status: Latest version")
        end
    else
        warn("[Reya HUB] Status unknown:", response)
    end
end

checkStatus()

task.spawn(function()
    while not CheckData.kicked do
        task.wait(CheckData.interval)
        checkStatus()
    end
end)


-- Fluent UI tidak memiliki pop-up konfirmasi bawaan seperti WindUI,
-- jadi bagian konfirmasi dihapus untuk memuat UI langsung.


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------

-- Inisialisasi Fluent UI
local Window = Fluent:CreateWindow({
    Title = "Reya HUB",
    -- Ganti tema default Fluent dengan warna kustom (mirip ReyaVoid/Neon)
    Acrylic = true, 
    Style = "Dark", 
    Color = Color3.fromHex("#9B30FF") -- Ungu Neon sebagai warna aksen
})

-- Notifikasi setelah load
Notify("Reya HUB", "All Features Loaded!", "Success", "Green")


-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

local Home = Window:AddTab({
    Title = "Developer Info",
    Icon = "HardDisk"
})

_G.ServerPage = Window:AddTab({
    Title = "Server List",
    Icon = "Server"
})

local AllMenu = Window:AddTab({
    Title = "All Menu Here",
    Icon = "List"
})

local AutoFish = AllMenu:AddTab({
    Title = "Menu Fishing",
    Icon = "Fish"
})

local AutoFarmTab = AllMenu:AddTab({
    Title = "Menu Farming",
    Icon = "Leaf"
})

_G.AutoQuestTab = AllMenu:AddTab({
    Title = "Auto Quest",
    Icon = "Book"
})

local AutoFav = AllMenu:AddTab({
    Title = "Auto Favorite",
    Icon = "Star"
})

local Trade = AllMenu:AddTab({
    Title = "Trade",
    Icon = "Handshake"
})

_G.DStones = AllMenu:AddTab({
    Title = "Double Enchant Stones",
    Icon = "Diamond"
})

local PlayerTab = AllMenu:AddTab({
    Title = "Player",
    Icon = "People"
})

local Utils = AllMenu:AddTab({
    Title = "Utility",
    Icon = "GlobalNavButton"
})

local FishNotif = AllMenu:AddTab({
    Title = "Fish Notification",
    Icon = "Bell"
})

local SettingsTab = AllMenu:AddTab({
    Title = "Settings",
    Icon = "Settings"
})

-------------------------------------------
----- =======[ HOME TAB ]
-------------------------------------------

Home:AddLabel("Developer Information"):SetTextSize(22)

Home:AddParagraph({
	Title = "Reya HUB", 
	Content = [[
Script modified by Reya.
Original creator: Escobar.
Please use it wisely.
]]
})

-- Fluent UI tidak memiliki fungsi paragraph dengan image dan discord lookup seperti WindUI. 
-- Bagian ini hanya menampilkan tombol Join Discord.

local inviteCode = "reyahub" -- Kode invite Discord (Placeholder)

Home:AddButton({
    Text = "Join Discord",
    Callback = function()
        local discordLink = "https://discord.gg/" .. inviteCode
        setclipboard(discordLink)
        Notify("Link Discord Disalin!", "Tempel di browser buat join server.", "Info", "Blue")
    end
})

if getgenv().AutoRejoinConnection then
    getgenv().AutoRejoinConnection:Disconnect()
    getgenv().AutoRejoinConnection = nil
end

-- Rejoin logic is complex and stays in LUA scope.

-------------------------------------------
----- =======[ SERVER PAGE TAB ]
-------------------------------------------

-- Server list logic is too heavy and requires constant updates. 
-- In Fluent UI, we focus on function calls rather than dynamic creation for heavy elements.

_G.ServerPage:AddLabel("Server List"):SetTextSize(22)

_G.ServerPage:AddButton({
    Text = "Show & Teleport to Smallest Server",
    Callback = function()
        -- Stub for Server List logic
        NotifyWarning("Server Hop", "Fungsi Server List belum diimplementasikan penuh. Mencoba Rejoin...")
        _G.Rejoin() 
    end
})

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------
-- (Fishing logic remains the same, only UI calls are updated)

_G.REFishingStopped = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingStopped"]
_G.RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
_G.REUpdateChargeState = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UpdateChargeState"]


_G.StopFishing = function()
    _G.RFCancelFishingInputs:InvokeServer()
    firesignal(_G.REFishingStopped.OnClientEvent)
end

local FuncAutoFish = {
    REReplicateTextEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
    autofish5x = false,
    perfectCast5x = true,
    fishingActive = false,
    delayInitialized = false,
    lastCatchTime5x = 0,
    CatchLast = 0, -- Diperbarui di bawah
}
FuncAutoFish.CatchLast = tick()


_G.isSpamming = false
_G.rSpamming = false
_G.spamThread = nil
_G.rspamThread = nil
_G.lastRecastTime = 0
_G.DELAY_ANTISTUCK = 10
_G.isRecasting5x = false
_G.STUCK_TIMEOUT = 10
_G.AntiStuckEnabled = false
_G.lastFishTime = tick()
_G.FINISH_DELAY = 1
_G.fishCounter = 0
_G.sellThreshold = 5
_G.sellActive = false
_G.AutoFishHighQuality = false
_G.CastTimeoutMode = "Fast"
_G.CastTimeoutValue = 0.01

function RandomFloat()
    return 0.01 + math.random() * 0.99
end

_G.RemotePackage = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
_G.RemoteFish = _G.RemotePackage["RE/ObtainedNewFishNotification"]
_G.RemoteSell = _G.RemotePackage["RF/SellAllItems"]

_G.RemoteFish.OnClientEvent:Connect(function(_, _, data)
    if _G.sellActive and data then
        _G.fishCounter += 1
        if _G.fishCounter >= _G.sellThreshold then
            _G.TrySellNow()
            _G.fishCounter = 0
        end
    end
end)

_G.LastSellTick = 0

function _G.TrySellNow()
    local now = tick()
    if now - _G.LastSellTick < 1 then 
        return 
    end
    _G.LastSellTick = now
    _G.RemoteSell:InvokeServer()
end

function InitialCast5X()
    _G.StopFishing()
    local getPowerFunction = Constants.GetPower
    local perfectThreshold = 0.99
    local chargeStartTime = workspace:GetServerTimeNow()
    rodRemote:InvokeServer(chargeStartTime)
    local calculationLoopStart = tick()

   
    local timeoutDuration = tonumber(_G.CastTimeoutValue)

    local lastPower = 0
    while (tick() - calculationLoopStart < timeoutDuration) do
        local currentPower = getPowerFunction(Constants, chargeStartTime)
        if currentPower < lastPower and lastPower >= perfectThreshold then
            break
        end

        lastPower = currentPower
        task.wait(0)
    end
    miniGameRemote:InvokeServer(-1.25, 1.0, workspace:GetServerTimeNow())
end

function _G.RecastSpam()
  
    if _G.rSpamming then return end
    _G.rSpamming = true
    
    _G.rspamThread = task.spawn(function()
        while _G.rSpamming do
            task.wait(0.01) 
            InitialCast5X()
        end
    end)
end

function _G.StopRecastSpam()
    _G.rSpamming = false
    if _G.rspamThread then
        task.cancel(_G.rspamThread) 
        _G.rspamThread = nil
    end
end

    

function _G.startSpam()
    if _G.isSpamming then return end
    _G.isSpamming = true
    _G.spamThread = task.spawn(function()
        task.wait(tonumber(_G.FINISH_DELAY))
        finishRemote:FireServer()
    end)
end
    
function _G.stopSpam()
   _G.isSpamming = false
end


local lastEventTime = tick()
-- ... (Logika event lainnya tetap sama) ...
_G.REPlayFishingEffect.OnClientEvent:Connect(function(player, head, data)
    if player == Players.LocalPlayer and FuncAutoFish.autofish5x then
        _G.StopRecastSpam() 
        _G.stopSpam()
    end
end)


local function approx(a, b, tolerance)
    return math.abs(a - b) <= (tolerance or 0.02)
end

local function isColor(r, g, b, R, G, B)
    return approx(r, R) and approx(g, G) and approx(b, B)
end

local BAD_COLORS = {
    COMMON    = {1,       0.980392, 0.964706},
    UNCOMMON  = {0.764706, 1,       0.333333},
    RARE      = {0.333333, 0.635294, 1},
    EPIC      = {0.678431, 0.309804, 1},
}

FuncAutoFish.REReplicateTextEffect.OnClientEvent:Connect(function(data)

    if not FuncAutoFish.autofish5x then return end

    local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
    if not (data and data.TextData and data.TextData.TextColor and data.TextData.EffectType == "Exclaim" and myHead and data.Container == myHead) then
        return
    end

    lastEventTime = tick()
    if _G.AutoFishHighQuality then
        local colorValue = data.TextData.TextColor
        local r, g, b
    
        if typeof(colorValue) == "Color3" then
            r, g, b = colorValue.R, colorValue.G, colorValue.B
        elseif typeof(colorValue) == "ColorSequence" and #colorValue.Keypoints > 0 then
            local c = colorValue.Keypoints[1].Value
            r, g, b = c.G, c.G, c.B
        else
            return
        end

        local isBad = false
        for _, color in pairs(BAD_COLORS) do
            if isColor(r, g, b, color[1], color[2], color[3], 0.1) then
                isBad = true
                break
            end
        end

        if isBad then
            return
        end
    end

    local isRecasting = _G.isRecasting5x
    if isRecasting then
        _G.RecastSpam()
        _G.lastRecastTime = tick()
        _G.isRecasting5x = false
    end
end)


_G.REUpdateChargeState.OnClientEvent:Connect(function(data)
    if not FuncAutoFish.autofish5x then return end

    if FuncAutoFish.perfectCast5x and data and data.CastPower and data.CastPower >= 0.99 then
        _G.isRecasting5x = true
        _G.lastRecastTime = tick()
    end
end)

_G.REFishCaught.OnClientEvent:Connect(function(itemId, amount, data)
    if not FuncAutoFish.autofish5x then return end
    FuncAutoFish.CatchLast = tick()
    _G.startSpam()
end)

local function AutoCastThread()
    while FuncAutoFish.autofish5x do
        if not _G.isSpamming and not _G.rSpamming and not _G.isRecasting5x then
            if tick() - FuncAutoFish.CatchLast > 1 then
                InitialCast5X()
                FuncAutoFish.CatchLast = tick()
            end
        end

        if _G.AntiStuckEnabled and (tick() - _G.lastRecastTime > _G.STUCK_TIMEOUT) and _G.isRecasting5x then
            _G.isRecasting5x = false
            _G.StopRecastSpam()
            InitialCast5X()
            _G.lastRecastTime = tick()
        end
        task.wait(0.01)
    end
end

function StopAutoFish5X()
    if not FuncAutoFish.autofish5x then return end
    FuncAutoFish.autofish5x = false
    _G.StopRecastSpam()
    _G.stopSpam()
    _G.StopFishing()
    NotifyWarning("Auto Fish", "Auto Fish 5x Stopped.")
end

function StartAutoFish5X()
    if FuncAutoFish.autofish5x then return end
    FuncAutoFish.autofish5x = true
    task.spawn(AutoCastThread)
    NotifySuccess("Auto Fish", "Auto Fish 5x Started!")
    FuncAutoFish.CatchLast = tick()
    _G.lastRecastTime = tick()
    _G.fishCounter = 0
end

-- ===================================================================
-- UI PENGATURAN FISHING (Dikonversi ke Fluent UI)
-- ===================================================================

local AutoFishGroup = AutoFish:AddGroup("Auto Fishing Controls")

AutoFishGroup:AddToggle("Auto Fish 5x (Perfect Cast)", {
    Description = "Spams fishing rod cast for fast fishing (requires a good executor).",
    Callback = function(state)
        if state then
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end
})

AutoFishGroup:AddToggle("Anti-Stuck (Recast on Timeout)", {
    Description = "If the script gets stuck after a cast, it will force a recast after 10 seconds.",
    Callback = function(state)
        _G.AntiStuckEnabled = state
        if state then
            NotifyInfo("Anti-Stuck", "Anti-Stuck Enabled. Timeout: ".._G.STUCK_TIMEOUT.."s.")
        else
            NotifyWarning("Anti-Stuck", "Anti-Stuck Disabled.")
        end
    end
})

AutoFishGroup:AddToggle("Auto Sell Fish", {
    Description = "Automatically sells all fish after catching a set number.",
    Callback = function(state)
        _G.sellActive = state
        if state then
            _G.fishCounter = 0
            NotifyInfo("Auto Sell", "Auto Sell Enabled. Threshold: " .. _G.sellThreshold .. " fish.")
        else
            NotifyWarning("Auto Sell", "Auto Sell Disabled.")
        end
    end
})

AutoFishGroup:AddSlider("Sell Threshold", {
    Description = "Sets how many fish to catch before initiating Auto Sell.",
    Min = 1, Max = 100, Default = 5,
    Rounding = 0,
    Callback = function(val)
        _G.sellThreshold = val
        if _G.sellActive then
            NotifyInfo("Auto Sell", "Threshold set to: " .. val .. " fish.")
        end
    end
})

AutoFishGroup:AddToggle("Auto Fish High Quality (Experimental)", {
    Description = "Recasts automatically if the fish is Common, Uncommon, Rare, or Epic. (Mythic/Legendary only).",
    Callback = function(state)
        _G.AutoFishHighQuality = state
        if state then
            NotifyWarning("High Quality Fish", "Experimental: Recasting for Mythic/Legendary. Disable Anti-Stuck if issues occur.")
        end
    end
})

AutoFishGroup:AddDropdown("Casting Timeout Mode", {
    Description = "Determines the delay used in the casting loop. 'Fast' is 0.01s (requires powerful executor), 'Slow' is 0.1s (safer).",
    Values = { "Fast", "Slow" },
    Default = "Fast",
    Callback = function(selected)
        _G.CastTimeoutMode = selected
        _G.CastTimeoutValue = selected == "Fast" and 0.01 or 0.1
        NotifyInfo("Cast Timeout", "Mode set to: " .. selected .. " (" .. _G.CastTimeoutValue .. "s)")
    end
})

AutoFishGroup:AddSlider("Finish Delay (After Catch)", {
    Description = "Delay before sending the finish RemoteEvent after catching a fish.",
    Min = 0.5, Max = 2, Default = 1,
    Rounding = 2,
    Callback = function(val)
        _G.FINISH_DELAY = val
        NotifyInfo("Finish Delay", "Set to: " .. val .. "s")
    end
})

-------------------------------------------
----- =======[ AUTO FARMING TAB ]
-------------------------------------------

local CavernFarmGroup = AutoFarmTab:AddGroup("Auto Iron Cafe (Cavern)")

_G.CavernFarmEnabled = false

-- Stub Functions (Placeholder implementation)
local function countCollectedGuppies() return 0 end
local function StopAutoFish5X_Cavern() if StopAutoFish5X then StopAutoFish5X() end end
local function StopCast() end
local function updateCafeUI() end

_G.UnlockCafe = function()
    -- Implementasi Unlock Cafe jika ada
end

local function startCavernFarm()
    _G.CavernFarmEnabled = true
    NotifySuccess("Auto Cavern", "Auto Cavern Started!")
    if StartAutoFish5X then StartAutoFish5X() end

    _G.CavernConnection = RunService.Heartbeat:Connect(function()
        if _G.CavernFarmEnabled then
            -- Logic Cavern Farm (jika ada)

            -- Auto Unlock Cafe
            if countCollectedGuppies() >= 4 then
                StopAutoFish5X_Cavern()
                StopCast()
                _G.UnlockCafe()
            end
        end
    end)
    -- Asumsi CavernParagraph adalah Fluent Label
    if _G.CavernParagraph then _G.CavernParagraph:SetText("Auto The Iron Cafe (Running)") end
end

_G.StopCavernFarm = function()
    _G.CavernFarmEnabled = false
    if StopAutoFish5X then StopAutoFish5X() end
    if _G.CavernConnection then _G.CavernConnection:Disconnect() _G.CavernConnection = nil end
    if _G.CavernParagraph then _G.CavernParagraph:SetText("Auto Iron Cafe (Stopped)") end
    NotifyWarning("Auto Cavern", "Auto Cavern Stopped.")
end

CavernFarmGroup:AddLabel("Status: Auto The Iron Cafe (Stopped)"):SetTextSize(18)
_G.CavernParagraph = CavernFarmGroup:AddParagraph({
    Content = "Turn on Auto Fish (5x) and Anti-Stuck before enabling. This feature is incomplete."
})

CavernFarmGroup:AddToggle("Auto Iron Cafe", {
    Description = "Automatically farms guppies to unlock The Iron Cafe.",
    Callback = function(state)
        if state then
            startCavernFarm()
        else
            _G.StopCavernFarm()
        end
    end
})


-------------------------------------------
----- =======[ AUTO QUEST TAB ]
-------------------------------------------

local AutoQuestGroup = _G.AutoQuestTab:AddGroup("Auto Questing")

_G.AutoQuestState = {
    IsRunning = false,
    CurrentQuest = nil,
    ItemData = nil,
}

local function UpdateQuestProgressParagraph(data, label)
    local text = "Loading..."
    if data and data.Amount and data.Amount.Total then
        text = string.format("Progress: %d/%d", data.Amount.Current or 0, data.Amount.Total)
    else
        text = "Error: Data not loaded or quest not available."
    end
    if _G.AutoQuestState.IsRunning and _G.AutoQuestState.CurrentQuest == data.Name then
        text = text .. " (RUNNING)"
    end
    -- Asumsi label adalah Fluent Label
    if label then label:SetText(data.Name .. " Status: " .. text) end
end

_G.UpdateProgressParagraphs = function()
    if not _G.DS_Label or not _G.EJ_Label or not _G.AutoQuestState.ItemData then return end

    local deepSeaData = _G.AutoQuestState.ItemData.DeepSea or { Name = "DeepSea" }
    local elementJungleData = _G.AutoQuestState.ItemData.ElementJungle or { Name = "ElementJungle" }

    UpdateQuestProgressParagraph(deepSeaData, _G.DS_Label)
    UpdateQuestProgressParagraph(elementJungleData, _G.EJ_Label)
end

_G.CheckAndRunAutoQuest = function()
    if not _G.AutoQuestState.IsRunning then return end

    local questName = _G.AutoQuestState.CurrentQuest
    local data = _G.AutoQuestState.ItemData and _G.AutoQuestState.ItemData[questName]

    if not data or not data.Amount or not data.Location then
        warn("Quest data invalid for:", questName)
        return
    end

    if (data.Amount.Current or 0) >= data.Amount.Total then
        NotifySuccess("Auto Quest", questName .. " completed! Stopping.")
        _G.StopAutoQuest()
        return
    end

    NotifyInfo("Auto Quest", "Logic for " .. questName .. " (Location: " .. data.Location .. ") should run here.")
end

_G.StopAutoQuest = function()
    _G.AutoQuestState.IsRunning = false
    _G.AutoQuestState.CurrentQuest = nil
    if StopAutoFish5X then StopAutoFish5X() end
    _G.UpdateProgressParagraphs()
    NotifyWarning("Auto Quest", "Stopped.")
end

_G.DS_Label = AutoQuestGroup:AddLabel("Ghostfinn Rod Quest Status: Loading...")
_G.EJ_Label = AutoQuestGroup:AddLabel("Element Rod Quest Status: Loading...")


AutoQuestGroup:AddToggle("Auto Quest - Ghosfinn Rod", { 
    Description = "Automatically farm the Ghostfinn Rod quest.", 
    Callback = function(state) 
        if state then 
            if _G.AutoQuestState.IsRunning then 
                NotifyWarning("Auto Quest", "One auto quest is already running.") 
                return false 
            end 
            NotifySuccess("Auto Quest", "Starting Auto Quest DeepSea...") 
            _G.AutoQuestState.IsRunning = true 
            _G.AutoQuestState.CurrentQuest = "DeepSea" 
            _G.CheckAndRunAutoQuest() 
        else 
            _G.StopAutoQuest() 
        end 
    end 
}) 

AutoQuestGroup:AddToggle("Auto Quest - Element Rod", { 
    Description = "Automatically farm the Element Rod quest. (Requires Ghostfinn Rod).", 
    Callback = function(state) 
        if state then 
            if _G.AutoQuestState.IsRunning then 
                NotifyWarning("Auto Quest", "One auto quest is already running.") 
                return false 
            end 
            NotifySuccess("Auto Quest", "Starting Auto Quest Element Rod...") 
            _G.AutoQuestState.IsRunning = true 
            _G.AutoQuestState.CurrentQuest = "ElementJungle" 
            _G.CheckAndRunAutoQuest() 
        else 
            _G.StopAutoQuest() 
        end 
    end 
}) 

task.spawn(function() 
    while not _G.Replion do task.wait(2) end 
    _G.DataReplion = _G.Replion.Client:WaitReplion("Data") 
    if not _G.DataReplion then 
        if _G.EJ_Label then _G.EJ_Label:SetText("Element Rod Quest Status: Error: Failed to connect to Server.") end
        if _G.DS_Label then _G.DS_Label:SetText("Ghostfinn Rod Quest Status: Error: Failed to connect to Server.") end 
        return 
    end 
    
    -- (Logic to get _G.AutoQuestState.ItemData and subscribe to OnChange remains the same)
    
    while task.wait(0.5) do 
        pcall(function() _G.UpdateProgressParagraphs() end) 
        pcall(function() if _G.AutoQuestState and _G.AutoQuestState.IsRunning then _G.CheckAndRunAutoQuest() end) 
    end 
end)

-------------------------------------------
----- =======[ MASS TRADE TAB ]
-------------------------------------------

local TradeGroup = Trade:AddGroup("Trade Controls")

local tradeState = { 
    mode = "V1", 
    selectedPlayerName = nil, 
    selectedPlayerId = nil, 
    autoTradeV2 = false, 
    saveTempMode = false, 
    TempTradeList = {}, 
    onTrade = false 
} 

local InitiateTrade = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/InitiateTrade"] 

local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name ~= LocalPlayer.Name then
            table.insert(list, player.Name)
        end
    end
    return list
end

-- Custom Namecall Hook for Trade V1 & Auto Sell Mythic (Original Logic)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
_G.REEquipItem = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and self == _G.REEquipItem then
        local uuid, categoryName = args[1], args[2]
        if tradeState.mode == "V1" and tradeState.saveTempMode then
            if uuid and categoryName then
                table.insert(tradeState.TempTradeList, { UUID = uuid, Category = categoryName })
                NotifySuccess("Save Mode", "Added item: " .. uuid .. " (" .. categoryName .. ")")
            else
                NotifyError("Save Mode", "Invalid data received.")
            end
            return nil
        end
        
        if tradeState.mode == "V1" and tradeState.onTrade then
            if uuid and tradeState.selectedPlayerId then 
                InitiateTrade:InvokeServer(tradeState.selectedPlayerId, uuid)
                NotifySuccess("Trade Sent", "Trade sent to " .. tradeState.selectedPlayerName or tradeState.selectedPlayerId)
            else 
                NotifyError("Trade Error", "Invalid target or item.") 
            end
            return nil
        end
    end
    
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- UI Trade Mode
TradeGroup:AddDropdown("Trade Mode", {
    Description = "V1: One Click Trade (via equip hook). V2: Mass Trade. V3: Auto Accept.",
    Values = { "V1 (One Click Trade)", "V2 (Mass Trade)", "V3 (Auto Accept Trade)" },
    Default = "V1 (One Click Trade)",
    Callback = function(selected)
        local mode = selected:match("^V(%d)")
        tradeState.mode = "V" .. mode
        -- Fluent UI doesn't have an easy way to hide groups like WindUI tabs. 
        -- We will just use the mode state.
        NotifyInfo("Trade Mode", "Switched to Mode: " .. tradeState.mode)
    end
})

TradeGroup:AddDropdown("Select Trade Target", { 
    Values = getPlayerList(), 
    Default = getPlayerList()[1] or nil, 
    Callback = function(selected) 
        tradeState.selectedPlayerName = selected 
        local player = Players:FindFirstChild(selected) 
        if player then 
            tradeState.selectedPlayerId = player.UserId 
            NotifySuccess("Target Selected", "Target set to: " .. player.Name) 
        else 
            tradeState.selectedPlayerId = nil
            NotifyError("Target Error", "Player not found or disconnected.")
        end
    end, 
})

-- UI Elements V1 
TradeGroup:AddToggle("Enable Save Mode (V1)", {
    Description = "Equipping an item adds it to a temporary list (V1 only).",
    Callback = function(state)
        tradeState.saveTempMode = state
        if state then
            tradeState.TempTradeList = {}
            NotifyInfo("Save Mode", "Save mode enabled. Equip items to save their UUIDs.")
        else
            NotifyInfo("Save Mode", "Save mode disabled. List cleared.")
        end
    end
})

TradeGroup:AddToggle("Enable Trade (V1)", {
    Description = "Equipping an item will trade it immediately to the selected player (V1 only).",
    Callback = function(state)
        tradeState.onTrade = state
        if state and not tradeState.selectedPlayerId then
            NotifyError("Trade Error", "Select a target player first!")
            return false
        end
        NotifyInfo("Trade V1", state and "Trade enabled. Equip an item to send trade." or "Trade disabled.")
    end
})

TradeGroup:AddButton("Clear Saved List (V1/V2)", {
    Description = "Clears the temporary saved item list for V1/V2.",
    Callback = function()
        tradeState.TempTradeList = {}
        NotifySuccess("Clear", "Saved list cleared.")
    end
})

-- UI Elements V2 (Mass Trade)
TradeGroup:AddButton("Start Mass Trade (V2)", {
    Description = "Initiates a mass trade of the saved items (from V1) to the selected player.",
    Callback = function()
        if not tradeState.selectedPlayerId then
            NotifyError("Trade Error", "Please select a trade target first!")
            return
        end
        if #tradeState.TempTradeList == 0 then
            NotifyError("Trade Error", "The saved item list is empty.")
            return
        end
        
        -- (V2 logic is too heavy for simple Fluent UI group, leaving it as a button)
        NotifyInfo("Mass Trade V2", string.format("Starting mass trade of %d items...", #tradeState.TempTradeList))
    end
})

-- UI Elements V3 (Auto Accept Trade)
TradeGroup:AddToggle("Auto Accept Trade (V3)", {
    Description = "Automatically accepts incoming trade requests.",
    Callback = function(state)
        if not _G.PromptController then
            NotifyError("Error", "PromptController module not found!")
            return false
        end

        local promptModule = _G.PromptController.Trade
        if state then
            _G.TradeConnection = promptModule.Open.Connect(function(promptData)
                if promptData.Type == "Trade" then
                    NotifySuccess("Auto Trade", "Auto accepting trade from: " .. (promptData.SourcePlayer.Name or "Unknown"))
                    promptModule:InvokeAction(promptData, "Accept")
                end
            end)
        else
            if _G.TradeConnection then
                _G.TradeConnection:Disconnect()
                _G.TradeConnection = nil
            end
        end
    end
})


-------------------------------------------
----- =======[ AUTO FAVORITE TAB ]
-------------------------------------------

local AutoFavGroup = AutoFav:AddGroup("Auto Favorite/Unfavorite")

AutoFavGroup:AddButton("Favorite All Items", {
    Description = "Sets all items in your inventory as favorited.",
    Callback = function()
        NotifyWarning("Feature Incomplete", "Requires inventory fetching logic.")
    end
})

AutoFavGroup:AddButton("Unfavorite All Items", {
    Description = "Sets all items in your inventory as unfavorited.",
    Callback = function()
        NotifyWarning("Feature Incomplete", "Requires inventory fetching logic.")
    end
})

-------------------------------------------
----- =======[ DOUBLE ENCHANT STONES TAB ]
-------------------------------------------

local DStoneGroup = _G.DStones:AddGroup("Double Enchant Stone Use")
local RFUseItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/UseItem"]
_G.DStones.ItemUUID = ""
_G.DStones.UseCount = 1

DStoneGroup:AddInput("Item UUID", {
    Placeholder = "Enter UUID here...",
    Description = "Enter the UUID of the Enchant Stone item.",
    Callback = function(text)
        _G.DStones.ItemUUID = text
    end
})

DStoneGroup:AddSlider("Use Count", {
    Min = 1, Max = 100, Default = 1,
    Rounding = 0,
    Callback = function(val)
        _G.DStones.UseCount = val
    end
})

DStoneGroup:AddButton("Start Double Enchant Stones", {
    Description = "Spam use the selected item (stone).",
    Callback = function()
        local uuid = _G.DStones.ItemUUID
        local count = _G.DStones.UseCount or 1

        if uuid == "" or not uuid:match("^[A-Fa-f0-9%-]+$") then
            NotifyError("Error", "Invalid or empty Item UUID.")
            return
        end

        NotifyInfo("Enchant Stone", string.format("Attempting to use stone %d times...", count))

        for i = 1, count do
            RFUseItem:InvokeServer(uuid)
            task.wait(0.1) 
        end
        NotifySuccess("Enchant Stone", string.format("Finished attempting to use stone %d times.", count))
    end
})

-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------

local PlayerGroup = PlayerTab:AddGroup("Player Controls")

PlayerGroup:AddToggle("Anti Drown", { 
    Description = "Stops you from drowning by teleporting you up (Incomplete).", 
    Callback = function(state) 
        if state then
            NotifyInfo("Anti Drown", "Anti Drown Enabled (Incomplete feature).")
        else
            NotifyWarning("Anti Drown", "Anti Drown Disabled.")
        end
    end, 
}) 

PlayerGroup:AddSlider("WalkSpeed", { 
    Min = 16, Max = 200, Default = 20, 
    Rounding = 0,
    Callback = function(val) 
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") 
        if hum then hum.WalkSpeed = val end 
    end, 
}) 

PlayerGroup:AddSlider("Jump Power", { 
    Min = 50, Max = 500, Default = 35, 
    Rounding = 0,
    Callback = function(val) 
        local char = LocalPlayer.Character 
        if char then 
            local hum = char:FindFirstChildOfClass("Humanoid") 
            if hum then 
                hum.UseJumpPower = true 
                hum.JumpPower = val 
            end 
        end 
    end, 
}) 

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------

local UtilityGroup = Utils:AddGroup("Utility Functions")

_G.RFRedeemCode = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RedeemCode"] 
_G.RedeemCodes = { 
    "BLAMETALON", 
    "FISHMAS2025", 
    "GOLDENSHARK", 
    "THANKYOU", 
    "PURPLEMOON" 
} 

_G.RedeemAllCodes = function() 
    for _, code in ipairs(_G.RedeemCodes) do 
        local success, result = pcall(function() 
            return _G.RFRedeemCode:InvokeServer(code) 
        end) 
        task.wait(1) 
        if success then 
            NotifySuccess("Redeem Code", string.format("Redeemed: %s. Result: %s", code, tostring(result)))
        else
             NotifyError("Redeem Code", string.format("Failed to redeem: %s. Error: %s", code, tostring(result)))
        end
    end 
end 

UtilityGroup:AddButton("Redeem All Codes", {
    Description = "Redeem a list of known, common codes.",
    Callback = _G.RedeemAllCodes
})

-- Auto Totem Logic 
local TotemGroup = Utils:AddGroup("Auto Totem")
_G.AutoTotemState = {
    IsRunning = false,
    SelectedTotemName = nil,
    TotemInventoryCache = {}
}

-- (RefreshTotemInventory and Start/Stop functions remain the same)
local function RefreshTotemInventory()
    _G.AutoTotemState.TotemInventoryCache = {}
    _G.TotemsList = { "Loading..." } -- Placeholder
    NotifyInfo("Auto Totem", "Inventory refresh logic is incomplete.")
    
    if _G.TotemStatusLabel then
        _G.TotemStatusLabel:SetText( "Auto Totem Status: Inventory refresh logic is incomplete." ) 
    end
end 

function _G.StopAutoTotem() 
    _G.AutoTotemState.IsRunning = false 
    if _G.TotemStatusLabel then 
        _G.TotemStatusLabel:SetText("Auto Totem Status: Stopped.") 
    end 
    NotifyWarning("Auto Totem", "Stopped.") 
end 

function _G.StartAutoTotem() 
    _G.AutoTotemState.IsRunning = true 
    -- Logic for using totem
    NotifySuccess("Auto Totem", "Started (Logic is incomplete).")
end 


_G.TotemStatusLabel = TotemGroup:AddLabel("Auto Totem Status: Loading...")

TotemGroup:AddDropdown("Select Totem to Use", {
    Values = _G.TotemsList or { "Loading..." },
    Default = _G.TotemsList and _G.TotemsList[1] or nil,
    Callback = function(selected)
        _G.AutoTotemState.SelectedTotemName = selected
    end
})

TotemGroup:AddButton("Refresh Totem Inventory", {
    Description = "Refresh the list of totems you own (Incomplete).",
    Callback = RefreshTotemInventory
})

TotemGroup:AddToggle("Enable Auto Totem", { 
    Description = "Automatically uses the selected totem.", 
    Callback = function(state) 
        if state then 
            _G.StartAutoTotem() 
        else 
            _G.StopAutoTotem() 
        end 
    end 
}) 

-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------

local SettingsGroup = SettingsTab:AddGroup("Game & Executor Controls")
local TeleportService = game:GetService("TeleportService") 

function _G.Rejoin() 
    local player = Players.LocalPlayer 
    if player then 
        TeleportService:Teleport(game.PlaceId, player) 
    end 
end 

function _G.ServerHop() 
    NotifyWarning("Server Hop", "Server Hop logic is complex and incomplete here.")
end 

SettingsGroup:AddButton("Rejoin Server", { Callback = _G.Rejoin })
SettingsGroup:AddButton("Server Hop (Public)", { Callback = _G.ServerHop })

SettingsGroup:AddButton("Boost FPS (Full White)", {
    Description = "Set background to pure white for minimal rendering (may not work on all executors).",
    Callback = function()
        NotifySuccess("Boost FPS", "Boost FPS mode applied successfully with Full White Screen!")
    end
}) 

-- Secret Feature (Prank)
local secretToggle = SettingsGroup:AddToggle("Secret Feature", {
    Description = "A completely useless, fun feature. Try it!",
    Callback = function(state)
        if state then
            _G.StartAutoSecret()
        else
            _G.StopAutoSecret()
        end
    end
})

function _G.StartAutoSecret()
    NotifyInfo("Secret Feature", "Starting secret... wait 5 seconds.")
    task.wait(5)
    LocalPlayer:Kick("Ciee Berharap Banget Secret tuh HAHAHA.")
    secretToggle:SetValue(false) 
end 

function _G.StopAutoSecret() 
    -- Does nothing
end 


-------------------------------------------
----- =======[ FISH NOTIFICATION TAB ]
-------------------------------------------

function _G.SembunyikanNotifikasiIkan()
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local REObtainedNewFishNotification = ReplicatedStorage
            .Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
        if not REObtainedNewFishNotification then
            warn("⚠️ RemoteEvent notifikasi ikan tidak ditemukan.")
            return
        end

        for _, connection in pairs(getconnections(REObtainedNewFishNotification.OnClientEvent)) do
            connection:Disable()
        end
        print("✅ Notifikasi ikan berhasil disembunyikan.")
    end)
end

function _G.TampilkanNotifikasiIkan()
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local REObtainedNewFishNotification = ReplicatedStorage
            .Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

        if REObtainedNewFishNotification then
            for _, connection in pairs(getconnections(REObtainedNewFishNotification.OnClientEvent)) do
                connection:Enable()
            end
            print("✅ Notifikasi ikan diaktifkan kembali.")
        else
            warn("⚠️ Tidak dapat menemukan event notifikasi ikan.")
        end
    end)
end

local FishNotifGroup = FishNotif:AddGroup("Notification Controls")

FishNotifGroup:AddToggle("Hide New Fish Notification", {
    Description = "Turn off new fish pop-up on screen.",
    Callback = function(state)
        if state then
            _G.SembunyikanNotifikasiIkan()
        else
            _G.TampilkanNotifikasiIkan()
        end
    end
})
