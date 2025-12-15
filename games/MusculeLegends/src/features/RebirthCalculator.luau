--!strict

local Logger = require("../shared/Logger")
local CalculatorData = require("../data/RebirthCalculator")

local XpTables = CalculatorData.XpTables
local Rocks = CalculatorData.Rocks

local function GetGlitchInfo(Rebirth, RockName, Rarity, Type)
    local XpPerHit = Rocks[RockName]
    if not XpPerHit then
        return "Invalid rock selected."
    end

    local XpGain = (Rebirth + 20) * XpPerHit
    if XpGain % 1 ~= 0 then
        return Rebirth .. " is not glitchable."
    end

    local Data = XpTables[Type] and XpTables[Type][Rarity]
    if not Data then
        return "Invalid rarity or type selected."
    end

    local TargetXp
    for _, Xp in ipairs(Data.Accommodation) do
        if Xp >= XpGain then
            TargetXp = Xp
            break
        end
    end

    if not TargetXp then
        return "Not Glitchable."
    end

    local RemainingXp = TargetXp - XpGain
    for Level, Cost in ipairs(Data.PerLevel) do
        if RemainingXp < Cost then
            return string.format(
                "Rock: %s\nXP Gained: %d\nAccommodation XP Needed: %d\nLevel: %d\nXP to put on %s: %d",
                RockName,
                XpGain,
                TargetXp,
                Level,
                Type,
                RemainingXp
            )
        end
        RemainingXp -= Cost
    end

    return "Couldn't match any level."
end

return function(Window, Options)
    local StartTime = os.clock()

    local Tab = Window:AddTab({ Title = "Rebirth Calculator", Icon = "calculator" })

    local CurrentRebirth
    local CurrentRock
    local CurrentType = "Pet"
    local CurrentRarity = "Unique"
    local LastResult

    local RockNames = {}
    for Name in pairs(Rocks) do
        RockNames[#RockNames + 1] = Name
    end
    table.sort(RockNames)

    local ResultParagraph =
        Tab:AddParagraph("Result", {
            Title = "Result",
            Content = "Enter values to calculate."
        })

    local function UpdateResult()
        if not CurrentRebirth or not CurrentRock then
            ResultParagraph:SetContent("Please enter a rebirth and select a rock.")
            return
        end

        local Rebirth = tonumber(CurrentRebirth)
        if not Rebirth or Rebirth % 2 ~= 0 then
            ResultParagraph:SetContent("Odd rebirths can't glitch!")
            return
        end

        local Result = GetGlitchInfo(Rebirth, CurrentRock, CurrentRarity, CurrentType)
        ResultParagraph:SetContent(Result)
        LastResult = Result
    end

    Tab:AddInput("Rebirth", {
        Title = "Rebirth Count",
        Placeholder = "Even number only",
        Numeric = true
    }):OnChanged(function(Value)
        CurrentRebirth = Value
        UpdateResult()
    end)

    Tab:AddDropdown("Rock", {
        Title = "Rock",
        Values = RockNames,
        Default = 1
    }):OnChanged(function(Value)
        CurrentRock = Value
        UpdateResult()
    end)

    Tab:AddDropdown("Rarity", {
        Title = "Pet Rarity",
        Values = {"Basic", "Advanced", "Rare", "Epic", "Unique"},
        Default = 5
    }):OnChanged(function(Value)
        CurrentRarity = Value
        UpdateResult()
    end)

    Tab:AddDropdown("Type", {
        Title = "Type",
        Values = {"Pet", "Aura"},
        Default = 1
    }):OnChanged(function(Value)
        CurrentType = Value
        UpdateResult()
    end)

    Tab:AddButton({
        Title = "Copy To Clipboard",
        Callback = function()
            if LastResult then
                setclipboard(LastResult)
            end
        end
    })

    Logger.Log("RebirthCalculator initialized in " .. tostring(os.clock() - StartTime))
end
