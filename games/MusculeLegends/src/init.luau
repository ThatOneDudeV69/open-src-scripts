local Logger = require("./shared/Logger")

local StartTime = os.clock()

local LoadedTasks = {}
local SaveManagerLoaded = false

local function FetchCachedFile(FileName, Url)
	if not isfile(FileName) then
		local Success, Response = pcall(game.HttpGetAsync, game, Url)
		if not Success then
			error("Failed to fetch " .. Url)
		end
		writefile(FileName, Response)
	end
	return FileName
end

local FluentTask = FetchCachedFile(
	"Fluent.luau",
	"https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"
)
local SaveManagerTask = FetchCachedFile(
	"SaveManager.luau",
	"https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"
)

local Fluent, Options, Window
local SaveManager

task.spawn(function()
	Fluent = loadfile(FluentTask)()
	Options = Fluent.Options
	Window = Fluent:CreateWindow({
		Title = "Vector",
		SubTitle = "By Jake",
		TabWidth = 200,
		Size = UDim2.fromOffset(500, 300),
		Acrylic = true,
		Theme = "Darker",
		MinimizeKey = Enum.KeyCode.LeftControl,
	})
end)

task.spawn(function()
	SaveManager = loadfile(SaveManagerTask)()
	SaveManagerLoaded = true
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/AutoFarm")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/PackFarm")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/AutoRebirth")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/Teleports")(Window, Options)
	table.insert(LoadedTasks, true)
end)

--[[task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/AutoKill")(Window, Options)
	table.insert(LoadedTasks, true)
end)
]]
task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/Crystals")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/Stats")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/RebirthCalculator")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/Misc")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until Window and Options
	require("./features/Credit")(Window, Options)
	table.insert(LoadedTasks, true)
end)

task.spawn(function()
	repeat
		task.wait()
	until SaveManagerLoaded and Window
	local SettingsTab = Window:CreateTab({ Title = "Config", Icon = "server-cog" })
	SaveManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})
	SaveManager:SetFolder("FluentScriptHub/MusculeLegends")
	SaveManager:BuildConfigSection(SettingsTab)
	SaveManager:LoadAutoloadConfig()
end)

task.spawn(function()
	repeat
		task.wait()
	until #LoadedTasks == 9 and SaveManagerLoaded
	Logger.Log("MusculeLegends fully initialized in " .. tostring(os.clock() - StartTime) .. " seconds")
end)
