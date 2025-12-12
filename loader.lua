local GlobalEnv = (getgenv and getgenv()) or _G
local PlaceID = game.PlaceId
local BaseURL = "https://raw.githubusercontent.com/Dachenxi/LuaScript/main/"

GlobalEnv.Import = function(path)
    local url = BaseURL .. path .. "?t=" .. tostring(os.time())

    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or result == "404: Not Found" then
        warn("⚠️ Gagal mengambil file: " .. path)
        return nil
    end

    local func, err = loadstring(result)
    if not func then
        warn("⚠️ Syntax Error di " .. path .. ": " .. tostring(err))
        return nil
    end

    return func()
end

GlobalEnv.Library = GlobalEnv.Import("lib/ImGui.lua")
GlobalEnv.HubWindow = GlobalEnv.Import("lib/Window.lua")

local SettingsTab = GlobalEnv.HubWindow:CreateTab({
    Name = "Settings"
})
local SettingsRegion = CreateRegion(SettingsTab, "Settings")

if not GlobalEnv.Library then
    return warn("❌ Library gagal dimuat. Script berhenti.")
end

local Games = {
    ["test"] = "src/test.lua",
    [123456789] = "src/SuperSoldier.lua",
}

if Games[PlaceID] then
    print("✅ Game Terdeteksi! Loading script...")
    GlobalEnv.Import(Games[PlaceID])
else
    print("ℹ️ Game tidak terdaftar. Loading Default...")
    GlobalEnv.Import("src/test.lua") 
end