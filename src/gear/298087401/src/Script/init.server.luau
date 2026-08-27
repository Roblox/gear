--Made by Luckymaxer

wait()

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

ParticlesBin = script:WaitForChild("Particles")
Particles = {}
for i, v in pairs(ParticlesBin:GetChildren()) do
	if v:IsA("ParticleEmitter") then
		Particles[v.Name] = v
	end
end

ModeGui = script:WaitForChild("ModeGui")

BaseUrl = "http://www.roblox.com/asset/?id="

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Flame = Handle:WaitForChild("Flame"),
	IgniteFlameOn = Handle:WaitForChild("IgniteFlameOn"),
	IgniteFlameOff = Handle:WaitForChild("IgniteFlameOff"),
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
BaseProjectile.BrickColor = BrickColor.new("Pastel Blue")
BaseProjectile.Material = Enum.Material.Neon
BaseProjectile.Size = Vector3.new(0.2, 1.5, 0.2)
BaseProjectile.CanCollide = false
BaseProjectile.Locked = true
BaseProjectile.Anchored = false
Create("BlockMesh"){
	Scale = Vector3.new(0.5, 1, 0.5),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseProjectile,	
}
Create("PointLight"){
	Color = BaseProjectile.BrickColor.Color,
	Brightness = 50,
	Range = 2,
	Shadows = false,
	Enabled = true,
	Parent = BaseProjectile,
}

Modes = {
	{Name = "RapidFire", Text = "MODE: Rapid-Fire Gatling Gun", Color = Color3.new(0, 0, 1)},
	{Name = "Flamethrower", Text = "MODE: Underbarrel-Flamethrower", Color = Color3.new(1, 0, 0)},
}

FireMode = Modes[1]

Rate = (1 / 30)
Gravity = 196.20

MouseDown = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent and Player:IsA("Player")) and true) or false)
end

function CraftGun(Craft)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	Handle.Transparency = ((Craft and 1) or 0)
	if not Craft then
		return
	end
	local Gun = BasePart:Clone()
	Gun.Name = "Gun"
	Gun.Size = Vector3.new(0.2, 0.2, 0.2)
	Gun.CanCollide = false
	Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "287444318"),
		TextureId = (BaseUrl .. "287439796"),
		Scale = Mesh.Scale,
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Gun,
	}
	local Barrel = BasePart:Clone()
	Barrel.Name = "Barrel"
	Barrel.Size = Vector3.new(0.2, 0.2, 0.2)
	Barrel.CanCollide = false
	Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "287444248"),
		TextureId = (BaseUrl .. "287439796"),
		Scale = Mesh.Scale,
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Barrel,
	}
	Flamethrower = BasePart:Clone()
	Flamethrower.Name = "Flamethrower"
	Flamethrower.Transparency = 1
	Flamethrower.Size = Vector3.new(0.2, 0.2, 0.2)
	Flamethrower.CanCollide = false
	GunWeld = Create("Weld"){
		Part0 = Handle,
		Part1 = Gun,
		C0 = CFrame.new(0, 0, 0.25),
		C1 = CFrame.new(0, 0, 0),
		Parent = Gun,
	}
	BarrelMotor = Create("Motor6D"){
		Part0 = Gun,
		Part1 = Barrel,
		C0 = CFrame.new(0, 0.53, -1.825),
		C1 = CFrame.new(0, 0, 0),
		CurrentAngle = 0,
		DesiredAngle = 9999999999999,
		MaxVelocity = 0,
		Parent = Barrel
	}
	FlamethrowerWeld = Create("Weld"){
		Part0 = Handle,
		Part1 = Flamethrower,
		C0 = (CFrame.new(0, 0, -1.375) * CFrame.Angles(-(math.pi / 2), 0, 0)),
		C1 = CFrame.new(0, 0, 0),
		Parent = Flamethrower,
	}
	for i, v in pairs({Gun, Barrel, Flamethrower}) do
		v.Parent = Tool
	end
end

function GetProjectileManager()
	local ProjectileModelName = (Player.Name .. "'sProjectiles")
	local ProjectileModel = game:GetService("Workspace"):FindFirstChild(ProjectileModelName)
	if not ProjectileModel then
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
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

function FireProjectiles()
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	local BarrelSpeed = {Min = 0, Max = 0.375}
	local Charge = {Start = tick(), Max = 8}
	local BulletOffsets = {
		Vector3.new(0, 0.525, -2),
		Vector3.new(0.2, 0.365, -2),
		Vector3.new(0.2, 0.7, -2),
		Vector3.new(-0.2, 0.365, -2),
		Vector3.new(-0.2, 0.7, -2),
	}
	local FireSound = Sounds.Fire
	FireSound:Play()
	local Shooting = {Tick = 0, Delay = 0.25}
	while ToolEquipped and CurrentlyEquipped and CheckIfAlive() and MouseDown do
		local Now = tick()
		local ChargePercent = (Functions.Clamp(Functions.GetPercentage(Charge.Start, (Charge.Start + Charge.Max), Now), 0, 100) * 0.01)
		if BarrelMotor then
			BarrelMotor.MaxVelocity = Functions.Clamp((BarrelSpeed.Max * ChargePercent), BarrelSpeed.Min, BarrelSpeed.Max)
		end
		FireSound.Volume = Functions.Clamp((1 * ChargePercent), 0, 1)
		FireSound.Pitch = Functions.Clamp((0.75 * ChargePercent), 0.4, 0.75)
		Shooting.Delay = (1 - Functions.Clamp((0.75 * ChargePercent), 0.1, 0.75))
		if (Now - Shooting.Tick) >= Shooting.Delay and ChargePercent >= 0.25 then
			Shooting.Tick = Now
			local MouseData = InvokeClient("MouseData")
			if MouseData then
				local TargetPosition = MouseData.Position
				Spawn(function()
					for i, v in pairs(BulletOffsets) do
						if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() or not MouseDown then
							return
						end
						local Projectile = BaseProjectile:Clone()
						local Color = ((not Player.Neutral and Player.TeamColor) or Projectile.BrickColor)
						Projectile.BrickColor = Color
						for i, v in pairs(Projectile:GetChildren()) do
							if v:IsA("Light") then
								v.Color = Color.Color
							end
						end
						local SparksCopy = Particles.Sparks:Clone()
						SparksCopy.Color = ColorSequence.new(Color.Color, Color.Color)
						SparksCopy.Enabled = true
						SparksCopy.Parent = Projectile
						local StartPosition = (Handle.CFrame * CFrame.new(v.X, v.Y, (v.Z - (Projectile.Size.Y / 1.5))))
						local Direction = CFrame.new(StartPosition.p, TargetPosition)
						local Force = 75
						local Mass = (Projectile:GetMass() * Gravity)
						local Velocity = (Direction.lookVector * Force)
						Projectile.Velocity = Velocity
						local Orientation = (Direction * CFrame.Angles(-(math.pi / 2), 0, 0))
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
							{Name = "Damage", Class = "NumberValue", Value = 8},
							{Name = "Type", Class = "StringValue", Value = "Projectile"},
						}
						for i, v in pairs(Values) do
							local Value = Create(v.Class){
								Name = v.Name,
								Value = v.Value,
								Parent = Projectile,
							}
						end
						Projectile.CFrame = Orientation
						Debris:AddItem(Projectile, 1.5)
						Projectile.Parent = GetProjectileManager()
						wait()
					end
				end)
			end
		end
		wait()
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
end

function SprayFire()
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	local Shooting = {Tick = 0, Delay = 0.1}
	Sounds.IgniteFlameOn:Play()
	Sounds.Flame:Play()
	local Fire = Particles.Flame:Clone()
	Fire.Enabled = false
	Fire.Parent = Flamethrower
	while ToolEquipped and CurrentlyEquipped and CheckIfAlive() and MouseDown and Flamethrower.Parent and FlamethrowerWeld.Parent and FlamethrowerWeld.Part0 == Handle and FlamethrowerWeld.Part1 == Flamethrower do
		Fire.Enabled = true
		local Now = tick()
		if (Now - Shooting.Tick) >= Shooting.Delay then
			Shooting.Tick = Now
			local FirePart = BasePart:Clone()
			FirePart.Name = "Projectile"
			FirePart.Transparency = 1
			FirePart.Size = Vector3.new(1, 1, 1)
			FirePart.CanCollide = false
			local Fire = Particles.Flame
			local Direction = CFrame.new(Flamethrower.Position, (Flamethrower.CFrame * CFrame.new(0, 1, 0)).p)
			local VelocitySpread = CFrame.Angles(((math.random(-Fire.VelocitySpread, Fire.VelocitySpread) * 0.01) * 2.5), ((math.random(-Fire.VelocitySpread, Fire.VelocitySpread) * 0.01) * 2.5), ((math.random(-Fire.VelocitySpread, Fire.VelocitySpread) * 0.01) * 2.5))
			local Velocity = ((Direction * VelocitySpread).lookVector * Fire.Speed.Max)
			FirePart.CFrame = (Flamethrower.CFrame + Direction.lookVector * ((Flamethrower.Size.Z / 2) + (FirePart.Size.Z / 2) + 0.25))
			FirePart.Velocity = Velocity
			local Mass = (FirePart:GetMass() * Gravity)
			local Force = Create("BodyForce"){
				force = Vector3.new(0, Mass, 0),
				Parent = FirePart,
			}
			local Values = {
				{Name = "Damage", Class = "NumberValue", Value = 5},
				{Name = "Type", Class = "StringValue", Value = "Fire"},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = FirePart,
				}
			end
			Debris:AddItem(FirePart, Fire.Lifetime.Max)
			FirePart.Parent = GetProjectileManager()
		end
		wait()
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	Fire.Enabled = false
	Debris:AddItem(Fire, 2)
	Sounds.Flame:Stop()
	Sounds.IgniteFlameOff:Play()
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or MouseDown then
		return
	end
	Tool.Enabled = false
	MouseDown = true
	if FireMode == Modes[1] then
		FireProjectiles()
	elseif FireMode == Modes[2] then
		SprayFire()
	end
end

function Deactivated()
	if not MouseDown then
		return
	end
	MouseDown = false
	if FireMode == Modes[1] then
		local DecreaseRate = 100
		local WaitRate = 0.03
		local CurrentMotor = BarrelMotor
		local FireSound = Sounds.Fire
		local MotorDecreaseAmount = (CurrentMotor.MaxVelocity / DecreaseRate)
		local FireVolume = (FireSound.Volume / DecreaseRate)
		local FirePitch = (FireSound.Pitch / DecreaseRate)
		for i = 1, DecreaseRate do
			local DecreaseAmount = (DecreaseRate - i)
			CurrentMotor.MaxVelocity = (MotorDecreaseAmount * DecreaseAmount)
			FireSound.Volume = (FireVolume * DecreaseAmount)
			FireSound.Pitch = (FirePitch * DecreaseAmount)
			wait(WaitRate)
		end
		Sounds.Fire:Stop()
	elseif FireMode == Modes[2] then
		local Smoke = Particles.Smoke:Clone()
		Smoke.Enabled = true
		Debris:AddItem(Smoke, 3)
		Delay(1.5, (function()
			Smoke.Enabled = false
		end))
		Smoke.Parent = Flamethrower
		wait(2.5)
	end
	Tool.Enabled = true
end

function UpdateGui()
	if not ModeGuiCopy then
		return
	end
	local MainFrame = ModeGuiCopy:FindFirstChild("MainFrame")
	if not MainFrame then
		return
	end
	local Button = MainFrame:FindFirstChild("Button")
	if not Button then
		return
	end
	local ModeText = Button:FindFirstChild("ModeText")
	if not ModeText then
		return
	end
	ModeText.Text = FireMode.Text
	ModeText.TextColor3 = FireMode.Color
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			ModeGuiCopy = ModeGui:Clone()
			local Values = {
				{Name = "ServerConnection", Class = "ObjectValue", Value = ServerControl},
				{Name = "Tool", Class = "ObjectValue", Value = Tool},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = ModeGuiCopy,
				}
			end
			UpdateGui()
			ModeGuiCopy.Parent = PlayerGui
		end
		CraftGun(true)
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Hold)
		end)
		Deactivated()
	end)
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		for i, v in pairs({ModeGuiCopy}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		CraftGun(false)
		for i, v in pairs(Sounds) do
			v:Stop()
		end
		Deactivated()
	end)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not mode or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
		if Down and not MouseDown then
			Activated()
		elseif not Down and MouseDown then
			Deactivated()
		end
	elseif mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down and not MouseDown and ToolEquipped and CheckIfAlive() then
			for i, v in pairs(Modes) do
				if v == FireMode then
					local NewMode = Modes[(i + 1)]
					FireMode = ((NewMode and NewMode) or Modes[1])
					break
				end
			end
			UpdateGui()
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

CraftGun(true)

ServerControl.OnServerInvoke = OnServerInvoke

--Tool.Activated:connect(Activated)
--Tool.Deactivated:connect(Deactivated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)