local Debris = Game:GetService("Debris")

-- Constants --

local offset = Vector3.new(5, 0, 5) -- Distance from player
local timeBetweenShots = 0.25 -- Seconds between each poison shot (between animations)
local chaseTime = 10 -- How long to chase a target before giving up
local chanceToBurn = 0.5 -- % chance that biting will also burn the target
local chanceToPoison = 0.5 -- % chance that biting will also poison the target

-- Script Children --

local myModel = script.Parent
local myHumanoid = myModel:FindFirstChild("Humanoid")

local ballScript = script:FindFirstChild("FireBall")
local burnScript = ballScript:FindFirstChild("Burning")

local blobScript = script:FindFirstChild("PoisonBlob")
local poisonScript = blobScript:FindFirstChild("Poisoned")

local roarAnimation = script:FindFirstChild("QuadHeadUp")
local tailAnimation = script:FindFirstChild("TailShoot")

while not script:FindFirstChild("Pet") or not script.Pet.Value do wait() end
local pet = script.Pet.Value

while not pet:FindFirstChild("ClickTarget") do wait() end
local targetHumanoid = pet.ClickTarget.Value

while not myModel:FindFirstChild("PetAnimation") do wait() end
local petAnimScript = myModel.PetAnimation

-- Chimera Variables --

while not pet:FindFirstChild("Humanoid") or not pet:FindFirstChild("Head") or not pet:FindFirstChild("Tail") do wait() end

local petHumanoid = pet.Humanoid
local petHead = pet.Head
local petTail = pet.Tail

local roarSound = petHead:FindFirstChild("FieryRoar")
local chompSound = petHead:FindFirstChild("Chomp")
local snakeSound = petTail:FindFirstChild("Snake")
local shootSound = petTail:FindFirstChild("Whoosh")

local fireBall = Instance.new("Part") do
	fireBall.Name = "FireBall"
	fireBall.Transparency = 1
	fireBall.CanCollide = false
	fireBall.TopSurface = Enum.SurfaceType.Smooth
	fireBall.BottomSurface = Enum.SurfaceType.Smooth
	fireBall.Size = Vector3.new(4, 4, 4)
	Instance.new("BodyForce", fireBall).force = Vector3.new(0, fireBall:GetMass() * 196.2, 0) -- Antigravity
	Instance.new("Fire", fireBall) -- Fire it up
	local scriptClone = ballScript:Clone()
	scriptClone.Parent = fireBall
	scriptClone:FindFirstChild("Creator").Value = pet
end

local poisonBlob = Instance.new("Part") do
	poisonBlob.Name = "PoisonBlob"
	poisonBlob.BrickColor = BrickColor.new("Lime green")
	poisonBlob.CanCollide = false
	poisonBlob.TopSurface = Enum.SurfaceType.Smooth
	poisonBlob.BottomSurface = Enum.SurfaceType.Smooth
	poisonBlob.Size = Vector3.new(0.25, 0.66, 0.25)
	Instance.new("BodyForce", poisonBlob).force = Vector3.new(0, poisonBlob:GetMass() * 196.2, 0) -- Antigravity
	local mesh = Instance.new("SpecialMesh", poisonBlob)
	mesh.MeshId = "http://www.roblox.com/asset/?id=87142124"
	mesh.Scale = Vector3.new(0.2, 0.4, 0.2)
	local scriptClone = blobScript:Clone()
	scriptClone.Parent = poisonBlob
	scriptClone:FindFirstChild("Creator").Value = pet
end

local petMode = 0
local startTime = 0

-- Functions --

local function stop()
	targetHumanoid = myHumanoid
	petMode = 0
end

-- Function that updates the target (when the player clicks)
pet.ClickTarget.Changed:connect(function(newValue)
	if newValue and newValue:IsA("Humanoid") then
		targetHumanoid = newValue
		if petMode == 0 then
			petMode = math.random(2, 3) -- (1 is not a targeted attack)
			startTime = time()
		end
	else
		stop()
	end
end)

-- Returns the closest living Humanoid to position who isn't in excludeList
local function findClosestHumanoid(position, excludeList) -- (Vector3, table)
	if not position then print("Need a Vector3 position") return nil end

	-- Change list values to keys so we can use indexing
	local excludeSet = {}
	if excludeList and type(excludeList) == "table" then
		for _, l in ipairs(excludeList) do
			excludeSet[l] = true
		end
	end

	-- Search through workspace children
	local list = Game.Workspace:getChildren()
	local closestHumanoid = nil
	for i = 1, #list do
		item = list[i]
		if (item and item:FindFirstChild("Humanoid") and item.Humanoid.Health > 0 and not excludeSet[item.Humanoid])
		and (not closestHumanoid or (item.Humanoid.Torso.Position - position).magnitude < (closestHumanoid.Torso.Position - position).magnitude) then
			closestHumanoid = item.Humanoid
		end
	end
	return closestHumanoid --NOTE: Can be nil
end

-- Coroutine to decide when to automatically start
coroutine.resume(coroutine.create(function()
	wait(4)
	while pet do
		if petMode == 0 and math.random() < 0.33 then
			targetHumanoid = findClosestHumanoid(myHumanoid.Torso.Position, {myHumanoid, petHumanoid})
			if targetHumanoid then
				petMode = math.random(3)
			else -- No other living humanoids nearby
				petMode = 1
			end
			startTime = time()
		end
		wait(6)
	end
end))

-- Clones theScript to the target if it doesn't already exist there
local function cloneScriptToTarget(theScript, target)
	if theScript and target and not target:FindFirstChild(theScript.Name) then
		local scriptClone = theScript:Clone()
		scriptClone.Parent = target
		scriptClone.Disabled = false
	end
end

-- Rotates the pet to face the target
local function faceTarget()
	if petHumanoid and petHumanoid.Torso then
		local position = petHumanoid.Torso.Position
		local lookPoint = targetHumanoid.Torso.Position
		petHumanoid.Torso.CFrame = CFrame.new(position, Vector3.new(lookPoint.x, position.y, lookPoint.z)) -- Face target but stay horizontal
	end
end

-- Tells petAnimScript to try to play the animation
local function sendAnimation(animation)
	if petAnimScript and petAnimScript:FindFirstChild("Current") then
		petAnimScript.Current.Value = animation --NOTE: Allowed to be nil
	end
end

-- Main Pet AI Loop

while true do
	if not myHumanoid or not myHumanoid.Torso or not petHumanoid or not petHumanoid.Torso or not petHead then break end

	-- Jumping over obstacles
	local hit = Game.Workspace:FindPartOnRay(Ray.new(petHead.Position, petHead.CFrame.lookVector * 3.0), nil)
	if hit and hit.Parent ~= myModel then
		petHumanoid.Jump = true
	end

	if petMode == 0 then -- Default: Follow the player
		petHumanoid:MoveTo(myHumanoid.Torso.Position + offset, myHumanoid.Torso)
	elseif petMode == 1 then -- Mode 1: Fire-breathing roar!
		petHumanoid:MoveTo(petHumanoid.Torso.Position, petHumanoid.Torso) -- Stand still (reset possible move target)
		if roarAnimation then sendAnimation(roarAnimation) end
		wait(0.25) -- Animating: Head up
		if roarSound then roarSound:Play() end
		for i = -0.20, 0.25, 0.05 do -- 10 times
			local ballClone = fireBall:Clone()
			ballClone.Parent = Workspace
			ballClone.CFrame = CFrame.new(petHead.Position)
			ballClone.FireBall.Disabled = false -- Ball armed
			ballClone.Velocity = (petHead.CFrame * CFrame.Angles(0, i * math.pi, 0)).lookVector * 30
			Debris:AddItem(ballClone, 2.5)
			wait(0.25) -- Animation is holding still for 2.5 seconds
		end
		wait(0.25) -- Animating: Head down
		sendAnimation(nil)
		stop()
	elseif petMode == 2 then -- Mode 2: Shoot poison at target
		if targetHumanoid and targetHumanoid.Torso and targetHumanoid.Health > 0 then
			petHumanoid:MoveTo(petHumanoid.Torso.Position, petHumanoid.Torso) -- Stand still (reset possible move target)
			if snakeSound then snakeSound:Play() end
			do -- Follow target until sound finishes (Sound:IsPlaying is buggy)
				local startTime = time()
				repeat
					faceTarget()
					wait()
				until time() - startTime > 1.5
			end
			local totalShots = math.random(3, 6)
			for i = 1, totalShots do
				if targetHumanoid and targetHumanoid.Health <= 0 then break end
				if tailAnimation then sendAnimation(tailAnimation) end
				wait(0.5) -- Animating: Pull back
				if shootSound then shootSound:Play() end
				wait(0.1) -- Animating: Fire
				if petTail and petHead and targetHumanoid and targetHumanoid.Health > 0 and targetHumanoid.Torso then
					local blobClone = poisonBlob:Clone()
					blobClone.Parent = Workspace
					local spawnPoint = petHead.Position
					blobClone.CFrame = CFrame.new(spawnPoint, targetHumanoid.Torso.Position) -- Facing is off
					blobClone.CFrame = blobClone.CFrame - blobClone.CFrame.p -- Remove position from CFrame
					blobClone.CFrame = blobClone.CFrame + spawnPoint -- Add new position to CFrame
					blobClone.CFrame = blobClone.CFrame * CFrame.Angles(-math.pi / 2, 0, 0) -- Facing fixed
					blobClone.PoisonBlob.Disabled = false -- Blob armed
					blobClone.Velocity = (targetHumanoid.Torso.Position - petTail.Position).unit * 100
					Debris:AddItem(blobClone, 2)
				end
				wait(0.15) -- Animating: Reset 
				sendAnimation(nil)
				wait(timeBetweenShots)
				faceTarget()
			end
		end
		stop()
	elseif petMode == 3 then -- Mode 3: Chase and bite the target
		if targetHumanoid and targetHumanoid.Torso and targetHumanoid.Health > 0 then
			if time() - startTime > chaseTime then -- Give up trying to reach target
				stop()
			elseif (targetHumanoid.Torso.Position - petHumanoid.Torso.Position).magnitude > offset.magnitude then -- Get up close
				petHumanoid:MoveTo(targetHumanoid.Torso.Position, targetHumanoid.Torso)
			else -- We've reached the player, bite 'em
				petHumanoid.Jump = true
				wait(0.25) -- Imagine the fear in their eyes at this moment
				if targetHumanoid then
					if chompSound then chompSound:Play() end
					targetHumanoid:TakeDamage(math.random(30, 60))
					if math.random() > 0.5 then -- Equal chance for burn-check or poison-check
						if math.random() <= chanceToBurn then cloneScriptToTarget(burnScript, targetHumanoid) end
					else
						if math.random() <= chanceToPoison then cloneScriptToTarget(poisonScript, targetHumanoid) end
					end
				end
				stop()
			end
		else
			stop()
		end
	end

	wait()
end
