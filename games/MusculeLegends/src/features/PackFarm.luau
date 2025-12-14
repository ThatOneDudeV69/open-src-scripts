local Logger = require("../shared/Logger")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local PackFarmRunning = false
local PackFarmThread = nil
local SpeedGrindRunning = false
local SpeedGrindThread = nil

local function UnequipAllPets()
    local PetsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not PetsFolder then return end

    for _, Folder in ipairs(PetsFolder:GetChildren()) do
        if Folder:IsA("Folder") then
            for _, Pet in ipairs(Folder:GetChildren()) do
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", Pet)
            end
        end
    end

    task.wait(0.1)
end

local function EquipUniquePet(PetName)
    local PetsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not PetsFolder then return end

    UnequipAllPets()
    task.wait(0.05)

    local Unique = PetsFolder:FindFirstChild("Unique")
    if not Unique then return end

    for _, Pet in ipairs(Unique:GetChildren()) do
        if Pet.Name == PetName then
            ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", Pet)
        end
    end
end

local function FindMachine(MachineName)
    local MachinesFolder = workspace:FindFirstChild("machinesFolder")
    if MachinesFolder then
        local Machine = MachinesFolder:FindFirstChild(MachineName)
        if Machine then return Machine end
    end

    for _, Folder in ipairs(workspace:GetChildren()) do
        if Folder:IsA("Folder") and Folder.Name:lower():find("machines") then
            local Machine = Folder:FindFirstChild(MachineName)
            if Machine then
                return Machine
            end
        end
    end
end

local function PressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

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

local function StartSpeedGrind()
    if SpeedGrindRunning then return end
    SpeedGrindRunning = true

    SpeedGrindThread = task.spawn(function()
        while SpeedGrindRunning do
            for _ = 1, 12 do
                LocalPlayer.muscleEvent:FireServer("rep")
            end
            task.wait()
        end
    end)
end

local function StopSpeedGrind()
    SpeedGrindRunning = false
end

local function PackFarmLoop()
    Logger.Log("PackFarm started")

    while PackFarmRunning do
        local Stats = LocalPlayer:FindFirstChild("leaderstats")
        if not Stats then
            task.wait(1)
            continue
        end

        local Strength = Stats:FindFirstChild("Strength")
        if not Strength then
            task.wait(1)
            continue
        end

        local RebirthCost = GetRebirthCost()

        EquipUniquePet("Swift Samurai")

        while PackFarmRunning and Strength.Value < RebirthCost do
            for _ = 1, 10 do
                LocalPlayer.muscleEvent:FireServer("rep")
            end
            task.wait()
        end

        if not PackFarmRunning then break end

        EquipUniquePet("Tribal Overlord")

        local Machine = FindMachine("Jungle Bar Lift")
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")

        if Machine and Humanoid and Root and Machine:FindFirstChild("interactSeat") then
            Root.CFrame = Machine.interactSeat.CFrame * CFrame.new(0, 3, 0)

            repeat
                task.wait(0.1)
                PressE()
            until Humanoid.Sit or not PackFarmRunning
        end

        if not PackFarmRunning then break end

        local InitialRebirths = Stats.Rebirths.Value

        repeat
            ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            task.wait(0.2)
        until Stats.Rebirths.Value > InitialRebirths or not PackFarmRunning

        task.wait()
    end

    Logger.Log("PackFarm stopped")
end

local function StartPackFarm()
    if PackFarmRunning then return end
    PackFarmRunning = true
    PackFarmThread = task.spawn(PackFarmLoop)
end

local function StopPackFarm()
    PackFarmRunning = false
end

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({ Title = "Pack Farm", Icon = "bot" })

    Tab:AddToggle("SpeedGrind", { Title = "Speed Grind (No Rebirth)", Default = false })
        :OnChanged(function(State)
            Options.SpeedGrind = State
            if State then
                StartSpeedGrind()
            else
                StopSpeedGrind()
            end
        end)

    Tab:AddToggle("PackFarm", { Title = "Rebirth using packs", Default = false })
        :OnChanged(function(State)
            Options.PackFarm = State
            if State then
                StartPackFarm()
            else
                StopPackFarm()
            end
        end)

    LocalPlayer.CharacterAdded:Connect(function()
        if Options.SpeedGrind then
            StartSpeedGrind()
        end

        if Options.PackFarm then
            StartPackFarm()
        end
    end)

    Logger.Log(("PackFarm init done in %.3fs"):format(os.clock() - StartTime))
end
