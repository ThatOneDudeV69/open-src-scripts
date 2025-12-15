--!strict

local Logger = require("../shared/Logger")

local Players = game:GetService("Players")

local function FormatNumber(Number)
    if typeof(Number) ~= "number" then
        return Number
    end

    local Formatted = tostring(Number)
    local Count

    repeat
        Formatted, Count = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    until Count == 0

    return Formatted
end

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({ Title = "Stats", Icon = "bar-chart" })

    local Player = Players.LocalPlayer
    local Leaderstats = Player:FindFirstChild("leaderstats")

    local PlayerStrength = Leaderstats and Leaderstats:FindFirstChild("Strength")
    local PlayerDurability = Player:FindFirstChild("Durability")
    local PlayerAgility = Player:FindFirstChild("Agility")
    local PlayerRebirths = Leaderstats and Leaderstats:FindFirstChild("Rebirths")
    local PlayerKills = Leaderstats and Leaderstats:FindFirstChild("Kills")
    local PlayerBrawls = Leaderstats and Leaderstats:FindFirstChild("Brawls")

    local StatsParagraph =
        Tab:CreateParagraph("StatsParagraph", {
            Title = "Stats",
            Content = ""
        })

    local function UpdateStats()
        local Content =
            "Strength: " .. (PlayerStrength and FormatNumber(PlayerStrength.Value) or "N/A") .. "\n" ..
            "Durability: " .. (PlayerDurability and FormatNumber(PlayerDurability.Value) or "N/A") .. "\n" ..
            "Agility: " .. (PlayerAgility and FormatNumber(PlayerAgility.Value) or "N/A") .. "\n" ..
            "Rebirths: " .. (PlayerRebirths and FormatNumber(PlayerRebirths.Value) or "N/A") .. "\n" ..
            "Kills: " .. (PlayerKills and FormatNumber(PlayerKills.Value) or "N/A") .. "\n" ..
            "Brawls: " .. (PlayerBrawls and FormatNumber(PlayerBrawls.Value) or "N/A")

        StatsParagraph:SetContent(Content)
    end

    UpdateStats()

    if PlayerStrength then
        PlayerStrength:GetPropertyChangedSignal("Value"):Connect(UpdateStats)
    end
    if PlayerDurability then
        PlayerDurability:GetPropertyChangedSignal("Value"):Connect(UpdateStats)
    end
    if PlayerAgility then
        PlayerAgility:GetPropertyChangedSignal("Value"):Connect(UpdateStats)
    end
    if PlayerRebirths then
        PlayerRebirths:GetPropertyChangedSignal("Value"):Connect(UpdateStats)
    end
    if PlayerKills then
        PlayerKills:GetPropertyChangedSignal("Value"):Connect(UpdateStats)
    end
    if PlayerBrawls then
        PlayerBrawls:GetPropertyChangedSignal("Value"):Connect(UpdateStats)
    end

    Logger.Log("Stats initialized in " .. tostring(os.clock() - StartTime))
end
