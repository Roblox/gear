--Made by Luckymaxer
--[[
	Fixed by ArceusInator
	- Works with FE
--]]

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

EquipSound = Handle:WaitForChild("EquipSound")
PewPew = Handle:WaitForChild("PewPew")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 3

Damage = 20

Grips = {
	NormalGrip = CFrame.new(0.125, -0.25, 0.949999988, 1, 0, -3.69598024e-006, 0, 1, 0, 3.69598024e-006, 0, 1),
	ReloadGrip = CFrame.new(0.125, -0.25, 0.949999988, 1, 0, -0, -0, 0.957826257, -0.287347883, 0, 0.287347883, 0.957826257),
	FireGrip = CFrame.new(0.125, -0.25, 0.949999988, 1, 0, 0, -0, 0.988936365, 0.148340464, 0, -0.148340464, 0.988936365)
}

Rounds = 3
TimesShot = 0

Projectile = Instance.new("Part")
Projectile.Name = "Projectile"
Projectile.Material = Enum.Material.Plastic
Projectile.Shape = Enum.PartType.Block
Projectile.FormFactor = Enum.FormFactor.Custom
Projectile.TopSurface = Enum.SurfaceType.Smooth
Projectile.BottomSurface = Enum.SurfaceType.Smooth
Projectile.Size = Vector3.new(0.25, 0.25, 0.25)
Projectile.CanCollide = true
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Sphere
Mesh.Parent = Projectile

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

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

function PositionProjectile(handle, x, y, z)
	local HandleClone = handle:Clone()
	local HandleCloneY = HandleClone:Clone()
	HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
	HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * y
	local HandleCloneZ = HandleCloneY:Clone()
	HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * z
	local HandleCloneX = HandleCloneZ:Clone()
	HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * x
	return HandleCloneX.CFrame
end

function Activated(TargetPoint)
	if Tool.Enabled then
		Tool.Enabled = false
		if TimesShot < Rounds then
			TimesShot = TimesShot + 1
			PewPew:Play()
			local Positions = {
				Vector3.new(0.5, 0, ((Handle.Size.Z / 2) + (Projectile.Size.Z / 2) - 0)),
				Vector3.new(0.15, 0, ((Handle.Size.Z / 2) + (Projectile.Size.Z / 2) - 0)),
				Vector3.new(-0.20, 0, ((Handle.Size.Z / 2) + (Projectile.Size.Z / 2) - 0)),
				Vector3.new(-0.55, 0, ((Handle.Size.Z / 2) + (Projectile.Size.Z / 2) - 0)),
			}
			local OriginalCFrame = Handle.CFrame
			Tool.Grip = Grips.FireGrip
			for i, v in pairs(Positions) do
				local ProjectileClone = Projectile:Clone()
				local BodyForce = Instance.new("BodyForce")
				BodyForce.force = Vector3.new(0, ProjectileClone:GetMass() * 196.20, 0)
				BodyForce.Parent = ProjectileClone
				ProjectileClone.Touched:connect(function(Hit)
					if Hit and Hit.Parent and Hit.Name ~= Projectile.Name then
						local character, humanoid = FindCharacterAncestor(Hit.Parent)
						if character and character ~= Character and humanoid and humanoid.Health > 0 then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(Damage)
						end
						if not character or character ~= Character then
							ProjectileClone:Destroy()
						end
					end
				end)
				Debris:AddItem(ProjectileClone, 5)
				ProjectileClone.Parent = game:GetService("Workspace")
				ProjectileClone.CFrame = PositionProjectile(Handle, v.X, v.Y, v.Z)
				ProjectileClone.Velocity = CFrame.new(ProjectileClone.Position, TargetPoint).lookVector * 25
			end
			wait(0.25)
			Tool.Grip = Grips.NormalGrip
			wait(0.25)
		else
			Tool.Grip = Grips.ReloadGrip
			wait(ReloadTime)
			Tool.Grip = Grips.NormalGrip
			TimesShot = 0
		end
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid then
		return
	end
	Equipped = true
	Tool.Grip = Grips.NormalGrip
	EquipSound:Play()
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Equipped = false
end

--Tool.Activated:connect(Activated)
Tool:WaitForChild'RemoteClick'.OnServerEvent:connect(function(client, p)
	if client.Character == Tool.Parent then
		Activated(p)
	end
end)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)