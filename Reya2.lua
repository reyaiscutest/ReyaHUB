local Version = "1.6.53"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" ..
Version .. "/main.lua"))()

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
        _G.Title.Text = "ReyaHUB"

     
    -- efek neon/glow
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 2
        uiStroke.Color = Color3.fromRGB(255, 20, 147) -- DeepPink
        uiStroke.Parent = _G.Title

        -- daftar warna buat gradasi neon (nuansa pink)
        local colors = {
            Color3.fromRGB(255, 20, 147), -- DeepPink
       
        Color3.fromRGB(255, 105, 180), -- HotPink
            Color3.fromRGB(255, 0, 255), -- Fuchsia
            Color3.fromRGB(255, 192, 203), -- Pink Muda
            Color3.fromRGB(139, 0, 139)  -- DarkMagenta
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
        Icon = "circle-check",
        Color = Color3.fromHex("#FF69B4") -- Hot Pink untuk Success
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "ban",
        Color = Color3.fromHex("#8B008B") -- Dark Magenta untuk Error
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
   
       Content = message,
        Duration = duration,
        Icon = "info",
        Color = Color3.fromHex("#FF1493") -- Deep Pink untuk Info
    })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "triangle-alert",
        Color = Color3.fromHex("#FFC0CB") -- Light Pink untuk Warning
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
            CheckData.kicked 
 = true
            LocalPlayer:Kick("ReyaHUB Update,Rejoin Ulang Dan Execute Lagi!.")
        end
    elseif response == "LATEST" then
        if not CheckData.notified then
            CheckData.notified = true
            warn("[ReyaHUB] Status: Latest version")
        end
    else
        warn("[ReyaHUB] Status unknown:", response)
   
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
    Title = "ReyaHUB",
    Icon = "crown",
    Content = [[
Thank you for using ReyaHUB.
Don't forget Subscribe ReyaHUB Channel!
]],
    Buttons = {
        { Title = "Start Script",  Variant = "Primary",   Callback = function() confirmed = true end },
    }
})

repeat task.wait() until confirmed


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------

-- Tema Pink Gelap Baru
WindUI:AddTheme({
    Name = "Reya Pink", -- Tema baru: Pink Gelap/Deep Pink
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF1493"), Transparency = 0 },  -- Deep Pink
        ["50"]  = { Color = Color3.fromHex("#FF69B4"), Transparency = 0 },  -- Hot Pink
        ["100"] = { Color = Color3.fromHex("#FFC0CB"), Transparency = 0 },  -- Light Pink
    }, {
        Rotation = 45,
    }),

    Dialog = Color3.fromHex("#1F001F"),         -- Latar gelap ungu/hitam
    Outline = Color3.fromHex("#FF1493"),        -- Deep Pink
    Text = Color3.fromHex("#FFFFFF"),           -- Teks Putih
    Placeholder = Color3.fromHex("#C7A3C7"),    -- Placeholder Pink Muda
    Background = Color3.fromHex("#0A000A"),     -- Latar Belakang Sangat Gelap
    Button = Color3.fromHex("#8B008B"),         -- Tombol Dark Magenta/Pink Gelap
    Icon = Color3.fromHex("#FF69B4")            -- Ikon Hot Pink
})
WindUI.TransparencyValue = 0.3

local Window = WindUI:CreateWindow({
    Title = "ReyaHUB",
    Icon = "crown",
    Author = "Fishit |
 Escobar",
    Folder = "ReyaHUB",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Reya Pink", -- Menggunakan tema Pink Gelap yang baru
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
    Title = "ReyaHUB",
   
  Icon = "bolt", -- Mengganti ikon menjadi bolt (kilat/kecepatan)
    CornerRadius = UDim.new(0,30),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#FF1493")), -- Deep Pink
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#FF69B4")), -- Hot Pink
        ColorSequenceKeypoint.new(1, Color3.fromHex("#FFC0CB")) -- Light Pink
    }),
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("ReyaXConfig")

WindUI:SetNotificationLower(true)

WindUI:Notify({
    Title = "ReyaHUB",
    Content = "All Features Loaded!",
    Duration = 5,
    Image = "sparkles" -- Mengganti ikon notifikasi menjadi sparkles
})

-------------------------------------------
----- =======[ ALL TAB 
 ]
-------------------------------------------

local Home = Window:Tab({
    Title = "Developer Info",
    Icon = "code" -- Ikon baru: code
})

_G.ServerPage = Window:Tab({
    Title = "Server List",
    Icon = "satellite" -- Ikon baru: satellite
})

local AllMenu = Window:Section({
    Title = "All Menu Here",
    Icon = "layers-3", -- Ikon baru: layers-3
    Opened = false,
})

local AutoFish = AllMenu:Tab({
    Title = "Menu Fishing",
    Icon = "fishing-rod" -- Ikon baru: fishing-rod
})

local AutoFarmTab = AllMenu:Tab({
    Title = "Menu Farming",
    Icon = "shovel" -- Ikon baru: shovel
})

_G.AutoQuestTab = AllMenu:Tab({
    Title = "Auto Quest",
    Icon 
 = "list-checks" -- Ikon baru: list-checks
})

local AutoFav = AllMenu:Tab({
    Title = "Auto Favorite",
    Icon = "gem" -- Ikon baru: gem
})

local Trade = AllMenu:Tab({
    Title = "Trade",
    Icon = "replace" -- Ikon baru: replace
})

_G.DStones = AllMenu:Tab({
    Title = "Double Enchant Stones",
    Icon = "shield-half" -- Ikon baru: shield-half
})

local Player = AllMenu:Tab({
    Title = "Player",
    Icon = "user-gear" -- Ikon baru: user-gear
})

local Utils = AllMenu:Tab({
    Title = "Utility",
    Icon = "wrench" -- Ikon baru: wrench
})

local FishNotif = AllMenu:Tab({
    Title = "Fish Notification",
    Icon = "bell-dot" -- Ikon baru: bell-dot
})

local SettingsTab = AllMenu:Tab({
   
  Title = "Settings",
    Icon = "settings-2" -- Ikon baru: settings-2
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
	Title = "ReyaHUB",
	Color = "Grey",
	Desc = [[
This is a script created by Escobar!.
 YouTube Channel = ReyaHUB
use the script wisely.
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

-- Kode invite Discord (Silakan ubah "reyahub" jika kode invite Anda berbeda)
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
                    Text = "Tempel di 
 browser buat join server.",
                    Duration = 5
                })
            end
        end
    })
else
    warn("Invite tidak valid.")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Invite Discord Invalid",
        Text = "Cek ulang 
 kode invite lu!",
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
    Icon = "satellite", -- Ikon Konsisten
    Callback = function()
        if _G.ServersShown then return end
        _G.ServersShown = true

        for _, server in ipairs(_G.ServerList.data) do
 
            _G.playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
            _G.ping = server.ping
            _G.id = server.id

            local buttonServer = _G.ServerListAll:Button({
                Title = "Server",
                Desc = "Player: " .. tostring(_G.playerCount) .. "\nPing: 
 " .. tostring(_G.ping),
                Locked = false,
                Icon = "server", -- Ikon Server
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
_G.lastRecastTime 
 = 0
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
end

local function isColor(r, g, b, R, G, B)
    return approx(r, R) and approx(g, G) and approx(b, B)
end

local BAD_COLORS = {
    COMMON    = {1,       0.980392, 0.964706},
    UNCOMMON  = {0.764706, 1,       
  0.333333},
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
        local colorValue 
 = data.TextData.TextColor
        local r, g, b
    
        if typeof(colorValue) == "Color3" then
            r, g, b = colorValue.R, colorValue.G, colorValue.B
        elseif typeof(colorValue) == "ColorSequence" and #colorValue.Keypoints > 0 then
            local c = colorValue.Keypoints[1].Value
            r, g, b = c.R, c.G, c.B
     
    end
    
        if not (r and g and b) then return end
    
        local isBadFish = false
    
        for _, col in pairs(BAD_COLORS) do
            if isColor(r, g, b, col[1], col[2], col[3]) then
                isBadFish = true
       
          break
            end
        end
    
        if isBadFish then
            _G.StopFishing()
            _G.RecastSpam()
        else
            _G.startSpam()
        end
    else
 
        _G.startSpam()
    end
end)



_G.REFishCaught.OnClientEvent:Connect(function(fishName, info)
    if FuncAutoFish.autofish5x then
        _G.stopSpam()
        _G.lastFishTime = tick()
        _G.RecastSpam()
    end
end)

task.spawn(function()
	while task.wait(1) do
		if _G.AntiStuckEnabled and FuncAutoFish.autofish5x and not _G.AutoFishHighQuality then
			if tick() - _G.lastFishTime > tonumber(_G.STUCK_TIMEOUT) then
				StopAutoFish5X()
				task.wait(0.5)
				StartAutoFish5X()
				_G.lastFishTime = tick()
			end
		end
	end
end)


function StartAutoFish5X()
    _G.equipRemote:FireServer(1)
    FuncAutoFish.autofish5x = true
    _G.AntiStuckEnabled = true
    lastEventTime = tick()
    _G.lastFishTime = tick()
    task.wait(0.5)
  
  InitialCast5X()
end


function StopAutoFish5X()
    FuncAutoFish.autofish5x = false
    _G.AntiStuckEnabled = false
    _G.StopFishing()
    _G.isRecasting5x = false
    _G.stopSpam()
    _G.StopRecastSpam()
}


--[[

INI AUTO FISH LEGIT 

]]


_G.RunService = game:GetService("RunService")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.FishingControllerPath = _G.ReplicatedStorage.Controllers.FishingController
_G.FishingController = require(_G.FishingControllerPath)

_G.AutoFishingControllerPath = _G.ReplicatedStorage.Controllers.AutoFishingController
_G.AutoFishingController = require(_G.AutoFishingControllerPath)
_G.Replion = require(_G.ReplicatedStorage.Packages.Replion)

_G.AutoFishState = {
    IsActive = false,
    MinigameActive = false
}

_G.SPEED_LEGIT = 0.5

function _G.performClick()
    _G.FishingController:RequestFishingMinigameClick()
    task.wait(tonumber(_G.SPEED_LEGIT))
}

_G.originalAutoFishingStateChanged = _G.AutoFishingController.AutoFishingStateChanged
function _G.forceActiveVisual(arg1)
    _G.originalAutoFishingStateChanged(true)
}

_G.AutoFishingController.AutoFishingStateChanged = _G.forceActiveVisual

function _G.ensureServerAutoFishingOn()
    local replionData = _G.Replion.Client:WaitReplion("Data")
    local currentAutoFishingState = 
 replionData:GetExpect("AutoFishing")

    if not currentAutoFishingState then
        local remoteFunctionName = "UpdateAutoFishingState"
        local Net = require(_G.ReplicatedStorage.Packages.Net)
        local UpdateAutoFishingRemote = Net:RemoteFunction(remoteFunctionName)

        local success, result = pcall(function()
            return UpdateAutoFishingRemote:InvokeServer(true)
        end)

        if success then
        else
        end
 
    else
    end
end

-- ===================================================================
-- BAGIAN 2: AUTO CLICK MINIGAME
-- ===================================================================

_G.originalRodStarted = _G.FishingController.FishingRodStarted
_G.originalFishingStopped = _G.FishingController.FishingStopped
_G.clickThread = nil

_G.FishingController.FishingRodStarted = function(self, arg1, arg2)
    _G.originalRodStarted(self, arg1, arg2)

    if _G.AutoFishState.IsActive and not _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = true

        if _G.clickThread then
            task.cancel(_G.clickThread)
        end

        _G.clickThread = task.spawn(function()
           
  while _G.AutoFishState.IsActive and _G.AutoFishState.MinigameActive do
                _G.performClick()
            end
        end)
    end
end

_G.FishingController.FishingStopped = function(self, arg1)
    _G.originalFishingStopped(self, arg1)

    if _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = false
        task.wait(1)
        _G.ensureServerAutoFishingOn()
    end
end

function _G.ToggleAutoClick(shouldActivate)
    _G.AutoFishState.IsActive = shouldActivate

    
 if shouldActivate then
        _G.ensureServerAutoFishingOn()
    else
        if _G.clickThread then
            task.cancel(_G.clickThread)
            _G.clickThread = nil
        end
        _G.AutoFishState.MinigameActive = false
    end
end

_G.FishAdvenc = AutoFish:Section({
    Title = "Adcenced Settings",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.FishSec 
 = AutoFish:Section({
    Title = "Auto Fishing Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.DelayFinish = _G.FishAdvenc:Input({
    Title = "Delay Finish",
    Desc = [[
High Rod = 1
Medium Rod = 1.5 - 1.7
Low Rod = 2 - 3
]],
    Value = _G.FINISH_DELAY,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        fDelays = tonumber(input)
        if 
 not fDelays then
            NotifyWarning("Please Input Valid Number")
        end
        _G.FINISH_DELAY = fDelays
    end
})

myConfig:Register("DelayFinish", _G.DelayFinish)

_G.StuckDelay = _G.FishAdvenc:Input({
    Title = "Anti Stuck Delay",
    Desc = "Cooldown for anti stuck Auto Fish",
    Value = _G.STUCK_TIMEOUT,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        stuck = tonumber(input)
        if not stuck then
            NotifyWarning("Please Input Valid Number")
        end
        _G.STUCK_TIMEOUT = stuck
    end
})

myConfig:Register("StuckDelay", _G.StuckDelay)


_G.FishAdvenc:Space()

_G.CastTimeOut = _G.FishAdvenc:Input({
    Title = "Cast Timeout (Auto Recast)",
    Desc = "Delay before perfect cast is sent. (Lower is Faster)",
    Value = _G.CastTimeoutValue,
    Type = "Input",
    Placeholder = "Input Cast Timeout..",
    Callback = function(input)
        timeout = tonumber(input)
        if not timeout then
            NotifyWarning("Please Input Valid Number")
        end
        _G.CastTimeoutValue = timeout
    end
})

myConfig:Register("CastTimeOut", _G.CastTimeOut)

_G.FishSec:Toggle({
    Title = "Auto Fish 5x",
    Desc = "Automatically casts and reels in the rod. (Fastest Method)",
    Default = false,
    Callback = function(state)
        if state then
            StartAutoFish5X()
            NotifySuccess("Auto Fish 5x", "Auto Fish 5x Activated!", 3)
        else
            StopAutoFish5X()
            NotifyError("Auto Fish 5x", "Auto Fish 5x Disabled!", 3)
        end
    end
})

_G.FishSec:Toggle({
    Title = "Anti Stuck",
    Desc = "Automatically recasts after a delay if no fish is caught.",
    Default = true,
    Callback = function(state)
        _G.AntiStuckEnabled = state
        if state then
            NotifySuccess("Anti Stuck", "Anti Stuck Activated!", 3)
        else
            NotifyError("Anti Stuck", "Anti Stuck Disabled!", 3)
        end
    end
})

_G.FishSec:Toggle({
    Title = "High Quality Fish Only",
    Desc = "Automatically cancels fishing for common/uncommon/rare fish.",
    Default = false,
    Callback = function(state)
        _G.AutoFishHighQuality = state
        if state then
            NotifySuccess("High Quality Fish Only", "High Quality Fish Filter Activated!", 3)
            if FuncAutoFish.autofish5x then
                StopAutoFish5X()
                task.wait(0.5)
                StartAutoFish5X()
            end
        else
            NotifyError("High Quality Fish Only", "High Quality Fish Filter Disabled!", 3)
        end
    end
})

_G.FishSec:Toggle({
    Title = "Auto Fish Legit",
    Desc = "Automatically clicks the fishing mini-game. (Slower but Safer)",
    Default = false,
    Callback = function(state)
        _G.ToggleAutoClick(state)
        if state then
            NotifySuccess("Auto Fish Legit", "Auto Click Minigame Activated!", 3)
            -- memastikan 5x mati jika legit nyala
            if FuncAutoFish.autofish5x then
                StopAutoFish5X()
            end
        else
            NotifyError("Auto Fish Legit", "Auto Click Minigame Disabled!", 3)
        end
    end
})

_G.FishSec:Space()
_G.SellSetting = _G.FishSec:Section({
    Title = "Auto Sell Fish",
    Opened = false,
})

_G.Threshold = _G.SellSetting:Input({
    Title = "Sell Threshold",
    Desc = "Sell all fish when this number of fish are caught.",
    Value = _G.sellThreshold,
    Type = "Input",
    Placeholder = "Input Sell Threshold..",
    Callback = function(input)
        threshold = tonumber(input)
        if not threshold or threshold < 1 then
            NotifyWarning("Please Input Valid Number (>0)", 3)
            return
        end
        _G.sellThreshold = threshold
    end
})
myConfig:Register("Threshold", _G.Threshold)

_G.SellSetting:Toggle({
    Title = "Auto Sell",
    Desc = "Automatically sells all fish after catching the threshold amount.",
    Default = false,
    Callback = function(state)
        _G.sellActive = state
        if state then
            NotifySuccess("Auto Sell", "Auto Sell Activated!", 3)
        else
            NotifyError("Auto Sell", "Auto Sell Disabled!", 3)
        end
    end
})

_G.SellSetting:Button({
    Title = "Sell Now",
    Desc = "Manually sell all fish in your inventory.",
    Icon = "store",
    Callback = function()
        _G.TrySellNow()
        NotifyInfo("Sell Now", "All items sold!", 3)
    end
})

-------------------------------------------
----- =======[ AUTO FARM TAB ]
-------------------------------------------

_G.AutoFarmSetting = AutoFarmTab:Section({
    Title = "Auto Farm Setting",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})


-------------------------------------------
----- =======[ AUTO QUEST TAB ]
-------------------------------------------

_G.AutoQuestTab:Section({
    Title = "Auto Quest Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

-------------------------------------------
----- =======[ AUTO FAVORITE TAB ]
-------------------------------------------

AutoFav:Section({
    Title = "Auto Favorite Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

-------------------------------------------
----- =======[ TRADE TAB ]
-------------------------------------------

Trade:Section({
    Title = "Trade Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

-------------------------------------------
----- =======[ DOUBLE STONES TAB ]
-------------------------------------------

_G.DStones:Section({
    Title = "Double Enchant Stones Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------

Player:Section({
    Title = "Player Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------

Utils:Section({
    Title = "Utility Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

-------------------------------------------
----- =======[ FISH NOTIF TAB ]
-------------------------------------------

FishNotif:Section({
    Title = "Fish Notification Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})


-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------

SettingsTab:Section({
    Title = "UI Settings",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

SettingsTab:Slider({
    Title = "UI Opacity",
    Desc = "Adjusts the transparency of the entire user interface.",
    Value = 30,
    Min = 0,
    Max = 100,
    Decimals = 0,
    Callback = function(value)
        WindUI.TransparencyValue = value / 100
    end,
})

-- Tambahkan fitur Sembunyikan Notifikasi Ikan
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
SettingsTab:Space()

SettingsTab:Toggle({
    Title = "Hide Notif Fish",
    Desc = "Turn off new fish pop-up",
    Default = false,
    Callback = function(state)
        if state then
            _G.SembunyikanNotifikasiIkan()
            NotifySuccess("Hide Notif Fish", "Notifikasi ikan dinonaktifkan!", 3)
        else
            _G.TampilkanNotifikasiIkan()
            NotifyError("Hide Notif Fish", "Notifikasi ikan diaktifkan!", 3)
        end
    end
})

SettingsTab:Space()
SettingsTab:Button({
    Title = "Unload Script",
    Desc = "Hapus semua UI dan fitur dari game.",
    Icon = "trash-2",
    Callback = function()
        WindUI:Destroy()
        NotifyWarning("Unload Script", "Script berhasil di-unload. Silakan rejoin.", 5)
    end,
})
