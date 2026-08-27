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
local BlastDamage = 90 -- Amount of damage done to players
local BlastForce = 1500 -- Amount of force applied to parts
local TimeUntilSplit = 0.75
local RocketSpeed = 100 -- Speed of the spawned ChildRockets

-- Rocket will fly through things named these
local RocketIgnoreList = {rocket = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

-- Offsets for the spawn positions of new rockets, list size determines how many are spawned
local SpawnOffsets = {Vector3.new(-1, 1, 0), Vector3.new(1, 1, 0), Vector3.new(0, -1, 0)}

-----------------------
--| Other Variables |--
-----------------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local MotherRocket = script.Parent
local ChildRocket = WaitForChild(MotherRocket, 'ChildRocket')
local CreatorTag = WaitForChild(MotherRocket, 'creator')
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
	if hitPart and hitDistance and not RocketIgnoreList[string.lower(hitPart.Name)] then
		local humanoid = nil
		if hitPart.Parent and hitPart.Parent:FindFirstChild('Humanoid') then
			humanoid = hitPart.Parent.Humanoid

			-- Don't hurt self
			if humanoid.Parent == MyPlayer.Character then return end

			if not MyPlayer.Neutral then -- Ignore teammates caught in the blast
				local player = PlayersService:GetPlayerFromCharacter(hitPart.Parent)
				if player and player.TeamColor == MyPlayer.TeamColor then
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
		explosion.Position = MotherRocket.Position
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Parent = Workspace

		-- Connect custom logic for the explosion
		explosion.Hit:connect(function(hitPart, hitDistance) OnExplosionHit(hitPart, hitDistance, explosion.Position) end)

		if MotherRocket:FindFirstChild('Boom') then
			MotherRocket.Boom:Play()
		end

		-- Hide the rocket so it can keep running the connection but not be seen/heard

		if MotherRocket:FindFirstChild('Fire') then
			MotherRocket.Fire:Destroy()
		end

		if MotherRocket:FindFirstChild('Swoosh') then
			MotherRocket.Swoosh:Stop()
		end

		MotherRocket.Transparency = 1
		MotherRocket.Anchored = true
		DebrisService:AddItem(MotherRocket, 3)
	end
end

--------------------
--| Script Logic |--
--------------------

MotherRocket.Touched:connect(OnTouched)

wait(TimeUntilSplit)

if not Exploded then
	-- Spawn ChildRockets
	for i = 1, #SpawnOffsets do
		local childClone = ChildRocket:Clone()
		DebrisService:AddItem(childClone, 30)
		childClone.Name = 'Rocket'

		local tagClone = CreatorTag:Clone()
		tagClone.Parent = childClone

		childClone.Transparency = 0

		-- Add fire
		local fire = Instance.new('Fire', childClone)
		fire.Heat = 5
		fire.Size = 2

		-- Add antigravity
		local bodyForce = Instance.new('BodyForce', childClone)
		bodyForce.Name = 'Antigravity'
		bodyForce.force = Vector3.new(0, childClone:GetMass() * 196.2, 0)

		childClone.Position = MotherRocket.Position + MotherRocket.CFrame:vectorToObjectSpace(SpawnOffsets[i])
		childClone.Parent = Workspace

		childClone.Velocity = childClone.CFrame.lookVector * RocketSpeed
		childClone.RotVelocity = Vector3.new(0, 0, 0)

		-- Add sound
		if MotherRocket:FindFirstChild('Swoosh') then
			local swooshClone = MotherRocket.Swoosh:Clone()
			swooshClone.Parent = childClone
			wait(0)
			if swooshClone then swooshClone:Play() end
		end

		local childScript = WaitForChild(childClone, 'ChildRocket')
		childScript.Disabled = false
	end

	-- Out of fuel
	if MotherRocket:FindFirstChild('Fire') then
		MotherRocket.Fire:Destroy()
	end
	MotherRocket.Velocity = MotherRocket.Velocity / 2

	if MotherRocket:FindFirstChild('Swoosh') then
		MotherRocket.Swoosh:Stop()
	end

	-- Drop this empty shell
	if MotherRocket:FindFirstChild('Antigravity') then
		MotherRocket.Antigravity.force = MotherRocket.Antigravity.force / 2
	end
end
