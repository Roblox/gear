--Rescripted by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Grips = {
	Normal = CFrame.new(0.300000012, 0, 0, 0.217036337, 0, 0.976163626, 0, 1, -0, -0.976163507, 0, 0.217036366),
	Eating = CFrame.new(0.949999988, -0.75999999, 1.39999998, 0.217036337, 0, -0.976163626, 0, 1, 0, 0.976163507, -0, 0.217036366),
}

Sounds = {
	Open = Handle:WaitForChild("Open"),
	Drink = Handle:WaitForChild("Drink"),
}

ToolEquipped = false

Tool.Grip = Grips.Normal
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	
	Tool.Enabled = false
	
	Tool.Grip = Grips.Eating
	
	Sounds.Drink:Play()
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	local CurrentlyEquipped = true
	
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	wait(0.8)
	
	if CurrentlyEquipped and CheckIfAlive() then
		Humanoid.Health = (Humanoid.Health + 1.6)
	end
	
	Tool.Grip = Grips.Normal
	
	Tool.Enabled = true

end

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
	ToolEquipped = true
	Sounds.Open:Play()
end

function Unequipped()
	Tool.Grip = Grips.Normal
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)