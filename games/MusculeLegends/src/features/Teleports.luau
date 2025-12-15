--!strict

local Players = game:GetService("Players")

local TeleportData = require("../data/Teleports")

local LocalPlayer = Players.LocalPlayer

local function TeleportTo(cf)
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if Root then
        Root.CFrame = cf
    end
end

return function(Window, Options) -- yes ik its useful ignore it
    local TeleportsTab = Window:AddTab({
        Title = "Teleports",
        Icon = "map-pin"
    })

    for _, Teleport in ipairs(TeleportData) do
        TeleportsTab:AddButton({
            Title = Teleport.Name,
            Description = Teleport.Description,
            Callback = function()
                TeleportTo(Teleport.CFrame)
            end
        })
    end
end
