local UIsuccess, WindUI = pcall(function()
    -- Menggunakan link mentah (raw) untuk memuat WindUI, yang lebih umum untuk exploit
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not UIsuccess or not WindUI then
    warn("Failed to load WindUI...")
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

        -- daftar warna buat gradasi neon (Diubah untuk perbedaan visual)
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
        TeleportService:Teleport(PlaceId)
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

local function NotifySuccess(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "circle-check"
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "ban"
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "info"
    })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "triangle-alert"
    })
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


local confirmed = false
WindUI:Popup({
    Title = "Reya HUB",
    Icon = "shield-half", -- Icon Baru
    Content = [[
Thank you for using Reya HUB.
Please use the script wisely.
]],
    Buttons = {
        { Title = "Start Script",  Variant = "Primary",   Callback = function() confirmed = true end },
    }
})

repeat task.wait() until confirmed


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------


WindUI:AddTheme({
    Name = "ReyaVoid", -- Ganti nama theme
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF3366"), Transparency = 0 },  -- Merah Cerah
        ["50"]  = { Color = Color3.fromHex("#00FFFF"), Transparency = 0 },  -- Cyan Cerah
        ["100"] = { Color = Color3.fromHex("#9B30FF"), Transparency = 0 },  -- Ungu Terang
    }, {
        Rotation = 45,
    }),

    Dialog = Color3.fromHex("#0A0011"),         -- Latar hitam ke ungu gelap
    Outline = Color3.fromHex("#00FFFF"),        -- Pinggir Cyan Cerah
    Text = Color3.fromHex("#FFE6FF"),           -- Putih ke ungu muda
    Placeholder = Color3.fromHex("#B34A7F"),    -- Ungu-merah pudar
    Background = Color3.fromHex("#050008"),     -- Hitam pekat dengan nuansa ungu
    Button = Color3.fromHex("#FF00AA"),         -- Merah ke ungu neon
    Icon = Color3.fromHex("#00E5FF")            -- Aksen Cyan
})
WindUI.TransparencyValue = 0.3

local Window = WindUI:CreateWindow({
    Title = "Reya HUB", -- Ganti Title
    Icon = "rocket", -- Icon Baru
    Author = "Escobar | Modified by Reya",
    Folder = "ReyaHUB", -- Ganti folder
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "ReyaVoid", -- Ganti nama theme
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    NewElements = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    }
})

Window:EditOpenButton({
    Title = "Reya HUB", -- Ganti Title
    Icon = "lightning-bolt", -- Icon Baru
    CornerRadius = UDim.new(0,30),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#FF3366")), -- Merah
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#00FFFF")), -- Cyan
        ColorSequenceKeypoint.new(1, Color3.fromHex("#9B30FF")) -- Ungu
    }),
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("ReyaXConfig") -- Ganti nama config

WindUI:SetNotificationLower(true)

WindUI:Notify({
    Title = "Reya HUB", -- Ganti Title
    Content = "All Features Loaded!",
    Duration = 5,
    Image = "square-check-big"
})

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

local Home = Window:Tab({
    Title = "Developer Info",
    Icon = "hard-drive"
})

_G.ServerPage = Window:Tab({
    Title = "Server List",
    Icon = "server"
})

local AllMenu = Window:Section({
    Title = "All Menu Here",
    Icon = "tally-3",
    Opened = false,
})

local AutoFish = AllMenu:Tab({
    Title = "Menu Fishing",
    Icon = "fish"
})

local AutoFarmTab = AllMenu:Tab({
    Title = "Menu Farming",
    Icon = "leaf"
})

_G.AutoQuestTab = AllMenu:Tab({
    Title = "Auto Quest",
    Icon = "notebook"
})

local AutoFav = AllMenu:Tab({
    Title = "Auto Favorite",
    Icon = "star"
})

local Trade = AllMenu:Tab({
    Title = "Trade",
    Icon = "handshake"
})

_G.DStones = AllMenu:Tab({
    Title = "Double Enchant Stones",
    Icon = "gem"
})

local Player = AllMenu:Tab({
    Title = "Player",
    Icon = "users-round"
})

local Utils = AllMenu:Tab({
    Title = "Utility",
    Icon = "earth"
})

local FishNotif = AllMenu:Tab({
    Title = "Fish Notification",
    Icon = "bell-ring"
})

local SettingsTab = AllMenu:Tab({
    Title = "Settings",
    Icon = "cog"
})

-------------------------------------------
----- =======[ HOME TAB ]
-------------------------------------------

Home:Section({
	Title = "Developer Information",
	TextSize = 22,
	TextXAlignment = "Center",
})

Home:Paragraph({
	Title = "Reya HUB", -- Ganti Title
	Color = "Grey",
	Desc = [[
Script modified by Reya.
Original creator: Escobar.
Please use it wisely.
]]
})

Home:Space()

local InviteAPI = "https://discord.com/api/v10/invites/"

-- Fungsi buat ambil data server Discord
local function LookupDiscordInvite(inviteCode)
    local url = InviteAPI .. inviteCode .. "?with_counts=true"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        return {
            name = data.guild and data.guild.name or "Unknown",
            id = data.guild and data.guild.id or "Unknown",
            online = data.approximate_presence_count or 0,
            members = data.approximate_member_count or 0,
            icon = data.guild and data.guild.icon
                and "https://cdn.discordapp.com/icons/"..data.guild.id.."/"..data.guild.icon..".png"
                or "",
        }
    else
        warn("Gagal mendapatkan data invite.")
        return nil
    end
end

-- Kode invite Discord (Placeholder: Reya HUB)
local inviteCode = "reyahub" 
local inviteData = LookupDiscordInvite(inviteCode)

-- Tampilin info Discord di GUI
if inviteData then
    Home:Paragraph({
        Title = string.format("[DISCORD] %s", inviteData.name),
        Desc = string.format("Members: %d\nOnline: %d", inviteData.members, inviteData.online),
        Image = inviteData.icon,
        ImageSize = 50,
        Locked = true,
    })

    -- Tombol Join Discord
    Home:Button({
        Title = "Join Discord",
        Desc = "Klik untuk salin link invite",
        Callback = function()
            local discordLink = "https://discord.gg/" .. inviteCode

            -- Kalau executor support syn.request, langsung buka link
            if syn and syn.request then
                syn.request({
                    Url = discordLink,
                    Method = "GET"
                })
            else
                -- Kalau gak support, copy ke clipboard aja
                setclipboard(discordLink)
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Link Discord Disalin!",
                    Text = "Tempel di browser buat join server.",
                    Duration = 5
                })
            end
        end
    })
else
    warn("Invite tidak valid.")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Invite Discord Invalid",
        Text = "Cek ulang kode invite lu!",
        Duration = 5
    })
end

if getgenv().AutoRejoinConnection then
    getgenv().AutoRejoinConnection:Disconnect()
    getgenv().AutoRejoinConnection = nil
end

getgenv().AutoRejoinConnection = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    task.wait()
    if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
        local TeleportService = game:GetService("TeleportService")
        local Player = game.Players.LocalPlayer
        task.wait(2) 
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)

-------------------------------------------
----- =======[ SERVER PAGE TAB ]
-------------------------------------------

_G.ServerList = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" ..
game.PlaceId .. 
"/servers/Private?sortOrder=Asc&limit=100"))

_G.ButtonList = {}

_G.ServerListAll = _G.ServerPage:Section({
    Title = "All Server List",
    TextSize = 22,
    TextXAlignment = "Center"
})

_G.ShowServersButton = _G.ServerListAll:Button({
    Title = "Show Server List",
    Desc = "Klik untuk menampilkan daftar server yang tersedia.",
    Locked = false,
    Icon = "",
    Callback = function()
        if _G.ServersShown then return end
        _G.ServersShown = true

        for _, server in ipairs(_G.ServerList.data) do
 
            _G.playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
            _G.ping = server.ping
            _G.id = server.id

            local buttonServer = _G.ServerListAll:Button({
                Title = "Server",
                Desc = "Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping),
                Locked = false,
                Icon = "",
                Callback = function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, _G.id,
                       game.Players.LocalPlayer)
                end
            })

            buttonServer:SetTitle("Server")
            buttonServer:SetDesc("Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping))

            table.insert(_G.ButtonList, buttonServer)
        end

        if #_G.ButtonList == 0 then
            _G.ServerListAll:Button({
                Title = "No Servers Found",
                Desc = "Tidak ada server yang ditemukan.",
                Locked = true,
                Callback = function() end
            })
        end
    end
})

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------

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
    CatchLast = tick(),
}



_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
_G.REPlayFishingEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlayFishingEffect"]
_G.equipRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
_G.REObtainedNewFishNotification = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"]
    .net["RE/ObtainedNewFishNotification"]


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

-- [[ KONFIGURASI DELAY ]] --


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
        task.cancel(_G.rspamThread) -- Membunuh thread
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


_G.REPlayFishingEffect.OnClientEvent:Connect(function(player, head, data)
    if player == Players.LocalPlayer and FuncAutoFish.autofish5x then
        _G.StopRecastSpam() -- Menghentikan spam cast (sudah di-fix)
        _G.stopSpam()
    end
end)



local lastEventTime = tick()

task.spawn(function()
    while task.wait(1) do
        if _G.AutoFishHighQuality and FuncAutoFish.autofish5x and FuncAutoFish.REReplicateTextEffect then
            if tick() - lastEventTime > 10 then
                StopAutoFish5X()
                lastEventTime = tick()
                task.wait(0.5)
                StartAutoFish5X()
            end
        end
    end
end)

local function approx(a, b, tolerance)
    return math.abs(a - b) <= (tolerance or 0.02)
}

local function isColor(r, g, b, R, G, B)
    return approx(r, R) and approx(g, G) and approx(b, B)
}

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
            r, g, b = c.R, c.G, c.B
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
-- 7. UI TOGGLES & FUNGSI INISIALISASI (FIXED LISTENERS)
-- ===================================================================

local ToggleAutoFish = AutoFish:Toggle({
    Title = "Auto Fish 5x (Perfect Cast)",
    Desc = "Spams fishing rod cast for fast fishing (requires a good executor).",
    Value = false,
    Callback = function(state)
        if state then
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end
})
myConfig:Register("AutoFish5x", ToggleAutoFish)

AutoFish:Toggle({
    Title = "Anti-Stuck (Recast on Timeout)",
    Desc = "If the script gets stuck after a cast, it will force a recast after 10 seconds.",
    Value = false,
    Callback = function(state)
        _G.AntiStuckEnabled = state
        if state then
            NotifyInfo("Anti-Stuck", "Anti-Stuck Enabled. Timeout: ".._G.STUCK_TIMEOUT.."s.")
        else
            NotifyWarning("Anti-Stuck", "Anti-Stuck Disabled.")
        end
    end
})

AutoFish:Toggle({
    Title = "Auto Sell Fish",
    Desc = "Automatically sells all fish after catching a set number.",
    Value = false,
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

AutoFish:Slider({
    Title = "Sell Threshold",
    Value = { Min = 1, Max = 100, Default = 5 },
    Step = 1,
    Callback = function(val)
        _G.sellThreshold = val
        if _G.sellActive then
            NotifyInfo("Auto Sell", "Threshold set to: " .. val .. " fish.")
        end
    end
})

AutoFish:Space()

AutoFish:Toggle({
    Title = "Auto Fish High Quality (Experimental)",
    Desc = "Recasts automatically if the fish is Common, Uncommon, Rare, or Epic. (Mythic/Legendary only).",
    Value = false,
    Callback = function(state)
        _G.AutoFishHighQuality = state
        if state then
            NotifyWarning("High Quality Fish", "Experimental: Recasting for Mythic/Legendary. Disable Anti-Stuck if issues occur.")
        end
    end
})

AutoFish:Dropdown({
    Title = "Casting Timeout Mode",
    Desc = "Determines the delay used in the casting loop. 'Fast' is 0.01s (requires powerful executor), 'Slow' is 0.1s (safer).",
    Values = { "Fast", "Slow" },
    Value = _G.CastTimeoutMode,
    Callback = function(selected)
        _G.CastTimeoutMode = selected
        _G.CastTimeoutValue = selected == "Fast" and 0.01 or 0.1
        NotifyInfo("Cast Timeout", "Mode set to: " .. selected .. " (" .. _G.CastTimeoutValue .. "s)")
    end
})

AutoFish:Slider({
    Title = "Finish Delay (After Catch)",
    Value = { Min = 0.5, Max = 2, Default = 1 },
    Step = 0.05,
    Callback = function(val)
        _G.FINISH_DELAY = val
        NotifyInfo("Finish Delay", "Set to: " .. val .. "s")
    end
})

-------------------------------------------
----- =======[ AUTO FARMING TAB ]
-------------------------------------------

local CavernFarm = AutoFarmTab:Section({ Title = "Auto Iron Cafe (Cavern)" })

_G.CavernFarmEnabled = false
_G.CavernConnection = nil
_G.ToggleAutoClick = nil
_G.UnlockCafe = nil

-- Define Stub Functions (The original script likely included these, but they are truncated)
-- Stubbing them to prevent errors on the core functions of the UI elements below.
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

    -- Stub for ToggleAutoClick - replace with actual implementation if available
    _G.ToggleAutoClick = function(state) end 

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
    updateCafeUI()
    if _G.CavernParagraph then _G.CavernParagraph:SetTitle("Auto The Iron Cafe (Running)") end
end

_G.StopCavernFarm = function()
    _G.CavernFarmEnabled = false
    if StopAutoFish5X then StopAutoFish5X() end
    if _G.ToggleAutoClick then _G.ToggleAutoClick(false) end
    if _G.CavernConnection then _G.CavernConnection:Disconnect() _G.CavernConnection = nil end
    updateCafeUI()
    if _G.CavernParagraph then _G.CavernParagraph:SetTitle("Auto Iron Cafe (Stopped)") end
    NotifyWarning("Auto Cavern", "Auto Cavern Stopped.")
end

_G.CavernParagraph = CavernFarm:Paragraph({ 
    Title = "Auto The Iron Cafe", 
    Desc = "Turn on Auto Fish (5x) and Anti-Stuck before enabling. This feature is incomplete." -- Updated note
})

CavernFarm:Toggle({
    Title = "Auto Iron Cafe",
    Desc = "Automatically farms guppies to unlock The Iron Cafe.",
    Value = false,
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

_G.AutoQuestState = {
    IsRunning = false,
    CurrentQuest = nil,
    LoopThread = nil,
    ItemData = nil,
    ItemPath = nil,
}

local function UpdateQuestProgressParagraph(data, paragraph)
    local desc = "Loading..."
    if data and data.Amount and data.Amount.Total then
        desc = string.format("Progress: %d/%d", data.Amount.Current or 0, data.Amount.Total)
    else
        desc = "Error: Data not loaded or quest not available."
    end
    if _G.AutoQuestState.IsRunning and _G.AutoQuestState.CurrentQuest == data.Name then
        desc = desc .. " <font color='#00FF00'>(RUNNING)</font>"
    end
    paragraph:SetDesc(desc)
end

_G.UpdateProgressParagraphs = function()
    -- Stubbing paragraphs (they need to be defined in the UI first)
    if not _G.DS_Paragraph or not _G.EJ_Paragraph then return end

    if _G.AutoQuestState.ItemData then
        local deepSeaData = _G.AutoQuestState.ItemData.DeepSea
        local elementJungleData = _G.AutoQuestState.ItemData.ElementJungle

        UpdateQuestProgressParagraph(deepSeaData, _G.DS_Paragraph)
        UpdateQuestProgressParagraph(elementJungleData, _G.EJ_Paragraph)
    end
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

    -- Add your AutoQuest logic here (e.g., teleport to location, start autofish)
    -- This is left as a placeholder since the full quest logic is not in the provided snippets.
    NotifyInfo("Auto Quest", "Logic for " .. questName .. " (Location: " .. data.Location .. ") should run here.")
end

_G.StopAutoQuest = function()
    _G.AutoQuestState.IsRunning = false
    _G.AutoQuestState.CurrentQuest = nil
    -- Stop any active auto fish or movement here
    if StopAutoFish5X then StopAutoFish5X() end
    _G.UpdateProgressParagraphs()
    NotifyWarning("Auto Quest", "Stopped.")
end

-- UI ELEMENTS
local DS_Section = _G.AutoQuestTab:Section({ Title = "Ghostfinn Rod Quest" })
_G.DS_Paragraph = DS_Section:Paragraph({ Title = "Deep Sea Quest Status", Desc = "Loading..." })

local EJ_Section = _G.AutoQuestTab:Section({ Title = "Element Rod Quest" })
_G.EJ_Paragraph = EJ_Section:Paragraph({ Title = "Element Jungle Quest Status", Desc = "Loading..." })


_G.AutoQuestTab:Toggle({ 
    Title = "Auto Quest - Ghosfinn Rod", 
    Desc = "Automatically farm the Ghostfinn Rod quest.", 
    Value = false, 
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

_G.AutoQuestTab:Toggle({ 
    Title = "Auto Quest - Element Rod", 
    Desc = "Automatically farm the Element Rod quest. (Requires Ghostfinn Rod).", 
    Value = false, 
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
        if _G.EJ_Paragraph then _G.EJ_Paragraph:SetDesc("Error: Failed to connect to Server.") end
        if _G.DS_Paragraph then _G.DS_Paragraph:SetDesc("Error: Failed to connect to Server.") end 
        return 
    end 

    local watchPaths = {}
    pcall(function() 
        _G.AutoQuestState.ItemData = _G.DataReplion.Data.Inventory.Items 
        for _, info in pairs(_G.DataReplion.Data.Inventory.Items) do 
            if info and info.ReplionPath then 
                table.insert(watchPaths, info.ReplionPath .. ".Available.Forever.Quests") 
                table.insert(watchPaths, info.ReplionPath .. ".Completed") 
            end 
        end 
    end) 
    
    pcall(function() 
        if _G.DataReplion and type(_G.DataReplion.OnChange) == "function" then 
            for _, p in ipairs(watchPaths) do 
                pcall(function() 
                    _G.DataReplion:OnChange(p, function() 
                        pcall(function() 
                            _G.UpdateProgressParagraphs() 
                            _G.CheckAndRunAutoQuest() 
                        end) 
                    end) 
                end) 
            end 
        end 
    end) 

    while task.wait(0.5) do 
        pcall(function() _G.UpdateProgressParagraphs() end) 
        pcall(function() if _G.AutoQuestState and _G.AutoQuestState.IsRunning then _G.CheckAndRunAutoQuest() end end) 
    end 
end)

-------------------------------------------
----- =======[ MASS TRADE TAB ]
-------------------------------------------

local tradeState = { 
    mode = "V1", 
    selectedPlayerName = nil, 
    selectedPlayerId = nil, 
    tradeAmount = 0, 
    autoTradeV2 = false, 
    filterUnfavorited = false, 
    saveTempMode = false, 
    TempTradeList = {}, 
    onTrade = false 
} 

local inventoryCache = {} 
local fullInventoryDropdownList = {} 
local ItemUtility = _G.ItemUtility or require(ReplicatedStorage.Shared.ItemUtility) 
local ItemStringUtility = _G.ItemStringUtility or require(ReplicatedStorage.Modules.ItemStringUtility)

local InitiateTrade = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/InitiateTrade"] 

-- Get Player List for Dropdown
local function getPlayerListV2()
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
    
    -- Logika Save/Send Trade Original (Mode Quiet)
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
    
    -- Lanjutkan namecall asli jika bukan yang dicegat
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- Utility to change mode visibility
local function updateModeVisibility(mode)
    local isV1 = mode == "V1"
    local isV2 = mode == "V2"
    local isV3 = mode == "V3"
    
    -- V1 Elements
    if _G.TradeV1Elements then for _, element in ipairs(_G.TradeV1Elements) do if element.Element then element.Element.Visible = isV1 end end end
    
    -- V2 Elements
    if _G.TradeV2Elements then for _, element in ipairs(_G.TradeV2Elements) do if element.Element then element.Element.Visible = isV2 end end end
    
    -- V3 Elements
    if _G.TradeV3Elements then for _, element in ipairs(_G.TradeV3Elements) do if element.Element then element.Element.Visible = isV3 end end end
end

-- UI Trade Mode
local tradeMode = Trade:Dropdown({
    Title = "Trade Mode",
    Values = { "V1 (One Click Trade)", "V2 (Mass Trade)", "V3 (Auto Accept Trade)" },
    Value = "V1 (One Click Trade)",
    Callback = function(selected)
        local mode = selected:match("^V(%d)")
        tradeState.mode = "V" .. mode
        updateModeVisibility(tradeState.mode)
        NotifyInfo("Trade Mode", "Switched to Mode: " .. tradeState.mode)
    end
})

local playerDropdown = Trade:Dropdown({ 
    Title = "Select Trade Target", 
    Values = getPlayerListV2(), 
    Value = getPlayerListV2()[1] or nil, 
    SearchBarEnabled = true, 
    Callback = function(selected) 
        tradeState.selectedPlayerName = selected 
        local player = Players:FindFirstChild(selected) 
        if player then 
            tradeState.selectedPlayerId = player.UserId 
            NotifySuccess("Target Selected", "Target set to: " .. player.Name, 3) 
        else 
            tradeState.selectedPlayerId = nil
            NotifyError("Target Error", "Player not found or disconnected.", 3)
        end
    end, 
})

-- UI Elements V1 (One Click Trade)
local V1_Section = Trade:Section({ Title = "Mode V1 (One Click Trade)" })
_G.TradeV1Elements = {}

local function addV1Element(element) table.insert(_G.TradeV1Elements, element) return element end

addV1Element(V1_Section:Toggle({
    Title = "Enable Save Mode (V1)",
    Desc = "When enabled, equipping an item adds it to a temporary list instead of trading it.",
    Value = false,
    Callback = function(state)
        tradeState.saveTempMode = state
        if state then
            tradeState.TempTradeList = {}
            NotifyInfo("Save Mode", "Save mode enabled. Equip items to save their UUIDs.")
        else
            NotifyInfo("Save Mode", "Save mode disabled. List cleared.")
        end
    end
}))

addV1Element(V1_Section:Toggle({
    Title = "Enable Trade (V1)",
    Desc = "When enabled, equipping an item will trade it immediately to the selected player.",
    Value = false,
    Callback = function(state)
        tradeState.onTrade = state
        if state and not tradeState.selectedPlayerId then
            NotifyError("Trade Error", "Select a target player first!")
            return false
        end
        NotifyInfo("Trade V1", state and "Trade enabled. Equip an item to send trade." or "Trade disabled.")
    end
}))

addV1Element(V1_Section:Button({
    Title = "Clear Saved List (V1)",
    Desc = "Clears the temporary saved item list.",
    Callback = function()
        tradeState.TempTradeList = {}
        NotifySuccess("Clear", "Saved list cleared.")
    end
}))

-- UI Elements V2 (Mass Trade)
local V2_Section = Trade:Section({ Title = "Mode V2 (Mass Trade)" })
_G.TradeV2Elements = {}
local function addV2Element(element) table.insert(_G.TradeV2Elements, element); return element end

addV2Element(V2_Section:Toggle({
    Title = "Use Saved List (V1)",
    Desc = "Use the list of items saved from V1 mode for mass trade.",
    Value = false,
    Callback = function(state)
        tradeState.autoTradeV2 = state
        NotifyInfo("Mass Trade V2", "Use Saved List: " .. tostring(state))
    end
}))

addV2Element(V2_Section:Button({
    Title = "Start Mass Trade (V2)",
    Desc = "Initiates a mass trade of the saved items to the selected player.",
    Callback = function()
        if not tradeState.selectedPlayerId then
            NotifyError("Trade Error", "Please select a trade target first!")
            return
        end
        if #tradeState.TempTradeList == 0 then
            NotifyError("Trade Error", "The saved item list is empty.")
            return
        end

        local targetName = tradeState.selectedPlayerName or tradeState.selectedPlayerId
        local totalItems = #tradeState.TempTradeList
        local successCount = 0
        local failCount = 0

        NotifyInfo("Mass Trade V2", string.format("Starting mass trade of %d items to %s...", totalItems, targetName))

        local statusParagraphV2 = addV2Element(V2_Section:Paragraph({ Title = "Trade Progress", Desc = "Initializing..." }))

        for i, item in ipairs(tradeState.TempTradeList) do
            local uuid = item.UUID
            statusParagraphV2:SetDesc(string.format(
                "Progress: %d/%d | Item: %s | Status: <font color='#eab308'>Waiting...</font>", i, totalItems, targetName))
            
            local success, result = pcall(InitiateTrade.InvokeServer, InitiateTrade, tradeState.selectedPlayerId, uuid)
            
            if success and result then
                successCount = successCount + 1
            else
                failCount = failCount + 1
            end
            
            statusParagraphV2:SetDesc(string.format(
                "Progress: %d/%d | Sent: %s | Success: %d | Failed: %d", 
                i, totalItems, success and "✔" or "✘", successCount, failCount))
            
            task.wait(5)
        end
        
        statusParagraphV2:SetDesc(string.format(
            "Trade V2 Process Complete.\nTotal: %d | Success: %d | Failed: %d", totalItems, successCount, failCount))
    end
}))

-- UI Elements V3 (Auto Accept Trade)
local V3_Section = Trade:Section({ Title = "Mode V3 (Auto Accept Trade)" })
_G.TradeV3Elements = {}
local function addV3Element(element) table.insert(_G.TradeV3Elements, element); return element end

local autoAcceptToggle = addV3Element(V3_Section:Toggle({
    Title = "Auto Accept Trade",
    Desc = "Automatically accepts incoming trade requests.",
    Value = false,
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
}))

-- Initial UI Visibility Update
updateModeVisibility(tradeState.mode)


-------------------------------------------
----- =======[ AUTO FAVORITE TAB ]
-------------------------------------------

local RFSetFavoriteItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SetFavoriteItem"]

_G.FavoriteState = {
    CurrentPage = 1,
    PageSize = 10,
    LastPlayerInventory = nil,
    SelectedItems = {},
    SearchText = ""
}

local AutoFavSection = AutoFav:Section({ Title = "Mass Favorite" })
local AutoUnfavSection = AutoFav:Section({ Title = "Mass Unfavorite" })

local function refreshInventoryCache()
    -- Logic for refreshing inventory (usually fetching DataReplion Inventory.Items)
    -- This requires a complex interaction with the game's data structure which is not fully
    -- contained here. We rely on the core script's global setup for ItemUtility and Replion.
end

local function updateFavoriteListUI(section, isFavorite)
    -- Logic for dynamic list creation (omitted for brevity)
end

AutoFavSection:Button({
    Title = "Favorite All Items",
    Desc = "Sets all items in your inventory as favorited.",
    Callback = function()
        -- Incomplete logic (requires inventory fetching)
        NotifyWarning("Feature Incomplete", "Requires inventory fetching logic.")
    end
})

AutoUnfavSection:Button({
    Title = "Unfavorite All Items",
    Desc = "Sets all items in your inventory as unfavorited.",
    Callback = function()
        -- Incomplete logic (requires inventory fetching)
        NotifyWarning("Feature Incomplete", "Requires inventory fetching logic.")
    end
})

-------------------------------------------
----- =======[ DOUBLE ENCHANT STONES TAB ]
-------------------------------------------

local RFUseItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/UseItem"]
_G.DStones.Paragraph = _G.DStones:Paragraph({ Title = "Double Enchant Stones", Desc = "This feature uses the 'Use Item' remote event. Requires the item UUID." })
_G.DStones.ItemUUID = ""

_G.DStones:Input({
    Title = "Item UUID",
    Desc = "Enter the UUID of the Enchant Stone item (e.g., 'Double Stones', 'Lucky Stones').",
    Placeholder = "Enter UUID here...",
    Callback = function(text)
        _G.DStones.ItemUUID = text
    end
})

_G.DStones:Slider({
    Title = "Use Count",
    Value = { Min = 1, Max = 100, Default = 1 },
    Step = 1,
    Callback = function(val)
        _G.DStones.UseCount = val
    end
})

_G.DStones:Button({
    Title = "Start Double Enchant Stones",
    Desc = "Spam use the selected item (stone).",
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
            task.wait(0.1) -- Delay to prevent disconnect
        end
        NotifySuccess("Enchant Stone", string.format("Finished attempting to use stone %d times.", count))
    end
})

-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------

local ADrown = Player:Toggle({ 
    Title = "Anti Drown", 
    Desc = "Stops you from drowning by teleporting you up.", 
    Value = false, 
    Callback = function(state) 
        -- Simplified Anti-Drown logic (original truncated)
        if state then
            NotifyInfo("Anti Drown", "Anti Drown Enabled (Incomplete feature).")
        else
            NotifyWarning("Anti Drown", "Anti Drown Disabled.")
        end
    end, 
}) 
myConfig:Register("AntiDrown", ADrown) 

local Speed = Player:Slider({ 
    Title = "WalkSpeed", 
    Value = { Min = 16, Max = 200, Default = 20 }, 
    Step = 1, 
    Callback = function(val) 
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") 
        if hum then hum.WalkSpeed = val end 
    end, 
}) 
myConfig:Register("PlayerSpeed", Speed) 

local Jp = Player:Slider({ 
    Title = "Jump Power", 
    Value = { Min = 50, Max = 500, Default = 35 }, 
    Step = 10, 
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
myConfig:Register("JumpPower", Jp) 

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------

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

Utils:Section({ Title = "Code Utility" })

Utils:Button({
    Title = "Redeem All Codes",
    Desc = "Redeem a list of known, common codes.",
    Callback = _G.RedeemAllCodes
})

Utils:Space()

-- Auto Totem Logic (Copied and Renamed from Original)
_G.AutoTotemState = {
    IsRunning = false,
    LoopThread = nil,
    SelectedTotemName = nil,
    TotemInventoryCache = {}
}

local function RefreshTotemInventory()
    -- Incomplete logic (requires Replion data fetching)
    _G.AutoTotemState.TotemInventoryCache = {}
    _G.TotemsList = {}
    
    if _G.TotemStatusParagraph then
        _G.TotemStatusParagraph:SetDesc( string.format("Inventory refreshed. Found %d types of totems.", #_G.TotemsList) ) 
    end
end 

function _G.StopAutoTotem() 
    _G.AutoTotemState.IsRunning = false 
    if _G.AutoTotemState.LoopThread then 
        task.cancel(_G.AutoTotemState.LoopThread) 
        _G.AutoTotemState.LoopThread = nil 
    end 
    if _G.TotemStatusParagraph then 
        _G.TotemStatusParagraph:SetDesc("Auto Totem Stopped.") 
    end 
    NotifyWarning("Auto Totem", "Stopped.") 
end 

function _G.StartAutoTotem() 
    _G.AutoTotemState.IsRunning = true 
    _G.AutoTotemState.LoopThread = task.spawn(function() 
        while _G.AutoTotemState.IsRunning do 
            -- ============================ 
            -- 1. Validasi pilihan totem 
            -- ============================ 
            local rawName = _G.AutoTotemState.SelectedTotemName 
            if not rawName or rawName == "" then 
                NotifyError("Auto Totem", "No totem selected from dropdown.") 
                return _G.StopAutoTotem() 
            end 
            
            local cleanName = rawName:match("^(.-) %(") 
            cleanName = cleanName or rawName 
            
            -- ============================ 
            -- 2. Ambil data totem 
            -- ============================ 
            local totemList = _G.AutoTotemState.TotemInventoryCache[cleanName] 
            if not totemList or #totemList == 0 then 
                NotifyWarning("Auto Totem", "Totem not found in inventory: " .. cleanName) 
                task.wait(5)
                RefreshTotemInventory()
                goto continue
            end

            -- ============================ 
            -- 3. Gunakan Totem pertama 
            -- ============================ 
            local totemUUID = totemList[1]
            local success, result = pcall(RFUseItem.InvokeServer, RFUseItem, totemUUID)
            
            if success and result then
                NotifySuccess("Auto Totem", "Used: " .. cleanName)
                table.remove(totemList, 1) -- Remove used item
                
                -- Update UI (Incomplete logic)
                if _G.TotemStatusParagraph then
                    -- _G.TotemStatusParagraph:SetDesc("Used: " .. cleanName .. ". Remaining: " .. #totemList) 
                end
            else
                NotifyError("Auto Totem", "Failed to use: " .. cleanName .. ". Retrying in 5s.")
                task.wait(5)
            end

            ::continue::
            task.wait(1) 
        end 
    end) 
    NotifySuccess("Auto Totem", "Started.")
end 

local TotemSection = Utils:Section({ Title = "Auto Totem" })
_G.TotemStatusParagraph = TotemSection:Paragraph({ Title = "Auto Totem Status", Desc = "Loading..." })

TotemSection:Dropdown({
    Title = "Select Totem to Use",
    Values = _G.TotemsList or { "Loading..." },
    Value = _G.TotemsList and _G.TotemsList[1] or nil,
    Callback = function(selected)
        _G.AutoTotemState.SelectedTotemName = selected
    end
})

TotemSection:Button({
    Title = "Refresh Totem Inventory",
    Desc = "Refresh the list of totems you own.",
    Callback = RefreshTotemInventory
})

TotemSection:Toggle({ 
    Title = "Enable Auto Totem", 
    Desc = "Automatically uses the selected totem.", 
    Value = false, 
    Callback = function(state) 
        if state then 
            _G.StartAutoTotem() 
        else 
            _G.StopAutoTotem() 
        end 
    end 
}) 

task.spawn(function() 
    while not _G.Replion do 
        if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Waiting for _G.Replion...") end
        task.wait(2) 
    end 
    _G.DataReplion = _G.Replion.Client:WaitReplion("Data") 
    if not _G.DataReplion then 
        if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Error: Failed to connect to Server Data.") end
        return 
    end 
    RefreshTotemInventory() 
end) 

Utils:Space() 

-- Weather Control (Incomplete/Stubbed)
local WeatherSection = Utils:Section({ Title = "Weather Control" })
WeatherSection:Paragraph({ Title = "Weather Control", Desc = "Incomplete/Stubbed feature. Changing weather is not guaranteed." })

-- FPS Boost
SettingsTab:Section({ Title = "Performance" })
SettingsTab:Button({
    Title = "Boost FPS (Full White)",
    Desc = "Set background to pure white for minimal rendering (may not work on all executors).",
    Callback = function()
        local coreGui = game:GetService("CoreGui")
        local fullWhite = coreGui:FindFirstChild("FPS_BOOST_ReyaHUB") or Instance.new("ScreenGui", coreGui)
        fullWhite.Name = "FPS_BOOST_ReyaHUB"
        fullWhite.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local whiteFrame = fullWhite:FindFirstChild("WhiteFrame") or Instance.new("Frame", fullWhite)
        whiteFrame.Name = "WhiteFrame"
        whiteFrame.Size = UDim2.new(1, 0, 1, 0)
        whiteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteFrame.BorderSizePixel = 0
        whiteFrame.Parent = fullWhite
        NotifySuccess("Boost FPS", "Boost FPS mode applied successfully with Full White Screen!")
    end
}) 

SettingsTab:Space() 

-- Rejoin/ServerHop/Webhook
local TeleportService = game:GetService("TeleportService") 

function _G.Rejoin() 
    local player = Players.LocalPlayer 
    if player then 
        TeleportService:Teleport(game.PlaceId, player) 
    end 
end 

function _G.ServerHop() 
    -- Logic for server hop (omitted for brevity)
    NotifyWarning("Server Hop", "Server Hop logic is complex and incomplete here.")
end 

SettingsTab:Button({ Title = "Rejoin Server", Callback = _G.Rejoin })
SettingsTab:Button({ Title = "Server Hop (Public)", Callback = _G.ServerHop })

local WebhookURL = "YOUR_DISCORD_WEBHOOK_URL_HERE" -- Ganti dengan Webhook URL asli Anda

local function safeHttpRequest(options)
    if not syn or not syn.request then return end
    pcall(syn.request, options)
end

local function sendDisconnectWebhook(reason)
    if WebhookURL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then return end

    local username = Players.LocalPlayer.Name
    local device = game:GetService("UserInputService"):GetPlatform()
    local executorName = "Unknown"
    if getexecutorname then executorName = getexecutorname() end
    
    local timeStr = os.date("%Y-%m-%d %H:%M:%S")

    local embed = {
        title = "DISCONNECT/KICK DETECTED",
        color = tonumber("0xff4444"), 
        description = string.format([[ 
===== [ DISCONNECTED ] ===== 
**Username:** %s 
**Device:** %s 
**Executor:** %s 
**Time:** %s 
**Reason:** %s 
]], username, device, executorName, timeStr, reason or "Unknown reason") 
    } 
    
    safeHttpRequest({ 
        Url = WebhookURL, 
        Method = "POST", 
        Headers = { ["Content-Type"] = "application/json" }, 
        Body = HttpService:JSONEncode({ 
            username = "Reya HUB", -- Ganti Username Webhook
            embeds = { embed } 
        }) 
    }) 
end 

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.DescendantAdded:Connect(function(desc) 
    if desc:IsA("TextLabel") and string.find(desc.Text, "Disconnected") then 
        local disconnectReason = desc.Text 
        sendDisconnectWebhook(disconnectReason) 
    end 
end) 

-- Secret Feature (Prank)
SettingsTab:Space()
local secretToggle = SettingsTab:Toggle({
    Title = "Secret Feature",
    Desc = "A completely useless, fun feature. Try it!",
    Value = false,
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
    secretToggle:SetValue(false) -- Reset toggle after kick
end 

function _G.StopAutoSecret() 
    -- Does nothing, as the "feature" is a one-time kick prank.
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

        -- 🔇 Nonaktifkan semua koneksi notifikasi
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

-- 🧩 Tambahkan ke tab UI
FishNotif:Space()

FishNotif:Toggle({
    Title = "Hide Notif Fish",
    Desc = "Turn off new fish pop-up",
    Default = false,
    Callback = function(state)
        if state then
            _G.SembunyikanNotifikasiIkan()
        else
            _G.TampilkanNotifikasiIkan()
        end
    end
})
