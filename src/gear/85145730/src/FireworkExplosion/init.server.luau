--4th of July 2012 Firework
function WaitForChild(ChildName)
	while script:FindFirstChild(ChildName) == nil do
		wait()
	end
	return script:FindFirstChild(ChildName)
end

local Debris = game.Debris
local Rocket = script.Parent

local ScreamSound = WaitForChild("Scream")
local ExplosionSound = WaitForChild("Explosion")

--Positions for the USA particles
local ParticlePositions = {}
ParticlePositions.U = { Vector3.new(-2, 4, 0), Vector3.new(-2, 3, 0), Vector3.new(-2, 2, 0), Vector3.new(-2, 1, 0), Vector3.new(-2, 0, 0), Vector3.new(-2, -1, 0), --[[Vector3.new(-1, -1, 0),]]--
								Vector3.new(-1, -2, 0), Vector3.new(0, -2, 0), Vector3.new(1, -2, 0), --[[Vector3.new(1, -1, 0),]] Vector3.new(2, -1, 0), Vector3.new(2, 0, 0), Vector3.new(2, 1, 0),
								Vector3.new(2, 2, 0), Vector3.new(2, 3, 0), Vector3.new(2, 4, 0) }

ParticlePositions.S = { Vector3.new(1, 4, 0), Vector3.new(0, 4, 0), Vector3.new(-1, 4, 0), Vector3.new(-2, 3, 0), Vector3.new(-2, 2, 0), Vector3.new(-1, 1, 0), Vector3.new(0, 1, 0),
								Vector3.new(1, 0, 0), Vector3.new(1, -1, 0), Vector3.new(0, -2, 0), Vector3.new(-1, -2, 0), Vector3.new(-2, -2, 0) }

ParticlePositions.A = { Vector3.new(-2, -2, 0), Vector3.new(-2, -1, 0), Vector3.new(-2, 0, 0), Vector3.new(-2, 1, 0), Vector3.new(-2, 2, 0), Vector3.new(-1, 3, 0), Vector3.new(0, 4, 0),
								Vector3.new(1, 3, 0), Vector3.new(2, 2, 0), Vector3.new(2, 1, 0), Vector3.new(2, 0, 0), Vector3.new(2, -1, 0), Vector3.new(2, -2, 0),
								Vector3.new(-1, 0, 0), Vector3.new(0, 0, 0), Vector3.new(1, 0, 0) }


local Colors = { Color3.new(1,0,0), Color3.new(1,1,1), Color3.new(0,0,1) }
	
--Flies the rocket in the direction it's pointing
function Fly()
	--Add some force to the rocket to make it fly
	local UpForce = Instance.new("BodyForce")
	UpForce.Parent = Rocket
	UpForce.Name = "RocketThrust"

	ScreamSound:Play()
	--Fly the direction we are pointing
	for i = 1, 30 do
		UpForce.force = Vector3.new(0, 1, 0) * Rocket:GetMass() * 98 * 2.2
		wait(.1)
	end
end

--Displays a letter made out of particles. 
--ParticleTable - The letter to display as a table of Vector3s
--Parent - The object that displays the string
--Offset - The offset from the center to display the letter
--Color - The color to diplay the letters as
function DisplayParticleLetter(ParticleTable, Parent, Offset, Color)
	for i = 1, #ParticleTable do
		--Create the parts for the particles to emit from
		local ParticlePoint = Instance.new("Part")
		ParticlePoint.CanCollide = false
		ParticlePoint.Anchored = true
		ParticlePoint.Size = Vector3.new(1,1,1)
		ParticlePoint.Parent = Parent
		ParticlePoint.Position = Parent.Position + Offset + (ParticleTable[i] * 2)	
		ParticlePoint.Transparency = 1
		
		--Create the particles for display
		local Particle = Instance.new("Fire")
		Particle.Color = Color
		Particle.Parent = ParticlePoint
		
		delay(5, function() 
			--Send them flying
			local ParticleForce = Instance.new("BodyForce")
			ParticleForce.Parent = ParticlePoint
			ParticleForce.force = Vector3.new(math.random(-20,20), math.random(20, 50), math.random(-20,20)) * 10
			Debris:AddItem(ParticleForce, .3)
		
			ParticlePoint.Anchored = false 
			ParticlePoint.CanCollide = true 
	
			Debris:AddItem(ParticlePoint, 4.5 + math.random())

			end )

	end

end

--Creates a random number of particles and lets them fall down from the sky.  
function ParticleExplosion()
	local NumParticles = math.random(5,15)
	for i = 0, NumParticles do
		--Create the parts for the particles to emit from
		local ParticlePoint = Instance.new("Part")
		ParticlePoint.Size = Vector3.new(1,1,1)
		ParticlePoint.Parent = Rocket
		ParticlePoint.Position = Rocket.Position + Vector3.new(math.random(1,5), 0, math.random(1,5)	)
		ParticlePoint.Transparency = 1
		
		--Create the particles for display
		local Particle = Instance.new("Fire")
		Particle.Color = Colors[math.random(1, #Colors)]
		Particle.Parent = ParticlePoint

		--Send them flying
		local ParticleForce = Instance.new("BodyForce")
		ParticleForce.Parent = ParticlePoint
		ParticleForce.force = Vector3.new(math.random(-20,20), 0, math.random(-20,20)) * 10
		Debris:AddItem(ParticleForce, .3)
		
		Debris:AddItem(ParticlePoint, 4.5 + math.random())
	end

end

--Makes the rocket explode and display USA
function Explode()
	--Explode the rocket
	ExplosionSound:Play()
	Rocket.Transparency = 1
	Rocket:FindFirstChild("Particle"):Destroy()
	Rocket.Anchored = true

	--Show the particles
	DisplayParticleLetter(ParticlePositions.U, Rocket, Vector3.new(-11,0,0), Colors[1])
	wait()
	DisplayParticleLetter(ParticlePositions.S, Rocket, Vector3.new(0,0,0), Colors[2])
	wait()
	DisplayParticleLetter(ParticlePositions.A, Rocket, Vector3.new(10,0,0), Colors[3])
	ParticleExplosion()
	--Clean up
	Debris:AddItem(Rocket, 10.5)

end


--Fly then explode.  Duh.

Fly()

Explode()