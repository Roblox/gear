--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Fire = Tool:WaitForChild("Fire")
Reload = Tool:WaitForChild("Reload")

EquipSound = Handle:WaitForChild("Equip")
ReloadSound = Handle:WaitForChild("Reload")
SwooshSound = Handle:WaitForChild("Swoosh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BoxingGlovePart = Instance.new("Part")
BoxingGlovePart.Name = "BoxingGlove"
BoxingGlovePart.Material = Enum.Material.Plastic
BoxingGlovePart.Shape = Enum.PartType.Block
BoxingGlovePart.TopSurface = Enum.SurfaceType.Smooth
BoxingGlovePart.BottomSurface = Enum.SurfaceType.Smooth
BoxingGlovePart.FormFactor = Enum.FormFactor.Custom
BoxingGlovePart.Size = Vector3.new(0.75, 1, 1)
BoxingGlovePart.CanCollide = false
local Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.FileMesh
Mesh.MeshId = "http://www.roblox.com/asset?id=166886053"
Mesh.TextureId = "http://www.roblox.com/asset?id=166886089"
Mesh.Scale = Vector3.new(1, 1, 1)
Mesh.Parent = BoxingGlovePart

Damage = 20

Active = false
BoxingGlove = Handle:FindFirstChild("BoxingGlove")
Loaded = ((BoxingGlove and true) or false)

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

function CreateBoxingGlove()
	BoxingGlove = Handle:FindFirstChild("BoxingGlove")
	if BoxingGlove then
		BoxingGlove:Destroy()
	end
	BoxingGlove = BoxingGlovePart:Clone()
	BoxingGloveWeld = Instance.new("Weld")
	BoxingGloveWeld.Name = "BoxingGloveWeld"
	BoxingGloveWeld.Part0 = Handle
	BoxingGloveWeld.Part1 = BoxingGlove
	BoxingGloveWeld.C1 = CFrame.new(0.075, -0.3, 2.3)
	BoxingGloveWeld.Parent = BoxingGlove
	BoxingGlove.Parent = Handle
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function Activated()
	if not Humanoid or Humanoid.Health == 0 or Active then
		return
	end
	Tool.Enabled = false
	Active = true
	if Loaded then
		Loaded = false
		local BoxingGloveProjectile = BoxingGlovePart:Clone()
		BoxingGloveProjectile.CanCollide = true
		local BoxingGloveCFrame = BoxingGlove.CFrame
		if BoxingGlove and BoxingGlove.Parent then
			BoxingGlove:Destroy()
		end
		BoxingGloveProjectile.CFrame = BoxingGloveCFrame
		local Mass = BoxingGloveProjectile:GetMass()
		local TargetPoint = Humanoid.TargetPoint
		local Direction = CFrame.new(BoxingGloveProjectile.Position, Humanoid.TargetPoint)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new((Mass * 196.2), (Mass * 196.2), (Mass * 196.2))
		BodyVelocity.velocity = CFrame.new(BoxingGloveProjectile.Position, TargetPoint).lookVector * 50
		BodyVelocity.Parent = BoxingGloveProjectile
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new((Mass * 196.2), (Mass * 196.2), (Mass * 196.2))
		BodyGyro.cframe = Direction
		BodyGyro.Parent = BoxingGloveProjectile
		local Debounce = false
		BoxingGloveProjectile.Touched:connect(function(Hit)
			if Hit and Hit.Parent and Hit.Parent ~= Character and not Debounce then
				local humanoid = Hit.Parent:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 then
					Debounce = true
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
					local Weld = Instance.new("Weld")
					Weld.Part0 = BoxingGloveProjectile
					Weld.Part1 = Hit
					Weld.C0 = BoxingGloveProjectile.CFrame:inverse()
					Weld.C1 = Hit.CFrame:inverse()
					Weld.Parent = BoxingGloveProjectile
					if BodyVelocity and BodyVelocity.Parent then
						BodyVelocity:Destroy()
					end
					if BodyGyro and BodyGyro.Parent then
						BodyGyro:Destroy()
					end
					local torso = Hit.Parent:FindFirstChild("Torso")
					if torso then
						local Mass = GetTotalMass(Character)
						local BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.maxForce = Vector3.new((Mass * 196.2 * 2), (Mass * 196.2 * 2), (Mass * 196.2 * 2))
						BodyVelocity.velocity = BoxingGloveProjectile.CFrame.lookVector * 50
						Debris:AddItem(BodyVelocity, 5)
						local BoxingGloveChanged
						Spawn(function()
							while BodyVelocity and BodyVelocity.Parent do
								torso.Velocity = BoxingGloveProjectile.CFrame.lookVector * 50
								wait(0.1)
							end
						end)
						BoxingGloveChanged = Weld.Changed:connect(function(Property)
							if Property == "Parent" and not BoxingGloveProjectile.Parent then
								if BodyVelocity and BodyVelocity.Parent then
									BodyVelocity:Destroy()
									BoxingGloveChanged:disconnect()
								end
							end
						end)
						Delay(5, function()
							if BoxingGloveChanged then
								BoxingGloveChanged:disconnect()
							end
						end)
						BodyVelocity.Parent = torso
					end
				end
			end
		end)
		Debris:AddItem(BoxingGloveProjectile, 5)
		BoxingGloveProjectile.Parent = game:GetService("Workspace")
		BoxingGloveProjectile.CFrame = Direction
		FireAnim = Humanoid:LoadAnimation(Fire)
		if FireAnim then
			FireAnim:Play(nil, nil, 0.75)
		end
		wait(2.125)
		if FireAnim then
			FireAnim:Stop()
		end
	else
		local LeftArm = Character:FindFirstChild("Left Arm")
		if LeftArm then
			ReloadBoxingGlove = BoxingGlovePart:Clone()
			ReloadBoxingGloveWeld = Instance.new("Weld")
			ReloadBoxingGloveWeld.Part0 = LeftArm
			ReloadBoxingGloveWeld.Part1 = ReloadBoxingGlove
			ReloadBoxingGloveWeld.C1 = CFrame.new(0, 0, 1.525) * CFrame.Angles((math.pi / 2), 0, 0)
			ReloadBoxingGloveWeld.Parent = ReloadBoxingGlove
			Debris:AddItem(ReloadBoxingGlove, 5)
			ReloadBoxingGlove.Parent = Character
		end
		ReloadAnim = Humanoid:LoadAnimation(Reload)
		if ReloadAnim then
			ReloadAnim:Play(nil, nil, 0.5)
		end
		wait(1.5)
		if ReloadBoxingGlove and ReloadBoxingGlove.Parent then
			ReloadBoxingGlove:Destroy()
		end
		CreateBoxingGlove()
		wait(0.5)
		if ReloadAnim then
			ReloadAnim:Stop()
		end
		Loaded = true
	end
	Active = false
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	for i, v in pairs({FireAnim, ReloadAnim}) do
		if v then
			v:Stop()
		end
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)