local games = {
  [76558904092080] = "https://raw.githubusercontent.com/ThatOneDudeV69/open-src-scripts/refs/heads/main/TheForge.luau" -- the forge
}

if games[game.placeId] then
  loadstring(game:HttpGet(games[game.placeId]))()
else
  error("game is not supported")
end
