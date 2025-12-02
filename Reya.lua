local UIsuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not UIsuccess or not WindUI then
    warn("Failed to load WindUI...")
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

local Modules = {}
local function customRequire(module)
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

local success, errorMessage = pcall(function()
    local Controllers = ReplicatedStorage:WaitForChild("Controllers", 20)
    local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild(
        "sleitnick_net@0.2.0"):WaitForChild("net", 20)
    local Shared = ReplicatedStorage:WaitForChild("Shared", 20)
    
    if not (Controllers and NetFolder and Shared) then error("Core game folders not found.") end

    Modules.Replion = customRequire(ReplicatedStorage.Packages.Replion)
    Modules.ItemUtility = customRequire(Shared.ItemUtility)
    Modules.FishingController = customRequire(Controllers.FishingController)
    
    Modules.EquipToolEvent = NetFolder["RE/EquipToolFromHotbar"]
    Modules.ChargeRodFunc = NetFolder["RF/ChargeFishingRod"]
    Modules.StartMinigameFunc = NetFolder["RF/RequestFishingMinigameStarted"]
    Modules.CompleteFishingEvent = NetFolder["RE/FishingCompleted"]
end)

if not success then
    warn("FATAL ERROR DURING MODULE LOADING: " .. tostring(errorMessage))
    return
end

task.wait(1)

WindUI:AddTheme({
    Name = "Reya Dark",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#7C3AED"), Transparency = 0 },
        ["50"]  = { Color = Color3.fromHex("#A78BFA"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#C4B5FD"), Transparency = 0 },
    }, {
        Rotation = 45,
    }),
    Dialog = Color3.fromHex("#1E1B4B"),
    Outline = Color3.fromHex("#7C3AED"),
    Text = Color3.fromHex("#F5F3FF"),
    Placeholder = Color3.fromHex("#8B5CF6"),
    Background = Color3.fromHex("#0F0A2E"),
    Button = Color3.fromHex("#6D28D9"),
    Icon = Color3.fromHex("#A78BFA")
})

WindUI.TransparencyValue = 0.3

local Window = WindUI:CreateWindow({
    Title = "Reya HUB",
    Icon = "zap",
    Author = "Fishit | Reya",
    Size = UDim2.fromOffset(600, 400),
    Folder = "ReyaHub",
    Transparent = true,
    Theme = "Reya Dark",
    ToggleKey = Enum.KeyCode.G,
    SideBarWidth = 140
})

if not Window then
    warn("Failed to create UI Window.")
    return
end

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

local confirmed = false
WindUI:Popup({
    Title = "Reya HUB",
    Icon = "zap",
    Content = [[
Welcome to Reya HUB.
Enhanced features for your fishing experience!
]],
    Buttons = {
        { Title = "Start Script", Variant = "Primary", Callback = function() confirmed = true end },
    }
})

repeat task.wait() until confirmed

_G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(player.Name)
_G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
_G.Overhead = _G.HRP:WaitForChild("Overhead")
_G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
_G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
_G.XPBar = player:WaitForChild("PlayerGui"):WaitForChild("XP")
_G.XPLevel = _G.XPBar:WaitForChild("Frame"):WaitForChild("LevelCount")
_G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
_G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")

if player and VirtualUser then
    player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

task.spawn(function()
    if _G.XPBar then
        _G.XPBar.Enabled = true
    end
end)

task.spawn(function()
    if _G.TitleEnabled then
        _G.TitleEnabled.Visible = true
        _G.Title.TextScaled = false
        _G.Title.TextSize = 10
        _G.Title.Text = "Reya HUB"

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 2
        uiStroke.Color = Color3.fromRGB(124, 58, 237)
        uiStroke.Parent = _G.Title

        local colors = {
            Color3.fromRGB(124, 58, 237),
            Color3.fromRGB(167, 139, 250),
            Color3.fromRGB(196, 181, 253),
            Color3.fromRGB(139, 92, 246),
            Color3.fromRGB(109, 40, 217)
        }

        local i = 1
        while task.wait(1.5) do
            local nextColor = colors[(i % #colors) + 1]
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            
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
        TeleportService:Teleport(_G.PlaceId)
    end
end)

task.spawn(AutoReconnect)

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

local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))

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

local AutoFarmTab = AllMenu:Tab({
    Title = "Farming",
    Icon = "leaf"
})

local AutoFav = AllMenu:Tab({
    Title = "Auto Favorite",
    Icon = "star"
})

local Trade = AllMenu:Tab({
    Title = "Trade",
    Icon = "handshake"
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

Home:Section({
	Title = "Reya HUB",
	TextSize = 22,
	TextXAlignment = "Center",
})

Home:Paragraph({
	Title = "About",
	Color = "Grey",
	Desc = [[
Enhanced fishing script with advanced features.
Created by Reya Development Team.
Use wisely and enjoy!
]]
})

local featureState = {
    AutoFish = false,
    Instant_ChargeDelay = 0.07,
    Instant_SpamCount = 5,
    Instant_WorkerCount = 2,
    Instant_StartDelay = 1.20,
    Instant_CatchTimeout = 0.01,
    Instant_CycleDelay = 0.01,
    Instant_ResetCount = myConfig:Get("Instant_ResetCount") or 10,
    Instant_ResetPause = myConfig:Get("Instant_ResetPause") or 0.01
}

local fishingTrove = {}
local autoFishThread = nil
local fishCaughtBindable = Instance.new("BindableEvent")

local function equipFishingRod()
    if Modules.EquipToolEvent then
        pcall(Modules.EquipToolEvent.FireServer, Modules.EquipToolEvent, 1)
    end
end

task.spawn(function()
    local lastFishName = ""
    while task.wait(0.25) do
        local playerGui = player:findFirstChild("PlayerGui")
        if playerGui then
            local notificationGui = playerGui:FindFirstChild("Small Notification")
            if notificationGui and notificationGui.Enabled then
                local container = notificationGui:FindFirstChild("Display", true) and
                    notificationGui.Display:FindFirstChild("Container", true)
                if container then
                    local itemNameLabel = container:FindFirstChild("ItemName")
                    if itemNameLabel and itemNameLabel.Text ~= "" and itemNameLabel.Text ~= lastFishName then
                        lastFishName = itemNameLabel.Text
                        fishCaughtBindable:Fire()
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
    
    for i, item in ipairs(fishingTrove) do
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

local function startAutoFishMethod_Instant()
    if not (Modules.ChargeRodFunc and Modules.StartMinigameFunc and Modules.CompleteFishingEvent and Modules.FishingController) then
        return
    end

    featureState.AutoFish = true

    local chargeCount = 0
    local isCurrentlyResetting = false
    local counterLock = false

    local function worker()
        while featureState.AutoFish and player do
            local currentResetTarget_Worker = featureState.Instant_ResetCount or 10

            if isCurrentlyResetting or chargeCount >= currentResetTarget_Worker then
                break
            end

            local success, err = pcall(function()
                while counterLock do task.wait() end
                counterLock = true

                if chargeCount < currentResetTarget_Worker then
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

                if not featureState.AutoFish or isCurrentlyResetting then return end

                for _ = 1, featureState.Instant_SpamCount do
                    if not featureState.AutoFish or isCurrentlyResetting then break end
                    Modules.CompleteFishingEvent:FireServer()
                    task.wait(0.05)
                end

                if not featureState.AutoFish or isCurrentlyResetting then return end

                local gotFishSignal = false
                local connection
                local timeoutThread = task.delay(featureState.Instant_CatchTimeout, function()
                    if not gotFishSignal and connection and connection.Connected then
                        connection:Disconnect()
                    end
                end)

                connection = fishCaughtBindable.Event:Connect(function()
                    if gotFishSignal then return end
                    gotFishSignal = true
                    task.cancel(timeoutThread)
                    if connection and connection.Connected then
                        connection:Disconnect()
                    end
                end)

                while not gotFishSignal and task.wait() do
                    if not featureState.AutoFish or isCurrentlyResetting then break end
                    if timeoutThread and coroutine.status(timeoutThread) == "dead" then break end
                end

                if connection and connection.Connected then connection:Disconnect() end

                if Modules.FishingController and Modules.FishingController.RequestClientStopFishing then
                    pcall(Modules.FishingController.RequestClientStopFishing, Modules.FishingController, true)
                end

                task.wait()
            end)

            if not success then
                warn("Auto Fish Error: ", err)
                task.wait(1)
            end

            if not featureState.AutoFish then break end
            task.wait(featureState.Instant_CycleDelay)
        end
    end

    autoFishThread = task.spawn(function()
        while featureState.AutoFish do
            local currentResetTarget = featureState.Instant_ResetCount or 10
            local currentPauseTime = featureState.Instant_ResetPause or 0.01

            chargeCount = 0
            isCurrentlyResetting = false

            local batchTrove = {}

            for i = 1, featureState.Instant_WorkerCount do
                if not featureState.AutoFish then break end
                local workerThread = task.spawn(worker)
                table.insert(batchTrove, workerThread)
                table.insert(fishingTrove, workerThread)
            end

            while featureState.AutoFish and chargeCount < currentResetTarget do
                task.wait()
            end

            isCurrentlyResetting = true

            if featureState.AutoFish then
                for _, thread in ipairs(batchTrove) do
                    task.cancel(thread)
                end
                batchTrove = {}

                task.wait(currentPauseTime)
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
        task.wait(0.01)
        startAutoFishMethod_Instant()
    else
        stopAutoFishProcesses()
    end
end

AutoFish:Section({ Title = "Settings", Opened = true })

local startDelaySlider = AutoFish:Slider({
    Title = "Delay Recast",
    Desc = "(Default: 1.20)",
    Value = { Min = 0.00, Max = 5.0, Default = featureState.Instant_StartDelay },
    Precise = 2,
    Step = 0.01,
    Callback = function(v)
        featureState.Instant_StartDelay = tonumber(v)
    end
})
myConfig:Register("Instant_StartDelay", startDelaySlider)

local resetCountSlider = AutoFish:Slider({
    Title = "Spam Finish",
    Desc = "(Default: 10)",
    Value = { Min = 5, Max = 50, Default = featureState.Instant_ResetCount },
    Precise = 0,
    Step = 1,
    Callback = function(v)
        local num = math.floor(tonumber(v) or 10)
        featureState.Instant_ResetCount = num
        myConfig:Set("Instant_ResetCount", num)
    end
})
myConfig:Register("Instant_ResetCount", resetCountSlider)

local resetPauseSlider = AutoFish:Slider({
    Title = "Cooldown Recast",
    Desc = "(Default: 0.01)",
    Value = { Min = 0.01, Max = 5, Default = featureState.Instant_ResetPause },
    Precise = 2,
    Step = 0.01,
    Callback = function(v)
        local num = tonumber(v) or 2.0
        featureState.Instant_ResetPause = num
        myConfig:Set("Instant_ResetPause", num)
    end
})
myConfig:Register("Instant_ResetPause", resetPauseSlider)

AutoFish:Section({ Title = "X5 Speed", Opened = true })

local autoFishToggle = AutoFish:Toggle({
    Title = "AutoFish X5",
    Desc = "Advanced auto fishing",
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
        for _, track in ipairs(humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
            track:Stop(0)
        end

        local conn = humanoid:FindFirstChildOfClass("Animator").AnimationPlayed:Connect(function(track)
            task.defer(function()
                track:Stop(0)
            end)
        end)
        table.insert(stopAnimConnections, conn)

        WindUI:Notify({
            Title = "Animation Disabled",
            Content = "All animations disabled",
            Duration = 4,
            Icon = "pause-circle"
        })
    else
        for _, conn in pairs(stopAnimConnections) do
            conn:Disconnect()
        end
        stopAnimConnections = {}

        WindUI:Notify({
            Title = "Animation Enabled",
            Content = "Animations reactivated",
            Duration = 4,
            Icon = "play-circle"
        })
    end
end

local gameAnimToggle = AutoFish:Toggle({
    Title = "No Animation",
    Desc = "Stop all game animations",
    Value = false,
    Callback = function(v)
        setGameAnimationsEnabled(v)
    end
})
myConfig:Register("DisableGameAnimations", gameAnimToggle)

local GlobalFav = {
    REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"],
    REFavoriteItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"],
    FishIdToName = {},
    FishNameToId = {},
    FishNames = {},
    FishRarity = {},
    Variants = {},
    SelectedFishIds = {},
    SelectedVariants = {},
    SelectedRarities = {},
    AutoFavoriteEnabled = false
}

local TierToRarityName = {
    [3] = "RARE",
    [4] = "EPIC",
    [5] = "LEGENDARY",
    [6] = "MYTHIC",
    [7] = "SECRET"
}

for _, item in ipairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        local id = data.Data.Id
        local name = data.Data.Name
        local tier = data.Data.Tier or 1

        local nameWithId = name .. " [ID:" .. id .. "]"

        GlobalFav.FishIdToName[id] = nameWithId
        GlobalFav.FishNameToId[nameWithId] = id
        GlobalFav.FishRarity[id] = tier

        table.insert(GlobalFav.FishNames, nameWithId)
    end
end

for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData.Data.Name then
        local name = variantData.Data.Name
        GlobalFav.Variants[name] = name
    end
end

AutoFav:Section({
    Title = "Auto Favorite Menu",
    TextSize = 22,
    TextXAlignment = "Center",
})

AutoFav:Toggle({
    Title = "Enable Auto Favorite",
    Value = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
        if state then
            WindUI:Notify({
                Title = "Auto Favorite",
                Content = "Auto Favorite enabled",
                Duration = 3,
                Icon = "star"
            })
        else
            WindUI:Notify({
                Title = "Auto Favorite",
                Content = "Auto Favorite disabled",
                Duration = 3,
                Icon = "star"
            })
        end
    end
})

AutoFav:Dropdown({
    Title = "Auto Favorite Fishes",
    Values = GlobalFav.FishNames,
    Value = {},
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedNames)
        GlobalFav.SelectedFishIds = {}
        for _, nameWithId in ipairs(selectedNames) do
            local id = GlobalFav.FishNameToId[nameWithId]
            if id then
                GlobalFav.SelectedFishIds[id] = true
            end
        end
    end
})

AutoFav:Dropdown({
    Title = "Auto Favorite Variants",
    Values = GlobalFav.Variants,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedVariants)
        GlobalFav.SelectedVariants = {}
        for _, vName in ipairs(selectedVariants) do
            for vId, name in pairs(GlobalFav.Variants) do
                if name == vName then
                    GlobalFav.SelectedVariants[vId] = true
                end
            end
        end
    end
})

local rarityList = {}
for tier, name in pairs(TierToRarityName) do
    table.insert(rarityList, name)
end

AutoFav:Dropdown({
    Title = "Auto Favorite by Rarity",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedRarities)
        GlobalFav.SelectedRarities = {}
        for _, rarityName in ipairs(selectedRarities) do
            for tier, name in pairs(TierToRarityName) do
                if name == rarityName then
                    GlobalFav.SelectedRarities[tier] = true
                end
            end
        end
    end
})

GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end

    local uuid = data.InventoryItem and data.InventoryItem.UUID
    if not uuid then return end

    local fishName = GlobalFav.FishIdToName[itemId] or "Unknown"
    local variantId = data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId
    local tier = GlobalFav.FishRarity[itemId] or 1
    local rarityName = TierToRarityName[tier] or "Unknown"

    local isFishSelected = GlobalFav.SelectedFishIds[itemId]
    local isVariantSelected = variantId and GlobalFav.SelectedVariants[variantId]
    local isRaritySelected = GlobalFav.SelectedRarities[tier]

    local shouldFavorite = false
    if (isFishSelected or not next(GlobalFav.SelectedFishIds))
       and (isVariantSelected or not next(GlobalFav.SelectedVariants))
       and (isRaritySelected or not next(GlobalFav.SelectedRarities)) then
        shouldFavorite = true
    end

    if shouldFavorite then
        GlobalFav.REFavoriteItem:FireServer(uuid)
    end
end)

local ijump = false

Player:Toggle({
    Title = "Infinity Jump",
    Callback = function(val)
        ijump = val
    end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if ijump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local Speed = Player:Slider({
    Title = "WalkSpeed",
    Value = {
        Min = 16,
        Max = 200,
        Default = 20
    },
    Step = 1,
    Callback = function(val)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end,
})

myConfig:Register("PlayerSpeed", Speed)

local Jp = Player:Slider({
    Title = "Jump Power",
    Value = {
        Min = 50,
        Max = 500,
        Default = 35
    },
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

local defaultMinZoom = player.CameraMinZoomDistance
local defaultMaxZoom = player.CameraMaxZoomDistance

Player:Toggle({
    Title = "Unlimited Zoom",
    Desc = "Unlimited Camera Zoom",
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

Utils:Button({
    Title = "Boost FPS",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
                v.Transparency = v.Transparency > 0.5 and 1 or v.Transparency
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Trail") then
                v.Lifetime = 0
            elseif v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") or v:IsA("ForceField") or v:IsA("Sparkles") then
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
            Title = "FPS Boost",
            Content = "Graphics optimized",
            Duration = 3,
            Icon = "zap"
        })
    end
})

_G.Keybind = SettingsTab:Keybind({
    Title = "Toggle Key",
    Desc = "Key to open/close UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

myConfig:Register("Keybind", _G.Keybind)

SettingsTab:Section({
    Title = "Configuration",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

SettingsTab:Button({
    Title = "Save Config",
    Justify = "Center",
    Icon = "save",
    Callback = function()
        myConfig:Save()
        WindUI:Notify({
            Title = "Config Saved",
            Content = "Settings saved successfully",
            Duration = 3,
            Icon = "check-circle"
        })
    end
})

SettingsTab:Button({
    Title = "Load Config",
    Justify = "Center",
    Icon = "upload",
    Callback = function()
        myConfig:Load()
        WindUI:Notify({
            Title = "Config Loaded",
            Content = "Settings loaded successfully",
            Duration = 3,
            Icon = "check-circle"
        })
    end
})

if Window then
    Window:SelectTab(1)
    WindUI:Notify({
        Title = "Reya HUB Ready",
        Content = "All features loaded!",
        Duration = 5,
        Icon = "zap"
    })
end
