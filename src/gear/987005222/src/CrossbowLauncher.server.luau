Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

FireSound = Handle:WaitForChild("FireSound")
HitSound = Handle:WaitForChild("HitSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local BaseUrl = "rbxassetid://"

local Damage = 0

local DisplayArrow = nil

local RemoteFunction = Tool:WaitForChild("RemoteFunction")

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

function CreateArrow()
	local missile = Instance.new("Part")
	missile.Material = Enum.Material.Plastic
	missile.TopSurface = Enum.SurfaceType.Smooth
	missile.BottomSurface = Enum.SurfaceType.Smooth
	missile.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0)
	missile.CanCollide = true
	missile.Name = "CrossbowBolt"
	missile.Elasticity = 0
	missile.Size = Vector3.new(0.25, 0.25, 1)

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = BaseUrl .. 984987741
	mesh.TextureId = BaseUrl .. 984988604
	mesh.Parent = missile	

	return missile
end 

function Fire(TargetPos)
	local missile = CreateArrow()
	local startCFrame = CFrame.new(Handle.Position, Humanoid.TargetPoint) + (Handle.CFrame.lookVector * (missile.Size.z * 2))
	local LookAt = (TargetPos - startCFrame.p).unit
	missile.Velocity =  LookAt * 150

	local BodyForce = Instance.new("BodyForce")
	BodyForce.Force = Vector3.new(0, workspace.Gravity * 0.75 * missile:GetMass(), 0)
	BodyForce.Parent = missile
	
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
		if Hit and Hit.Parent and not Hit:FindFirstChild("ArrowAttachment") then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character ~= Character then
				TouchedConnection:disconnect()
				gyro:Destroy()
				BodyForce:Destroy()
				hitsound:Play()
				if humanoid and humanoid.Parent and humanoid.Health > 0 and Humanoid ~= humanoid then
					humanoid:TakeDamage(Damage)
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
	
 	missile.CFrame = startCFrame
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

	if not Tool.Enabled or not RootPart or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 or not Player or not Player.Parent then
		return
	end

	Tool.Enabled = false

	--local TargetPos = Humanoid.TargetPoint
	local TargetPos = RemoteFunction:InvokeClient(Player)
	if not TargetPos then return end 

	--local LookAt = (TargetPos - RootPart.Position).unit

	FireSound:Play()

--	DisplayArrow.Transparency = 1
	Handle.Mesh.MeshId = "rbxassetid://" .. 984988088
	Fire(TargetPos)

	wait(2)

	Handle.Mesh.MeshId = "rbxassetid://" .. 984988307
--	DisplayArrow.Transparency = 0
	Tool.Enabled = true

end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)

	--PlaceArrowOnCrossbow()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)