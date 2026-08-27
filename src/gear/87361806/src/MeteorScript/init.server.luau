--Exort Wex Exort!

local function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child] 
end 

local Meteor = script.Parent
local Rock = Meteor.ArmageddonMeteor

local Explosion = waitForChild(script, "Explosion")
local Rumble = waitForChild(script, "Rumble")
local Fall = waitForChild(script, "Fall")

local Owner = waitForChild(script, "Owner")

Fall:Play()


local TouchedEvent


Rock.Elasticity = 0

local ForceMultiplier = 2000
local FallForceMultiplier = 5000

local FallVelocity = Instance.new("BodyVelocity")
FallVelocity.Name = "FallPush"
FallVelocity.velocity = Rock.CFrame.lookVector * FallForceMultiplier
FallVelocity.maxForce = Vector3.new(FallForceMultiplier, FallForceMultiplier, FallForceMultiplier)
FallVelocity.P = FallForceMultiplier
FallVelocity.Parent = Rock




--Creates a random number of particles and lets them fall down from the sky.  
function ParticleExplosion(Parent, Colors, MinParticles, MaxParticles, Offset, Lifetime)
	local Debris = game.Debris
	
	--Initialize to default values
	MinParticles = MinParticles or 0
	MaxParticles = MaxParticles or 5
	Offset = Offset or Vector3.new(0,0,0)
	Lifetime = Lifetime or 1
	
	local NumParticles = math.random(MinParticles, MaxParticles)
	for i = 0, NumParticles do
		--Create the parts for the particles to emit from
		local ParticlePoint = Instance.new("Part")
		ParticlePoint.Size = Vector3.new(1,1,1)
		ParticlePoint.Parent = Parent
		ParticlePoint.Position = Parent.Position + Vector3.new(math.random(-5,5), math.random(4, 7), math.random(-5,5)	) + Offset
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
		Debris:AddItem(ParticleForce, .3)
		
		Debris:AddItem(ParticlePoint, Lifetime + math.random())
	end

end
	




function RollingBallOfDeath(part)
	if(part.Parent:FindFirstChild("Humanoid") and Owner.Value ~= part.Parent) then part.Parent:FindFirstChild("Humanoid"):TakeDamage(100) end
end








function onHitGround(part)
	Fall:Stop()
	Explosion:Play()


	Rock.Velocity = Vector3.new(0,0,0)
		
	Rock.FallPush:Destroy()

	local RockRotation = Instance.new("BodyVelocity")
	RockRotation.maxForce = Vector3.new(ForceMultiplier, ForceMultiplier, ForceMultiplier)
	RockRotation.P = ForceMultiplier
	RockRotation.velocity = Rock.CFrame.lookVector * ForceMultiplier
	RockRotation.Parent = Rock

	ParticleExplosion(Rock, {Color3.new(1,0,0), Color3.new(1, .5, 0)}, 15, 20, Vector3.new(0, -1, 0), .5)

	Rumble:Play()
	TouchedEvent:disconnect()

	Rock.Touched:connect(RollingBallOfDeath)
	

end
TouchedEvent = Rock.Touched:connect(onHitGround)

