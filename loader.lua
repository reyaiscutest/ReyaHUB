-- ============================================
-- UNIVERSAL HUB LOADER
-- Upload file ini ke GitHub sebagai loader.lua
-- ============================================

-- Configuration
local Config = {
    GitHubUser = "reyaiscutest",  -- Ganti dengan username GitHub Anda
    RepoName = "ReyaHUB",  -- Ganti dengan nama repository Anda
    Branch = "main"               -- atau "master"
}

-- Base URL
local BaseURL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s",
    Config.GitHubUser,
    Config.RepoName,
    Config.Branch
)

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function LoadScript(path)
    local url = BaseURL .. "/" .. path
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local loadSuccess, loadResult = pcall(function()
            return loadstring(result)()
        end)
        
        if loadSuccess then
            return true, "Script loaded successfully"
        else
            return false, "Failed to execute script: " .. tostring(loadResult)
        end
    else
        return false, "Failed to fetch script: " .. tostring(result)
    end
end

local function Notify(title, content, duration)
    duration = duration or 5
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = content,
        Duration = duration,
        Icon = "rbxassetid://10723415766"
    })
end

-- ============================================
-- GAME DETECTION
-- ============================================

local GameScripts = {
    -- Fish It
    [16732694052] = "games/ReyaHUB.lua",
    
    -- Blox Fruits (example)
    [2753915549] = "games/bloxfruits.lua",
    [4442272183] = "games/bloxfruits.lua",
    
    -- Tambahkan game lain di sini
    -- [PlaceID] = "path/to/script.lua",
}

-- ============================================
-- AUTO LOAD
-- ============================================

local PlaceId = game.PlaceId
local GameScript = GameScripts[PlaceId]

if GameScript then
    Notify("Hub Loader", "Loading script for this game...", 3)
    
    local success, message = LoadScript(GameScript)
    
    if success then
        Notify("Success", "Hub loaded successfully!", 5)
    else
        Notify("Error", message, 10)
        warn("[Hub Loader] Error:", message)
    end
else
    Notify("Not Supported", "This game is not supported yet.", 10)
    warn("[Hub Loader] Game not supported. PlaceId:", PlaceId)
end

-- ============================================
-- MANUAL LOAD FUNCTION (Optional)
-- ============================================

-- Jika ingin load manual, uncomment ini:
--[[
_G.LoadHub = function(gameName)
    local scripts = {
        fishit = "games/fishit.lua",
        bloxfruits = "games/bloxfruits.lua",
    }
    
    local scriptPath = scripts[gameName:lower()]
    if scriptPath then
        return LoadScript(scriptPath)
    else
        return false, "Game not found"
    end
end

-- Usage: _G.LoadHub("fishit")
--]]
