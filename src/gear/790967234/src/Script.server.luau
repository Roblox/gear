--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Character = nil
local Humanoid = nil
local OriginalWalkSpeed = 16

local FAST_WALKSPEED = 25

local Grips = {
	R15 = CFrame.new(0.699999988, -0.200000003, 0, 0, -1, 0, 0.772708714, 0, -0.634760797, 0.634760737, 0, 0.772708833);
	R6 = CFrame.new(0.699999988, -0.200000003, 0, 0.829463363, -0.55516243, 0.0615250356, 0, -0.110149145, -0.993915081, 0.558561206, 0.824416161, -0.0913646743)
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