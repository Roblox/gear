--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

FunctionsLibrary = script:WaitForChild("Functions")
ProjectileManager = script:WaitForChild("ProjectileManager")
Functions = require(FunctionsLibrary)

Logo = script:WaitForChild("Logo")

BaseUrl = "http://www.roblox.com/asset/?id="

Grips = {
	Unequipped = CFrame.new(0, -0.55, 0.25, 0.999456942, 0.0329490229, 8.57583218e-005, -0.032949131, 0.999453723, 0.00260133552, 0, -0.00260274881, 0.999996662),
	Equipped = CFrame.new(0, -0.55, 0, 0.895361722, -0.122880988, 0.428051084, -0.0245711952, 0.946083665, 0.322989047, -0.444661349, -0.299709737, 0.844067812),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Reload = Handle:WaitForChild("Reload"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Material = Enum.Material.Neon
BaseProjectile.Size = Vector3.new(0.2, 0.2, 0.4)
BaseProjectile.CanCollide = false
BaseProjectile.Locked = true
BaseProjectile.Anchored = false
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "515584133"),
	TextureId = (BaseUrl .. "515586133"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseProjectile,
}

Rate = (1 / 30)
Gravity = 196.20

Configuration = {
	BarrelOffsets = {
		{Offset = CFrame.new(0.12, 0.015, -0.725), Ready = true, Part = nil},
		{Offset = CFrame.new(-0.12, 0.015, -0.725), Ready = true, Part = nil},
		{Offset = CFrame.new(0.12, 0.015 - 0.1, -0.725), Ready = true, Part = nil},
		{Offset = CFrame.new(-0.12, 0.015 - 0.1, -0.725), Ready = true, Part = nil},
		{Offset = CFrame.new(0.12, 0.015 - 0.2, -0.725), Ready = true, Part = nil},
		{Offset = CFrame.new(-0.12, 0.015 - 0.2, -0.725), Ready = true, Part = nil},
		{Offset = CFrame.new(0.12, 0.015 - 0.3, -0.725), Ready = true, Part = nil},
		{Offset = CFrame.new(-0.12, 0.015 - 0.3, -0.725), Ready = true, Part = nil},
	},
	Damage = 0,
	FireRate = 0.1,
	ReloadTime = 1.5,
	Projectile = {
		Speed = 50,
		Duration = 1.125,
	},
}

CurrentBarrel = 1

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Player and Player.Parent) and true) or false)
end

function CraftGun(Craft)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not Craft then
		return
	end
	Saw = BasePart:Clone()
	Saw.Name = "Saw"
	Saw.Size = Vector3.new(0.2, 0.2, 0.2)
	Saw.CanCollide = false
	Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "515998042"),
		TextureId = (BaseUrl .. "515586133"),
		Scale = Mesh.Scale,
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Saw,
	}
	SawMotor = Create("Motor6D"){
		Part0 = Handle,
		Part1 = Saw,
		C0 = (CFrame.new(0, -0.095, -1.7, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles((math.pi / 2), -(math.pi / 2), 0)),
		C1 = (CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(-(math.pi / 2), (math.pi / 2), 0)),
		CurrentAngle = 0,
		DesiredAngle = 1e+010,
		MaxVelocity = 0,
		Parent = Saw
	}
	for i, v in pairs({Saw}) do
		v.Parent = Tool
	end
	ReloadBarrels()
end

function ReloadBarrels()
	for i, v in pairs(Configuration.BarrelOffsets) do
		if v.Ready then
			if not v.Part or not v.Part.Parent then
				local FakeDart = BaseProjectile:Clone()
				FakeDart.Name = "Dart"
				FakeDart.CanCollide = false
				local Weld = Create("Weld"){
					Name = "Weld",
					Part0 = Handle,
					Part1 = FakeDart,
					C0 = v.Offset,
					C1 = CFrame.new(0, 0, 0),
					Parent = FakeDart,
				}
				v.Part = FakeDart
				FakeDart.Parent = Tool
			end
		else
			if v.Part and v.Part.Parent then
				v.Part:Destroy()
			end
			v.Part = nil
		end
	end
end

function GetProjectileManager()
	local ProjectileModelName = (Player.Name .. "'sProjectiles")
	local ProjectileModel = game:GetService("Workspace"):FindFirstChild(ProjectileModelName)
	if not ProjectileModel then
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
			{Name = "Damage", Class = "NumberValue", Value = Configuration.Damage},
		}
		ProjectileModel = Create("Model"){
			Name = ProjectileModelName,
		}
		local ProjectileManagerCopy = ProjectileManager:Clone()
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = ProjectileManagerCopy,
			}
		end
		local FunctionsCopy = FunctionsLibrary:Clone()
		FunctionsCopy.Parent = ProjectileManagerCopy
		ProjectileManagerCopy.Disabled = false
		ProjectileManagerCopy.Parent = ProjectileModel
		ProjectileModel.Parent = game:GetService("Workspace")
	end
	return ProjectileModel
end

function FireProjectile(TargetPosition)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local Projectile = BaseProjectile:Clone()
	local StartPosition = (Handle.CFrame * Configuration.BarrelOffsets[CurrentBarrel].Offset)
	local Direction = CFrame.new(StartPosition.p, TargetPosition)
	local Mass = (Projectile:GetMass() * Gravity)
	local Velocity = (Direction.lookVector * Configuration.Projectile.Speed)
	Projectile.Velocity = Velocity
	local Orientation = (Direction * CFrame.Angles(0, 0, 0))
	local Force = Create("BodyForce"){
		force = Vector3.new(0, Mass, 0),
		Parent = Projectile,
	}
	local Gyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		cframe = Orientation,
		Parent = Projectile,
	}
	local Values = {
		{Name = "Damage", Class = "NumberValue", Value = Configuration.Damage},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Projectile,
		}
	end
	Configuration.BarrelOffsets[CurrentBarrel].Ready = false
	ReloadBarrels()
	Projectile.CFrame = Orientation
	Debris:AddItem(Projectile, Configuration.Projectile.Duration)
	Projectile.Parent = GetProjectileManager()
	CurrentBarrel = (CurrentBarrel + 1)
	if CurrentBarrel > #Configuration.BarrelOffsets then
		CurrentBarrel = 1
		wait(Configuration.ReloadTime)
		for i, v in pairs(Configuration.BarrelOffsets) do
			v.Ready = true
		end
		ReloadBarrels()
	end
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local TargetPosition = MouseData.Position
	SawMotor.MaxVelocity = 0.1
	for i = 1, 1 do
		if CheckIfAlive() and ToolEquipped and CurrentlyEquipped then
			local TempSound = Sounds.Fire:Clone()
			Debris:AddItem(TempSound, 1.5)
			TempSound.Parent = Handle
			TempSound:Play()
			FireProjectile(TargetPosition)
			wait(0.175)
		end
	end
	SawMotor.MaxVelocity = 0
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	Sounds.Reload:Play()
	wait(Configuration.FireRate)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	Spawn(function()
		--[[LogoCopy = Logo:Clone()
		LogoCopy.Adornee = Head
		LogoCopy.Enabled = true
		Debris:AddItem(LogoCopy, 5)
		LogoCopy.Parent = Tool]]
		CraftGun(true)
		InvokeClient("PlayAnimation", Animations.Hold)
	end)
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	Spawn(function()
		if LogoCopy and LogoCopy.Parent then
			LogoCopy:Destroy()
		end
		CraftGun(true)
		for i, v in pairs(Sounds) do
			v:Stop()
		end
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

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CraftGun(true)
end))

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)