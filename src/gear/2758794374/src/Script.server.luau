Tool = script.Parent
Handle = Tool.Handle

Players = game:GetService("Players")

Sparkles = Handle:WaitForChild("Sparkles")

Sounds = {
	Clap = Handle:WaitForChild("Clap"),
}

ToolEquipped = false

Sparkles.Enabled = false
Tool.Enabled = true

function Goldify(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local MassCheck = Hit:Clone()
	MassCheck.Material = Enum.Material.Plastic
	if MassCheck:GetMass() <= 5 then
		return
	end
	Hit.Material = Enum.Material.Ice
	Hit.TopSurface = Enum.SurfaceType.Smooth
	Hit.BottomSurface = Enum.SurfaceType.Smooth
	Hit.BrickColor = BrickColor.new("Bright yellow")
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Health > 0) and true) or false)
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds.Clap:Play()
	Sparkles.Enabled = true
	GoldifyHit = Handle.Touched:connect(Goldify)
	wait(5)
	if GoldifyHit then
		GoldifyHit:disconnect()
	end
	Sparkles.Enabled = false
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
	if GoldifyHit then
		GoldifyHit:disconnect()
	end
	Sounds.Clap:Stop()
	Sparkles.Enabled = false
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

