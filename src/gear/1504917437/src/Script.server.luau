-- // Created by StarWars
local Tool = script.Parent

local CacheJumpPower = 50
local Humanoid = nil

Tool.Equipped:Connect(function()
	local Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		CacheJumpPower = Humanoid.JumpPower
		Humanoid.JumpPower = CacheJumpPower * 2
	end
end)

Tool.Unequipped:Connect(function()
	if Humanoid then
		Humanoid.JumpPower = CacheJumpPower
	end
end)