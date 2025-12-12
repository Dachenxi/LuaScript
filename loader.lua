local PlaceID = game.PlaceId
local RepoURL = "https://raw.githubusercontent.com/Dachenxi/LuaScript/main/"
getgenv().Import = function(path)
    local url = RepoURL .. path
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local func = loadstring(result)
        return func()
    else
        warn("Gagal mengambil file: " .. path)
        return nil
    end
end

getgenv().Library = Import("lib/ImGui.lua")
getgenv().ESP_Lib = Import("lib/ESP.lua")

local Games = {
    ["test"] = "src/test.lua",
    [123456789] = "src/SuperSoldier.lua",  -- Ganti 123456789 dengan PlaceID game yang diinginkan
}

if Games[PlaceID] then
    print("Game Terdeteksi! Loading script...")
    Import(Games[PlaceID])
else
    Import("src/Default.lua")
end