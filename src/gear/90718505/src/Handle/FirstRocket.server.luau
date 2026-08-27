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

local BlastRadius = 10 -- Blast radius of the explosion
local BlastDamage = 300 -- Amount of damage done to players
local BlastForce = 2000 -- Amount of force applied to parts
local TimeUntilSplit = 0.75
local RocketSpeed = 75 -- Speed of the spawned MotherRockets

-- Rocket will fly through things named these
local RocketIgnoreList = {rocket = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

-- Offsets for the spawn positions of new rockets, list size determines how many are spawned
local SpawnOffsets = {Vector3.new(-3, 3, 0), Vector3.new(3, 3, 0), Vector3.new(0, -3, 0)}

-----------------------
--| Other Variables |--
-----------------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local FirstRocket = script.Parent
local CreatorTag = WaitForChild(FirstRocket, 'creator')
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
				if player and player ~= MyPlayer and player.TeamColor == MyPlayer.TeamColor then
					return
				end
			end

			if (hitPart.Name == 'Torso' or hitPart.Name == 'UpperTorso') and humanoid.Health > 0 then -- Tag and damage the victim
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
		explosion.Position = FirstRocket.Position
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Parent = Workspace

		-- Connect custom logic for the explosion
		explosion.Hit:connect(function(hitPart, hitDistance) OnExplosionHit(hitPart, hitDistance, explosion.Position) end)

		if FirstRocket:FindFirstChild('Boom') then
			FirstRocket.Boom:Play()
		end

		-- Hide the rocket so it can keep running the connection but not be seen/heard

		if FirstRocket:FindFirstChild('Fire') then
			FirstRocket.Fire:Destroy()
		end

		if FirstRocket:FindFirstChild('Swoosh') then
			FirstRocket.Swoosh:Stop()
		end

		FirstRocket.Transparency = 1
		FirstRocket.Anchored = true
		DebrisService:AddItem(FirstRocket, 3)
	end
end

--------------------
--| Script Logic |--
--------------------

FirstRocket.Touched:connect(OnTouched)

wait(TimeUntilSplit)

if not Exploded then
	-- Spawn MotherRockets
	for i = 1, #SpawnOffsets do
		local motherClone = FirstRocket:Clone()
		DebrisService:AddItem(motherClone, 30)
		motherClone.Name = 'Rocket'

		local thisScript = WaitForChild(motherClone, script.Name)
		thisScript.Disabled = true

		motherClone.Position = FirstRocket.Position + FirstRocket.CFrame:vectorToObjectSpace(SpawnOffsets[i])
		motherClone.Parent = Workspace

		motherClone.Velocity = motherClone.CFrame.lookVector * RocketSpeed
		motherClone.RotVelocity = Vector3.new(0, 0, 0)

		wait(0)
		if motherClone:FindFirstChild('Swoosh') then
			motherClone.Swoosh:Play()
		end

		local motherScript = WaitForChild(motherClone, 'MotherRocket')
		motherScript.Disabled = false
	end

	-- Out of fuel
	if FirstRocket:FindFirstChild('Fire') then
		FirstRocket.Fire:Destroy()
	end
	FirstRocket.Velocity = FirstRocket.Velocity / 2

	if FirstRocket:FindFirstChild('Swoosh') then
		FirstRocket.Swoosh:Stop()
	end

	-- Drop this empty shell
	if FirstRocket:FindFirstChild('Antigravity') then
		FirstRocket.Antigravity.force = FirstRocket.Antigravity.force / 2
	end
end
