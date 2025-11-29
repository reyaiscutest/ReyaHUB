-- ============================================
-- REYA HUB LOADER
-- Simple execution script for users
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(1)

-- ============================================
-- CONFIGURATION
-- ============================================
local SCRIPT_URL = "https://raw.githubusercontent.com/reyaiscutest/ReyaHUB/main/Reya.lua"
local EXPECTED_PLACEID = 121864768012064
local HUB_NAME = "Reya Hub"

-- ============================================
-- NOTIFICATION FUNCTION
-- ============================================
local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
            Icon = "rbxassetid://10723415766"
        })
    end)
end

-- ============================================
-- PLACE ID CHECK
-- ============================================
local currentPlaceId = game.PlaceId

if currentPlaceId ~= EXPECTED_PLACEID then
    Notify("⚠️ Wrong Game", 
        "This script is for Fish It!\nCurrent PlaceID: " .. currentPlaceId .. "\nExpected: " .. EXPECTED_PLACEID,
        10
    )
    warn("════════════════════════════════════════")
    warn("❌ WRONG GAME DETECTED!")
    warn("════════════════════════════════════════")
    warn("Current PlaceID:", currentPlaceId)
    warn("Expected PlaceID:", EXPECTED_PLACEID)
    warn("Please join Fish It game first!")
    warn("════════════════════════════════════════")
    return
end

-- ============================================
-- LOADING NOTIFICATION
-- ============================================
Notify("🎣 " .. HUB_NAME, "Loading script...\nPlease wait...", 5)

print("════════════════════════════════════════")
print("🎣 " .. HUB_NAME:upper() .. " LOADER")
print("════════════════════════════════════════")
print("PlaceID:", currentPlaceId, "✅")
print("Player:", game.Players.LocalPlayer.Name)
print("Downloading script from GitHub...")
print("════════════════════════════════════════")

-- ============================================
-- DOWNLOAD SCRIPT
-- ============================================
local downloadSuccess, scriptContent = pcall(function()
    return game:HttpGet(SCRIPT_URL, true)
end)

if not downloadSuccess then
    Notify("❌ Download Failed", 
        "Cannot download script\nCheck your internet connection",
        10
    )
    warn("❌ DOWNLOAD FAILED!")
    warn("Error:", scriptContent)
    warn("")
    warn("💡 TROUBLESHOOTING:")
    warn("1. Check your internet connection")
    warn("2. Make sure GitHub is accessible")
    warn("3. Verify repository is public")
    warn("4. Try again in a few seconds")
    warn("════════════════════════════════════════")
    return
end

-- Verify content
if not scriptContent or #scriptContent < 100 then
    Notify("❌ Invalid Content", 
        "Downloaded content is invalid\nPlease contact developer",
        10
    )
    warn("❌ INVALID SCRIPT CONTENT!")
    warn("Content length:", #(scriptContent or ""))
    return
end

print("✅ Downloaded successfully!")
print("Script size:", #scriptContent, "bytes")
print("Executing script...")

-- ============================================
-- EXECUTE SCRIPT
-- ============================================
local executeSuccess, executeError = pcall(function()
    local loadSuccess, loadedFunction = pcall(loadstring, scriptContent)
    
    if loadSuccess and loadedFunction then
        loadedFunction()
    else
        error(loadedFunction or "Failed to load script")
    end
end)

if executeSuccess then
    Notify("✅ Success!", 
        HUB_NAME .. " loaded!\nEnjoy fishing! 🎣",
        5
    )
    print("✅ " .. HUB_NAME:upper() .. " LOADED!")
    print("════════════════════════════════════════")
    print("🎮 FEATURES:")
    print("  • Instant Fishing")
    print("  • Auto Sell")
    print("  • Location Teleport")
    print("  • Player Teleport")
    print("  • Oxygen Bypass")
    print("  • Server Controls")
    print("════════════════════════════════════════")
    print("⭐ Enjoy " .. HUB_NAME .. "!")
    print("════════════════════════════════════════")
else
    Notify("❌ Execute Failed", 
        "Script error\nCheck console (F9) for details",
        10
    )
    warn("❌ EXECUTION FAILED!")
    warn("Error:", executeError)
    warn("")
    warn("💡 POSSIBLE CAUSES:")
    warn("1. Script syntax error")
    warn("2. Missing game dependencies")
    warn("3. Game updated (breaking changes)")
    warn("4. Executor compatibility issue")
    warn("")
    warn("💡 WHAT TO DO:")
    warn("1. Press F9 to see full error")
    warn("2. Make sure you're in Fish It game")
    warn("3. Try different executor (Solara recommended)")
    warn("4. Contact developer with error details")
    warn("════════════════════════════════════════")
end
