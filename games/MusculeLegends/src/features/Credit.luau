--!strict

local Logger = require("../shared/Logger")

local DiscordInvite = "https://discord.gg/DfyeaRbTCC"

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({ Title = "Credits", Icon = "user" })

    local stupidlineododod  = "just move on. discord: xyz.jake"

    Tab:AddParagraph("JakeCredit", {
        Title = "Jake",
        Content = stupidlineodododo
    })

    Tab:AddButton({
        Title = "Discord",
        Description = "Join our discord!",
        Callback = function()
            setclipboard(DiscordInvite)
        end
    })

    Logger.Log("Credits initialized in " .. tostring(os.clock() - StartTime))
end
