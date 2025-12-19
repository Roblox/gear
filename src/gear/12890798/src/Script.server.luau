--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	Calibrate = Handle:WaitForChild("Calibrate"),
	Explosion = Handle:WaitForChild("Explosion"),
}

Grips = {
	Normal = CFrame.new(0, 0, -0.4, 0, 0, 1, 1, 0, 0, 0, 1, 0),
	Active = CFrame.new(0.5, -1.5, -1.56, 0, 0, -1, -0.707, -0.707, -0, -0.707, 0.707, 0),
}

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
	Sounds.Calibrate:Play()
	wait(2)
	local Explosion = Instance.new("Explosion")
	Explosion.ExplosionType = Enum.ExplosionType.NoCraters
	Explosion.BlastRadius = 2
	Explosion.BlastPressure = 1000000
	Explosion.Position = Handle.Position
	Explosion.Parent = game:GetService("Workspace")
	wait(0.1)
	Tool.Parent = game:GetService("Workspace")
	Tool.Grip = Grips.Normal
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