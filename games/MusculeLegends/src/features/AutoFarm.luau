local Logger = require("../shared/Logger")
local GetTool = require("../utils/GetTool")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local AutoEggRunning = false
local AutoEggThread = nil

local ToolRunning = {}
local ToolThreads = {}

local function ForceSitLoop()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    if not Humanoid or Humanoid.Sit then return end

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.3)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

    repeat
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.1)
    until Humanoid.Sit
end

local function ShouldEatEgg()
    local Folder = LocalPlayer:FindFirstChild("boostTimersFolder")
    local Egg = Folder and Folder:FindFirstChild("Protein Egg")
    return not Egg or Egg.Value < 5
end

local function EatEgg()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    if Humanoid and not Humanoid.Sit then
        ForceSitLoop()
    end
    ReplicatedStorage.rEvents.proteinEggEvent:FireServer("useEgg")
end

local function AutoEggLoop()
    Logger.Log("AutoEgg started")
    while AutoEggRunning do
        if ShouldEatEgg() then
            EatEgg()
        end
        task.wait(1)
    end
    Logger.Log("AutoEgg stopped")
end

local function StartAutoEgg()
    if AutoEggRunning then return end
    AutoEggRunning = true
    AutoEggThread = task.spawn(AutoEggLoop)
end

local function StopAutoEgg()
    if not AutoEggRunning then return end
    AutoEggRunning = false
end

local function AutoToolLoop(ToolName)
    Logger.Log("Started farm: " .. ToolName)

    while ToolRunning[ToolName] do
        local Character = LocalPlayer.Character
        local Tool = GetTool(ToolName)

        if Tool and Character then
            Tool.Parent = Character

            if ToolName == "Punch" then
                LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
                LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
            else
                for _ = 1, 10 do
                    LocalPlayer.muscleEvent:FireServer("rep")
                    task.wait()
                end
            end
        end

        task.wait()
    end

    local Tool = GetTool(ToolName)
    if Tool and LocalPlayer.Backpack then
        Tool.Parent = LocalPlayer.Backpack
    end

    Logger.Log("Stopped farm: " .. ToolName)
end

local function StartTool(ToolName)
    if ToolRunning[ToolName] then return end
    ToolRunning[ToolName] = true
    ToolThreads[ToolName] = task.spawn(function()
        AutoToolLoop(ToolName)
    end)
end

local function StopTool(ToolName)
    if not ToolRunning[ToolName] then return end
    ToolRunning[ToolName] = false
end

return function(Window, Options)
    local StartTime = os.clock()
    local FarmTab = Window:AddTab({ Title = "Auto Farm", Icon = "bot" })

    FarmTab:AddToggle("AutoEatEgg", { Title = "Auto Protein Egg", Default = false })
        :OnChanged(function(State)
            Options.AutoEatEgg = State
            if State then
                StartAutoEgg()
            else
                StopAutoEgg()
            end
        end)

    local ToolMap = {
        Weight = "Weight",
        Pushups = "Pushups",
        Situps = "Situps",
        Handstand = "Handstands",
        Punch = "Punch"
    }

    for Name, ToolName in pairs(ToolMap) do
        ToolRunning[ToolName] = false

        FarmTab:AddToggle("Auto" .. Name, { Title = "Auto " .. Name, Default = false })
            :OnChanged(function(State)
                Options["Auto" .. Name] = State
                if State then
                    StartTool(ToolName)
                else
                    StopTool(ToolName)
                end
            end)
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if Options.AutoEatEgg then
            StartAutoEgg()
        end

        for _, ToolName in pairs(ToolMap) do
            if ToolRunning[ToolName] then
                StartTool(ToolName)
            end
        end
    end)

    Logger.Log(("Farm init done in %.3fs"):format(os.clock() - StartTime))
end
