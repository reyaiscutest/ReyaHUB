-- Reya HUB - Fluent UI Version
-- More stable UI library with better compatibility

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- Load Fluent UI Library
local Fluent
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not Fluent then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Reya HUB Error",
        Text = "Failed to load UI library. Please try again.",
        Duration = 10
    })
    return
end

-- SaveManager & InterfaceManager
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Module loader with error handling
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
            return nil
        end
    end
end

-- Initialize game modules (for specific fishing game)
local gameModulesLoaded = false
local moduleSuccess = pcall(function()
    local Controllers = ReplicatedStorage:WaitForChild("Controllers", 5)
    local NetFolder = ReplicatedStorage:WaitForChild("Packages", 5)
        :WaitForChild("_Index", 5)
        :WaitForChild("sleitnick_net@0.2.0", 5)
        :WaitForChild("net", 5)
    local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
    
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

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "Reya HUB " .. (gameModulesLoaded and "✓" or "⚠"),
    SubTitle = "by Fishit | Enhanced Version",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.G
})

-- Create Tabs
local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    AutoFish = Window:AddTab({ Title = "Auto Fishing", Icon = "fish" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Utils = Window:AddTab({ Title = "Utilities", Icon = "wrench" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Anti-AFK
if player and VirtualUser then
    player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- Setup character elements
task.spawn(function()
    if gameModulesLoaded then
        pcall(function()
            local chars = workspace:WaitForChild("Characters", 10)
            if chars then
                _G.Characters = chars:WaitForChild(player.Name, 10)
                if _G.Characters then
                    _G.HRP = _G.Characters:WaitForChild("HumanoidRootPart", 10)
                    if _G.HRP then
                        _G.Overhead = _G.HRP:WaitForChild("Overhead", 10)
                        
                        if _G.Overhead then
                            local titleContainer = _G.Overhead:FindFirstChild("TitleContainer")
                            if titleContainer then
                                titleContainer.Visible = true
                                local title = titleContainer:FindFirstChild("Label")
                                if title then
                                    title.Text = "Reya HUB"
                                    title.TextSize = 10
                                    
                                    -- Glowing effect
                                    local uiStroke = Instance.new("UIStroke")
                                    uiStroke.Thickness = 2
                                    uiStroke.Color = Color3.fromRGB(124, 58, 237)
                                    uiStroke.Parent = title
                                    
                                    -- Color animation
                                    task.spawn(function()
                                        local colors = {
                                            Color3.fromRGB(124, 58, 237),
                                            Color3.fromRGB(167, 139, 250),
                                            Color3.fromRGB(196, 181, 253),
                                        }
                                        local i = 1
                                        while title and title.Parent do
                                            task.wait(1.5)
                                            i = (i % #colors) + 1
                                            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad)
                                            TweenService:Create(title, tweenInfo, { TextColor3 = colors[i] }):Play()
                                            TweenService:Create(uiStroke, tweenInfo, { Color = colors[i] }):Play()
                                        end
                                    end)
                                end
                            end
                        end
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
end)

-- Handle disconnect
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
-- HOME TAB
-- ================================

Tabs.Home:AddParagraph({
    Title = "Welcome to Reya HUB",
    Content = "Enhanced script hub with advanced features for your gaming experience.\n\nVersion: 2.0 Stable\nCreated by: Reya Development Team"
})

local statusText = gameModulesLoaded and 
    "✓ Game Detected\n✓ All Features Available\n✓ Auto Fishing: Ready" or
    "⚠ Universal Mode\n⚠ Some features may be limited\n✓ Player Features: Available"

Tabs.Home:AddParagraph({
    Title = "Status",
    Content = statusText
})

Tabs.Home:AddParagraph({
    Title = "Features",
    Content = [[
• Auto Fishing (5x Speed)
• Infinite Jump
• Walk Speed Control
• Jump Power Control
• Unlimited Camera Zoom
• FPS Booster
• Auto Reconnect
• Anti-AFK System
]]
})

Tabs.Home:AddButton({
    Title = "Join Discord",
    Description = "Get support and updates",
    Callback = function()
        Fluent:Notify({
            Title = "Discord",
            Content = "Discord link copied! (If available)",
            Duration = 5
        })
    end
})

-- ================================
-- AUTO FISHING TAB
-- ================================

if gameModulesLoaded then
    local featureState = {
        AutoFish = false,
        ChargeDelay = 0.07,
        SpamCount = 5,
        WorkerCount = 2,
        StartDelay = 1.20,
        CatchTimeout = 0.01,
        CycleDelay = 0.01,
        ResetCount = 10,
        ResetPause = 0.01
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
                local notif = playerGui:FindFirstChild("Small Notification")
                if notif and notif.Enabled then
                    local display = notif:FindFirstChild("Display", true)
                    if display then
                        local container = display:FindFirstChild("Container", true)
                        if container then
                            local itemName = container:FindFirstChild("ItemName")
                            if itemName and itemName.Text ~= "" and itemName.Text ~= lastFishName then
                                lastFishName = itemName.Text
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
    
    local function stopAutoFish()
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
    
    local function startAutoFish()
        if not (Modules.ChargeRodFunc and Modules.StartMinigameFunc and Modules.CompleteFishingEvent) then
            return
        end
        
        featureState.AutoFish = true
        
        local chargeCount = 0
        local isResetting = false
        local counterLock = false
        
        local function worker()
            while featureState.AutoFish do
                if isResetting or chargeCount >= featureState.ResetCount then
                    break
                end
                
                pcall(function()
                    while counterLock do task.wait() end
                    counterLock = true
                    
                    if chargeCount < featureState.ResetCount then
                        chargeCount = chargeCount + 1
                    else
                        counterLock = false
                        return
                    end
                    counterLock = false
                    
                    Modules.ChargeRodFunc:InvokeServer(nil, nil, nil, workspace:GetServerTimeNow())
                    task.wait(featureState.ChargeDelay)
                    
                    Modules.StartMinigameFunc:InvokeServer(-139, 1, workspace:GetServerTimeNow())
                    task.wait(featureState.StartDelay)
                    
                    if not featureState.AutoFish or isResetting then return end
                    
                    for _ = 1, featureState.SpamCount do
                        if not featureState.AutoFish or isResetting then break end
                        Modules.CompleteFishingEvent:FireServer()
                        task.wait(0.05)
                    end
                    
                    if not featureState.AutoFish or isResetting then return end
                    
                    local gotFish = false
                    local connection
                    local timeout = task.delay(featureState.CatchTimeout, function()
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
                        if coroutine.status(timeout) == "dead" then break end
                    end
                    
                    if connection then connection:Disconnect() end
                    
                    if Modules.FishingController then
                        pcall(Modules.FishingController.RequestClientStopFishing, Modules.FishingController, true)
                    end
                end)
                
                if not featureState.AutoFish then break end
                task.wait(featureState.CycleDelay)
            end
        end
        
        autoFishThread = task.spawn(function()
            while featureState.AutoFish do
                chargeCount = 0
                isResetting = false
                
                local batchTrove = {}
                
                for i = 1, featureState.WorkerCount do
                    if not featureState.AutoFish then break end
                    local workerThread = task.spawn(worker)
                    table.insert(batchTrove, workerThread)
                    table.insert(fishingTrove, workerThread)
                end
                
                while featureState.AutoFish and chargeCount < featureState.ResetCount do
                    task.wait()
                end
                
                isResetting = true
                
                if featureState.AutoFish then
                    for _, thread in ipairs(batchTrove) do
                        task.cancel(thread)
                    end
                    batchTrove = {}
                    task.wait(featureState.ResetPause)
                end
            end
            stopAutoFish()
        end)
        
        table.insert(fishingTrove, autoFishThread)
    end
    
    -- UI Elements
    Tabs.AutoFish:AddParagraph({
        Title = "Auto Fishing",
        Content = "Automatically catch fish with 5x speed boost. Configure settings below for optimal performance."
    })
    
    local AutoFishToggle = Tabs.AutoFish:AddToggle("AutoFishToggle", {
        Title = "Enable Auto Fish",
        Description = "Start automatic fishing",
        Default = false,
        Callback = function(value)
            if value then
                stopAutoFish()
                equipFishingRod()
                task.wait(0.1)
                startAutoFish()
                Fluent:Notify({
                    Title = "Auto Fish",
                    Content = "Auto fishing started!",
                    Duration = 3
                })
            else
                stopAutoFish()
                Fluent:Notify({
                    Title = "Auto Fish",
                    Content = "Auto fishing stopped",
                    Duration = 3
                })
            end
        end
    })
    
    Tabs.AutoFish:AddSlider("StartDelay", {
        Title = "Recast Delay",
        Description = "Delay before recasting (seconds)",
        Default = 1.20,
        Min = 0,
        Max = 5,
        Rounding = 2,
        Callback = function(value)
            featureState.StartDelay = value
        end
    })
    
    Tabs.AutoFish:AddSlider("ResetCount", {
        Title = "Spam Finish Count",
        Description = "Number of finish attempts per cycle",
        Default = 10,
        Min = 5,
        Max = 50,
        Rounding = 0,
        Callback = function(value)
            featureState.ResetCount = value
        end
    })
    
    Tabs.AutoFish:AddSlider("ResetPause", {
        Title = "Cooldown Between Batches",
        Description = "Pause time between cycles (seconds)",
        Default = 0.01,
        Min = 0.01,
        Max = 5,
        Rounding = 2,
        Callback = function(value)
            featureState.ResetPause = value
        end
    })
    
    local stopAnimConnections = {}
    local animDisabled = false
    
    Tabs.AutoFish:AddToggle("DisableAnims", {
        Title = "Disable Animations",
        Description = "Stop fishing animations for better performance",
        Default = false,
        Callback = function(state)
            animDisabled = state
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
                
                Fluent:Notify({
                    Title = "Animations",
                    Content = "Animations disabled",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Animations",
                    Content = "Animations enabled",
                    Duration = 3
                })
            end
        end
    })
else
    Tabs.AutoFish:AddParagraph({
        Title = "Not Available",
        Content = "Auto Fishing is only available in supported games.\n\nCurrent game: Not Supported\n\nThis feature requires the game to have specific modules loaded."
    })
end

-- ================================
-- PLAYER TAB
-- ================================

Tabs.Player:AddParagraph({
    Title = "Player Controls",
    Content = "Customize your character's movement and abilities."
})

local ijump = false

Tabs.Player:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Description = "Jump indefinitely without touching ground",
    Default = false,
    Callback = function(value)
        ijump = value
    end
})

UserInputService.JumpRequest:Connect(function()
    if ijump and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Adjust your walking speed",
    Default = 20,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust your jump height",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = value
            end
        end
    end
})

local defaultMinZoom = player.CameraMinZoomDistance
local defaultMaxZoom = player.CameraMaxZoomDistance

Tabs.Player:AddToggle("UnlimitedZoom", {
    Title = "Unlimited Camera Zoom",
    Description = "Remove camera zoom distance limits",
    Default = false,
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
-- UTILITIES TAB
-- ================================

Tabs.Utils:AddParagraph({
    Title = "Utilities",
    Content = "Performance optimization and other useful tools."
})

Tabs.Utils:AddButton({
    Title = "Boost FPS",
    Description = "Optimize graphics for better performance",
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
        
        Fluent:Notify({
            Title = "FPS Boost",
            Content = "Graphics optimized successfully!",
            Duration = 5
        })
    end
})

Tabs.Utils:AddButton({
    Title = "Rejoin Server",
    Description = "Reconnect to current game server",
    Callback = function()
        Fluent:Notify({
            Title = "Rejoining",
            Content = "Reconnecting to server...",
            Duration = 3
        })
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, player)
    end
})

Tabs.Utils:AddButton({
    Title = "Copy Game ID",
    Description = "Copy current game's Place ID",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
        Fluent:Notify({
            Title = "Copied",
            Content = "Game ID copied to clipboard: " .. game.PlaceId,
            Duration = 5
        })
    end
})

-- ================================
-- SETTINGS TAB
-- ================================

Tabs.Settings:AddParagraph({
    Title = "Settings",
    Content = "Configure UI preferences and save your settings."
})

-- Add InterfaceManager and SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("ReyaHub")
SaveManager:SetFolder("ReyaHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ================================
-- FINAL NOTIFICATION
-- ================================

Window:SelectTab(1)

Fluent:Notify({
    Title = "Reya HUB Loaded!",
    Content = "Welcome! All features are ready to use. Press G to toggle UI.",
    Duration = 8
})

print("============================================")
print("Reya HUB - Fluent UI Version")
print("Version: 2.0 Stable")
print("Game Support: " .. (gameModulesLoaded and "✓ Enabled" or "⚠ Universal Mode"))
print("Status: Successfully Loaded")
print("============================================")
