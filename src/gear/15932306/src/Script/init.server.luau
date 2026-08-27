--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	Drink = Handle:WaitForChild("Drink"),
}

Grips = {
	Normal = CFrame.new(0.200000003, -0.100000001, 0, 0.217036337, 0, 0.976163626, 0, 1, -0, -0.976163507, 0, 0.217036366),
	Active = CFrame.new(1.5, -0.5, 0.300000012, 1, 0, -0, -0, 0.651038408, 0.759044766, 0, -0.759044766, 0.651038408),
}

SpeedEffect = script:WaitForChild("SpeedEffect")

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Tool.Grip = Grips.Active
	Sounds.Drink:Play()
	wait(3)
	if CheckIfAlive() then
		local EffectCopy = Character:FindFirstChild(SpeedEffect.Name)
		if not EffectCopy then
			EffectCopy = SpeedEffect:Clone()
			EffectCopy.Disabled = false
			EffectCopy.Parent = Character
		end
	end
	Tool.Grip = Grips.Normal
	wait(60)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)