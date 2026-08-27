--Made by Luckymaxer

wait()

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ProjectileScript = script:WaitForChild("ProjectileScript")
Bubbles = script:WaitForChild("Bubbles")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Animations = {}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

BasePlunger = BasePart:Clone()
BasePlunger.Name = "Projectile"
BasePlunger.Size = Vector3.new(0.5, 0.5, 3)
BasePlunger.CanCollide = true
BasePlunger.Locked = true
BasePlunger.Anchored = false
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "287440098"),
	TextureId = (BaseUrl .. "287440323"),
	Scale = Vector3.new(0.75, 0.75, 0.75),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BasePlunger,
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Rate = (1 / 30)
Gravity = 196.20

MaxDistance = 60
Damage = 30
ReloadTime = 1

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function Shoot(TargetPos)
	
	local StartPos = Handle.CFrame
	local Direction = CFrame.new(StartPos.p, TargetPos)
	local Force = 150
	
	local Plunger = BasePlunger:Clone()
	Plunger.Velocity = (Direction.lookVector * Force)
	Plunger.CanCollide = true
	Plunger.CFrame = (Direction + Direction.lookVector * 4.5)
	
	local ParticlePart = BasePart:Clone()
	ParticlePart.Name = "Effect"
	ParticlePart.Transparency = 1
	ParticlePart.CanCollide = false
	ParticlePart.Parent = Plunger
	
	local Mass = ((Plunger:GetMass() + ParticlePart:GetMass()) * Gravity)
	
	local ParticleWeld = Create("Weld"){
		Part0 = Plunger,
		Part1 = ParticlePart,
		C0 = (CFrame.new(0, 0, ((Plunger.Size.Z / 2) + (ParticlePart.Size.Z / 2))) * CFrame.Angles((math.pi / 2), 0, 0)),
		C1 = CFrame.new(0, 0, 0),
		Parent = ParticlePart,
	}
	local Force = Create("BodyForce"){
		force = Vector3.new(0, Mass, 0),
		Parent = Plunger,
	}
	local Gyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, Mass, math.huge),
		cframe = Direction,
		Parent = Plunger,
	}
	local BubbleParticles = Bubbles:Clone()
	BubbleParticles.Enabled = true
	BubbleParticles.Parent = ParticlePart
	if DisplayPlunger then
		DisplayPlunger.Transparency = 1
	end
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Origin", Class = "Vector3Value", Value = StartPos.p},
		{Name = "Damage", Class = "NumberValue", Value = Damage},
		{Name = "BaseProjectile", Class = "ObjectValue", Value = BasePlunger},
	}
	local PlungerScript = ProjectileScript:Clone()
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = PlungerScript,
		}
	end
	PlungerScript.Disabled = false
	PlungerScript.Parent = Plunger
	Debris:AddItem(Plunger, 5)
	Plunger.Parent = game:GetService("Workspace")
	Sounds.Fire:Play()
	wait(ReloadTime)
	if DisplayPlunger then
		DisplayPlunger.Transparency = 0
	end
	Tool.Enabled = true
end

function CreateDisplay(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	DisplayPlunger = BasePlunger:Clone()
	DisplayPlunger.Name = "DisplayPart"
	DisplayPlunger.Transparency = ((Tool.Enabled and 0) or 1)
	DisplayPlunger.CanCollide = false
	local Weld = Create("Weld"){
		Part0 = Handle,
		Part1 = DisplayPlunger,
		C0 = (CFrame.new(0.25, -1.25, 0) * CFrame.Angles(-(math.pi / 2), 0, math.pi)),
		C1 = CFrame.new(0, 0, 0),
		Parent = DisplayPlunger,
	}
	DisplayPlunger.Parent = Tool
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		return
	end
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	local TargetPosition = MousePosition.Position
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Throw)
	end)
	Shoot(TargetPosition)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateDisplay(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		CreateDisplay(true)
	end)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not mode or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

CreateDisplay(true)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)