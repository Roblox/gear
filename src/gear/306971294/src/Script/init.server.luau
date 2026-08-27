--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")
RunService = game:GetService("RunService")

BatModel = InsertService:LoadAsset(167116921)
BaseBat = BatModel:GetChildren()[1]:Clone()
Debris:AddItem(BatModel, 1)

ScaleModule = require(201433042)
BaseBat.Torso.Anchored = true
BaseBat.Parent = game:GetService("Workspace")
ScaleModule.ScaleCharacter(BaseBat, 0.2, {ResizeModels = true})
BaseBat.Parent = nil

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))
BatManagement = script:WaitForChild("BatManagement")

EffectFire = script:WaitForChild("EffectFire")
ParticleScript = script:WaitForChild("ParticleScript")

Grips = {
	Unequipped = CFrame.new(0, -0.25, 0.6, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0, -0.25, 0.6, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Strike = {Animation = Tool:WaitForChild("Strike"), FadeTime = nil, Weight = nil, Speed = 1.75, Duration = 1.25},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1.25},
	DoubleSlash = {Animation = Tool:WaitForChild("DoubleSlash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 1.5},
	JumpAttack = {Animation = Tool:WaitForChild("JumpAttack"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1.125},
	Slice = {Animation = Tool:WaitForChild("Slice"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.75},
	Cut = {Animation = Tool:WaitForChild("Cut"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1},
	SpinSlash = {Animation = Tool:WaitForChild("SpinSlash"), FadeTime = nil, Weight = nil, Speed = 2.25, Duration = 0.75},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Swipe1 = Handle:WaitForChild("Swipe1"),
	Swipe2 = Handle:WaitForChild("Swipe2"),
	Swipe3 = Handle:WaitForChild("Swipe3"),
	Swipe4 = Handle:WaitForChild("Swipe4"),
	Hit = Handle:WaitForChild("Hit"),
}

Damages = {
	Touch = 4,
	Slash = 20,
}
CurrentDamage = Damages.Touch

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Gravity = 196.20

Falling = false
JumpEnabled = true
ToolEquipped = false

Tool.Enabled = true
Tool.Grip = Grips.Unequipped

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

function BlowHit(Hit, Damage)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or RightGrip.Part0 ~= RightArm or RightGrip.Part1 ~= Handle then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
		return
	end
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	if humanoid.Health <= 0 then
	end
	return true
end

function CreateScythePiece(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	Blade = BasePart:Clone()
	Blade.Name = "Blade"
	Blade.Transparency = 1
	Blade.Size = Vector3.new(0.25, 1.5, 4)
	Blade.CanCollide = false
	local Weld = Create("Weld"){
		Part0 = Handle,
		Part1 = Blade,
		C0 = CFrame.new(0, 2, -1),
		C1 = CFrame.new(0, 0, 0),
		Parent = Blade,
	}
	Blade.Parent = Tool
	local HitDelay = false
	for i, v in pairs({Handle, Blade}) do
		v.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or not CheckIfAlive() or HitDelay then
				return
			end
			local HitSuccessful = BlowHit(Hit, 10)
			if HitSuccessful then
				HitDelay = true
				wait(0.25)
				HitDelay = false
			end
		end)
	end
end

function CreateBats()
	local Bats = {}
	for i = 1, 8 do
		local Bat = BaseBat:Clone()
		local torso = Bat:FindFirstChild("Torso")
		if torso then
			local Mass = 0
			for i, v in pairs(Bat:GetChildren()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
					Mass = (Mass + v:GetMass())
				end
			end
			Mass = (Mass * Gravity * 1.25)
			local BodyGyro = Create("BodyGyro"){
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				Parent = torso,
			}
			local BodyPosition = Create("BodyPosition"){
				D = 10000,
				P = 20000,
				maxForce = Vector3.new(Mass, Mass, Mass),
				Parent = torso,
			}
			table.insert(Bats, {Bat = Bat, Torso = torso, BodyGyro = BodyGyro, BodyPosition = BodyPosition})
		end
	end
	return Bats
end

function PlaceBats()
	if BatModel and BatModel.Parent then
		BatModel:Destroy()
	end
	BatModel = Create("Model"){
		Name = (Player.Name .. "'s Bats"),
	}
	local BatManagementClone = BatManagement:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
		{Name = "Target", Class = "ObjectValue", Value = Handle},
		{Name = "TargetOffset", Class = "Vector3Value", Value = Vector3.new(0, 0.5, 0)},
		{Name = "Range", Class = "RayValue", Value = Ray.new(Vector3.new(-6, -2, -6), Vector3.new(6, 6, 6))},
		{Name = "Damage", Class = "NumberValue", Value = 2.5},
	}
	ValueObjects = {}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = BatManagementClone,
		}
		ValueObjects[v.Name] = Value
	end
	BatManagementClone.Disabled = false
	BatManagementClone.Parent = BatModel
	local Bats = CreateBats()
	for i, v in pairs(Bats) do
		for ii, vv in pairs(v.Bat:GetChildren()) do
			if vv:IsA("BasePart") then
				vv.Transparency = (1 - (0.1 * i))
			end
		end
		v.Torso.CFrame = (CFrame.new(Handle.Position) * CFrame.Angles(-(math.pi / 2), 0, 0))--v.Origin.CFrame --Enables bats to appear flying around already when you equip this tool
		v.Torso.Anchored = false
		v.BodyGyro.cframe = v.Torso.CFrame
		v.Bat.Parent = BatModel
	end
	BatModel.Parent = game:GetService("Workspace")
	Spawn(function()
		for i = 1, 10 do
			for ii, v in pairs(Bats) do
				for ii, vv in pairs(v.Bat:GetChildren()) do
					if vv:IsA("BasePart") then
						vv.Transparency = (1 - (0.1 * i))
					end
				end
			end
			wait(0.1)
		end
	end)
end

function SetUpBats()
	Spawn(function()
		if BatModel and BatModel.Parent then
			BatModel:Destroy()
		end
		PlaceBats()
	end)
end

function Jump()
	if not CheckIfAlive() or not ToolEquipped or not JumpEnabled then
		return
	end
	Tool.Enabled = false
	JumpEnabled = false
	Falling = true
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local Animation = Animations.JumpAttack
	Humanoid.WalkSpeed = 0
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	if CheckIfAlive() and ToolEquipped and CurrentlyEquipped then
		local RayHit, RayPos, RayNormal, RaySurface = Functions.CastRay(Torso.Position, Vector3.new(0, -1, 0), 10, {Character}, false)
		if RayHit then
			local PossibleColors = {Color3.new((115 / 255), (0 / 255), (0 / 255))}
			Sounds.Hit:Play()
			for i = 1, 30 do
				local Part = BasePart:Clone()
				Part.Name = "Effect"
				Part.Transparency = 1
				Part.Size = Vector3.new(2, 2, 2)
				Part.CanCollide = false
				local Color = PossibleColors[math.random(1, #PossibleColors)]
				local Light = Create("PointLight"){
					Color = Color,
					Brightness = 50,
					Range = 8,
					Shadows = false,
					Enabled = true,
					Parent = Part,
				}
				local Fire = Create("Fire"){
					Color = Color,
					SecondaryColor = Color,
					Size = 2,
					Heat = 9,
					Parent = Part,
				}
				local Effect = EffectFire:Clone()
				Effect.Color = ColorSequence.new(Color, Color)
				Effect.LockedToPart = true
				Effect.Enabled = true
				Effect.Parent = Part
				Part.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent then
						return
					end
					local SuccessfullyHit = BlowHit(Hit, 6)
					if SuccessfullyHit then
						AlreadyHit = true
						local Fire = Hit:FindFirstChild(EffectFire.Name)
						if not Fire then
							Fire = Effect:Clone()
							local ParticleScriptCopy = ParticleScript:Clone()
							local Duration = Create("NumberValue"){
								Name = "Duration",
								Value = 3,
								Parent = Fire,
							}
							ParticleScriptCopy.Disabled = false
							ParticleScriptCopy.Parent = Fire
							Debris:AddItem(Fire, 4.5)
							Fire.Parent = Hit
						end
					end
				end)
				Part.CFrame = CFrame.new(Vector3.new(Blade.Position.X, RayPos.Y, Blade.Position.Z))
				Part.Velocity = ((((CFrame.new(RayPos) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0)).lookVector * Vector3.new(1, 0, 1)) * math.random(15, 60)) + Vector3.new(0, math.random(50, 75), 0))
				Debris:AddItem(Part, 1.5)
				Part.Parent = game:GetService("Workspace")
			end
			Spawn(function()
				local OrigRange = ValueObjects.Range.Value
				local OrigDamage = ValueObjects.Damage.Value
				ValueObjects.Range.Value = Ray.new(Vector3.new(-20, -2, -20), Vector3.new(20, 20, 20))
				ValueObjects.Damage.Value = (OrigDamage * 4)
				wait(4)
				ValueObjects.Range.Value = OrigRange
				ValueObjects.Damage.Value = OrigDamage
			end)
		end
	end
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	Falling = false
	Tool.Enabled = true
	Delay(5, (function()
		JumpEnabled = true
	end))
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Attack()
	CurrentDamage = Damages.Slash
	local SlashSounds = {Sounds.Swipe1, Sounds.Swipe2, Sounds.Swipe3, Sounds.Swipe4}
	SlashSounds[math.random(1, #SlashSounds)]:Play()
	local SlashAnimations = {Animations.Slash, Animations.Strike, Animations.DoubleSlash, Animations.Slice, Animations.Cut, Animations.SpinSlash}
	local Animation = SlashAnimations[math.random(1, #SlashAnimations)]
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	CurrentDamage = Damages.Touch
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Attack()
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Tool.Grip = Grips.Equipped
	Spawn(function()
		CreateScythePiece(true)
		SetUpBats()
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	Sounds.Unsheath:Play()
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	if BatModel and BatModel.Parent then
		BatModel:Destroy()
	end
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	CreateScythePiece(false)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down and not Humanoid.Jump then
			if JumpEnabled then
				Spawn(function()
					InvokeClient("DisableJump", {Disabled = true})
				end)
				Jump()
				Spawn(function()
					InvokeClient("DisableJump", {Disabled = false})
				end)
			end
			--[[local MouseData = InvokeClient("MouseData")
			if not MouseData or not MouseData.Position or not BatModel or not BatModel.Parent then
				return
			end
			local StartPosition = (Handle.CFrame + Handle.CFrame.lookVector * Handle.Size.Z).p
			local TargetPosition = MouseData.Position
			local Direction = CFrame.new(StartPosition, TargetPosition)
			local SpinDirection = (Direction * CFrame.Angles(0, (math.pi / 2), 0))
			local FakeHandle = Handle:Clone()
			FakeHandle.Name = "Scythe"
			FakeHandle.CanCollide = true
			local Mass = (FakeHandle:GetMass() * Gravity)
			local Force = 75
			local BodyVelocity = Create("BodyVelocity"){
				maxForce = Vector3.new(Mass, Mass, Mass),
				velocity = (Direction.lookVector * Force),
				Parent = FakeHandle,
			}
			local BodyGyro = Create("BodyGyro"){
				maxTorque = Vector3.new(0, math.huge, 0),
				cframe = Direction,
				Parent = FakeHandle,
			}
			local BodyAngularVelocity = Create("BodyAngularVelocity"){
				maxTorque = Vector3.new(Mass, Mass, Mass),
				angularvelocity = ((Direction * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * 10),
				Parent = FakeHandle,
			}
			FakeHandle.CFrame = CFrame.new(StartPosition, TargetPosition)
			FakeHandle.Velocity = (Direction.lookVector * Force)
			Debris:AddItem(FakeHandle, 5)
			FakeHandle.Parent = BatModel
			ValueObjects.Target.Value = FakeHandle]]
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

CreateScythePiece(false)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

ServerControl.OnServerInvoke = OnServerInvoke