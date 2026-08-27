--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ToolEquipped = false

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if RightArm then
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if RightGrip then
			RightGripMotor = Instance.new("Motor6D")
			RightGripMotor.Part0 = RightGrip.Part0
			RightGripMotor.Part1 = RightGrip.Part1
			RightGrip.Part0 = nil
			RightGrip.Part1 = nil
			RightGripMotor.Parent = RightGrip.Parent
			if RightGrip and RightGrip.Parent then
				RightGrip:Destroy()
				Debris:AddItem(RightGrip, 0)
			end
		end
	end
	ToolEquipped = true
end

function Unequipped()
	if RightGripMotor and RightGripMotor.Parent then
		RightGripMotor:Destroy()
		Debris:AddItem(RightGripMotor, 0)
	end
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)