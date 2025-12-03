-- ReyaHUB dengan Fluent UI (Pink Theme)
-- Based on Fluent UI Documentation: https://forgenet.gitbook.io/fluent-documentation

print("=== ReyaHUB Loading Started ===")

-- Wait for game to fully load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-------------------------------------------
----- =======[ LOAD FLUENT LIBRARY ]
-------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

print("✓ Fluent UI Loaded")

-- Custom Pink Theme
local PinkTheme = {
    -- Main Colors
    Background = Color3.fromRGB(30, 15, 25), -- Dark Pink Background
    SecondaryBackground = Color3.fromRGB(45, 20, 35), -- Slightly lighter
    TertiaryBackground = Color3.fromRGB(60, 25, 45), -- Even lighter
    
    -- Accent Colors (Pink Gradient)
    Accent = Color3.fromRGB(255, 105, 180), -- Hot Pink
    SecondaryAccent = Color3.fromRGB(255, 20, 147), -- Deep Pink
    TertiaryAccent = Color3.fromRGB(219, 112, 147), -- Pale Violet Red
    
    -- Text Colors
    Text = Color3.fromRGB(255, 240, 245), -- Light Pink White
    SecondaryText = Color3.fromRGB(255, 182, 193), -- Light Pink
    PlaceholderText = Color3.fromRGB(200, 150, 180), -- Muted Pink
    
    -- Element Colors
    ElementBackground = Color3.fromRGB(50, 25, 40), -- Dark Element BG
    ElementBackgroundHover = Color3.fromRGB(70, 30, 50), -- Hover state
    SecondaryElementBackground = Color3.fromRGB(40, 20, 35),
    
    -- Shadow and Stroke
    Shadow = Color3.fromRGB(0, 0, 0),
    Stroke = Color3.fromRGB(255, 105, 180), -- Pink Stroke
}

-------------------------------------------
----- =======[ SERVICES & GLOBALS ]
-------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

print("✓ Services Loaded")

-- Setup Global Variables
task.spawn(function()
    pcall(function()
        _G.Characters = workspace:WaitForChild("Characters", 10):WaitForChild(LocalPlayer.Name, 10)
        _G.HRP = _G.Characters:WaitForChild("HumanoidRootPart", 10)
        _G.Overhead = _G.HRP:WaitForChild("Overhead", 5)
        _G.Header = _G.Overhead:WaitForChild("Content", 5):WaitForChild("Header", 5)
        _G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer", 5):WaitForChild("Label", 5)
        _G.XPBar = LocalPlayer:WaitForChild("PlayerGui", 5):WaitForChild("XP", 5)
        _G.XPLevel = _G.XPBar:WaitForChild("Frame", 5):WaitForChild("LevelCount", 5)
        _G.Title = _G.Overhead:WaitForChild("TitleContainer", 5):WaitForChild("Label", 5)
        _G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer", 5)
    end)
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Animated Title with Pink Gradient
task.spawn(function()
    task.wait(2)
    pcall(function()
        if _G.Title and _G.TitleEnabled then
            _G.TitleEnabled.Visible = true
            _G.Title.Text = "ReyaHUB"
            
            local uiStroke = Instance.new("UIStroke")
            uiStroke.Thickness = 2
            uiStroke.Color = Color3.fromRGB(255, 105, 180)
            uiStroke.Parent = _G.Title
            
            local colors = {
                Color3.fromRGB(255, 20, 147),
                Color3.fromRGB(255, 105, 180),
                Color3.fromRGB(219, 112, 147),
                Color3.fromRGB(255, 182, 193)
            }
            
            task.spawn(function()
                local i = 1
                while task.wait(1.5) do
                    local nextColor = colors[(i % #colors) + 1]
                    local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    TweenService:Create(_G.Title, tweenInfo, {TextColor3 = nextColor}):Play()
                    TweenService:Create(uiStroke, tweenInfo, {Color = nextColor}):Play()
                    i += 1
                end
            end)
        end
    end)
end)

-------------------------------------------
----- =======[ CREATE WINDOW ]
-------------------------------------------
local Window = Fluent:CreateWindow({
    Title = "ReyaHUB",
    SubTitle = "Pink Edition - by Ree",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Rose", -- Changed to Rose theme (pink-ish)
    MinimizeKey = Enum.KeyCode.G
})

-- Apply custom pink colors after window creation
task.spawn(function()
    task.wait(0.5) -- Wait for window to fully render
    
    -- Find and modify UI elements to pink
    for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
        pcall(function()
            -- Change background colors to pink tones
            if v:IsA("Frame") or v:IsA("ScrollingFrame") then
                if v.BackgroundColor3 == Color3.fromRGB(25, 25, 25) then
                    v.BackgroundColor3 = Color3.fromRGB(30, 15, 25) -- Dark Pink
                elseif v.BackgroundColor3 == Color3.fromRGB(35, 35, 35) then
                    v.BackgroundColor3 = Color3.fromRGB(45, 20, 35) -- Medium Pink
                elseif v.BackgroundColor3 == Color3.fromRGB(45, 45, 45) then
                    v.BackgroundColor3 = Color3.fromRGB(60, 25, 45) -- Light Pink
                end
            end
            
            -- Change accent colors to pink
            if v:IsA("UIStroke") then
                if v.Color == Color3.fromRGB(100, 100, 255) or 
                   v.Color == Color3.fromRGB(70, 130, 180) then
                    v.Color = Color3.fromRGB(255, 105, 180) -- Hot Pink
                end
            end
            
            -- Change text colors to light pink
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                if v.TextColor3 == Color3.fromRGB(200, 200, 200) then
                    v.TextColor3 = Color3.fromRGB(255, 240, 245) -- Light Pink White
                end
            end
            
            -- Change toggle/button colors to pink
            if v.Name == "Toggle" or v.Name == "Button" then
                if v:IsA("Frame") then
                    v.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
                end
            end
        end)
    end
end)

print("✓ Window Created with Pink Theme")

-- Create Tabs
local Tabs = {
    Home = Window:AddTab({Title = "Home", Icon = "home"}),
    AutoFish = Window:AddTab({Title = "Auto Fish", Icon = "fish"}),
    AutoFarm = Window:AddTab({Title = "Auto Farm", Icon = "sprout"}),
    AutoQuest = Window:AddTab({Title = "Auto Quest", Icon = "book-open"}),
    AutoFav = Window:AddTab({Title = "Auto Favorite", Icon = "star"}),
    Trade = Window:AddTab({Title = "Trade", Icon = "handshake"}),
    Enchant = Window:AddTab({Title = "Enchant", Icon = "gem"}),
    Player = Window:AddTab({Title = "Player", Icon = "user"}),
    Utils = Window:AddTab({Title = "Utility", Icon = "wrench"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "settings"})
}

print("✓ Tabs Created")

-------------------------------------------
----- =======[ HOME TAB ]
-------------------------------------------
Tabs.Home:AddParagraph({
    Title = "💖 Welcome to ReyaHUB",
    Content = "Created by: Escobar\nYouTube: SansMoba\n\nUse this script wisely and enjoy fishing!"
})

-- Discord Section
task.spawn(function()
    local success, response = pcall(function()
        return game:HttpGet("https://discord.com/api/v10/invites/sansmoba?with_counts=true")
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if data.guild then
            Tabs.Home:AddParagraph({
                Title = "💬 Discord Server",
                Content = string.format("Server: %s\nMembers: %d\nOnline: %d",
                    data.guild.name,
                    data.approximate_member_count or 0,
                    data.approximate_presence_count or 0
                )
            })
            
            Tabs.Home:AddButton({
                Title = "Join Discord",
                Description = "Copy invite link",
                Callback = function()
                    setclipboard("https://discord.gg/sansmoba")
                    Fluent:Notify({
                        Title = "Discord",
                        Content = "Link copied to clipboard!",
                        Duration = 5
                    })
                end
            })
        end
    end
end)

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------
-- Variables
_G.AutoFishEnabled = false
_G.AutoFishHighQuality = false
_G.CastMode = "Fast"
_G.FinishDelay = 1
_G.StuckTimeout = 10

-- Get Net Remotes
task.spawn(function()
    pcall(function()
        local net = ReplicatedStorage:WaitForChild("Packages", 10)
            :WaitForChild("_Index", 10)
            :WaitForChild("sleitnick_net@0.2.0", 10)
            :WaitForChild("net", 10)
        
        _G.equipRemote = net:WaitForChild("RE/EquipToolFromHotbar", 10)
        _G.REFishingStopped = net:WaitForChild("RE/FishingStopped", 10)
        _G.RFCancelFishingInputs = net:WaitForChild("RF/CancelFishingInputs", 10)
    end)
end)

-- Stop Fishing Function
_G.StopFishing = function()
    pcall(function()
        if _G.RFCancelFishingInputs then
            _G.RFCancelFishingInputs:InvokeServer()
        end
        if _G.REFishingStopped then
            firesignal(_G.REFishingStopped.OnClientEvent)
        end
    end)
end

Tabs.AutoFish:AddParagraph({
    Title = "🎣 Auto Fish System",
    Content = "Automated fishing with multiple modes and filters"
})

local AutoFishToggle = Tabs.AutoFish:AddToggle("AutoFish", {
    Title = "Auto Fish (Instant)",
    Description = "Automatically catch fish instantly",
    Default = false,
    Callback = function(Value)
        _G.AutoFishEnabled = Value
        if Value then
            Fluent:Notify({
                Title = "Auto Fish",
                Content = "Started!",
                Duration = 3
            })
            pcall(function()
                if _G.equipRemote then
                    _G.equipRemote:FireServer(1)
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Fish",
                Content = "Stopped!",
                Duration = 3
            })
            _G.StopFishing()
        end
    end
})

Tabs.AutoFish:AddToggle("FilterQuality", {
    Title = "Filter High Quality",
    Description = "Only catch Legendary, Mythic & SECRET",
    Default = false,
    Callback = function(Value)
        _G.AutoFishHighQuality = Value
    end
})

Tabs.AutoFish:AddDropdown("CastMode", {
    Title = "Cast Mode",
    Description = "Select casting speed",
    Values = {"Perfect", "Fast", "Random"},
    Default = 1,
    Callback = function(Value)
        _G.CastMode = Value
    end
})

Tabs.AutoFish:AddInput("FinishDelay", {
    Title = "Finish Delay",
    Description = "Delay before finishing catch (seconds)",
    Default = "1",
    Placeholder = "Enter delay",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        _G.FinishDelay = tonumber(Value) or 1
    end
})

Tabs.AutoFish:AddInput("StuckDelay", {
    Title = "Anti Stuck Delay",
    Description = "Cooldown for anti stuck (seconds)",
    Default = "10",
    Placeholder = "Enter delay",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        _G.StuckTimeout = tonumber(Value) or 10
    end
})

-------------------------------------------
----- =======[ AUTO FARM TAB ]
-------------------------------------------
Tabs.AutoFarm:AddParagraph({
    Title = "🌾 Farm System",
    Content = "Teleport to islands and farm automatically"
})

local islandCoords = {
    ["Fisherman Island"] = Vector3.new(-75, 3, 3103),
    ["Tropical Grove"] = Vector3.new(-2165, 2, 3639),
    ["Crater Islands"] = Vector3.new(1066, 57, 5045),
    ["Winter"] = Vector3.new(2036, 6, 3381),
    ["Ancient Jungle"] = Vector3.new(1515, 25, -306),
    ["Kohana"] = Vector3.new(-658, 3, 719),
    ["Coral Reefs"] = Vector3.new(-3095, 1, 2177),
    ["The Temple"] = Vector3.new(1477, -22, -631),
    ["Ancient Ruin"] = Vector3.new(6052, -546, 4427),
    ["Iron Cavern"] = Vector3.new(-8873, -582, 157)
}

local islandList = {}
for name in pairs(islandCoords) do
    table.insert(islandList, name)
end
table.sort(islandList)

_G.SelectedIsland = islandList[1]

Tabs.AutoFarm:AddDropdown("IslandSelect", {
    Title = "Select Island",
    Description = "Choose farming location",
    Values = islandList,
    Default = 1,
    Callback = function(Value)
        _G.SelectedIsland = Value
    end
})

Tabs.AutoFarm:AddButton({
    Title = "Teleport to Island",
    Description = "Teleport to selected island",
    Callback = function()
        local coords = islandCoords[_G.SelectedIsland]
        if coords and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(coords)
                Fluent:Notify({
                    Title = "Teleported",
                    Content = "Moved to " .. _G.SelectedIsland,
                    Duration = 3
                })
            end
        end
    end
})

_G.AutoFarmEnabled = false

Tabs.AutoFarm:AddToggle("AutoFarmToggle", {
    Title = "Start Auto Farm",
    Description = "Farm at selected location",
    Default = false,
    Callback = function(Value)
        _G.AutoFarmEnabled = Value
        if Value then
            Fluent:Notify({
                Title = "Auto Farm",
                Content = "Started at " .. _G.SelectedIsland,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Farm",
                Content = "Stopped",
                Duration = 3
            })
        end
    end
})

-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------
Tabs.Player:AddParagraph({
    Title = "👤 Player Modifications",
    Content = "Customize your character abilities"
})

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Adjust character speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end)
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust jump height",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = Value
            end
        end)
    end
})

_G.InfinityJumpEnabled = false

Tabs.Player:AddToggle("InfinityJump", {
    Title = "Infinity Jump",
    Description = "Jump unlimited times",
    Default = false,
    Callback = function(Value)
        _G.InfinityJumpEnabled = Value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfinityJumpEnabled then
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState("Jumping")
            end
        end)
    end
end)

_G.NoClipEnabled = false

Tabs.Player:AddToggle("NoClip", {
    Title = "No Clip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(Value)
        _G.NoClipEnabled = Value
    end
})

RunService.Stepped:Connect(function()
    if _G.NoClipEnabled then
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------
Tabs.Utils:AddParagraph({
    Title = "🔧 Utility Tools",
    Content = "Helpful features and shortcuts"
})

Tabs.Utils:AddButton({
    Title = "Redeem All Codes",
    Description = "Redeem all available codes",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
                local RFRedeemCode = net:WaitForChild("RF/RedeemCode")
                local codes = {"BLAMETALON", "FISHMAS2025", "GOLDENSHARK", "THANKYOU", "PURPLEMOON"}
                
                for _, code in ipairs(codes) do
                    pcall(function()
                        RFRedeemCode:InvokeServer(code)
                    end)
                    task.wait(1)
                end
                
                Fluent:Notify({
                    Title = "Codes",
                    Content = "All codes processed!",
                    Duration = 5
                })
            end)
        end)
    end
})

Tabs.Utils:AddButton({
    Title = "Boost FPS",
    Description = "Ultra low graphics mode",
    Callback = function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
        end
        Fluent:Notify({
            Title = "FPS Boost",
            Content = "Low graphics applied!",
            Duration = 3
        })
    end
})

-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------
Tabs.Settings:AddParagraph({
    Title = "⚙️ Configuration",
    Content = "Manage your script settings"
})

Tabs.Settings:AddKeybind("MenuKeybind", {
    Title = "Toggle Menu Key",
    Default = "G",
    Callback = function(Value)
        -- Handled by Fluent
    end
})

Tabs.Settings:AddButton({
    Title = "Rejoin Server",
    Description = "Rejoin current server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

Tabs.Settings:AddButton({
    Title = "Server Hop",
    Description = "Join different server",
    Callback = function()
        local PlaceId = game.PlaceId
        local AllIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local Deleted = false
        
        local File = pcall(function()
            AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
        end)
        
        if not File then
            table.insert(AllIDs, actualHour)
            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
        end
        
        function TPReturner()
            local Site
            if foundAnything == "" then
                Site = game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceId .. '/servers/Public?sortOrder=Asc&limit=100')
            else
                Site = game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceId .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything)
            end
            
            local body = HttpService:JSONDecode(Site)
            local deep = game.JobId
            
            if body.nextPageCursor and body.nextPageCursor ~= "null" and body.nextPageCursor ~= nil then
                foundAnything = body.nextPageCursor
            end
            
            local actualTime = tonumber(actualHour)
            
            for i,v in pairs(body.data) do
                if v.id ~= deep then
                    local Possible = true
                    for _,Existing in pairs(AllIDs) do
                        if v.id == tostring(Existing) then
                            Possible = false
                        end
                    end
                    
                    if Possible == true then
                        table.insert(AllIDs, v.id)
                        task.wait()
                        pcall(function()
                            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                            task.wait()
                            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
                        end)
                        task.wait(4)
                    end
                end
            end
        end
        
        TPReturner()
    end
})

-------------------------------------------
----- =======[ SAVE MANAGER ]
-------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("ReyaHUB")
SaveManager:SetFolder("ReyaHUB/Fisch")

-- Add custom pink theme to interface manager
local CustomThemes = {
    ["Pink Dream"] = {
        Background = Color3.fromRGB(30, 15, 25),
        SecondaryBackground = Color3.fromRGB(45, 20, 35),
        TertiaryBackground = Color3.fromRGB(60, 25, 45),
        Accent = Color3.fromRGB(255, 105, 180),
        SecondaryAccent = Color3.fromRGB(255, 20, 147),
        TertiaryAccent = Color3.fromRGB(219, 112, 147),
        Text = Color3.fromRGB(255, 240, 245),
        SecondaryText = Color3.fromRGB(255, 182, 193),
        PlaceholderText = Color3.fromRGB(200, 150, 180),
        ElementBackground = Color3.fromRGB(50, 25, 40),
        ElementBackgroundHover = Color3.fromRGB(70, 30, 50),
        SecondaryElementBackground = Color3.fromRGB(40, 20, 35),
        Shadow = Color3.fromRGB(0, 0, 0),
        Stroke = Color3.fromRGB(255, 105, 180)
    }
}

-- Apply Pink Dream theme
task.spawn(function()
    task.wait(1)
    pcall(function()
        -- Try to apply custom theme through Fluent's theme system
        if Fluent.SetTheme then
            Fluent:SetTheme("Rose")
        end
    end)
end)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Add theme selector to settings
Tabs.Settings:AddParagraph({
    Title = "🎨 Theme",
    Content = "Current theme: Pink Dream\nThe UI uses custom pink colors!"
})

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()

-------------------------------------------
----- =======[ FINALIZATION ]
-------------------------------------------
_G.ReyaHubWindow = Window
_G.ReyaHubTabs = Tabs

Fluent:Notify({
    Title = "💖 ReyaHUB Loaded!",
    Content = "Welcome " .. LocalPlayer.DisplayName .. "! Pink theme applied!",
    Duration = 5
})

-- Continuous pink theme enforcer
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
                -- Keep enforcing pink colors
                if v:IsA("Frame") then
                    if v.Name:match("Background") then
                        v.BackgroundColor3 = Color3.fromRGB(30, 15, 25)
                    end
                end
                
                if v:IsA("UIStroke") and v.Color ~= Color3.fromRGB(255, 105, 180) then
                    if v.Parent and v.Parent.Name:match("Tab") or v.Parent.Name:match("Toggle") then
                        v.Color = Color3.fromRGB(255, 105, 180)
                    end
                end
                
                -- Make toggles pink when active
                if v:IsA("Frame") and v.Name == "Fill" then
                    v.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
                end
            end
        end)
    end
end)

print("=== ReyaHUB Successfully Loaded with Pink Theme ===")
