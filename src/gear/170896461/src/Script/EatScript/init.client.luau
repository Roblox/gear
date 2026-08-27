--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Food = script:WaitForChild("Food").Value
Eat = script:WaitForChild("EatAnim")
R15Eat = script:WaitForChild("R15EatAnim")

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

if Humanoid.RigType == Enum.HumanoidRigType.R15 then
	EatAnim = Humanoid:LoadAnimation(R15Eat)
else
	EatAnim = Humanoid:LoadAnimation(Eat)
end
if EatAnim then
	EatAnim:Play()
end

Food.Changed:connect(function(Property)
	if Property == "Parent" and not Food.Parent then
		if EatAnim then
			EatAnim:Stop()
		end
		script:Destroy()
	end
end)