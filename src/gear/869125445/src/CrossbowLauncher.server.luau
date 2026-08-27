Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

FireSound = Handle:WaitForChild("FireSound")
HitSound = Handle:WaitForChild("HitSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local BaseUrl = "rbxassetid://"

local Damage = 20

local DisplayArrow = nil

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
	missile.CanCollide = false
	missile.Name = "CrossbowBolt"
	missile.Elasticity = 0
	missile.Size = Vector3.new(0.25, 0.25, 3.25)

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = BaseUrl .. 867725170
	mesh.TextureId = BaseUrl .. 867725274
	mesh.Parent = missile

	local attachment = Instance.new("Attachment")
	attachment.Name = "ArrowAttachment"
	attachment.Orientation = Vector3.new(0, -90, 0)
	attachment.Position = Vector3.new(0, 0, 1.766)
	attachment.Axis = Vector3.new(0, 0, 1)
	attachment.SecondaryAxis = Vector3.new(0, 1, 0)
	attachment.Parent = missile		

	return missile
end 

function PlaceArrowOnCrossbow()
	if DisplayArrow then return end

	DisplayArrow = CreateArrow()
	DisplayArrow.Parent = Tool
	local Weld = Instance.new("Weld")
	Weld.Part0 = DisplayArrow
	Weld.Part1 = Handle
	Weld.C0 = DisplayArrow.ArrowAttachment.CFrame
	Weld.C1 = Handle.ArrowAttachment.CFrame
	Weld.Parent = DisplayArrow
end 

function Fire(v)

	local missile = CreateArrow()
	missile.Velocity =  v * 150

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

	if not Tool.Enabled or not RootPart or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 or not Player or not Player.Parent then
		return
	end

	Tool.Enabled = false

	local TargetPos = Humanoid.TargetPoint

	local LookAt = (TargetPos - RootPart.Position).unit

	FireSound:Play()

	DisplayArrow.Transparency = 1
	Fire(LookAt)

	wait(2)

	DisplayArrow.Transparency = 0
	Tool.Enabled = true

end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)

	PlaceArrowOnCrossbow()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)