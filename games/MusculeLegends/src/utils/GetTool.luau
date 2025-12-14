local Players = game:GetService("Players")

local function GetTool(ToolName)
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		return nil
	end

	local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	if Backpack then
		local Tool = Backpack:FindFirstChild(ToolName)
		if Tool then
			return Tool
		end
	end

	local Character = LocalPlayer.Character
	if Character then
		local Tool = Character:FindFirstChild(ToolName)
		if Tool then
			return Tool
		end
	end

	return nil
end

return GetTool
