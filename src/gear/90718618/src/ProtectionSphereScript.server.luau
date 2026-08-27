--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Sounds = {
	ShutDown = Tool:WaitForChild("ShutDown"),
	PoweringUp = Tool:WaitForChild("PoweringUp"),
	Deflect = Tool:WaitForChild("Deflect"),
	Pulse = Tool:WaitForChild("Pulse")
}

RemovableClasses = {"TouchTransmitter", "RocketPropulsion", "BodyVelocity", "BodyForce", "BodyPosition", "BodyThrust", "LocalScript", "Script"}

Duration = 30
MaxHealDistance = 20

ReadyToActivate = true

Gravity = 196.20

ObjectsAlreadyDeflected = {}

SpherePart = Instance.new("Part")
SpherePart.Material = Enum.Material.Plastic
SpherePart.Shape = Enum.PartType.Ball
SpherePart.TopSurface = Enum.SurfaceType.Smooth
SpherePart.BottomSurface = Enum.SurfaceType.Smooth
SpherePart.FormFactor = Enum.FormFactor.Custom
SpherePart.Size = Vector3.new(0.2, 0.2, 0.2)
SpherePart.CanCollide = false
SpherePart.Anchored = true
SpherePart.Locked = true
SphereMesh = Instance.new("SpecialMesh")
SphereMesh.MeshType = Enum.MeshType.FileMesh
SphereMesh.MeshId = "http://www.roblox.com/asset/?id=90782182"
SphereMesh.TextureId = "http://www.roblox.com/asset/?id=90782359"
SphereMesh.Scale = Vector3.new(1, 1, 1)
SphereMesh.Parent = SpherePart

local DisplayPart = Tool:FindFirstChild("DisplayModel")

if DisplayPart then
	DisplayPart:Destroy()
	Handle.Transparency = 0.25
end

Tool.Enabled = true

function CheckForClass(Table, Object)
	for i, v in pairs(Table) do
		if Object:IsA(v) then
			return true
		end
	end
	return false
end

function CheckTable(Table, Object)
	for i, v in pairs(Table) do
		if v == Object then
			return true
		end
	end
	return false
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

function CalculateRecursiveMass(RootPart)
	local Mass = 0
	local function CalculateMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			CalculateMass(v)
		end
	end
	CalculateMass(RootPart)
	return Mass
end

function ReflectVector3(Incoming, Normal)
	return (2 * ((-1 * Incoming):Dot(Normal)) * Normal + Incoming)
end

function CleanProjectile(Object)
	if not Object or not Object.Parent then
		return
	end
	local ObjectClone = Object:Clone()
	for i, v in pairs(ObjectClone:GetChildren()) do
		if CheckForClass(RemovableClasses, v) then
			v:Destroy()
		end
	end
	Object:Destroy()
	ObjectClone.Parent = game:GetService("Workspace")
	return ObjectClone
end

function FindPlayerInDirection(StartPosition, Direction)
	local Attacker = nil
	local ClosestAngle = math.huge
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character then
			local torso = v.Character:FindFirstChild("Torso")
			if torso then
				local AngleBetween = math.abs(math.acos((StartPosition - Torso.CFrame.p).unit:Dot(Direction)))
				if AngleBetween < (math.pi / 4) then
					if (torso.CFrame.p - StartPosition).magnitude < 300 and AngleBetween < ClosestAngle then
						Attacker = v
						ClosestAngle = AngleBetween
					end
				end
			end
		end
	end
	return Attacker
end

function CreateReflector(OrientationCFrame)
	local Sphere = SpherePart:Clone()
	Sphere.Transparency = 0.75
	Sphere.Size = Vector3.new(3, 3, 3)
	Sphere.CFrame = OrientationCFrame
	local SphereMesh = Sphere:FindFirstChild("Mesh")
	SphereMesh.Scale = Vector3.new(0.2, 0.2, 0.2)
	Debris:AddItem(Sphere, 3)
	Sphere.Parent = game:GetService("Workspace")
	Spawn(function()
		for i = 1, 3, 0.5 do
			if SphereMesh then
				SphereMesh.Scale = Vector3.new((0.2 * i), (0.2 * i), (0.2 * i)) 
			end
			wait(0.05)
		end
		local MaxScale = SphereMesh.Scale
		for j = 1, 0, -0.1 do
			if SphereMesh then
				SphereMesh.Scale = (MaxScale * i)
				wait(0.05)
			end
		end
	end)
end

function HandleReflection(Sphere, Part)
	if not Part or not Part.Parent or Part.Anchored or Part.Parent ~= game:GetService("Workspace") or Part.Velocity.magnitude < 5 or CalculateRecursiveMass(Part) > 160 then
		return
	end
	if math.acos((Part.CFrame.p - Sphere.CFrame.p).unit:Dot(Part.Velocity.unit)) < (math.pi / 2) or (Part.CFrame.p - Sphere.CFrame.p).magnitude < 13 then
		return
	end
	local ConnectedParts = Part:GetConnectedParts()
	for i, v in pairs(ConnectedParts) do
		if v and v.Parent then
			local character, humanoid = FindCharacterAncestor(v)
			if character and character == CurrentCharacter then
				return
			end
		end
	end
	Part = CleanProjectile(Part)
	if CheckTable(ObjectsAlreadyDeflected, Part) then
		return
	end
	table.insert(ObjectsAlreadyDeflected, Part)
	Part.CFrame = (Part.CFrame - Part.Velocity * 0.1)
	Debris:AddItem(Part, 10)
	CreateReflector(CFrame.new(Part.Position, Part.Position + ((Sphere.Position - Vector3.new(0, (Sphere.Size.Y / 3), 0)) - Part.Position).unit) * CFrame.Angles(math.rad(90), 0, 0))
	Part.Anchored = true
	local SphereMesh = Sphere:FindFirstChild("Mesh")
	if SphereMesh then
		SphereMesh.VertexColor = Vector3.new(1, 1, 0)
	end
	
	local Attacker = nil
	
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ObjectValue") and string.lower(v.Name) == string.lower("Creator") and v.Value and v.Value.Parent and v.Value:IsA("Player") then
			Creator = v.Value
		end
	end
	
	Attacker = ((not Attacker and FindPlayerInDirection(Part.Position, Part.Velocity.unit)) or Attacker)
	if Deflect then
		Sounds.Deflect:Play()
	end
	
	wait(1)
	
	if SphereMesh and SphereMesh.Parent then
		SphereMesh.VertexColor = Vector3.new(1, 1, 1)
	end
	if not Part or not Part.Parent then
		return
	end
	
	Part.Anchored = false
	local DeflectVelocity = Instance.new("BodyVelocity")
	local ReflectDirection = ReflectVector3(Part.Velocity.unit, (Part.CFrame.p - Sphere.CFrame.p).unit).unit
	DeflectVelocity.velocity = ReflectDirection * Part.Velocity.magnitude
	DeflectVelocity.Parent = Part
	Debris:AddItem(DeflectVelocity, 10)
	-- reorient it so it is facing the direction it is going
	Part.CFrame = CFrame.new(Part.Position, (Part.Position + DeflectVelocity.velocity.unit))
	if not Attacker or not Attacker.Parent or not Attacker.Character then
		return
	end
	local torso = Attacker.Character:FindFirstChild("Torso")
	if not torso then
		return
	end
	if not Part:FindFirstChild("Fire") then
		local Fire = Instance.new("Fire")
		Fire.Color = Color3.new((105 / 255), (222 / 255), (214/ 255))
		Fire.Enabled = true
		Fire.Parent = Part
	end
	DeflectVelocity.velocity = (torso.CFrame.p - Part.CFrame.p).unit * Part.Velocity.magnitude * 2
	Part.Touched:connect(function(OtherPart)
		if not OtherPart or not OtherPart.Parent or not Attacker or not Attacker.Parent or not Attacker.Character then
			return
		end
		local humanoid = Attacker.Character:FindFirstChild("Humanoid")
		if not humanoid then
			return
		end
		if OtherPart.Parent == Attacker.Character then
			humanoid:TakeDamage(50)
			if Part and Part.Parent then
				Part:Destroy()
			end
		end
	end)
end

function AddFeatures(Sphere, Range)
	local HealTick = 0
	while Sphere and Sphere.Parent do
		Spawn(function()
			local IgnoreObjects = {CurrentCharacter, Sphere}
			local NegativePartRadius = Vector3.new((Range.X / 2), (Range.Y / 2), (Range.Z / 2))
			local PositivePartRadius = Vector3.new((Range.X / 2), (Range.Y / 2), (Range.Z / 2))
			local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(Sphere.Position - NegativePartRadius, Sphere.Position + PositivePartRadius), IgnoreObjects, 100)
			for i, v in pairs(Parts) do
				if v and v.Parent then
					HandleReflection(Sphere, v)
				end
			end
			if (tick() - HealTick) >= 1 then
				HealTick = tick()
				local HealedSomebody = false
				for i, v in pairs(Players:GetChildren()) do
					if v:IsA("Player") and v.Character then
						local humanoid = v.Character:FindFirstChild("Humanoid")
						local torso = v.Character:FindFirstChild("Torso")
						if humanoid and torso and humanoid.Health > 0 and (torso.Position - Sphere.Position).magnitude <= MaxHealDistance then
							Humanoid.Health = math.min(Humanoid.MaxHealth, Humanoid.Health + 10)
							HealedSomebody = true
						end
					end
				end
				if HealedSomebody then
					Sounds.Pulse:Play()
				end
			end
		end)
		wait()
	end
end

function TweenScale(SphereMesh, StartSize, EndSize, TweenDuration, Steps)
	local StepSize = (TweenDuration / Steps)
	for i = 0, Steps do
		local Ratio = (i / Steps)
		SphereMesh.Scale = ((1 - Ratio) * StartSize + (EndSize * Ratio))
		wait(StepSize)
	end
	SphereMesh.Scale = EndSize
end

function TweenCFrame(Sphere, StartCFrame, EndCFrame, TweenDuration, Steps)
	local StepSize = (TweenDuration / Steps)
	for i = 0, Steps do
		local Ratio = (i / Steps)
		Sphere.CFrame = CFrame.new((1 - Ratio) * StartCFrame.p + (EndCFrame.p * Ratio))
		wait(StepSize)
	end
	Sphere.CFrame = EndCFrame
end

function Activated()
	if not ReadyToActivate then
		return
	end
	
	ReadyToActivate = false
	Tool.Enabled = false
	
	CurrentCharacter = Character
	CurrentTorso = Torso
	
	Handle.Transparency = 1

	local Sphere = SpherePart:Clone()
	Sphere.Name = "ProtectionSphere"
	Sphere.Transparency = 1
	local SphereMesh = Sphere:FindFirstChild("Mesh")
	Debris:AddItem(Sphere, Duration)
	Sphere.Parent = game:GetService("Workspace")
	Spawn(function()
		TweenScale(SphereMesh, Vector3.new(0.1, 0.1, 0.1), Vector3.new(4, 4, 4), 0.5, 10)
	end)
	local TorsoCFrame = CFrame.new(CurrentTorso.Position)
	Spawn(function()
		TweenCFrame(Sphere, TorsoCFrame, (TorsoCFrame + Vector3.new(0, 8.5, 0)), 0.5, 10)
	end)
	Sounds.PoweringUp:Play()
	for i = 1, 15 do
		Sphere.Transparency = math.max(0, (Sphere.Transparency - 0.05))
		wait(0.1)
	end
	Sphere.Transparency = 0.25
	Spawn(function()
		AddFeatures(Sphere, Vector3.new(32.5, 25, 32.5))
	end)
	wait((Duration - 1.5))
	Handle.Transparency = 0.25
	Sounds.ShutDown:Play()
	Tool.Enabled = true
	ReadyToActivate = true
end

function PlayerIsAlive()
	return (Player.Parent and Humanoid.Parent and Humanoid.Health > 0 and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not PlayerIsAlive() then
		return
	end
end

function Unequipped()
	Handle.Transparency = 0
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)