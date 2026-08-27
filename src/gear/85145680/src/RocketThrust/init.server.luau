--ParaRocket

local Rocket = script.Parent

local Thrust = script:WaitForChild("Thrust")
local Pop = script:WaitForChild("Pop")
local Tag = Rocket:WaitForChild("AttachedPlayer")
local Explosion = script:WaitForChild("Explosion")



local function CalculateCharacterMass(Character)
	local Children = Character:GetChildren()
	local TotalMass = 0
	for i = 1, #Children do
		if Children[i]:IsA("BasePart") or Children[i]:IsA("MeshPart") then TotalMass = TotalMass + Children[i]:GetMass() end
	end
	return TotalMass
end



--Creates a random number of particles and lets them fall down from the sky.  
local function ParticleExplosion(Parent, Colors)
	local NumParticles = math.random(20,25)
	for i = 0, NumParticles do
		--Create the parts for the particles to emit from
		local ParticlePoint = Instance.new("Part")
		ParticlePoint.Size = Vector3.new(1,1,1)
		ParticlePoint.Parent = Parent
		ParticlePoint.Position = Parent.Position + Vector3.new(math.random(-5,5), math.random(4, 7), math.random(-5,5)	)
		ParticlePoint.Transparency = 1
		
		--Create the particles for display
		local Particle = Instance.new("Fire")
		local Color = Colors[math.random(1, #Colors)]
		Particle.Color = Color
		Particle.SecondaryColor = Color
		Particle.Parent = ParticlePoint

		--Send them flying
		local ParticleForce = Instance.new("BodyForce")
		ParticleForce.Parent = ParticlePoint
		ParticleForce.force = Vector3.new(math.random(-20,20), 40, math.random(-20,20)) * 7
		game.Debris:AddItem(ParticleForce, .3)
		
		game.Debris:AddItem(ParticlePoint, 2 + math.random())
	end

end



function ExplodeRocket()
	Rocket.Transparency = 1
	Rocket.CanCollide = false
	Rocket.Anchored = true
	Rocket.RocketEffect:Destroy()
	
	Explosion:Play()

	ParticleExplosion(Rocket, { Color3.new(1,0,0), Color3.new(1,1,1), Color3.new(0,0,1) })
end

local function Fly()
	--Add some force to the rocket to make it fly
	local UpForce = Instance.new("BodyForce")
	UpForce.Parent = Rocket
	UpForce.Name = "RocketThrust"

	local EffectCenter = Instance.new("Part")
	EffectCenter.CanCollide = false
	EffectCenter.Transparency = 1
	EffectCenter.Size = Vector3.new(1,1,1)
	EffectCenter.CFrame = Rocket.CFrame + Vector3.new(0, -4, 0)
	EffectCenter.Name = "RocketEffect"
	EffectCenter.Parent = Rocket

	local EffectWeld = Instance.new("Weld")
	EffectWeld.Part0 = EffectCenter
	EffectWeld.Part1 = Rocket
	EffectWeld.C1 = CFrame.new(0, -4, 0)
	EffectWeld.Parent = EffectCenter

	local Fire = Instance.new("Fire")
	Fire.Parent = EffectCenter
	Fire.Name = "RocketFire"
	
	--local CharMass = CalculateCharacterMass(Tag.Value)
	local TorsoTag = Tag.Value:FindFirstChild("Torso") or Tag.Value:FindFirstChild("UpperTorso")
	local CharMass = TorsoTag:GetMass() * .75
	Thrust:Play()
	--Fly the direction we are pointing
	
	for i = 1, 30 do
		UpForce.force = Vector3.new(0, 1, 0) * Rocket:GetMass() * CharMass * 98 * 1
		wait(.1)
	end

	wait(1)
	delay(1, ExplodeRocket)
end

local function DropPlayer()
	
	local Character = Tag.Value
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	local Backpack = Torso:FindFirstChild("Backpack")
	if(Backpack == nil) then -- They took off their parachute.  GG
		wait(1)
		Character.Humanoid:TakeDamage(100) --Kill them for their stupidity
		return 
	end 


	Rocket.Weld:Destroy()
	Pop:Play()
	

	Torso.Backpack.Mesh.MeshId = "http://www.roblox.com/asset/?id=85027689"
	



	local FallForce = Instance.new("BodyForce")
	FallForce.Name = "Parachute"
	FallForce.Parent = Torso

	for i = 1, 35 do
		FallForce.force = Vector3.new(0, 1, 0) * Torso:GetMass() * 6 * 98 * 2
		wait(.1)
	end

	FallForce:Destroy() 
	Torso.Backpack.Mesh.MeshId = "http://www.roblox.com/asset/?id=85027479"

		
end


Fly()


DropPlayer()

