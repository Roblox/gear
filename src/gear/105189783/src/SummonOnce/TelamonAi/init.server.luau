-----------------
--| Constants |--
-----------------

local THROWABLE_DAMAGE = 15
local THROWABLE_CHANCE = 0.05
local THROWABLE_TIMETOLIVE = 15

local ONE_STEP = 1 / 30

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
local PlayersService = Game:GetService('Players')

local ThrowSound = WaitForChild(script, 'Throw')
local SwooshSound = WaitForChild(script, 'Swoosh')
local SmackSound = WaitForChild(script, 'Smack')

local Pet = script.Parent
local PetHumanoid = WaitForChild(Pet, 'Humanoid')
local Throwable = WaitForChild(Pet, 'Throwable')

local CreatorTag = WaitForChild(script, 'creator')

local MyPlayer = CreatorTag.Value
local MyModel = MyPlayer.Character
local MyHumanoid = MyModel.Humanoid

local LastThrowTime = 0

-----------------
--| Functions |--
-----------------

-- Returns the closest living Humanoid to position who isn't in excludeList
local function FindClosestHumanoid(position, excludeList) -- (Vector3, table)
	if not position then print("Need a Vector3 position") return nil end

	-- Change list values to keys so we can use indexing
	local excludeSet = {}
	if excludeList and type(excludeList) == "table" then
		for _, l in ipairs(excludeList) do
			excludeSet[l] = true
		end
	end

	-- Search through Workspace children
	local closestHumanoid = nil
	for _, child in pairs(Game.Workspace:GetChildren()) do
		if (child and child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and not excludeSet[child.Humanoid])
		and (not closestHumanoid or (child.Humanoid.RootPart.Position - position).magnitude < (closestHumanoid.RootPart.Position - position).magnitude) then
			closestHumanoid = child.Humanoid
		end
	end
	return closestHumanoid --NOTE: Can be nil
end

-- Removes any old creator tags and applies new ones to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end
	local creatorTag = CreatorTag:Clone()
	DebrisService:AddItem(creatorTag, 4)
	creatorTag.Parent = target
end

local function OnThrowableReachedTarget(throwable, targetHumanoid)
	local smackSound = throwable:FindFirstChild('Smack')
	if smackSound then
		smackSound:Play()
	end
	if targetHumanoid.Health > 0 then
		ApplyTags(targetHumanoid)
		targetHumanoid:TakeDamage(THROWABLE_DAMAGE)
	end
	throwable:Destroy()
end

local function PickNewTarget(throwable)
	local homing = throwable:FindFirstChild('Homing')
	if homing then
		local targetHumanoid = FindClosestHumanoid(throwable.Position, {MyHumanoid, PetHumanoid})
		if targetHumanoid and targetHumanoid.RootPart then
			local targetHead = targetHumanoid.Parent:FindFirstChild('Head')
			homing.Target = targetHead or targetHumanoid.RootPart
			return
		end
		-- Otherwise, fall
		homing:Destroy()
	end
	-- Fall to kill plane
	throwable.CanCollide = false
end

-- Change target when the old target disappears
local function OnTargetModelChanged(targetModel, property, throwable)
	if property == 'Parent' and targetModel.Parent == nil then
		PickNewTarget(throwable)
	end
end

--------------------
--| Script Logic |--
--------------------

ThrowSound.Parent = Throwable --NOTE: To be played from hand
SwooshSound.Parent = Throwable --NOTE: To be played from projectile
SmackSound.Parent = Throwable --NOTE: To be played from projectile on hit

PetHumanoid.Health = PetHumanoid.MaxHealth -- This never works
Delay(1, function() PetHumanoid.Health = PetHumanoid.Health + 1 end) -- So at least trigger healing

MyHumanoid.Died:connect(function()
	MyHumanoid = nil
end)

PlayersService.PlayerRemoving:connect(function(player)
	if player == MyPlayer then
		MyHumanoid = nil
	end
end)

while PetHumanoid and MyHumanoid and MyHumanoid.Health > 0 do
	local torso = MyHumanoid.RootPart
	PetHumanoid:MoveTo(torso.Position + Vector3.new(4, 0, 4), torso)

	local now = tick()
	if now - LastThrowTime > 0.5 and math.random() <= THROWABLE_CHANCE then
		--print("Throw")
		LastThrowTime = now
		local targetHumanoid = FindClosestHumanoid(torso.Position, {MyHumanoid, PetHumanoid})
		if targetHumanoid and targetHumanoid.RootPart then
			local targetModel = targetHumanoid.Parent
			local targetHead = targetModel:FindFirstChild('Head')
			Spawn(function()
				ThrowSound:Play()
				local throwable = Throwable:Clone()
				throwable.Name = 'HomingTurkey'
				local homing = Instance.new('RocketPropulsion')
				homing.Name = 'Homing'
				homing.Target = targetHead or targetHumanoid.RootPart
				homing.ReachedTarget:connect(function()
					OnThrowableReachedTarget(throwable, targetHumanoid)
				end)
				targetModel.Changed:connect(function(property)
					OnTargetModelChanged(targetModel, property, throwable)
				end)
				homing.Parent = throwable
				DebrisService:AddItem(throwable, THROWABLE_TIMETOLIVE)
				throwable.Parent = Workspace
				throwable.Velocity = Vector3.new(0, 100, 0)
				wait(0.5)
				if throwable then
					local projectileSwoosh = throwable:FindFirstChild('Swoosh')
					if projectileSwoosh then
						projectileSwoosh:Play()
					end
					throwable.Size = Vector3.new(0.5, 1, 0.5)
					throwable.CanCollide = true
					homing:Fire()
				end
			end)
		end
	end
	wait(ONE_STEP)
end

DebrisService:AddItem(Pet, 0)
