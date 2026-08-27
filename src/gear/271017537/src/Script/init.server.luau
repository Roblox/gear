--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Bubbles = Handle:WaitForChild("Bubbles")
Ink = Handle:WaitForChild("Ink")
ProjectileScript = script:WaitForChild("ProjectileScript")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Size = Vector3.new(1, 2.25, 1)
BaseProjectile.BrickColor = BrickColor.new("Really black")
BaseProjectile.CanCollide = false
BaseProjectile.Anchored = false
BaseProjectileMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "11144802"),
	TextureId = (BaseUrl .. "11144797"),
	Scale = Vector3.new(0.5, 0.5, 0.5),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseProjectile,
}

Projectiles = {
	Vector3.new(-0.125, 0, -3),
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

Gravity = 196.20

ReloadTime = 1.5
Damage = 15

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local MousePosition = InvokeClient("MousePosition")
	if MousePosition then
		Sounds.Fire:Play()
		MousePosition = MousePosition.Position
		local CreatedProjectiles = {}
		for i, v in pairs(Projectiles) do
			local Offset = (Handle.CFrame * CFrame.new(v))
			local Direction = CFrame.new(Offset.p, MousePosition)
			local Orientation = (Direction * CFrame.Angles((math.pi / 2), 0, 0))
			local Projectile = BaseProjectile:Clone()
			local RageChance = math.random(1, 10)
			local RageMode = (RageChance == 1)
			if RageMode then
				local Mesh = Projectile.Mesh
				Mesh.VertexColor = Vector3.new((255 / 255), (0 / 255), (122 / 255))
				local Particles = Ink:Clone()
				Particles.Enabled = true
				Particles.Parent = Projectile
				local RageMode = Create("StringValue"){
					Name = "RageMode",
					Value = "",
					Parent = Projectile,
				}
			else
				local Particles = Bubbles:Clone()
				Particles.Enabled = true
				Particles.Parent = Projectile
			end
			Projectile.CFrame = Orientation
			local Force = 100
			local Mass = (Projectile:GetMass() * Gravity)
			local Velocity = (Direction.lookVector * Force)
			local BodyVelocity = Create("BodyVelocity"){
				maxForce = Vector3.new(Mass, Mass, Mass),
				velocity = Velocity,
				Parent = Projectile,
			}
			local BodyGyro = Create("BodyGyro"){
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				cframe = Orientation,
				Parent = Projectile,
			}
			Projectile.Velocity = Velocity
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue", Value = (Damage * ((RageMode and 2) or 1))},
			}
			for ii, vv in pairs(Values) do
				local Value = Create(vv.Class){
					Name = vv.Name,
					Value = vv.Value,
					Parent = Projectile,
				}
			end
			local ProjectileScriptCopy = ProjectileScript:Clone()
			ProjectileScriptCopy.Disabled = false
			ProjectileScriptCopy.Parent = Projectile
			Debris:AddItem(Projectile, 2)
			Projectile.Parent = game:GetService("Workspace")
		end
		wait(ReloadTime)
	end
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
end

function Unequipped()
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