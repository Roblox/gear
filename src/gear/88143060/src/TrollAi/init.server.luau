-- Troll Constants --

local offset = Vector3.new(5, 0, 5) -- Distance from player or target
local radius = 5 -- Radius of TrollMode2's orbit
local orbitSpeed = 5 -- Speed of TrollMode2's orbit
local trollTime = 10 -- Stop trolling after this much time

-- Script Children --

local myModel = script.Parent
local myHumanoid = myModel:FindFirstChild("Humanoid")

while not script:FindFirstChild("Pet") or not script.Pet.Value do wait() end
local pet = script.Pet.Value

while not pet:FindFirstChild("ClickTarget") do wait() end
local targetHumanoid = pet.ClickTarget.Value

-- Troll Variables --

while not pet:FindFirstChild("Humanoid") or not pet:FindFirstChild("Head") do wait() end

local petHumanoid = pet.Humanoid

local powSound = pet.Head:FindFirstChild("Pow")
local hornSound = pet.Head:FindFirstChild("Horn") --NOTE: Looped
local heySound = pet.Head:FindFirstChild("Hey")
local heyYouSound = pet.Head:FindFirstChild("HeyYou")

local petMode = 0
local startTime = 0
local lastHeyTime = 0

-- Functions --

local function start()
	petMode = math.random(3)
	startTime = time()
end

local function stop()
	targetHumanoid = myHumanoid
	if hornSound then hornSound:Stop() end
	petMode = 0
end

-- Function that updates the target (when the player clicks)
pet.ClickTarget.Changed:connect(function(newValue)
	if newValue and newValue:IsA("Humanoid") and newValue ~= petHumanoid then
		targetHumanoid = newValue
		if petMode == 0 then start() end
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
				start()
			end
		end
		wait(6)
	end
end))

-- Main Pet AI Loop

while true do
	if not myHumanoid or not myHumanoid.Torso or not petHumanoid or not petHumanoid.Torso then break end

	-- Jumping over obstacles
	local hit = Game.Workspace:FindPartOnRay(Ray.new(petHumanoid.Torso.Position, petHumanoid.Torso.CFrame.lookVector * 3.0), myModel)
	if hit then
		petHumanoid.Jump = true
	end

	if not targetHumanoid or not targetHumanoid.Torso then
		stop()
	elseif petMode == 0 then -- Default: Follow the player
		petHumanoid:MoveTo(myHumanoid.Torso.Position + offset, myHumanoid.Torso)
	elseif petMode == 1 then -- Mode 1: Knock down the target
		if time() - startTime > trollTime then -- Give up trying to get to target
			stop()
		elseif (targetHumanoid.Torso.Position - petHumanoid.Torso.Position).magnitude > offset.magnitude then -- Get up close
			petHumanoid:MoveTo(targetHumanoid.Torso.Position, targetHumanoid.Torso)
		else -- We've reached the player, knock 'em out
			petHumanoid.Jump = true
			wait(0.25) -- Airtime
			if targetHumanoid then
				if powSound then powSound:Play() end
				targetHumanoid.Sit = true
				local slapForce = Instance.new("BodyForce", targetHumanoid.Torso)
				slapForce.force = petHumanoid.Torso.CFrame.lookVector * 1500
				Game:GetService("Debris"):AddItem(slapForce, 0.4)
				wait(0.4) -- Let it sink in
				if targetHumanoid then targetHumanoid.Sit = false end
			end
			stop()
		end
	elseif petMode == 2 then -- Mode 2: Circle the target annoyingly
		if time() - startTime <= trollTime then
			if hornSound and not hornSound.IsPlaying then hornSound:Play() end
			local xPos = radius * math.cos(time() * orbitSpeed) + targetHumanoid.Torso.Position.x
			local zPos = radius * math.sin(time() * orbitSpeed) + targetHumanoid.Torso.Position.z
			local point = Vector3.new(xPos, 0, zPos)
			petHumanoid:MoveTo(point, targetHumanoid.Torso)
		else
			stop()
		end
	elseif petMode == 3 then -- Mode 3: Follow the target at an uncomfortably close distance
		if time() - startTime <= trollTime then
			if time() - lastHeyTime > 1 then
				if math.random(2) == 1 and heySound then
					heySound:Play()
				elseif heyYouSound then
					heyYouSound:Play()
				end
				lastHeyTime = time()
			end
			local rightBehind = targetHumanoid.Torso.CFrame:pointToWorldSpace(Vector3.new(0, 0, 1))
			petHumanoid:MoveTo(rightBehind, targetHumanoid.Torso)
			if targetHumanoid.Jump then petHumanoid.Jump = true end
		else
			stop()
		end
	end

	wait()
end
