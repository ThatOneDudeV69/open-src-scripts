local VERSION = "1.0.0"

local BASE_URL = "https://github.com/ThatOneDudeV69/open-src-scripts/releases/download/%s/"

local Games = {
    [3623096087] = "MusculeLegends.lua",
    [76558904092080] = "TheForge.lua"
}

local ScriptName = Games[game.PlaceId]
if ScriptName then
    local Url = BASE_URL:format(VERSION) .. ScriptName
    loadstring(game:HttpGet(Url))()
end
