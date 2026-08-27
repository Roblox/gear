-----------------
--| Constants |--
-----------------

local BLAST_RADIUS = 4.3
local BLAST_PRESSURE = 0
local MAX_DMG = 42

-- Rocket will fly through things named these
local ROCKET_IGNORE_LIST = {rocket = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

ROCKET_IGNORE_LIST[string.lower(script.Parent.Name)] = 1


--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local DebrisService = Game:GetService('Debris')

local Rocket = script.Parent
local CreatorTag = WaitForChild(Rocket, 'creator')

local HitHumanoids = {}
local ExplosionOrigin
local Connection = nil


local CreatorPlayer = CreatorTag.Value
if CreatorPlayer.Character and CreatorPlayer.Character:FindFirstChild('Humanoid') then
	HitHumanoids[CreatorPlayer.Character:FindFirstChild('Humanoid')] = true
end

-----------------
--| Functions |--
-----------------

--  Adjusted from overpressure formula
local function DamageFalloffEquation(distance, startDamage)
	local distance = math.max(1, distance)
	local explosionNetWeight = 1.1
	local volumeOfHemisphere = math.max(1, math.log(distance))
	return startDamage * (explosionNetWeight / volumeOfHemisphere)
end

-- Returns the ancestor that contains a Humanoid, if it exists
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

function TagHumanoid(humanoid, creatorTag)
	-- Add more tags here to customize what tags are available.
	while humanoid:FindFirstChild('creator') do
		humanoid:FindFirstChild('creator'):Destroy()
	end
	creatorTag.Parent = humanoid 
end

local function OnExplosionHit(hitPart)
	if hitPart then
		local _, humanoid = FindCharacterAncestor(hitPart.Parent)
		if humanoid and humanoid.Health > 0 then
			if not HitHumanoids[humanoid] and ExplosionOrigin then
				local dmg = DamageFalloffEquation((hitPart.CFrame.p - ExplosionOrigin).magnitude , MAX_DMG)
				local hitBindable = humanoid:FindFirstChild('Hit')
				if hitBindable then
					hitBindable:Invoke(dmg, CreatorTag)
				else --Not in Roblox Battle
					TagHumanoid(humanoid, CreatorTag:Clone())
					humanoid:TakeDamage(dmg)
				end
				HitHumanoids[humanoid] = true
			end
		end
	end
end


local Exploded = false

local function Explode()
	if Exploded then return end
	Exploded = true
	-- Create the explosion
	local explosion = Instance.new('Explosion')
	explosion.BlastPressure = BLAST_PRESSURE
	explosion.BlastRadius = BLAST_RADIUS
	explosion.Position = Rocket.Position
	explosion.Hit:connect(OnExplosionHit)
	explosion.Parent = Workspace
	ExplosionOrigin = Rocket.CFrame.p
	-- Start playing the boom sound
	local boomSound = Rocket:FindFirstChild('explodeSound')
	if boomSound then
		boomSound:Play()
	end

	-- NOTE:
	-- If we just destroyed the rocket at this point, the boom sound would be destroyed too,
	-- so instead we will hide the rocket, keep it in the same spot, and schedule it for deletion

	-- Stop playing the swoosh sound
	local swooshSound = Rocket:FindFirstChild('Swoosh')
	if swooshSound then
		swooshSound:Stop()
	end

	-- Put out the fire
	local fire = Rocket:FindFirstChild('RocketTrail')
	if fire then
		fire:Destroy()
	end

	local smoke = Rocket:FindFirstChild('Smoke')
	if smoke then
		smoke.Size = 5
		smoke.RiseVelocity = 1.3
	end


	Rocket.Transparency = 1
	Rocket.CanCollide = false
	Rocket.Anchored = true
	Rocket.CFrame = CFrame.new(Rocket.CFrame.p)
	DebrisService:AddItem(Rocket, 3)

end

local function OnTouched(otherPart)
	if Rocket and otherPart then
		-- Fly through anything in the ignore list
		if ROCKET_IGNORE_LIST[string.lower(otherPart.Name)] then
			return
		end

		-- Don't react to creator
		local myPlayer = CreatorTag.Value
		if myPlayer and myPlayer.Character and myPlayer.Character:IsAncestorOf(otherPart) then
			return
		end

		local character = FindCharacterAncestor(otherPart)
		Explode()
		-- Destroy the connection so this method won't be called again
		Connection:disconnect()
		Rocket.Anchored = true
--[[
		if character then
			print("Triggering on " , otherPart.Name)
			Explode()
			-- Destroy the connection so this method won't be called again
			Connection:disconnect()
		else
			print("No Character, otherPart:" , otherPart , "character:" , character)
			Rocket.CFrame = CFrame.new(Rocket.CFrame.p)
			Rocket.Anchored = true
		end
		]]
	end
end

--------------------
--| Script Logic |--
--------------------

-- Arm the rocket and save the touch connection so we can disconnect it later
Connection = Rocket.Touched:connect(OnTouched)

wait(3)

Explode()

