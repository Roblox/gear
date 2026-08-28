--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Character = nil
local Humanoid = nil
local OriginalWalkSpeed = 16

local FAST_WALKSPEED = 25

local Grips = {
	R15 = CFrame.new(0.5, 0, 0, 0, -0.707106829, 0.707106829, 1, 0, 0, -0, 0.707106829, 0.707106829);
	R6 = CFrame.new(0.807406068, -0.278463125, 0.0284301639, 0.873827696, -0.161796004, 0.458527118, -0.0537106693, 0.905124426, 0.421740323, -0.483260036, -0.393156171, 0.782232523)
}

function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Tool.Grip = Grips.R15
	elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
		Tool.Grip = Grips.R6
	end
	OriginalWalkSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = FAST_WALKSPEED
end

function OnUnequipped()
	if Humanoid then
		Humanoid.WalkSpeed = OriginalWalkSpeed
	end
	Character = nil
	Humanoid = nil
	OriginalWalkSpeed = 16
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)