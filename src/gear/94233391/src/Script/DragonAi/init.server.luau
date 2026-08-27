-----------------
--| Constants |--
-----------------

local FPS = 30 -- FramesPerSecond
local TURN_RATE = 0.1 -- Can range from 0 to 1
local FIREBALL_SPEED = 70 -- Speed of the projectile
local FIREBALL_NAME = 'FireBall' -- Name of the projectile
local FIREBALL_LENGTH = 2 -- Seconds until the projectile is removed
local FIREBALL_TIME_BETWEEN = 0.1 -- Seconds between each projectile launch
local FIREBALL_NUMBER = 11 -- Number of projectiles to launch when breathing fire
local PET_FLIGHT_SPEED = 50 -- Speed of the pet
local PET_ATTACK_SPEED = 60 -- Speed of the pet when attacking

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

local Pet = script.Parent
local PetBody = WaitForChild(Pet, 'Body')
local LeftShoulderJoint = WaitForChild(PetBody, 'Left Shoulder')
local RightShoulderJoint = WaitForChild(PetBody, 'Right Shoulder')
local NeckJoint = WaitForChild(PetBody, 'Neck')
local PetHead = WaitForChild(Pet, 'Head')

local CreatorTag = WaitForChild(script, 'creator')
local Fire = WaitForChild(script, 'Fire')
local FireBallScript = WaitForChild(script, 'FireBall')
local SummonSound = WaitForChild(script, 'Summon')

local MyPlayer = CreatorTag.Value

local TargetPoint = PetBody.Position
local MoveAmount = Vector3.new()

local Flapping, Waiting, Down = false, false, true
local LastWingAngle = 0

local FireBall = nil

-------------------------
--| Utility Functions |--
-------------------------

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
		and (not closestHumanoid or (child.Humanoid.Torso.Position - position).magnitude < (closestHumanoid.Torso.Position - position).magnitude) then
			closestHumanoid = child.Humanoid
		end
	end
	return closestHumanoid --NOTE: Can be nil
end

-- Returns true if a is within epsilon of b
local function IsClose(a, b, epsilon)
	epsilon = epsilon or 0.01
	return (a <= b + epsilon and a >= b - epsilon)
end

-----------------------
--| Other Functions |--
-----------------------

local function OnPetPartTouched(otherPart)
	if otherPart and otherPart.Name ~= FIREBALL_NAME and not otherPart:IsDescendantOf(MyPlayer.Character) then
		--print("Valid Touch:", otherPart)

	end
end

local function SetFlyTarget(position, duration)
	TargetPoint = position
	MoveAmount = (position - PetBody.Position) / (duration * FPS)
end

local function LaunchFireBall()
	local fireBallClone = FireBall:Clone()
	DebrisService:AddItem(fireBallClone, FIREBALL_LENGTH)
	fireBallClone.Parent = Workspace
	fireBallClone.CFrame = PetHead.CFrame
	fireBallClone.Velocity = fireBallClone.CFrame.lookVector * FIREBALL_SPEED
end

local function BreatheFire()
	Spawn(function()
		SummonSound:Play()
		NeckJoint.DesiredAngle = 0.3
		wait(0.5)
		for i = 1, FIREBALL_NUMBER do
			LaunchFireBall()
			wait(FIREBALL_TIME_BETWEEN)
		end
		NeckJoint.DesiredAngle = 0
		wait(0.5)
	end)
end

local function Initialize()
	CreatorTag.Parent = nil
	SummonSound.Parent = PetHead

	BreatheFire()

	-- Create the initial FireBall to clone from
	FireBall = Instance.new('Part')
	FireBall.Name = FIREBALL_NAME
	FireBall.Transparency = 1
	FireBall.CanCollide = false
	FireBall.TopSurface = Enum.SurfaceType.Smooth
	FireBall.BottomSurface = Enum.SurfaceType.Smooth
	FireBall.Size = Vector3.new(4, 4, 4)
	Instance.new("BodyForce", FireBall).force = Vector3.new(0, FireBall:GetMass() * 196.2, 0) -- Antigravity
	local fire = Fire:Clone()
	fire.Enabled = true
	fire.Parent = FireBall -- Fire it up
	CreatorTag:Clone().Parent = FireBall -- Attach creator tag
	local ballScriptClone = FireBallScript:Clone()
	ballScriptClone.Parent = FireBall
	ballScriptClone.Disabled = false

	-- Connect to all pet parts
	for _, child in pairs(Pet:GetChildren()) do
		if child:IsA('BasePart') then
			child.Touched:connect(OnPetPartTouched)
		end
	end

	-- Start flying upwards
	local upLookVector = (Vector3.new(0, 1, 0) + PetBody.CFrame.lookVector).unit
	SetFlyTarget(PetBody.Position + (upLookVector * 100), 4)
	Flapping = true
end

local function DiveBomb()
	local humanoid = FindClosestHumanoid(PetBody.Position, {MyPlayer.Character.Humanoid})
	if humanoid then
		local target = humanoid.Parent.Torso.Position
		local direction = (target - PetBody.Position).unit
		local verticalOffset = Vector3.new(0, 1, 0) * 10
		local horizontalOffset = Vector3.new(direction.x, 0, direction.z) * 50
		local beforePoint = target - horizontalOffset + verticalOffset
		local timeToDestination = (beforePoint - PetBody.Position).magnitude / PET_ATTACK_SPEED
		SetFlyTarget(beforePoint, timeToDestination)
		wait(timeToDestination * 0.8)
		BreatheFire()
		wait(timeToDestination * 0.2)
		local afterPoint = target + horizontalOffset + verticalOffset
		timeToDestination = (afterPoint - PetBody.Position).magnitude / PET_ATTACK_SPEED
		SetFlyTarget(afterPoint, timeToDestination)
	end
end

--------------------
--| Script Logic |--
--------------------

Initialize()

Spawn(function()
	while true do
		wait(math.random(5, 15))
		DiveBomb()
	end
end)

local myHead = MyPlayer.Character.Head
local myHumanoid = MyPlayer.Character.Humanoid

myHumanoid.Died:connect(function()
	myHumanoid = nil
end)

PlayersService.PlayerRemoving:connect(function(player)
	if player == MyPlayer then
		myHumanoid = nil
	end
end)

while PetBody and PetHead and TargetPoint and myHead and myHumanoid do
	if (TargetPoint - PetBody.Position).magnitude > 5 then -- Incrementally fly toward TargetPoint
		local newPosition = PetBody.Position + MoveAmount
		local direction = (TargetPoint - PetBody.Position).unit
		local newLookVector = PetBody.CFrame.lookVector:Lerp(direction, TURN_RATE)
		PetBody.CFrame = CFrame.new(newPosition, newPosition + newLookVector)
	else -- Made it to TargetPoint, pick a new target
		print("Made it to target, picking a new random one")
		local newTarget = nil
		local distance = 0
		while distance < 80 do
			local angle = 2 * math.pi * math.random()
			local radius = math.random(50, 150)
			local height = math.random(100, 150)
			local x, z = radius * math.cos(angle), radius * math.sin(angle)
			newTarget = myHead.Position + Vector3.new(x, height, z)
			distance = (newTarget - TargetPoint).magnitude
		end
		SetFlyTarget(newTarget, distance / PET_FLIGHT_SPEED)
	end

	if Flapping then -- Update wings
		if not Waiting then
			local angle = Down and 0.5 or -0.4
			LeftShoulderJoint.DesiredAngle = angle
			RightShoulderJoint.DesiredAngle = angle
			LastWingAngle = angle
			Waiting = true
		else -- Waiting for wings to reach desired angle
			if IsClose(LeftShoulderJoint.CurrentAngle, LastWingAngle) or IsClose(RightShoulderJoint.CurrentAngle, LastWingAngle) then
				Down = not Down
				Waiting = false
			end
		end
	end

	wait(1 / FPS)
end

DebrisService:AddItem(Pet, 0)
