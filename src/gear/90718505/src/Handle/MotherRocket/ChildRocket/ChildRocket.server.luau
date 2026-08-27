--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

------------------------------
--| Customizable Variables |--
------------------------------

local BlastRadius = 8 -- Blast radius of the explosion
local BlastDamage = 75 -- Amount of damage done to players
local BlastForce = 1000 -- Amount of force applied to parts
local TimeUntilDrop = 6

-- Rocket will fly through things named these
local RocketIgnoreList = {rocket = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

-----------------------
--| Other Variables |--
-----------------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local ChildRocket = script.Parent
local CreatorTag = WaitForChild(ChildRocket, 'creator')
local MyPlayer = CreatorTag.Value

local Exploded = false

-----------------------
--| Local Functions |--
-----------------------

-- Removes any old creator tags and applies a new one to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end
	local tagClone = CreatorTag:Clone()
	tagClone.Parent = target
	DebrisService:AddItem(tagClone, 1.5)
end

-- Simulates explosive effects but doesn't affect teammates
local function OnExplosionHit(hitPart, hitDistance, blastCenter)
	if hitPart and hitDistance then
		local humanoid = nil
		if hitPart.Parent and hitPart.Parent:FindFirstChild('Humanoid') then
			humanoid = hitPart.Parent.Humanoid

			-- Don't hurt self
			if humanoid.Parent == MyPlayer.Character then return end

			if not MyPlayer.Neutral then -- Ignore teammates caught in the blast
				local player = PlayersService:GetPlayerFromCharacter(hitPart.Parent)
				if player and player ~= MyPlayer and player.TeamColor == MyPlayer.TeamColor then
					return
				end
			end

			if hitPart.Name == 'Torso' and humanoid.Health > 0 then -- Tag and damage the victim
				ApplyTags(humanoid)
				humanoid:TakeDamage(BlastDamage)
			end
		end

		-- Loose parts and dead parts get blasted
		if not humanoid or humanoid.Health <= 0 then
			if hitPart.Name ~= 'Handle' then
				hitPart:BreakJoints()
				local blastForce = Instance.new('BodyForce', hitPart)
				blastForce.force = (hitPart.Position - blastCenter).unit * BlastForce * hitPart:GetMass()
				DebrisService:AddItem(blastForce, 0.1)
			end
		end
	end
end

local function OnTouched(otherPart)
	if otherPart and not otherPart:IsDescendantOf(MyPlayer.Character) and not RocketIgnoreList[string.lower(otherPart.Name)] then
		-- Fly through other players on my team
		if not MyPlayer.Neutral and otherPart.Parent and otherPart.Parent:IsA('Model') then
			local player = PlayersService:GetPlayerFromCharacter(otherPart.Parent)
			if player and player ~= MyPlayer and player.TeamColor == MyPlayer.TeamColor then
				return
			end
		end

		Exploded = true

		-- Create the explosion
		local explosion = Instance.new('Explosion')
		explosion.BlastPressure = 0 -- Completely safe explosion
		explosion.BlastRadius = BlastRadius
		explosion.Position = ChildRocket.Position
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Parent = Workspace

		-- Connect custom logic for the explosion
		explosion.Hit:connect(function(hitPart, hitDistance) OnExplosionHit(hitPart, hitDistance, explosion.Position) end)

		if ChildRocket:FindFirstChild('Boom') then
			print("")
			ChildRocket.Boom:Play()
		end

		-- Hide the rocket so it can keep running the connection but not be seen/heard

		if ChildRocket:FindFirstChild('Fire') then
			ChildRocket.Fire:Destroy()
		end

		if ChildRocket:FindFirstChild('Swoosh') then
			ChildRocket.Swoosh:Stop()
		end

		ChildRocket.Transparency = 1
		ChildRocket.Anchored = true
		DebrisService:AddItem(ChildRocket, 3)
	end
end

--------------------
--| Script Logic |--
--------------------

ChildRocket.Touched:connect(OnTouched)

wait(TimeUntilDrop)

if not Exploded then
	-- Out of fuel
	if ChildRocket:FindFirstChild('Fire') then
		ChildRocket.Fire:Destroy()
	end
	ChildRocket.Velocity = ChildRocket.Velocity / 2

	if ChildRocket:FindFirstChild('Swoosh') then
		ChildRocket.Swoosh:Stop()
	end

	-- Drop this empty shell
	if ChildRocket:FindFirstChild('Antigravity') then
		ChildRocket.Antigravity.force = ChildRocket.Antigravity.force / 2
	end
end
