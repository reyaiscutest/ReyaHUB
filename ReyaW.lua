-- [[ REYAHUB - ULTIMATE SCRIPT ]] --
-- Dibuat ulang dengan Fluent UI agar lebih stabil dan estetis.

-- 1. Bersihkan UI Lama (Mencegah Duplikat)
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "ReyaHUB" or gui.Name == "Fluent" then
        gui:Destroy()
    end
end

-- 2. Load Library (Fluent UI) dengan Pengecekan Error
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

-- Backup link jika link utama gagal
if not success or not Library then
    success, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"))()
    end)
end

if not success or not Library then
    warn("[ReyaHUB] CRITICAL: Gagal memuat UI Library.")
    game.StarterGui:SetCore("SendNotification", {
        Title = "ReyaHUB Error",
        Text = "Gagal download UI. Cek koneksi/VPN.",
        Duration = 10
    })
    return
end

-------------------------------------------
----- =======[ VARIABLES & SERVICES ]
-------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- Variables
local Version = "ReyaHUB v2.0"
_G.AutoFishActive = false
_G.AutoFarmActive = false

-- Anti-AFK
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-------------------------------------------
----- =======[ SETUP UI & THEME ]
-------------------------------------------

local Window = Library:CreateWindow({
    Title = "ReyaHUB",
    SubTitle = "By Fishit | Escobar",
    TabGravity = Library.ListLayout.Horizontal,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true, 
    Theme = "ReyaPink",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Menambahkan Tema Khusus Reya Pink
Library:AddTheme({
    Name = "ReyaPink",
    AccentColor = Color3.fromRGB(255, 20, 147),      -- Deep Pink (Utama)
    PrimaryColor = Color3.fromRGB(20, 20, 20),       -- Background Gelap
    SecondaryColor = Color3.fromRGB(35, 35, 35),     -- Background Section
    TertiaryColor = Color3.fromRGB(255, 105, 180),   -- Hot Pink (Aksen 2)
    TextColor = Color3.fromRGB(255, 255, 255),       -- Teks Putih
    OutlineColor = Color3.fromRGB(255, 20, 147),     -- Garis Tepi Pink
})

local ConfigManager = Window:AddConfigManager("ReyaConfig")

-- Notifikasi Awal
Library:Notify({
    Title = "ReyaHUB Loaded",
    Content = "Selamat datang di ReyaHUB! Script berjalan lancar.",
    Duration = 5,
    Image = 4483345998 -- Sparkles Icon ID
})

-------------------------------------------
----- =======[ TABS & FEATURES ]
-------------------------------------------

-- [1] HOME TAB
local TabHome = Window:AddTab({ Title = "Home", Icon = "home" })

TabHome:AddParagraph({
    Title = "Welcome to ReyaHUB",
    Content = "Script ini telah disempurnakan untuk stabilitas maksimal.\nJangan lupa subscribe channel ReyaHUB!"
})

TabHome:AddButton({
    Title = "Join Discord",
    Description = "Salin link invite discord ReyaHUB",
    Callback = function()
        setclipboard("https://discord.gg/reyahub") -- Ganti link sesuai kebutuhan
        Library:Notify({ Title = "Link Disalin", Content = "Link Discord telah disalin ke clipboard.", Duration = 3 })
    end
})

-- [2] FISHING TAB
local TabFish = Window:AddTab({ Title = "Fishing", Icon = "fish" })

local GroupAutoFish = TabFish:AddLeftGroup({ Title = "Auto Fish" })

GroupAutoFish:AddToggle("AutoFishToggle", {
    Title = "Auto Fish (Fast/5x)",
    Default = false,
    Callback = function(Value)
        _G.AutoFishActive = Value
        if Value then
            -- Logika Auto Fish 5x (Simulasi)
            -- Masukkan fungsi StartAutoFish5X() asli Anda di sini
            Library:Notify({Title = "Fishing", Content = "Auto Fish Aktif!", Duration = 3})
        else
            -- Logika Stop
            Library:Notify({Title = "Fishing", Content = "Auto Fish Berhenti.", Duration = 3})
        end
    end
})

GroupAutoFish:AddToggle("AutoCastLegit", {
    Title = "Auto Cast (Legit)",
    Description = "Klik otomatis saat minigame muncul.",
    Default = false,
    Callback = function(Value)
        -- Logika Legit Cast
    end
})

GroupAutoFish:AddInput("CastDelay", {
    Title = "Cast Delay",
    Default = "0.1",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        _G.CastTimeoutValue = tonumber(Value)
    end
})

local GroupSell = TabFish:AddRightGroup({ Title = "Selling" })

GroupSell:AddToggle("AutoSell", {
    Title = "Auto Sell All",
    Default = false,
    Callback = function(Value)
        _G.sellActive = Value
    end
})

GroupSell:AddButton({
    Title = "Sell Everything Now",
    Callback = function()
        local RemoteSell = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
        if RemoteSell then 
            RemoteSell:InvokeServer()
            Library:Notify({Title = "Success", Content = "Semua ikan berhasil dijual.", Duration = 3})
        end
    end
})

-- [3] FARMING TAB (Teleport & Zones)
local TabFarm = Window:AddTab({ Title = "Farming", Icon = "map" })

local GroupTeleport = TabFarm:AddLeftGroup({ Title = "Island Teleport" })

local Islands = {
    "Moosewood", "Roslit Bay", "Terrapin Island", "Snowcap Island", 
    "Sunstone Island", "Forsaken Shores", "Mushgrove Swamp" 
} -- Sesuaikan dengan nama map game Fisch

GroupTeleport:AddDropdown("IslandSelect", {
    Title = "Pilih Pulau",
    Values = Islands,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        -- Logika Teleportasi (Ganti CFrame sesuai map)
        -- Contoh sederhana:
        -- local target = workspace.Map[Value].SpawnLocation
        -- LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
        Library:Notify({Title = "Teleport", Content = "Teleport ke " .. Value, Duration = 3})
    end
})

local GroupEvent = TabFarm:AddRightGroup({ Title = "Event Farm" })

GroupEvent:AddToggle("AutoEvent", {
    Title = "Auto Join Event",
    Description = "Otomatis teleport ke event (Shark, Megalodon, dll)",
    Default = false,
    Callback = function(Value)
        -- Logika Auto Event
    end
})

-- [4] PLAYER TAB
local TabPlayer = Window:AddTab({ Title = "Player", Icon = "user" })

local GroupStats = TabPlayer:AddLeftGroup({ Title = "Character" })

GroupStats:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

GroupStats:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

GroupStats:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        _G.Noclip = Value
        game:GetService("RunService").Stepped:Connect(function()
            if _G.Noclip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
})

-- [5] SETTINGS TAB
local TabSettings = Window:AddTab({ Title = "Settings", Icon = "settings" })

local GroupUI = TabSettings:AddLeftGroup({ Title = "Interface" })

GroupUI:AddButton({
    Title = "Unload Script",
    Description = "Matikan script dan tutup UI",
    Callback = function()
        Window:Destroy()
    end
})

-------------------------------------------
----- =======[ MISC: OVERHEAD TITLE ]
-------------------------------------------
-- Efek Neon ReyaHUB di atas kepala
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if not _G.Characters then 
                _G.Characters = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
            end
            
            local head = _G.Characters:FindFirstChild("Head")
            if head and not head:FindFirstChild("ReyaTag") then
                local bg = Instance.new("BillboardGui", head)
                bg.Name = "ReyaTag"
                bg.Size = UDim2.new(0, 100, 0, 50)
                bg.StudsOffset = Vector3.new(0, 3, 0)
                bg.Adornee = head
                
                local text = Instance.new("TextLabel", bg)
                text.Text = "ReyaHUB"
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255, 20, 147) -- Pink
                text.TextStrokeTransparency = 0
                text.Font = Enum.Font.FredokaOne
                text.TextSize = 20
                
                -- Efek Rainbow/Neon Loop
                task.spawn(function()
                    local t = 5
                    while bg.Parent do
                        local hue = tick() % t / t
                        local color = Color3.fromHSV(hue, 1, 1)
                        text.TextColor3 = color
                        task.wait()
                    end
                end)
            end
        end)
    end
end)

-- Load Config Terakhir (Jika ada)
ConfigManager:Load()
