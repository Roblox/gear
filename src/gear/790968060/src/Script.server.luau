-- // Made by StarWars
local RunService = game:GetService('RunService')

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Character = nil
local Torso = nil
local Humanoid = nil

local Grips = {
	R15 = CFrame.new(1.25, 0, 0.150000006, 0.98042661, 0, -0.196884856, 0, 1, 0, 0.196884856, -0, 0.98042661);
	R6 = CFrame.new(1, 0, 0.150000006, 0.943841159, -0, 0.330399513, 0, 1, 0, -0.330399483, 0, 0.943841279);
}

function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	
	if not Humanoid then return end
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Tool.Grip = Grips.R15
	elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
		Tool.Grip = Grips.R6
	end	
	
	Humanoid.JumpPower = 75
end

function OnUnequipped()
	if Humanoid then
		Humanoid.JumpPower = 50
	end
	Character = nil
	Humanoid = nil
	Torso = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)