-- Reya Hub - Fluent UI Version (Reconverted)
-- Full UI converted back from WindUI to Fluent UI

repeat task.wait() until game:IsLoaded()
task.wait(1)

-- LOAD FLUENT LIBRARY
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- NET
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- GLOBALS
_G.AutoFish = false
_G.ActiveFishing = false
_G.InstantDelay = 0.1

-- CHLOE-STYLE VARIABLES
_G.Instant = false
_G.CancelWaitTime = 2.5

-- BASIC FUNCS
equipRod = function()
    pcall(function()
        net:WaitForChild("RE/EquipToolFromHotbar"):FireServer(1)
    end)
end

SellAll = function()
    pcall(function()
        net:WaitForChild("RF/SellAllItems"):InvokeServer()
    end)
end

local function CancelFishing()
    pcall(function()
        net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
    end)
end

local function InstantReel()
    pcall(function()
        net:WaitForChild("RE/FishingCompleted"):FireServer()
    end)
end

-- INSTANT FISH
task.spawn(function()
    while task.wait() do
        if _G.AutoFish then
            _G.ActiveFishing = true
            local timestamp = Workspace:GetServerTimeNow()
            equipRod()
            task.wait(0.1)
            net:WaitForChild("RF/ChargeFishingRod"):InvokeServer(timestamp)
            local x = -0.75 + math.random(-5,5)/1000000
            local y = 1 + math.random(-5,5)/1000000
            net:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(x,y)
            _G.ActiveFishing = false
        end
    end
end)

-- AUTO REEL
net["RE/ReplicateTextEffect"].OnClientEvent:Connect(function(data)
    if _G.AutoFish and _G.ActiveFishing then
        local head = Character:FindFirstChild("Head")
        if head and data and data.Container == head then
            task.spawn(function()
                for i=1,3 do
                    task.wait(_G.InstantDelay)
                    InstantReel()
                end
            end)
        end
    end
end)

-- CHLOE BLATANT LOOP
local lastFishTime = tick()
local waiting = false
RunService.Stepped:Connect(function()
    if not _G.Instant then return end
    local now = tick()

    if waiting and now - lastFishTime >= _G.CancelWaitTime then
        InstantReel()
        waiting = false
        lastFishTime = now
    end

    if now - lastFishTime >= _G.CancelWaitTime + 0.5 then
        CancelFishing()
        waiting = false
        lastFishTime = now
    end
end)

-- DASHBOARD UI WINDOW
local Window = Fluent:CreateWindow({
    Title = "Reya Hub",
    SubTitle = "Fluent UI Version",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K
})

local Tabs = {
    Dashboard = Window:AddTab({Title = "Dashboard", Icon = "home"}),
    Automation = Window:AddTab({Title = "Automation", Icon = "zap"}),
    Travel = Window:AddTab({Title = "Travel", Icon = "map-pin"}),
    Systems = Window:AddTab({Title = "Systems", Icon = "settings"}),
    Utility = Window:AddTab({Title = "Utility", Icon = "tool"}),
    Server = Window:AddTab({Title = "Server", Icon = "server"})
}

-----------------------------------------------
-- DASHBOARD
-----------------------------------------------
Tabs.Dashboard:AddParagraph({Title = "Reya Hub", Content = "Fluent UI restored"})

local fpsLabel = Tabs.Dashboard:AddParagraph({Title = "FPS", Content = "0"})
local pingLabel = Tabs.Dashboard:AddParagraph({Title = "Ping", Content = "0"})

task.spawn(function()
    while task.wait(1) do
        local fps = math.floor(Workspace:GetRealPhysicsFPS())
        fpsLabel:SetDesc("FPS: "..fps)
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        pingLabel:SetDesc("Ping: "..ping)
    end
end)

-----------------------------------------------
-- AUTOMATION
-----------------------------------------------
Tabs.Automation:AddToggle("AutoFishToggle",{
    Title="Auto Fish (Instant)",Default=false,
    Callback=function(v)
        _G.AutoFish=v
        if not v then CancelFishing() end
    end
})

Tabs.Automation:AddSlider("InstantDelay",{
    Title="Instant Reel Delay",Default=_G.InstantDelay,Min=0,Max=5,Rounding=1,
    Callback=function(v) _G.InstantDelay=v end
})

-- CHLOE BLATANT UI
Tabs.Automation:AddToggle("ChloeStyle",{
    Title="Enable Blatant (Chloe)",Default=_G.Instant,
    Callback=function(v)
        _G.Instant=v
        if not v then CancelFishing() end
    end
})

Tabs.Automation:AddSlider("BlatantDelay",{
    Title="Blatant Delay",Default=_G.CancelWaitTime,Min=1,Max=6,Rounding=1,
    Callback=function(v) _G.CancelWaitTime=v end
})

-----------------------------------------------
-- TRAVEL
-----------------------------------------------
local locations={
    ["Ancient Jungle"] = CFrame.new(1221,6,-544),
    ["Coral Reefs"] = CFrame.new(-3262,2,2216),
    ["Crater Island"] = CFrame.new(986,3,5146)
}

local names={}
for k,_ in pairs(locations)do table.insert(names,k) end
local selected=names[1]

Tabs.Travel:AddDropdown("Location",{
    Title="Select Location",Values=names,Default=names[1],
    Callback=function(v) selected=v end
})

Tabs.Travel:AddButton({Title="Teleport",Callback=function()
    if selected then HumanoidRootPart.CFrame=locations[selected] end
end})

-----------------------------------------------
-- SERVER
-----------------------------------------------
Tabs.Server:AddButton({Title="Rejoin",Callback=function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId)
end})

Fluent:Notify({Title="Reya Hub",Content="Fluent UI Loaded",Duration=5})
