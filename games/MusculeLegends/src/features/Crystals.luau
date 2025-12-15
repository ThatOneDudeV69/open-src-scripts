--!strict

local Logger = require("../shared/Logger")
local CrystalData = require("../data/Crystals")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OpenCrystalRemote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("openCrystalRemote")

local CrystalThread = {}

local function AutoOpenCrystal(CrystalName: string, FlagName: string, Options)
    while Options[FlagName].Value do
        pcall(function()
            OpenCrystalRemote:InvokeServer("openCrystal", CrystalName)
        end)
        task.wait(1)
    end
end

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({ Title = "Crystals", Icon = "gem" })

    for FlagName, CrystalName in pairs(CrystalData) do
        Tab:AddToggle(FlagName, {
            Title = "Auto " .. CrystalName,
            Default = false
        }):OnChanged(function()
            if Options[FlagName].Value then
                if CrystalThreads[FlagName] then
                    return
                end

                CrystalThreads[FlagName] =
                    task.spawn(function()
                        AutoOpenCrystal(CrystalName, FlagName, Options)
                        CrystalThreads[FlagName] = nil
                    end)
            end
        end)
    end

    Logger.Log("Crystals initialized in " .. tostring(os.clock() - StartTime))
end
