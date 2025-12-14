--!strict

local Logger = require("./shared/Logger")

local AutoFarm = require("./features/AutoFarm")
local PackFarm = require("./features/PackFarm")

local StartTime = os.clock()

local Fluent =
    loadstring(
        game:HttpGet(
            "https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"
        )
    )()

local Options = Fluent.Options

local Window =
    Fluent:CreateWindow({
        Title = "Vector",
        SubTitle = "By Jake",
        TabWidth = 200,
        Size = UDim2.fromOffset(500, 300),
        Acrylic = true,
        Theme = "Darker",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

AutoFarm(Window, Options)
PackFarm(Window, Options)

Logger.Log(("Fully initialized in %.3fs"):format(os.clock() - StartTime))
