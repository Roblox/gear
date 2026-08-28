--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if RightArm then
		local RightGrip = RightArm:WaitForChild("RightGrip")
		if RightGrip and CurrentlyEquipped and CurrentlyEquipped then
			RightGripMotor = Instance.new("Motor6D")
			RightGripMotor.Name = "RightGrip"
			RightGripMotor.Part0 = RightGrip.Part0
			RightGripMotor.Part1 = RightGrip.Part1
			RightGripMotor.C0 = RightGrip.C0
			RightGripMotor.C1 = RightGrip.C1
			RightGrip:Destroy()
			RightGripMotor.Parent = RightArm
		end
	end
end

function Unequipped()
	for i, v in pairs({RightGripMotor, ToolUnequipped}) do
		if tostring(v) == "Connection" then
			v:disconnect()
		elseif type(v) == "userdata" and v and v.Parent then
			v:Destroy()
		end
	end
	if RightGripMotor and RightGripMotor.Parent then
		RightGripMotor:Destroy()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)