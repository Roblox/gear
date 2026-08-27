--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ProjectileScript = script:WaitForChild("ProjectileScript")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Shape = Enum.PartType.Ball
BaseProjectile.Size = Vector3.new(1, 1, 1)
BaseProjectile.BrickColor = BrickColor.new("Really blue")
BaseProjectile.Reflectance = 0.5
BaseSpark = Instance.new("Sparkles")
BaseSpark.Name = "Spark"
BaseSpark.SparkleColor = Color3.new(0, 0, 1)
BaseSpark.Enabled = true
BaseSpark.Parent = BaseProjectile

Grips = {
	Up = CFrame.new(0, -1, -0.300000012, 1, 0, -0, -0, 0.19592391, -0.980619073, 0, 0.980619192, 0.19592388),
	Out = CFrame.new(0, -1, -0.300000012, 1, 0, -0, 0, 0, -1, 0, 1, -0),
}

Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	PewPew = Handle:WaitForChild("PewPew"),
	Hit = Handle:WaitForChild("Hit"),
}

ReloadTime = 0.1

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ToolEquipped = false

Tool.Grip = Grips.Out
Tool.Enabled = true

function Fire(Direction)
	
	local SpawnPos = (Handle.Position + (Direction * 10))
	
	local Gravity = 196.20
	local Force = 200
	
	local Mass = (BaseProjectile:GetMass() * Gravity)

	local Projectile = BaseProjectile:Clone()
	Projectile.CFrame = CFrame.new(SpawnPos)
	Projectile.Velocity = (Direction * Force)
	local HitSound = Sounds.Hit:Clone()
	HitSound.Parent = Projectile
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)	
	BodyVelocity.velocity = (Direction * Force)
	BodyVelocity.Parent = Projectile
	
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Value = Player
	CreatorTag.Name = "Creator"
	CreatorTag.Parent = Projectile
	
	local ProjectileScriptClone = ProjectileScript:Clone()
	ProjectileScriptClone.Disabled = false
	ProjectileScriptClone.Parent = Projectile
	
	Debris:AddItem(Projectile, 5)
	Projectile.Parent = game:GetService("Workspace")

	Sounds.PewPew:Play()

end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	
	local TargetPos = InvokeClient("MousePosition")
	if not TargetPos then
		return
	end
	TargetPos = TargetPos.Position
	local Direction = (TargetPos - Handle.Position).unit
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end	
	
	local CurrentlyEquipped = true
	
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	Tool.Enabled = false
	
	for i = 1, 3 do
		if CurrentlyEquipped then
			Tool.Grip = Grips.Up
			Fire(Direction)
			wait(ReloadTime)
			Tool.Grip = Grips.Out
			wait(ReloadTime)
		end
	end
	
	wait(0.6)
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
	Sounds.Equip:Play()
end

function Unequipped()
	Tool.Grip = Grips.Out
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end	
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
