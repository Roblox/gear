--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Equipped = false
MouseDown = false

Void = nil
VoidParts = {}

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

ReloadTime = 3

BasePellet = Instance.new("Part")
BasePellet.Name = "Pellet"
BasePellet.BrickColor = BrickColor.new("Reddish brown")
BasePellet.Material = Enum.Material.Granite
BasePellet.Shape = Enum.PartType.Block
BasePellet.FormFactor = Enum.FormFactor.Custom
BasePellet.TopSurface = Enum.SurfaceType.Smooth
BasePellet.BottomSurface = Enum.SurfaceType.Smooth
BasePellet.Anchored = false
BasePellet.CanCollide = false
BasePellet.Locked = true
BasePellet.Size = Vector3.new(4, 4, 4)

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

function Fire(Direction, Projectile, Velocity, Damage, Duration)
	
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Parent = Projectile
	
	local ProjectileHit	
	
	ProjectileHit = Projectile.Touched:connect(function(Hit)
		if Hit and Hit.Parent then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character and humanoid and character ~= Character then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
				ProjectileHit:disconnect()
			end
		end
	end)
	Debris:AddItem(Projectile, 10)
	BodyVelocity.maxForce = Vector3.new(((Projectile:GetMass() ^ 2) ^ 2), ((Projectile:GetMass() ^ 2) ^ 2), ((Projectile:GetMass() ^ 2) ^ 2))
	BodyVelocity.velocity = Direction * Velocity
	Delay(Duration, function()
		BodyVelocity:Destroy()
	end)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	Equipped = true
	Void = Instance.new("Model")
	Void.Name = "Void"
	Angle = 0
	for i = 1, 5 do
		local VoidPart = Instance.new("Part")
		VoidPart.Name = "VoidPart"
		VoidPart.BrickColor = BrickColor.new("Really black")
		VoidPart.Material = Enum.Material.Plastic
		VoidPart.Shape = Enum.PartType.Block
		VoidPart.FormFactor = Enum.FormFactor.Custom
		VoidPart.TopSurface = Enum.SurfaceType.Smooth
		VoidPart.BottomSurface = Enum.SurfaceType.Smooth
		VoidPart.Anchored = true
		VoidPart.CanCollide = false
		VoidPart.Locked = true
		VoidPart.Size = Vector3.new(10, 0.2, 10)
		local BlockMesh = Instance.new("BlockMesh")
		BlockMesh.Scale = Vector3.new(1, (1 + (0.005 * i)), 1)
		BlockMesh.Parent = VoidPart
		VoidPart.Parent = Void
		table.insert(VoidParts, VoidPart)
	end
	Spawn(function()
		while Equipped and Humanoid.Parent and Humanoid.Health > 0 and Torso.Parent do
			if Angle == 360 then
				Angle = 0
			end
			Angle = Angle + 0.05
			local Hit, EndPosition = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 6.5), {Character})
			if Hit then
				if not Void.Parent then
					Void.Parent = Character
				end
				for i, v in pairs(VoidParts) do
					v.CFrame = CFrame.new(Torso.Position.X, EndPosition.Y, Torso.Position.Z) * CFrame.Angles(0, (Angle + i), 0)
				end
			else
				Void.Parent = nil
			end
			wait()
		end
	end)
end

Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'Mouse1' then
			local down, hit = ...
			
			if down then
				if Tool.Enabled and not MouseDown then
					MouseDown = true
					if Pellet and Pellet.Parent then
						Pellet:Destroy()
					end
					Pellet = BasePellet:Clone()
					BodyPosition = Instance.new("BodyPosition")
					BodyPosition.maxForce = Vector3.new(((Pellet:GetMass() ^ 2) ^ 2), ((Pellet:GetMass() ^ 2) ^ 2), ((Pellet:GetMass() ^ 2) ^ 2))
					BodyPosition.Parent = Pellet
					Pellet.CFrame = Torso.CFrame + Vector3.new(0, (Torso.Size.Y * 2), 0)
					BodyAngularVelocity = Instance.new("BodyAngularVelocity")
					BodyAngularVelocity.maxTorque = Vector3.new(((Pellet:GetMass() ^ 2) ^ 2), ((Pellet:GetMass() ^ 2) ^ 2), ((Pellet:GetMass() ^ 2) ^ 2))
					BodyAngularVelocity.angularvelocity = Vector3.new((math.random() - 0.5), (math.random() - 0.5), ((math.random() - 0.5) * 3))
					BodyAngularVelocity.Parent = Pellet
		
					Pellet.Parent = workspace
					while MouseDown do
						local SpawnLocation = hit.p
						local SpawnDistance = 10
						if (SpawnLocation - Torso.Position).magnitude > SpawnDistance then
							SpawnLocation = Torso.Position + (SpawnLocation - Torso.Position).unit * SpawnDistance
						end
						BodyPosition.position = SpawnLocation
						wait()
					end
				end
			else
				if Pellet then
					MouseDown = false
					Tool.Enabled = false
					Pellet.CanCollide = true
					BodyAngularVelocity:Destroy()
					BodyPosition:Destroy()
					Fire(CFrame.new(Torso.Position, hit.p).lookVector, Pellet, 200, 35, 0.75)
					Pellet = nil
					wait(ReloadTime)
					Tool.Enabled = true
				end
			end
		end
	end
end)

function Unequipped()
	Equipped = false
	MouseDown = false
	if Void and Void.Parent then
		Void:Destroy()
	end
	if Pellet and Pellet.Parent then
		Pellet:Destroy()
	end
	Pellet = nil
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)