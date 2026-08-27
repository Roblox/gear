--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent
RightArm = Character:WaitForChild("Right Arm") or Character:FindFirstChild("RightHand")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = script:WaitForChild("Creator")
Food = script:WaitForChild("Food")
Eat = script:WaitForChild("EatAnim")
R15Eat = script:WaitForChild("R15EatAnim")

Damage = 20

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

Player = Players:GetPlayerFromCharacter(Character)
if Player then
	Backpack = Player:FindFirstChild("Backpack")
	if Backpack then
		Character.ChildAdded:connect(function(Child)
			wait()
			if Child and Child.Parent and Child:IsA("Tool") then
				Child.Parent = Backpack
			end
		end)
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = Backpack
			end
		end
	end
end

Humanoid.WalkSpeed = 0
OldFood = Food.Value
Food = Food.Value:Clone()
OldFood:Destroy()
RightGrip = Instance.new("Weld")
RightGrip.Part0 = RightArm
RightGrip.Part1 = Food
RightGrip.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
RightGrip.C1 = CFrame.new(-0.550000012, 0.300000012, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0)
RightGrip.Parent = RightArm
Food.Parent = Character
if Humanoid then
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		EatAnim = Humanoid:LoadAnimation(R15Eat)
	else 
		EatAnim = Humanoid:LoadAnimation(Eat)
	end 
end
if EatAnim then
	EatAnim:Play()
end
wait(1.5)
UntagHumanoid(Humanoid)
TagHumanoid(Humanoid, Creator.Value)
Humanoid:TakeDamage(Damage)
if EatAnim then
	EatAnim:Stop()
end
Food:Destroy()
Humanoid.WalkSpeed = 16
script:Destroy()