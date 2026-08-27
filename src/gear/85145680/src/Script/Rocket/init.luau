-- // Made by StarWars

local Debris = game:GetService("Debris")

local Thrust = script.Thrust
local Pop = script.Pop
local Explosion = script.Explosion

local Rocket = {}
Rocket.__index = Rocket

local function CalculateCharacterMass(character)
	local Total = 0
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			Total = Total + v:GetMass()
		end
	end
	
	return Total
end

local function ParticleExplosion(parent, colors)
	local NumParticles = math.random(20, 25)
	for i = 0, NumParticles do
		local ParticlePoint = Instance.new("Part")
		ParticlePoint.Size = Vector3.new(1, 1, 1)
		ParticlePoint.Parent = parent
		ParticlePoint.Position = parent.Position + Vector3.new(math.random(-5, 5), math.random(4, 7), math.random(-5, 5))
		ParticlePoint.Transparency = 1
		
		local Particle = Instance.new("Fire")
		local Color = colors[math.random(1, #colors)]
		Particle.Color = Color
		Particle.SecondaryColor = Color
		Particle.Parent = ParticlePoint
		
		local ParticleForce = Instance.new("BodyForce")
		ParticleForce.Parent = ParticlePoint
		ParticleForce.Force = Vector3.new(math.random(-20, 20), 40, math.random(-20, 20)) * 7
		Debris:AddItem(ParticleForce, 0.3)
		Debris:AddItem(ParticlePoint, 2 + math.random())
	end
end

function Rocket.new(tool, character)
	local self = {}
	setmetatable(self, Rocket)
	
	self.Tool = tool
	self.Character = character
	self.Rocket = tool.Handle:Clone()
	self.ThrustSound = Thrust:Clone()
	self.ThrustSound.Parent = self.Rocket
	self.PopSound = Pop:Clone()
	self.PopSound.Parent = self.Rocket
	self.ExplosionSound = Explosion:Clone()
	self.ExplosionSound.Parent = self.Rocket	
	self.Rocket.Transparency = 0
	self.Rocket.Name = "Rocket"
	self.Rocket.Parent = workspace
	self.Rocket.Size = Vector3.new(3.35, 6.78, 3.53)
	
	local TorsoWeld = Instance.new("Weld")
	TorsoWeld.Part0 = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	TorsoWeld.Part1 = self.Rocket
	TorsoWeld.Parent = self.Rocket
	TorsoWeld.C1 = CFrame.Angles(0, math.pi*0.5, 0) * CFrame.new(0, -1.4, 1.6)	
	
	return self
end

function Rocket:Destroy()
	self.Rocket.Weld:Destroy()
	wait(0.75)
	local ParticlePart = Instance.new("Part")
	ParticlePart.CFrame = self.Rocket.CFrame
	ParticlePart.Anchored = true
	ParticlePart.CanCollide = false
	ParticlePart.Transparency = 1
	ParticlePart.Parent = workspace
	
	self.ExplosionSound.Parent = ParticlePart
	self.ExplosionSound:Play()
	self.Rocket:Destroy()
	
	ParticleExplosion(ParticlePart, { Color3.new(1, 0, 0), Color3.new(1, 1, 1), Color3.new(0, 0, 1) })
	Debris:AddItem(ParticlePart, 2.5)
end

function Rocket:DropPlayer()
	if not self.Character then return end
	local Torso = self.Character:FindFirstChild("Torso") or self.Character:FindFirstChild("UpperTorso")
	local Backpack = Torso:FindFirstChild("Backpack")
	if not Backpack then
		wait(1)
		self.Character.Humanoid.Health = 0
		return
	end
	
	self.PopSound:Play()
	Backpack.Mesh.MeshId = "rbxassetid://" .. 85027689
	
	local FallForce = Instance.new("BodyForce")
	FallForce.Name = "Parachute"	
	FallForce.Force = Vector3.new(0, 1, 0) * 1500 --3 * 6 * 98 * 2
	FallForce.Parent = Torso
	wait(5)
	FallForce:Destroy()
	if Backpack then
		Backpack.Mesh.MeshId = "rbxassetid://" .. 85027479
	end
end

function Rocket:Launch()
	local UpForce = Instance.new("BodyForce")
	UpForce.Parent = self.Rocket
	UpForce.Name = "RocketThrust"
	
	local EffectCenter = Instance.new("Part")
	EffectCenter.CanCollide = false
	EffectCenter.Transparency = 1
	EffectCenter.Size = Vector3.new(1, 1, 1)
	EffectCenter.CFrame = self.Rocket.CFrame + Vector3.new(0, -4, 0)
	EffectCenter.Name = "RocketEffect"
	EffectCenter.Parent = self.Rocket
	
	local EffectWeld = Instance.new("Weld")
	EffectWeld.Part0 = EffectCenter
	EffectWeld.Part1 = self.Rocket
	EffectWeld.C1 = CFrame.new(0, -4, 0)
	EffectWeld.Parent = EffectCenter
	
	local Fire = Instance.new("Fire")
	Fire.Name = "RocketFire"
	Fire.Parent = EffectCenter
	
	self.ThrustSound:Play()	
	UpForce.Force = Vector3.new(0, 1, 0) * self.Rocket:GetMass() * 16 * 20
	self.Character.Humanoid.Jump = true	
	
	wait(4)
	spawn(function() self:Destroy() end)
end

return Rocket