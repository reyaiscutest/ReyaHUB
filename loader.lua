-- ============================================
-- FISH IT HUB LOADER - FIXED VERSION
-- PlaceID: 121864768012064
-- ============================================

-- Configuration - GANTI DENGAN URL GITHUB ANDA
local Config = {
    GitHubUser = "reyaiscutest",     -- Ganti dengan username GitHub Anda
    RepoName = "ReyaHUB",     -- Ganti dengan nama repository Anda
    Branch = "main"                  -- atau "master"
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

local function Notify(title, content, duration)
    duration = duration or 5
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = content,
            Duration = duration,
            Icon = "rbxassetid://10723415766"
        })
    end)
end

local function LoadScript(path)
    local url = BaseURL .. "/" .. path
    
    Notify("Loading...", "Downloading script...", 3)
    
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if success then
        local loadSuccess, loadError = pcall(function()
            return loadstring(result)()
        end)
        
        if loadSuccess then
            return true, "Script loaded successfully"
        else
            return false, "Failed to execute: " .. tostring(loadError)
        end
    else
        return false, "Failed to download: " .. tostring(result)
    end
end

-- ============================================
-- GAME DETECTION WITH CORRECT PLACEID
-- ============================================

local GameScripts = {
    -- Fish It - CORRECT PlaceID
    [121864768012064] = "games/fishit.lua",
    
    -- Tambahkan game lain jika ada
    -- [PlaceID] = "path/to/script.lua",
}

-- ============================================
-- AUTO LOAD
-- ============================================

local PlaceId = game.PlaceId
local GameScript = GameScripts[PlaceId]

print("════════════════════════════════════")
print("🎣 Fish It Hub Loader")
print("════════════════════════════════════")
print("Current PlaceID:", PlaceId)
print("Looking for script...")

if GameScript then
    print("✅ Game detected: Fish It")
    print("Loading script from:", GameScript)
    print("════════════════════════════════════")
    
    Notify("🎣 Fish It Detected", "Loading hub...", 3)
    
    local success, message = LoadScript(GameScript)
    
    if success then
        Notify("✅ Success", "Fish It Hub loaded successfully!", 5)
        print("✅ Hub loaded successfully!")
    else
        Notify("❌ Error", message, 10)
        warn("❌ Error:", message)
        warn("💡 Check:")
        warn("1. GitHub URL correct?")
        warn("2. Repository is Public?")
        warn("3. File exists at: games/fishit.lua")
    end
else
    print("❌ Game not supported")
    print("════════════════════════════════════")
    
    Notify(
        "❌ Not Supported", 
        "This game is not supported.\nPlaceID: " .. PlaceId .. "\n\nExpected: 121864768012064", 
        15
    )
    
    warn("❌ Game not supported!")
    warn("Current PlaceID:", PlaceId)
    warn("Expected PlaceID: 121864768012064")
    warn("")
    warn("💡 Solutions:")
    warn("1. Make sure you're in Fish It game")
    warn("2. Check if game updated (PlaceID changed)")
    warn("3. Try rejoining the game")
    warn("4. Add new PlaceID to GameScripts table")
end

-- ============================================
-- MANUAL LOAD FUNCTION
-- ============================================

_G.FishItHub = {
    Load = function()
        return LoadScript("games/fishit.lua")
    end,
    
    ForceLoad = function(scriptPath)
        return LoadScript(scriptPath)
    end,
    
    GetPlaceId = function()
        return game.PlaceId
    end
}

-- Usage in console:
-- _G.FishItHub.Load()           -- Load Fish It Hub
-- _G.FishItHub.GetPlaceId()     -- Get current PlaceID
