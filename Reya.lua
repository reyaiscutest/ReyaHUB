-- Reya HUB - Enhanced Stable Version
-- Improved error handling and UI stability

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- Load WindUI with better error handling
local WindUI
local loadAttempts = 0
local maxAttempts = 3

repeat
    loadAttempts = loadAttempts + 1
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    
    if success and result then
        WindUI = result
        break
    else
        warn("WindUI load attempt " .. loadAttempts .. " failed. Retrying...")
        task.wait(1)
    end
until loadAttempts >= maxAttempts

if not WindUI then
    -- Fallback: Create simple notification
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Reya HUB Error",
        Text = "Failed to load WindUI library. Please check your internet connection.",
        Duration = 10
    })
    return
end

-- Module loader with better error handling
local Modules = {}
local function safeRequire(module)
    if not module then return nil end
    
    local success, result = pcall(require, module)
    if success then
        return result
    else
        local clone = module:Clone()
        clone.Parent = nil
        local cloneSuccess, cloneResult = pcall(require, clone)
        if cloneSuccess then
            return cloneResult
        else
            warn("Failed to load module: " .. module:GetFullName())
            return nil
        end
    end
end

-- Initialize game modules (for specific fishing game)
local gameModulesLoaded = false
local success = pcall(function()
    local Controllers = ReplicatedStorage:WaitForChild("Controllers", 10)
    local NetFolder = ReplicatedStorage:WaitForChild("Packages", 10)
        :WaitForChild("_Index", 10)
        :WaitForChild("sleitnick_net@0.2.0", 10)
        :WaitForChild("net", 10)
    local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
    
    if Controllers and NetFolder and Shared then
        Modules.Replion = safeRequire(ReplicatedStorage.Packages.Replion)
        Modules.ItemUtility = safeRequire(Shared.ItemUtility)
        Modules.FishingController = safeRequire(Controllers.FishingController)
        
        Modules.EquipToolEvent = NetFolder["RE/EquipToolFromHotbar"]
        Modules.ChargeRodFunc = NetFolder["RF/ChargeFishingRod"]
        Modules.StartMinigameFunc = NetFolder["RF/RequestFishingMinigameStarted"]
        Modules.CompleteFishingEvent = NetFolder["RE/FishingCompleted"]
        
        gameModulesLoaded = true
    end
end)

if not success then
    warn("Game-specific modules not found. Some features may be disabled.")
end

task.wait(0.5)

-- Custom Reya Theme
WindUI:AddTheme({
    Name = "Reya Dark",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#7C3AED"), Transparency = 0 },
        ["50"]  = { Color = Color3.fromHex("#A78BFA"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#C4B5FD"), Transparency = 0 },
    }, { Rotation = 45 }),
    Dialog = Color3.fromHex("#1E1B4B"),
    Outline = Color3.fromHex("#7C3AED"),
    Text = Color3.fromHex("#F5F3FF"),
    Placeholder = Color3.fromHex("#8B5CF6"),
    Background = Color3.fromHex("#0F0A2E"),
    Button = Color3.fromHex("#6D28D9"),
    Icon = Color3.fromHex("#A78BFA")
})

WindUI.TransparencyValue = 0.3

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Reya HUB",
    Icon = "zap",
    Author = "Fishit | Reya - Enhanced",
    Size = UDim2.fromOffset(600, 400),
    Folder = "ReyaHub",
    Transparent = true,
    Theme = "Reya Dark",
    ToggleKey = Enum.KeyCode.G,
    SideBarWidth = 140
})

if not Window then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Reya HUB Error",
        Text = "Failed to create UI Window.",
        Duration = 10
    })
    return
end

-- Customize open button
Window:EditOpenButton({
    Title = "Reya HUB",
    Icon = "zap",
    CornerRadius = UDim.new(0,30),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#7C3AED")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#A78BFA")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#C4B5FD"))
    }),
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("ReyaHubConfig")

WindUI:SetNotificationLower(true)

-- Welcome popup
local confirmed = false
WindUI:Popup({
    Title = "Reya HUB",
    Icon = "zap",
    Content = [[
Welcome to Reya HUB - Enhanced Version
Features: Auto Fishing, Player Settings, Utilities & More!

Status: ]] .. (gameModulesLoaded and "✓ Game Detected" or "⚠ Universal Mode") .. [[
]],
    Buttons = {
        { 
            Title = "Start", 
            Variant = "Primary", 
            Callback = function() confirmed = true end 
        },
    }
})

repeat task.wait() until confirmed

-- Anti-AFK
if player and VirtualUser then
    player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- Setup character elements (if game supports it)
task.spawn(function()
    if gameModulesLoaded then
        pcall(function()
            _G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(player.Name, 10)
            _G.HRP = _G.Characters:WaitForChild("HumanoidRootPart", 10)
            _G.Overhead = _G.HRP:WaitForChild("Overhead", 10)
            
            if _G.Overhead then
                local titleContainer = _G.Overhead:FindFirstChild("TitleContainer")
                if titleContainer then
                    titleContainer.Visible = true
                    local title = titleContainer:FindFirstChild("Label")
                    if title then
                        title.TextScaled = false
                        title.TextSize = 10
                        title.Text = "Reya HUB"
                        
                        -- Add glowing effect
                        local uiStroke = Instance.new("UIStroke")
                        uiStroke.Thickness = 2
                        uiStroke.Color = Color3.fromRGB(124, 58, 237)
                        uiStroke.Parent = title
                        
                        -- Animate colors
                        task.spawn(function()
                            local colors = {
                                Color3.fromRGB(124, 58, 237),
                                Color3.fromRGB(167, 139, 250),
                                Color3.fromRGB(196, 181, 253),
                            }
                            local i = 1
                            while task.wait(1.5) do
                                if not title or not title.Parent then break end
                                i = (i % #colors) + 1
                                local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                                TweenService:Create(title, tweenInfo, { TextColor3 = colors[i] }):Play()
                                TweenService:Create(uiStroke, tweenInfo, { Color = colors[i] }):Play()
                            end
                        end)
                    end
                end
            end
        end)
    end
end)

-- Auto Reconnect
task.spawn(function()
    Players.LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Failed then
            TeleportService:Teleport(game.PlaceId)
        end
    end)
    
    -- Monitor connection
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(game.PlaceId)
        end
    end
end)

-- Handle disconnect prompts
if getgenv().AutoRejoinConnection then
    getgenv().AutoRejoinConnection:Disconnect()
end

getgenv().AutoRejoinConnection = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    task.wait(0.1)
    if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, player)
    end
end)

-- ================================
-- UI TABS
-- ================================

local Home = Window:Tab({
    Title = "Home",
    Icon = "home"
})

local AllMenu = Window:Section({
    Title = "Features",
    Icon = "layers",
    Opened = false,
})

local AutoFish = AllMenu:Tab({
    Title = "Fishing",
    Icon = "fish"
})

local Player = AllMenu:Tab({
    Title = "Player",
    Icon = "user"
})

local Utils = AllMenu:Tab({
    Title = "Utility",
    Icon = "tool"
})

local SettingsTab = AllMenu:Tab({
    Title = "Settings",
    Icon = "settings"
})

-- ================================
-- HOME TAB
-- ================================

Home:Section({
    Title = "Reya HUB",
    TextSize = 22,
    TextXAlignment = "Center",
})

Home:Paragraph({
    Title = "About",
    Color = "Grey",
    Desc = [[
Enhanced Universal Script Hub
Version: 2.0 Stable

Features:
• Auto Fishing (Game-Specific)
• Player Movement Enhancements
• FPS Booster
• Auto Reconnect
• And More!

Created by Reya Development Team
]]
})

Home:Paragraph({
    Title = "Status",
    Color = gameModulesLoaded and "Green" or "Yellow",
    Desc = gameModulesLoaded and 
        "✓ Game modules loaded successfully\n✓ All features available" or
        "⚠ Running in Universal Mode\n⚠ Some features may be limited"
})

-- ================================
-- AUTO FISHING TAB
-- ================================

if gameModulesLoaded then
    local featureState = {
        AutoFish = false,
        Instant_ChargeDelay = 0.07,
        Instant_SpamCount = 5,
        Instant_WorkerCount = 2,
        Instant_StartDelay = 1.20,
        Instant_CatchTimeout = 0.01,
        Instant_CycleDelay = 0.01,
        Instant_ResetCount = 10,
        Instant_ResetPause = 0.01
    }
    
    local fishingTrove = {}
    local autoFishThread = nil
    local fishCaughtBindable = Instance.new("BindableEvent")
    
    local function equipFishingRod()
        if Modules.EquipToolEvent then
            pcall(Modules.EquipToolEvent.FireServer, Modules.EquipToolEvent, 1)
        end
    end
    
    -- Fish caught detector
    task.spawn(function()
        local lastFishName = ""
        while task.wait(0.25) do
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local notificationGui = playerGui:FindFirstChild("Small Notification")
                if notificationGui and notificationGui.Enabled then
                    local display = notificationGui:FindFirstChild("Display", true)
                    if display then
                        local container = display:FindFirstChild("Container", true)
                        if container then
                            local itemNameLabel = container:FindFirstChild("ItemName")
                            if itemNameLabel and itemNameLabel.Text ~= "" and itemNameLabel.Text ~= lastFishName then
                                lastFishName = itemNameLabel.Text
                                fishCaughtBindable:Fire()
                            end
                        end
                    end
                else
                    lastFishName = ""
                end
            end
        end
    end)
    
    local function stopAutoFishProcesses()
        featureState.AutoFish = false
        
        for _, item in ipairs(fishingTrove) do
            if typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif typeof(item) == "thread" then
                task.cancel(item)
            end
        end
        fishingTrove = {}
        
        pcall(function()
            if Modules.FishingController and Modules.FishingController.RequestClientStopFishing then
                Modules.FishingController:RequestClientStopFishing(true)
            end
        end)
    end
    
    local function startAutoFishMethod()
        if not (Modules.ChargeRodFunc and Modules.StartMinigameFunc and Modules.CompleteFishingEvent) then
            return
        end
        
        featureState.AutoFish = true
        
        local chargeCount = 0
        local isResetting = false
        local counterLock = false
        
        local function worker()
            while featureState.AutoFish and player do
                if isResetting or chargeCount >= featureState.Instant_ResetCount then
                    break
                end
                
                local success = pcall(function()
                    while counterLock do task.wait() end
                    counterLock = true
                    
                    if chargeCount < featureState.Instant_ResetCount then
                        chargeCount = chargeCount + 1
                    else
                        counterLock = false
                        return
                    end
                    counterLock = false
                    
                    Modules.ChargeRodFunc:InvokeServer(nil, nil, nil, workspace:GetServerTimeNow())
                    task.wait(featureState.Instant_ChargeDelay)
                    
                    Modules.StartMinigameFunc:InvokeServer(-139, 1, workspace:GetServerTimeNow())
                    task.wait(featureState.Instant_StartDelay)
                    
                    if not featureState.AutoFish or isResetting then return end
                    
                    for _ = 1, featureState.Instant_SpamCount do
                        if not featureState.AutoFish or isResetting then break end
                        Modules.CompleteFishingEvent:FireServer()
                        task.wait(0.05)
                    end
                    
                    if not featureState.AutoFish or isResetting then return end
                    
                    local gotFish = false
                    local connection
                    local timeout = task.delay(featureState.Instant_CatchTimeout, function()
                        if not gotFish and connection then
                            connection:Disconnect()
                        end
                    end)
                    
                    connection = fishCaughtBindable.Event:Connect(function()
                        if gotFish then return end
                        gotFish = true
                        task.cancel(timeout)
                        if connection then connection:Disconnect() end
                    end)
                    
                    while not gotFish and task.wait() do
                        if not featureState.AutoFish or isResetting then break end
                        if timeout and coroutine.status(timeout) == "dead" then break end
                    end
                    
                    if connection then connection:Disconnect() end
                    
                    if Modules.FishingController then
                        pcall(Modules.FishingController.RequestClientStopFishing, Modules.FishingController, true)
                    end
                    
                    task.wait()
                end)
                
                if not success then task.wait(1) end
                if not featureState.AutoFish then break end
                task.wait(featureState.Instant_CycleDelay)
            end
        end
        
        autoFishThread = task.spawn(function()
            while featureState.AutoFish do
                chargeCount = 0
                isResetting = false
                
                local batchTrove = {}
                
                for i = 1, featureState.Instant_WorkerCount do
                    if not featureState.AutoFish then break end
                    local workerThread = task.spawn(worker)
                    table.insert(batchTrove, workerThread)
                    table.insert(fishingTrove, workerThread)
                end
                
                while featureState.AutoFish and chargeCount < featureState.Instant_ResetCount do
                    task.wait()
                end
                
                isResetting = true
                
                if featureState.AutoFish then
                    for _, thread in ipairs(batchTrove) do
                        task.cancel(thread)
                    end
                    batchTrove = {}
                    task.wait(featureState.Instant_ResetPause)
                end
            end
            stopAutoFishProcesses()
        end)
        
        table.insert(fishingTrove, autoFishThread)
    end
    
    local function startOrStopAutoFish(shouldStart)
        if shouldStart then
            stopAutoFishProcesses()
            featureState.AutoFish = true
            equipFishingRod()
            task.wait(0.1)
            startAutoFishMethod()
        else
            stopAutoFishProcesses()
        end
    end
    
    AutoFish:Section({ Title = "Auto Fishing Settings", Opened = true })
    
    local startDelaySlider = AutoFish:Slider({
        Title = "Recast Delay",
        Desc = "Delay before recasting (Default: 1.20s)",
        Value = { Min = 0.00, Max = 5.0, Default = featureState.Instant_StartDelay },
        Precise = 2,
        Step = 0.01,
        Callback = function(v)
            featureState.Instant_StartDelay = tonumber(v)
        end
    })
    myConfig:Register("Instant_StartDelay", startDelaySlider)
    
    local resetCountSlider = AutoFish:Slider({
        Title = "Spam Finish Count",
        Desc = "Number of finish attempts (Default: 10)",
        Value = { Min = 5, Max = 50, Default = featureState.Instant_ResetCount },
        Precise = 0,
        Step = 1,
        Callback = function(v)
            featureState.Instant_ResetCount = math.floor(tonumber(v) or 10)
        end
    })
    myConfig:Register("Instant_ResetCount", resetCountSlider)
    
    local resetPauseSlider = AutoFish:Slider({
        Title = "Cooldown Between Batches",
        Desc = "Pause time between cycles (Default: 0.01s)",
        Value = { Min = 0.01, Max = 5, Default = featureState.Instant_ResetPause },
        Precise = 2,
        Step = 0.01,
        Callback = function(v)
            featureState.Instant_ResetPause = tonumber(v) or 0.01
        end
    })
    myConfig:Register("Instant_ResetPause", resetPauseSlider)
    
    AutoFish:Section({ Title = "Controls", Opened = true })
    
    local autoFishToggle = AutoFish:Toggle({
        Title = "Enable Auto Fish",
        Desc = "Automatically fish with 5x speed",
        Value = false,
        Callback = startOrStopAutoFish
    })
    myConfig:Register("AutoFish", autoFishToggle)
    
    local stopAnimConnections = {}
    local function setGameAnimationsEnabled(state)
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        for _, conn in pairs(stopAnimConnections) do
            conn:Disconnect()
        end
        stopAnimConnections = {}
        
        if state then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
                
                local conn = animator.AnimationPlayed:Connect(function(track)
                    task.defer(function() track:Stop(0) end)
                end)
                table.insert(stopAnimConnections, conn)
            end
            
            WindUI:Notify({
                Title = "Animations Disabled",
                Content = "All animations stopped",
                Duration = 3,
                Icon = "pause-circle"
            })
        else
            WindUI:Notify({
                Title = "Animations Enabled",
                Content = "Animations restored",
                Duration = 3,
                Icon = "play-circle"
            })
        end
    end
    
    local gameAnimToggle = AutoFish:Toggle({
        Title = "Disable Animations",
        Desc = "Stop fishing animations for better performance",
        Value = false,
        Callback = setGameAnimationsEnabled
    })
    myConfig:Register("DisableGameAnimations", gameAnimToggle)
else
    AutoFish:Paragraph({
        Title = "Not Available",
        Color = "Yellow",
        Desc = "Auto Fishing is only available in supported games. Current game is not supported."
    })
end

-- ================================
-- PLAYER TAB
-- ================================

Player:Section({ Title = "Movement", Opened = true })

local ijump = false

Player:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump indefinitely",
    Value = false,
    Callback = function(val)
        ijump = val
    end,
})

UserInputService.JumpRequest:Connect(function()
    if ijump and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

local Speed = Player:Slider({
    Title = "Walk Speed",
    Desc = "Adjust your walking speed",
    Value = { Min = 16, Max = 200, Default = 20 },
    Step = 1,
    Callback = function(val)
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end,
})
myConfig:Register("PlayerSpeed", Speed)

local Jp = Player:Slider({
    Title = "Jump Power",
    Desc = "Adjust your jump height",
    Value = { Min = 50, Max = 500, Default = 50 },
    Step = 10,
    Callback = function(val)
        local char = player.Character
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

Player:Section({ Title = "Camera", Opened = true })

local defaultMinZoom = player.CameraMinZoomDistance
local defaultMaxZoom = player.CameraMaxZoomDistance

Player:Toggle({
    Title = "Unlimited Zoom",
    Desc = "Remove camera zoom limits",
    Value = false,
    Callback = function(state)
        if state then
            player.CameraMinZoomDistance = 0.5
            player.CameraMaxZoomDistance = 9999
        else
            player.CameraMinZoomDistance = defaultMinZoom
            player.CameraMaxZoomDistance = defaultMaxZoom
        end
    end
})

-- ================================
-- UTILITY TAB
-- ================================

Utils:Section({ Title = "Performance", Opened = true })

Utils:Button({
    Title = "Boost FPS",
    Desc = "Optimize graphics for better performance",
    Icon = "zap",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Trail") then
                v.Lifetime = 0
            elseif v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then
                v.Enabled = false
            elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                v.Enabled = false
            end
        end
        
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        WindUI:Notify({
            Title = "FPS Boost Applied",
            Content = "Graphics optimized successfully",
            Duration = 4,
            Icon = "zap"
        })
    end
})

Utils:Section({ Title = "Other", Opened = true })

Utils:Button({
    Title = "Rejoin Server",
    Desc = "Reconnect to current server",
    Icon = "refresh-cw",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end
})

-- ================================
-- SETTINGS TAB
-- ================================

SettingsTab:Section({ Title = "Keybinds", Opened = true })

local Keybind = SettingsTab:Keybind({
    Title = "Toggle UI",
    Desc = "Key to show/hide the UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})
myConfig:Register("Keybind", Keybind)

SettingsTab:Section({ Title = "Configuration", Opened = true })

SettingsTab:Button({
    Title = "Save Config",
    Desc = "Save current settings",
    Icon = "save",
    Justify = "Center",
    Callback = function()
        myConfig:Save()
        WindUI:Notify({
            Title = "Config Saved",
            Content = "Your settings have been saved",
            Duration = 3,
            Icon = "check-circle"
        })
    end
})

SettingsTab:Button({
    Title = "Load Config",
    Desc = "Load saved settings",
    Icon = "upload",
    Justify = "Center",
    Callback = function()
        myConfig:Load()
        WindUI:Notify({
            Title = "Config Loaded",
            Content = "Your settings have been loaded",
            Duration = 3,
            Icon = "check-circle"
        })
    end
})

SettingsTab:Button({
    Title = "Reset Config",
    Desc = "Reset to default settings",
    Icon = "trash-2",
    Justify = "Center",
    Callback = function()
        WindUI:Popup({
            Title = "Confirm Reset",
            Icon = "alert-triangle",
            Content = "Are you sure you want to reset all settings to default?",
            Buttons = {
                { 
                    Title = "Yes, Reset", 
                    Variant = "Danger", 
                    Callback = function() 
                        myConfig:Delete()
                        WindUI:Notify({
                            Title = "Config Reset",
                            Content = "All settings reset to default. Rejoin to apply.",
                            Duration = 5,
                            Icon = "check-circle"
                        })
                    end 
                },
                { Title = "Cancel", Variant = "Muted" },
            }
        })
    end
})

-- ================================
-- FINALIZE
-- ================================

-- Select home tab
if Window then
    Window:SelectTab(1)
    
    WindUI:Notify({
        Title = "Reya HUB Ready!",
        Content = "All features loaded successfully. Press " .. (Keybind.Value or "G") .. " to toggle UI.",
        Duration = 6,
        Icon = "zap"
    })
end

print("Reya HUB Enhanced - Loaded Successfully!")
print("Version: 2.0 Stable")
print("Game Support: " .. (gameModulesLoaded and "Enabled" or "Universal Mode"))
