--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Handle:WaitForChild("PlaySound")
Charging = Tool:WaitForChild("Charging")

Equipped = false
MouseDown = false
ParticlesCompleted = true
Particles = {}
CurrentCharge = 0
MaxCharge = 4

-- Returns a character ancestor and its Humanoid, or nil
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

function CastLaser(StartPosition, Direction, MaxDistance, Ignore)
	
	local function RayCast(Pos, Dir, Max, IgnoreList)
		return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Pos, Dir.unit * (Max or 999.999)), IgnoreList) 
	end

	local Hit, EndPosition = RayCast(StartPosition, Direction, MaxDistance, Ignore)
	local Distance = (StartPosition - EndPosition).magnitude
	local LaserPart = Instance.new("Part")
	LaserPart.Name = "CloverLaser"
	LaserPart.Transparency = 0.000001
	LaserPart.FormFactor = Enum.FormFactor.Custom
	LaserPart.TopSurface = Enum.SurfaceType.Smooth
	LaserPart.BottomSurface = Enum.SurfaceType.Smooth
	LaserPart.Material = Enum.Material.SmoothPlastic
	LaserPart.CanCollide = false
	LaserPart.Anchored = true
	LaserPart.Locked = true
	LaserPart.Size = Vector3.new(0.2, 0.2, Distance)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "http://www.roblox.com/asset?id=149427420"
	Mesh.TextureId = "http://www.roblox.com/asset?id=149427485"
	Mesh.Scale = Vector3.new(3, 1 + CurrentCharge, ((Distance * 2) + (Distance / 2) + (Distance / 6)))
	LaserPart.Size = Vector3.new(LaserPart.Size.X, (Mesh.Scale.Y / 4), LaserPart.Size.Z)
	Mesh.Parent = LaserPart
	Debris:AddItem(LaserPart, 1)
	LaserPart.Parent = Character
	LaserPart.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, (-Distance / 2))
	Spawn(function()
		for i = 1, 20 do
			wait(0.05)
			LaserPart.Transparency = LaserPart.Transparency + 0.05
		end
	end)
	
	return Hit, EndPosition, ChosenColor
	
end

function Fire()
	if Tool.Enabled and Humanoid.Health > 0 then
		Tool.Enabled = false
		
		PlaySound.Value = "106018135"
		
		local StartingPosition = Handle.Position + Handle.CFrame.lookVector * (Handle.Size.Z / 2)
		
		local HandleClone = Handle:Clone()
		local HandleCloneY = HandleClone:Clone()
		HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
		HandleCloneY.CFrame = HandleCloneY.CFrame + HandleCloneY.CFrame.lookVector * ((HandleClone.Size.Y / 2) - 0.325)
		local HandleCloneZ = HandleCloneY:Clone()
		HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) + 0.05)	
		
		local Hit, EndPos = CastLaser(HandleCloneZ.CFrame.p, (Humanoid.TargetPoint - StartingPosition), 100, {Character})
		
		local character, humanoid = FindCharacterAncestor(Hit)

		if character and character.Parent and humanoid and humanoid.Parent then
			local creator_tag = Instance.new("ObjectValue")
			creator_tag.Name = "creator"
			creator_tag.Value = Player
			Debris:AddItem(creator_tag, 2)
			creator_tag.Parent = humanoid
			humanoid:TakeDamage((1 + CurrentCharge) * 10)
		end
		
		local CoinRadius = 5
		
		for i = 1, (5 + math.random(0, 20)) do
			local Coin = Instance.new("Part")
			Coin.Material = Enum.Material.SmoothPlastic
			Coin.FormFactor = Enum.FormFactor.Custom
			Coin.TopSurface = Enum.SurfaceType.Smooth
			Coin.BottomSurface = Enum.SurfaceType.Smooth
			Coin.Size = Vector3.new(1, 0.4, 1)
			Coin.Name = "Coin"
			Coin.Anchored = false
			Coin.CanCollide = true
			Coin.Locked = true
			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = Enum.MeshType.FileMesh
			Mesh.MeshId = "http://www.roblox.com/asset/?id=19059116"
			Mesh.TextureId = "http://www.roblox.com/asset/?id=19059111"
			Mesh.Scale = Vector3.new(1, 1, 1)
			Mesh.Parent = Coin
			Debris:AddItem(Coin, 10)
			Coin.Parent = game:GetService("Workspace")
			Coin.CFrame = CFrame.new((EndPos.X + math.random(-CoinRadius, CoinRadius)), (EndPos.Y + math.random(0, CoinRadius)), (EndPos.Z + math.random(-CoinRadius, CoinRadius)))
		end

		wait(1)

		Tool.Enabled = true
	end
end

function OnEquipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Humanoid = Character:WaitForChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not Tool.Enabled then
		wait(0.5)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		MouseDown = true
		Charging.Value = true
		while ((MouseDown or not ParticlesCompleted) and Equipped) do
			
			local ParticleRadius = 3
			
			local HandlePointClone = Handle:Clone()
			local HandlePointCloneY = HandlePointClone:Clone()
			HandlePointCloneY.CFrame = HandlePointCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
			HandlePointCloneY.CFrame = HandlePointCloneY.CFrame + HandlePointCloneY.CFrame.lookVector * ((HandlePointClone.Size.Y / 2) - 0.325)
			local HandlePointCloneZ = HandlePointCloneY:Clone()
			HandlePointCloneZ.CFrame = HandlePointCloneZ.CFrame + HandlePointClone.CFrame.lookVector * ((HandlePointClone.Size.Z / 2) + 0.05)	

			if MouseDown then
				ParticlesCompleted = false
		
				for i = 1, math.random(2, 7) do
					local Particle = Instance.new("Part")
					Particle.Material = Enum.Material.SmoothPlastic
					Particle.FormFactor = Enum.FormFactor.Custom
					Particle.TopSurface = Enum.SurfaceType.Smooth
					Particle.BottomSurface = Enum.SurfaceType.Smooth
					Particle.Size = Vector3.new(0.2, 0.2, 0.2)
					Particle.Name = "Particle"
					Particle.BrickColor = BrickColor.new("Pastel Blue")
					Particle.Anchored = true
					Particle.CanCollide = false
					Particle.Locked = true
					local Mesh = Instance.new("SpecialMesh")
					Mesh.MeshType = Enum.MeshType.Sphere
					Mesh.Scale = Vector3.new(0.75, 0.75, 0.75)
					Mesh.Parent = Particle
					
					local HandleClone = Handle:Clone()
					local HandleCloneY = HandleClone:Clone()
					HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
					HandleCloneY.CFrame = HandleCloneY.CFrame + HandleCloneY.CFrame.lookVector * ((HandleClone.Size.Y / 2) - 0.325 + math.random(-ParticleRadius, ParticleRadius))
					local HandleCloneZ = HandleCloneY:Clone()
					HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) + 0.7 + math.random(-ParticleRadius, ParticleRadius))
					local HandleCloneX = HandleCloneZ:Clone()
					HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
					HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * ((HandleClone.Size.X / 2) + math.random(-ParticleRadius, ParticleRadius))
					
					Debris:AddItem(Particle, 5)				
					
					Particle.Parent = Character
					Particle.CFrame = HandleCloneX.CFrame
					table.insert(Particles, Particle)
				end
			end
			for i, v in pairs(Particles) do
				v.CFrame = v.CFrame + CFrame.new(v.Position, HandlePointCloneZ.Position).lookVector * 0.5
				if (v.Position - HandlePointCloneZ.Position).magnitude < 0.25 then
					v:Destroy()
					table.remove(Particles, i)
					if #Particles == 0 then
						ParticlesCompleted = true
					end
				end
			end

			CurrentCharge = CurrentCharge + 0.05
			if CurrentCharge >= MaxCharge then
				CurrentCharge = MaxCharge
				MouseDown = false
			end			
			
			wait(0.01)
		end
		Charging.Value = false
		if Equipped then
			Fire()
		end
		CurrentCharge = 0
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
end

function OnUnequipped()
	Equipped = false
	MouseDown = false
	ParticlesCompleted = true
	for i, v in pairs(Particles) do
		v:Destroy()
	end
	Particles = {}
	Charging.Value = false
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)