local Logger = require("../shared/Logger")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local AutoRebirthRunning = false
local AutoRebirthThread = nil

local function GetRebirthCost()
    local Stats = LocalPlayer:FindFirstChild("leaderstats")
    if not Stats then return math.huge end

    local Rebirths = Stats:FindFirstChild("Rebirths")
    if not Rebirths then return math.huge end

    local Cost = 10000 + (5000 * Rebirths.Value)

    local Ultimates = LocalPlayer:FindFirstChild("ultimatesFolder")
    if Ultimates and Ultimates:FindFirstChild("Golden Rebirth") then
        Cost = math.floor(Cost * (1 - (Ultimates["Golden Rebirth"].Value * 0.1)))
    end

    return Cost
end

local function AutoRebirthLoop(Options)
    Logger.Log("AutoRebirth started")

    while AutoRebirthRunning do
        local Stats = LocalPlayer:FindFirstChild("leaderstats")
        if not Stats then
            task.wait(1)
            continue
        end

        local Strength = Stats:FindFirstChild("Strength")
        local Rebirths = Stats:FindFirstChild("Rebirths")
        if not Strength or not Rebirths then
            task.wait(1)
            continue
        end

        if Options.TargetRebirthEnabled and Rebirths.Value >= (Options.TargetRebirth or 0) then
            AutoRebirthRunning = false
            break
        end

        local RebirthCost = GetRebirthCost()

        if Strength.Value >= RebirthCost then
            ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end

    Logger.Log("AutoRebirth stopped")
end

local function StartAutoRebirth(Options)
    if AutoRebirthRunning then return end
    AutoRebirthRunning = true
    AutoRebirthThread = task.spawn(function()
        AutoRebirthLoop(Options)
    end)
end

local function StopAutoRebirth()
    AutoRebirthRunning = false
end

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({
        Title = "Auto Rebirth",
        Icon = "bot"
    })

    Tab:AddToggle("AutoRebirth", {
        Title = "Auto Rebirth",
        Default = false
    }):OnChanged(function(State)
        Options.AutoRebirth = State
        if State then
            StartAutoRebirth(Options)
        else
            StopAutoRebirth()
        end
    end)

    Tab:AddInput("TargetRebirth", {
        Title = "Target Rebirth",
        Default = "",
        Placeholder = "10000",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            Options.TargetRebirth = tonumber(Value)
        end
    })

    Tab:AddToggle("TargetRebirthEnabled", {
        Title = "Target Rebirth Enabled",
        Default = false
    }):OnChanged(function(State)
        Options.TargetRebirthEnabled = State
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        if Options.AutoRebirth then
            StartAutoRebirth(Options)
        end
    end)

    Logger.Log(("AutoRebirth init done in %.3fs"):format(os.clock() - StartTime))
end
