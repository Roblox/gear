--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

FireSound = Handle:WaitForChild("FireSound")
HitSound = Handle:WaitForChild("HitSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

function Fire(v)

	local missile = Instance.new("Part")
	missile.Material = Enum.Material.Plastic
	missile.TopSurface = Enum.SurfaceType.Smooth
	missile.BottomSurface = Enum.SurfaceType.Smooth
	missile.FormFactor = Enum.FormFactor.Custom
	missile.Name = "CrossbowBolt"
	missile.Elasticity = 0
	missile.Size = Vector3.new(0.2, 0.2, 0.6)
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	local FlowerChance = math.random(1, 5)
	mesh.MeshId = "http://www.roblox.com/asset?id=" .. tostring((FlowerChance == 1 and 150061460) or 150061482)
	mesh.TextureId = "http://www.roblox.com/asset?id=150061519"
	mesh.Scale = ((FlowerChance == 1 and Vector3.new(3, 3, 3)) or Vector3.new(1, 1, 1))
	mesh.Parent = missile

	missile.Velocity =  v * 40

	local force = Instance.new("BodyForce")
	force.force = v * 10
	force.Parent = missile
	
	local gyro = Instance.new("BodyGyro")
	gyro.maxTorque = Vector3.new(5e5, 5e5, 5e5)
	gyro.Parent = missile
	
	local hitsound = HitSound:Clone()
	hitsound.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = Player
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local TouchedConnection
	
	TouchedConnection = missile.Touched:connect(function(Hit)
		if Hit and Hit.Parent then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character ~= Character then
				TouchedConnection:disconnect()
				local Weld = Instance.new("Weld")
				Weld.Part0 = missile
				Weld.Part1 = Hit
				local CJ = CFrame.new(missile.Position)
				local C0 = missile.CFrame:inverse() * CJ
				local C1 = Hit.CFrame:inverse() * CJ
				Weld.C0 = C0
				Weld.C1 = C1
				Weld.Parent = missile
				gyro:Destroy()
				force:Destroy()
				hitsound:Play()
				if humanoid and humanoid.Parent and humanoid.Health > 0 and Humanoid ~= humanoid then
					humanoid:TakeDamage((FlowerChance == 1 and 25) or 12.5)
					for i, v in pairs(humanoid:GetChildren()) do
						if v.Name == "humanoid" then
							v:Destroy()
						end
					end
					local new_creator_tag = creator_tag:Clone()
					Debris:AddItem(new_creator_tag, 2)
					new_creator_tag.Parent = humanoid
				end
			end
		end
	end)

	Debris:AddItem(missile, 20)

	missile.Parent = game:GetService("Workspace")
	
 	missile.CFrame = CFrame.new(Handle.Position, Humanoid.TargetPoint) + (Handle.CFrame.lookVector * (missile.Size.z * 2))
	gyro.cframe = missile.CFrame
	
	Spawn(function()
		for i = 1, 100 do
			wait(0.1 * i)
			if gyro and gyro.Parent then
				gyro.cframe = CFrame.new(Vector3.new(0,0,0), -missile.Velocity.unit)
			end
		end
	end)
	
end

function Activated()

	if not Tool.Enabled or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 or not Player or not Player.Parent then
		return
	end

	Tool.Enabled = false

	local TargetPos = Humanoid.TargetPoint

	local LookAt = (TargetPos - Handle.Position).unit

	FireSound:Play()

	Fire(LookAt)

	wait(2)

	Tool.Enabled = true

end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)