--Made by Luckymaxer

Character = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Effect = script:FindFirstChild("Effect")
HoldUpAnimation = script:FindFirstChild("HoldUp")
TossHatAnimation = script:FindFirstChild("TossHat")
ApplauseClapSound = script:FindFirstChild("ApplauseClap")
ParticlesBin = script:FindFirstChild("ParticlesBin")

GradCaps = {161265831, 161210868, 28672647, 11721340, 53915490, 255792526, 115991937}

OriginalHats = {}

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	Debris:AddItem(AssetModel, 1)
	return Asset
end

function PickUpAndGraduate(Character)
	if not Character then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Head = Character:FindFirstChild("Head")
	local RightArm = Character:FindFirstChild("Right Arm")
	if not Humanoid or Humanoid.Health == 0 or not Head or not RightArm then
		return
	end
	local OriginalHats = {}
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Hat") then
			table.insert(OriginalHats, v)
			v.Parent = nil
		end
	end
	local GradCap = InsertAsset(GradCaps[math.random(1, #GradCaps)]):Clone()
	local Handle = GradCap:FindFirstChild("Handle")
	local HeadWeld
	if Handle then
		Handle.Size = Vector3.new(0.2, 0.2, 0.2)
		Handle.CanCollide = false
		Handle.Name = GradCap.Name
		HeadWeld = Create("Weld"){
			Name = "Weld",
			Part0 = Head,
			Part1 = Handle,
			Parent = Handle,
			C0 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			C1 = GradCap.AttachmentPoint,
		}
		Debris:AddItem(Handle, 10)
		Handle.Parent = Character
	end
	local EffectObject = Effect:Clone()
	local Weld = Create("Weld"){
		Name = "Weld",
		Part0 = RightArm,
		Part1 = EffectObject,
		C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
		C1 = CFrame.new(0.125, 0, -1, -0.188600376, -0.446652591, 0.87460357, -0.148713231, 0.893305182, 0.424134701, -0.970728755, -1, -0.234900832), --Effect grip offset
		Parent = EffectObject,
	}
	local Tools = {}
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player then
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				table.insert(Tools, v)
			end
		end
		Humanoid:UnequipTools()
	end
	Debris:AddItem(EffectObject, 5)
	EffectObject.Parent = Character
	local AnimationTrack = Humanoid:LoadAnimation(HoldUpAnimation)
	AnimationTrack:Play(0.25, nil, 0.25)
	wait(1.5)
	AnimationTrack:AdjustSpeed(0)
	local Particles = {}
	for i, v in pairs(ParticlesBin:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			table.insert(Particles, v)
		end
	end
	local ParticlesReady = {}
	for i = 1, math.random(6, 18) do
		local Particle = Particles[math.random(1, #Particles)]:Clone()
		local Color = (Vector3.new(math.random(), math.random(), math.random()) * 1)
		Color = Color3.new(Color.X, Color.Y, Color.Z)
		local ColorSeq = ColorSequence.new(Color, Color)
		Particle.Color = ColorSeq
		Particle.Transparency = NumberSequence.new(math.random() * 0.25)
		Particle.Rate = 0
		Particle.Lifetime = NumberRange.new(1.5, (math.random(1500, 3500) * 0.001))
		Particle.Speed = NumberRange.new(math.random(4500, 7500) * 0.001)
		Particle.Acceleration = Vector3.new(0, (math.abs(math.random(7500, 12000) * 0.001) * -1), 0)
		Particle.Enabled = false
		Debris:AddItem(Particle, 8)
		table.insert(ParticlesReady, Particle)
		Particle.Parent = Head
	end
	wait(0.1) --so emit works...
	for i, v in pairs(ParticlesReady) do
		v:Emit(math.random(6, 18))
	end
	local Sound = ApplauseClapSound:Clone()
	Sound.Parent = EffectObject
	Sound:Play()
	wait(1.5)
	AnimationTrack:AdjustSpeed(0.25)
	wait(0.5)
	Weld.C1 = CFrame.new(0, 0, -0.600000024, -0.829455853, -0.558572292, 0, -0.558572233, 0.829455972, 0, -0, 0, -1)
	wait(1)
	if EffectObject and EffectObject.Parent then
		EffectObject:Destroy()
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if LeftArm and Handle and Handle.Parent then
		local AnimationTrack = Humanoid:LoadAnimation(TossHatAnimation)
		AnimationTrack:Play(0.5, nil, 0.25)
		wait(0.75)
		--[[local Weld = Create("Weld"){
			Name = "Weld",
			Part0 = LeftArm,
			Part1 = Handle,
			C0 = LeftArm.CFrame:inverse(),
			C1 = Handle.CFrame:inverse(),
			Parent = Handle,
		}]]
		Debris:AddItem(Handle, 3)
		Handle.Parent = game:GetService("Workspace")
		local ThrowDirection = CFrame.new(Handle.Position, LeftArm.Position).lookVector
		ThrowDirection = (ThrowDirection * Vector3.new(1, 0, 1))
		if HeadWeld and HeadWeld.Parent then
			HeadWeld:Destroy()
		end
		Handle.Velocity = ((ThrowDirection * math.random(15, 40)) + Vector3.new(0, math.random(75, 125), 0))
		Handle.RotVelocity = Vector3.new(math.random(), math.random(), math.random())
		wait(0.5)
	else
		if Handle and Handle.Parent then
			Handle:Destroy()
		end
	end
	wait(1.5)
	for i, v in pairs(OriginalHats) do
		v.Parent = Character
	end
	for i, v in pairs(Tools) do
		if v and v.Parent then
			Humanoid:EquipTool(v)
		end
	end
end

function DestroyScript()
	Debris:AddItem(script, 1)
end

if not Effect or not Effect.Value or not HoldUpAnimation or not TossHatAnimation or not ApplauseClapSound or not ParticlesBin then
	DestroyScript()
	return
end

Effect = Effect.Value:Clone()

PickUpAndGraduate(Character)

DestroyScript()