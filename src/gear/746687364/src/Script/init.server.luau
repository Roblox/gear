--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

ShockWave = BasePart:Clone()
ShockWave.Name = "ShockWave"
ShockWave.Transparency = 1
ShockWave.Size = Vector3.new(0.2, 4, 0.2)
ShockWave.Anchored = true
ShockWave.CanCollide = false
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Brick
Mesh.Scale = Vector3.new(1, 0, 1)
Mesh.Parent = ShockWave
for i = 1, 2 do
	local Decal = Instance.new("Decal")
	Decal.Texture = (BaseUrl .. "183210124")
	Decal.Transparency = 0.125
	Decal.Face = ((i == 1 and Enum.NormalId.Top) or Enum.NormalId.Bottom)
	Decal.Color3 = Color3.new(255, 255, 255)
	Decal.Parent = ShockWave
end

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")

Animations = {
	R6Swing = {Animation = R6Anims:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1.5},
	R6Bash = {Animation = R6Anims:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.4},
	R15Swing = {Animation = R15Anims:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1.5},
	R15Bash = {Animation = R15Anims:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.4},
}

Sounds = {
	Swing = Handle:WaitForChild("Swing"),
	Hit = Handle:WaitForChild("Hit"),
	Bash = Handle:WaitForChild("Bash"),
}

DamageValues = {
	Swing = 10,
	Bash = 60,
}
Damage = DamageValues.Swing

HitCount = 0
LastBash = 0
LastAttack = 0
SpinEnabled = false
ToolEquipped = false

Remotes = (Tool:FindFirstChild("Remotes") or Instance.new("Folder"))
Remotes.Name = "Remotes"
Remotes.Parent = Tool

ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

Tool.Enabled = true

function CreateMallet(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not Create then
		return
	end
	MalletHead = BasePart:Clone()
	MalletHead.Name = "MalletHead"
	MalletHead.Transparency = 1
	MalletHead.Size = Vector3.new(1.25, 1.5, 2.25)
	local Weld = Instance.new("Weld")
	Weld.Name = "Weld"
	Weld.Part0 = Handle
	Weld.Part1 = MalletHead
	Weld.C0 = CFrame.new(0, 2.325, 0)
	Weld.C1 = CFrame.new(0, 0, 0)
	Weld.Parent = MalletHead
	Weld.Parent = MalletHead
	Blow(MalletHead)
	MalletHead.Parent = Tool
end

function Billboard(Pos, Text, Time, Color)
	local Rate = (1 / 30)
	local Pos = (Pos or Vector3.new(0, 0, 0))
	local Text = (Text or "")
	local Time = (Time or 2)
	local Color = (Color or Color3.new(1, 0, 0))
	local EffectPart = BasePart:Clone()
	EffectPart.Name = "Effect"
	EffectPart.Size = Vector3.new(0, 0, 0)
	EffectPart.CFrame = CFrame.new(Pos)
	EffectPart.Anchored = true
	EffectPart.CanCollide = false
	EffectPart.Transparency = 1
	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Size = UDim2.new(3, 0, 3, 0)
	BillboardGui.Adornee = EffectPart
	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Text = Text
	TextLabel.TextColor3 = Color
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.ArialBold
	TextLabel.Parent = BillboardGui
	BillboardGui.Parent = EffectPart
	Debris:AddItem(EffectPart, (Time + 0.1))
	EffectPart.Parent = game:GetService("Workspace")
	Delay(0, function()
		local Frames = (Time / Rate)
		for Frame = 1, Frames do
			wait(Rate)
			local Percent = (Frame / Frames)
			EffectPart.CFrame = CFrame.new(Pos) + Vector3.new(0, Percent, 0)
			TextLabel.TextTransparency = Percent
		end
		if EffectPart and EffectPart.Parent then
			EffectPart:Destroy()
		end
	end)
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not CurrentAnimation or HitCount >= 3 then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local rootpart = (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
	if not humanoid or humanoid.Health == 0 or not rootpart then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
		return
	end
	if HitCount == 0 then
		Sounds.Hit:Play()
	end
	HitCount = (HitCount + 1)
	local Radius = Vector3.new(1.25, 0.25, 1.25)
	Radius = (Radius * 100)
	local Offset = Vector3.new(math.random(-Radius.X, Radius.X), math.random(-Radius.Y, Radius.Y), math.random(-Radius.Z, Radius.Z))
	Offset = Offset * Vector3.new(0.01, 0.01, 0.01)
	Billboard((Handle.Position + Offset + Vector3.new(0, 2.5, 0)), Damage, 2, BrickColor.new("Really red").Color)
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	if HitCount == 1 and humanoid.Health <= (Humanoid.MaxHealth * 0.3) then
		local ThrowVelocity = 200
		rootpart.Velocity = ((CFrame.new(MalletHead.Position, rootpart.Position).lookVector * ThrowVelocity) + Vector3.new(0, (ThrowVelocity / 2), 0))
		rootpart.RotVelocity = Vector3.new(math.random(-(ThrowVelocity / 2), (ThrowVelocity / 2)), math.random(-(ThrowVelocity / 2), (ThrowVelocity / 2)), math.random(-(ThrowVelocity / 2), (ThrowVelocity / 2)))
	end
	if humanoid.Health <= 0 then
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") then
				local Fire = Instance.new("Fire")
				Fire.Name = "Fire"
				Fire.Heat = 9
				Fire.Size = 5
				Fire.Color = Color3.new((236 / 255), (139 / 255), (70 / 255))
				Fire.SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255))
				Fire.Enabled = true
				Fire.Parent = v
			end
		end
	end
end

function Swing()
	CurrentAnimation = Animations.R6Swing
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		CurrentAnimation = Animations.R15Swing
	end
	Damage = DamageValues.Swing
	Sounds.Swing:Play()
	Spawn(function()
		InvokeClient("PlayAnimation", CurrentAnimation)
	end)
	wait(CurrentAnimation.Duration)
	CurrentAnimation = nil
end

function Bash()
	CurrentAnimation = Animations.R6Bash
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		CurrentAnimation = Animations.R15Bash
	end
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Damage = DamageValues.Bash
	Spawn(function()
		InvokeClient("PlayAnimation", CurrentAnimation)
	end)
	wait(CurrentAnimation.Duration)
	if not CurrentlyEquipped or not ToolEquipped or not CheckIfAlive() then
		CurrentAnimation = nil
		return
	end
	local SpikeColors = {"Dark orange", "Daisy orange", "Artichoke", "Cadet blue"}
	local SpikeCount = math.random(12, 26)
	local function SpikeHit(Part, Hit)
		Part.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or not CheckIfAlive() or Part.Velocity.Magnitude < 3 then
				return
			end
			local character = Hit.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and (player == Player or Functions.IsTeamMate(Player, player)) then
				return
			end
			Functions.UntagHumanoid(humanoid)
			Functions.TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(20)
		end)
	end
	local BoulderCount = math.random(10, 16)
	for i = 1, BoulderCount do
		local Boulder = BasePart:Clone()
		Boulder.Name = "Boulder"
		Boulder.BrickColor = BrickColor.new("Bright orange")
		Boulder.Material = Enum.Material.Granite
		Boulder.Size = Vector3.new(math.random(4, 6), math.random(4, 6), math.random(4, 6))
		Boulder.Anchored = true
		local Origin = CFrame.new(RootPart.Position)
		local BoulderCF = ((Origin + (Origin * CFrame.Angles(0, ((math.pi * 2) / BoulderCount * i), 0)).lookVector * 7.5) * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360))))
		local RayHit, RayPos, RayNormal, RaySurface = Functions.CastRay(BoulderCF.p, Vector3.new(0, -1, 0), (RootPart.Size.Y * 2), {Character}, false)
		if RayHit then
			Boulder.CFrame = (CFrame.new(RayPos - Vector3.new(0, 0.75, 0)) * CFrame.Angles(BoulderCF:toEulerAnglesXYZ()))
			Debris:AddItem(Boulder, (6 + (math.random(0, 300) * 0.01)))
			Boulder.Parent = game:GetService("Workspace")
		end
	end
	for i = 1, SpikeCount do
		local Spike = BasePart:Clone()
		Spike.Name = "Projectile"
		Spike.Reflectance = 0.5
		Spike.BrickColor = BrickColor.new(SpikeColors[math.random(1, #SpikeColors)])
		Spike.Size = Vector3.new(1.5, 2, 1.5)
		local Mesh = Instance.new("SpecialMesh")
		Mesh.Name = "Mesh"
		Mesh.MeshType = Enum.MeshType.FileMesh
		Mesh.MeshId = (BaseUrl .. "59092052")
		Mesh.TextureId = ""
		Mesh.Scale = Vector3.new(2, 2, 2)
		Mesh.VertexColor = Vector3.new(1, 1, 1)
		Mesh.Offset = Vector3.new(0, 0, 0)
		Mesh.Parent = Spike
		local Gravity = game:GetService("Workspace").Gravity
		local Weight = (Spike:GetMass() * Gravity)
		--[[local Force = Instance.new("BodyVelocity")
		Force.Name = "BodyVelocity"
		Force.P = 1250
		Force.MaxForce = Vector3.new(0, math.huge, 0)
		Force.Parent = Spike
		local Gyro = Instance.new("BodyGyro")
		Gyro.Name = "BodyGyro"
		Gyro.D = 500
		Gyro.P = 300
		Gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		Gyro.Parent = Spike
		local Position = Instance.new("BodyPosition")
		Position.Name = "BodyPosition"
		Position.D = 10000
		Position.P = 1250
		Position.MaxForce = Vector3.new(math.huge, 0, math.huge)
		Position.Parent = Spike]]
		local Speed = math.random(175, 250)
		local Velocity = ((Vector3.new(0, 1, 0) * Speed) + (Vector3.new((math.random(-100, 100) * 0.01), 0, (math.random(-100, 100) * 0.01)) * math.random(5, 25)))
		local Origin = (CFrame.new(RootPart.Position) * CFrame.new(0, (RootPart.Size.Y * 1.5), 0))
		local Offset = (math.random(400, 1500) * 0.01)
		local SpikeCF = ((Origin + (Origin * CFrame.Angles(0, ((math.pi * 2) / SpikeCount * i), 0)).lookVector * Offset) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0))
		--Force.Velocity = Velocity
		--Gyro.CFrame = SpikeCF
		--Position.Position = SpikeCF.p
		Spike.CFrame = SpikeCF
		Spike.Velocity = Velocity
		Spike.RotVelocity = Vector3.new(math.random(), math.random(), math.random())
		SpikeHit(Spike)
		Debris:AddItem(Spike, (3 + (math.random(0, 300) * 0.01)))
		Spike.Parent = game:GetService("Workspace")
	end
	local UserPlayer = Player
	local UserCharacter = Character
	local IgnoreObjects = {UserCharacter, Tool}
	local Radius = 45
	local Humanoids = {}
	local PlayersNearby = {}
	local NegativeRadius = (RootPart.Position - Vector3.new(Radius, (RootPart.Size.Y * 1.25), Radius))
	local PositiveRadius = (RootPart.Position + Vector3.new(Radius, (Radius / 6), Radius))
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= UserPlayer then
			local character = v.Character
			if character and character.Parent then
				table.insert(IgnoreObjects, v)
				if not Functions.IsTeamMate(v, UserPlayer) then
					local humanoid = character:FindFirstChild("Humanoid")
					local rootpart = (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
					if humanoid and humanoid.Health > 0 and (RootPart.Position - rootpart.Position).magnitude <= Radius then
						table.insert(Humanoids, humanoid)
					end
				end
			end
		end
	end
	local Region = Region3.new(NegativeRadius, PositiveRadius)
	local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, IgnoreObjects, 3000)
	for i, v in pairs(Parts) do
		if v and v.Parent then
			local character = v.Parent
			if character:IsA("Accoutrement") or character:IsA("Tool") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local player = Players:GetPlayerFromCharacter(character)
			if not Functions.CheckTableForInstance(Humanoids, humanoid) and not Functions.CheckTableForInstance(PlayersNearby, character) then
				if humanoid and humanoid.Health > 0 and not Functions.CheckTableForInstance(Humanoids, humanoid) then
					table.insert(Humanoids, humanoid)
					if player and not Functions.CheckTableForInstance(PlayersNearby, player) then
						table.insert(PlayersNearby, player)
					end
				end
			end
		end
	end
	for i, v in pairs(Humanoids) do
		local character = v.Parent
		local player = Players:GetPlayerFromCharacter(character)
		local humanoid = character:FindFirstChild("Humanoid")
		local rootpart = (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
		if humanoid and humanoid.Health > 0 and rootpart then
			if (RootPart.Position - rootpart.Position).Magnitude <= 25 then
				Functions.UntagHumanoid(v)
				Functions.TagHumanoid(v, UserPlayer)
				humanoid.Sit = true
				v:TakeDamage(30)
			end
		end
	end
	Spawn(function()
		local PushBack = 50
		local DesiredRadius = 50
		for i = 1, 2 do
			wait(0.5)
			if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			local ShockWaveClone = ShockWave:Clone()
			local OriginalCFrame = CFrame.new(RootPart.Position)
			ShockWaveClone.CFrame = OriginalCFrame
			ShockWaveClone.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				local character = Hit.Parent
				if character:IsA("Accoutrement") then
					character = character.Parent
				end
				local player = Players:GetPlayerFromCharacter(character)
				if player and (player == Player or Functions.IsTeamMate(Player, player)) then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or humanoid.Health == 0 then
					return
				end
				local rootpart = (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
				if rootpart then
					rootpart.Velocity = (CFrame.new(rootpart.Position, RootPart.Position).lookVector * -PushBack)
				end
				Functions.UntagHumanoid(humanoid)
				Functions.TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(3)
				humanoid.Sit = true
			end)
			Debris:AddItem(ShockWaveClone, 5)
			ShockWaveClone.Parent = game:GetService("Workspace")
			Spawn(function()
				local Rate = (1 / 60)
				local ResizeRate = 25
				for i = 1, ResizeRate do
					local ShockWaveSize = ((DesiredRadius / 25) * i)
					for ii, vv in pairs(ShockWaveClone:GetChildren()) do
						if vv:IsA("Decal") then
							vv.Transparency = ((1 * i) / ResizeRate)
						end
					end
					ShockWaveClone.Size = Vector3.new(ShockWaveSize, ShockWave.Size.Y, ShockWaveSize)
					ShockWaveClone.CFrame = OriginalCFrame
					wait(Rate)
				end
				if ShockWaveClone and ShockWaveClone.Parent then
					ShockWaveClone:Destroy()
				end
			end)
		end
	end)
	Sounds.Bash:Play()
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	wait(2)
	CurrentAnimation = nil
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	HitCount = 0
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack) < 0.2 and (Tick - LastBash) >= 8 then
		LastBash = Tick
		Bash()
	else
		Spawn(function()
			if CurrentAnimation then
				return
			end
			Swing()
		end)
	end
	LastAttack = Tick
	Damage = DamageValues.Swing
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateMallet(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Spawn(function()
		CreateMallet(true)
	end)
	SpinEnabled = false
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value then
		return
	end
end

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CreateMallet(true)
end))

Handle.Touched:connect(Blow)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)