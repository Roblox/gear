--// Redone for R15 avatars by StarWars
local Debris = game:GetService('Debris')

local Tool = script.Parent
local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "MouseClick"
RemoteEvent.Parent = Tool

local Firerate = 0.7
local Power = 150
local Rate = 1/30
local Damage = 15
local LastFireTime = tick()

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local function CreateJetpack()
	if Torso and not Character:FindFirstChild("Jetpack") then
		local Accessory = Instance.new("Accessory")
		Accessory.Name = "Effect"
		local NewCframe = CFrame.new(0, 1, 0) * CFrame.Angles(0, math.pi, 0)
		local JetpackPart = Instance.new("Part")
		JetpackPart.Name = "Handle"
		JetpackPart.CanCollide = false
		JetpackPart.Size = Vector3.new(3, 3, 3)
		JetpackPart.CFrame = Torso.CFrame * NewCframe
		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshId = "rbxassetid://" .. 88654099
		Mesh.TextureId = "rbxassetid://" .. 88655181
		Mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
		Mesh.Parent = JetpackPart
		local Attachment = Instance.new("Attachment")
		Attachment.Name = "BodyBackAttachment"
		Attachment.Position = Vector3.new(0, -1.2, -0.4)
		Attachment.Parent = JetpackPart
		Attachment.Axis = Vector3.new(-1, 0, 0)
		Attachment.SecondaryAxis = Vector3.new(0, 1, 0)
		Attachment.Rotation = Vector3.new(-180, 0, -180)
		local BodyForce = Instance.new("BodyForce")
		BodyForce.Force = Vector3.new(0, (workspace.Gravity * JetpackPart:GetMass()) + 100, 0)
		BodyForce.Parent = JetpackPart
		JetpackPart.Parent = Accessory
		Accessory.Parent = Torso.Parent
	end
end

local function CreateBullet()
	local Part = Instance.new("Part")
	Part.Name = "Effect"
	Part.BrickColor = BrickColor.new("Medium stone grey")
	Part.CanCollide = false
	Part.TopSurface = Enum.SurfaceType.Smooth
	Part.BottomSurface = Enum.SurfaceType.Smooth
	Part.Shape = Enum.PartType.Ball
	Part.Size = Vector3.new(1, 1, 1)
	
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshId = "rbxassetid://" .. 88545836
	Mesh.TextureId = "rbxassetid://" .. 88545941
	Mesh.Scale = Vector3.new(2.5, 2.5, 2.5)
	Mesh.Parent = Part	
	
	local Fire = Instance.new("Fire")
	Fire.Color = Color3.new(0, 1, 1)
	Fire.SecondaryColor = Color3.new(1, 1, 1)
	Fire.Parent = Part
	
	local CreatorObject = Instance.new("ObjectValue")
	CreatorObject.Name = "creator"
	CreatorObject.Value = Player
	CreatorObject.Parent = Part
		
	local BodyForce = Instance.new("BodyForce")
	BodyForce.Force = Vector3.new(0, workspace.Gravity * Part:GetMass(), 0)
	BodyForce.Parent = Part
	
	Part.Touched:Connect(function(hit)
		if hit then
			if CreatorObject.Value and CreatorObject.Value.Character then
				if hit.Parent ~= CreatorObject.Value.Character and hit.Name ~= "Handle" and hit.Name ~= "Effect" and hit.Name ~= "Handle2" then
					local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
					local Torso = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
					if Humanoid and Torso and Humanoid.Health > 0 then
						for i, v in ipairs(Humanoid:GetChildren()) do
							if v.Name == "creator" then
								v:Destroy()
							end
						end
						
						CreatorObject:Clone().Parent = Humanoid
						Humanoid:TakeDamage(Damage)
						Part:Destroy()
					end
				end
			end
		end
	end)
	
	return Part
end

local function OnEquipped()
	Character = Tool.Parent
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = game.Players:GetPlayerFromCharacter(Character)
	CreateJetpack()
end

local function OnUnequipped()
	local Jetpack = Character:FindFirstChild("Effect")
	if Jetpack then
		Jetpack:Destroy()
	end
	
	Character = nil
	Humanoid = nil
	Torso = nil
	Player = nil
end

RemoteEvent.OnServerEvent:Connect(function(player, vector)
	if Player ~= player then return end
	if tick() - LastFireTime > Firerate then
		local Bullet = CreateBullet()
		local Sound = Tool.Handle:FindFirstChild("Sound")
		if Sound then
			Sound:Play()
		end
		if Tool:FindFirstChild("Effect") then
			Tool.Effect.Transparency = 1
		end
		Bullet.CFrame = CFrame.new(Torso.Position, Torso.Position + vector) * CFrame.new(0, 0, -5)
		Bullet.Velocity = vector * Power
		Debris:AddItem(Bullet, 5)
		Bullet.Parent = workspace
		
		LastFireTime = tick()
		wait(Firerate)
		if Tool:FindFirstChild("Effect") then
			Tool.Effect.Transparency = 0
		end		
	end
end)

--Tool.Activated:Connect(OnActivated)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)