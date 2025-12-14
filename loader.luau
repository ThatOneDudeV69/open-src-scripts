local Games = {
    [3623096087] = "https://raw.githubusercontent.com/ThatOneDudeV69/open-src-scripts/refs/heads/main/dist/MusculeLegends.lua",
    [76558904092080] = "https://raw.githubusercontent.com/ThatOneDudeV69/open-src-scripts/refs/heads/main/dist/TheForge.lua"
}

if Games[game.placeId] then
    loadstring(game:HttpGet(Games[game.placeId])()
end
