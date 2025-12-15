--!strict

local Logger = require("../shared/Logger")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({ Title = "Misc", Icon = "server-cog" })

    Tab:AddToggle("HideAllFrames", {
        Title = "Hide All Frames",
        Default = false
    }):OnChanged(function()
        for _, Obj in ipairs(ReplicatedStorage:GetChildren()) do
            if Obj.Name:match("Frame$") then
                Obj.Visible = not Options.HideAllFrames.Value
            end
        end
    end)

    Logger.Log("Misc initialized in " .. tostring(os.clock() - StartTime))
end
