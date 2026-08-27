-----------------
--| Constants |--
-----------------

local RBX_GRAVITY = -9.81 * 20
local ONE_STEP = 1 / 30
local OFFSET = Vector3.new(5, 0, 5) -- Distance from player or target
local MAX_DISTANCE = 240 -- The pet will stay within this distance of player
local JARS_TO_THROW = 3 -- Number of jars to throw
local DYNAMITE_TO_THROW = 1 -- Number of dynamite to throw
local MIN_GAP = 1.5 -- Seconds that must pass before the next mode can begin
local LAUNCH_SPEED = 60

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

local Pet = script.Parent
local PetHumanoid = WaitForChild(Pet, 'Humanoid')

local ClickTargetObject = WaitForChild(Pet, 'ClickTarget')
local NextTargetHumanoid = ClickTargetObject.Value

local MyModel = WaitForChild(script, 'Owner').Value
local MyHumanoid = WaitForChild(MyModel, 'Humanoid')

local RightArm = WaitForChild(Pet, 'Right Arm')
local SwooshSound = WaitForChild(RightArm, 'Swoosh')

local AnimationScript = WaitForChild(MyModel, 'PetAnimation')
local AnimationToPlayObject = WaitForChild(AnimationScript, 'AnimationToPlay')

local PetMode = 0
local StopTime = time()

local PickleJar = nil
local Dynamite = nil
local NinjaStar = nil

do -- Pick up the attachments, create the NinjaStar
	local pickleJarObject = WaitForChild(script, 'PickleJar')
	PickleJar = pickleJarObject.Value
	pickleJarObject:Destroy()

	local dynamiteObject = WaitForChild(script, 'Dynamite')
	Dynamite = dynamiteObject.Value
	dynamiteObject:Destroy()

	NinjaStar = Instance.new('Part')
	NinjaStar.Name = 'NinjaStar'
	local mesh = Instance.new('SpecialMesh', NinjaStar)
	mesh.MeshId = "http://www.roblox.com/asset/?id=92531211"
	mesh.TextureId = "http://www.roblox.com/asset/?id=92531141"
	NinjaStar.Size = Vector3.new(1.5, 1.5, 0.5)

	WaitForChild(PickleJar, 'Script'):Clone().Parent = NinjaStar
end

-----------------
--| Functions |--
-----------------

local function Start(modeOverride)
	PetMode = modeOverride or math.random(3)

	--[[
	if NextTargetHumanoid and NextTargetHumanoid.Torso and PetHumanoid and PetHumanoid.Torso then
		if NextTargetHumanoid.Torso.Position.y > 80 then
			PetMode = 3
		elseif (NextTargetHumanoid.Torso.Position - PetHumanoid.Torso.Position).magnitude < 10 then
			PetMode = 1
		else
			PetMode = 2
		end
	end
	PetMode = modeOverride or PetMode
	--]]

	if NextTargetHumanoid then
		TargetHumanoid = NextTargetHumanoid
	end
end

local function Stop()
	PetMode = 0
	StopTime = time()
end

-- When the player clicks, update the target
ClickTargetObject.Changed:connect(function(newValue)
	print("Changed!", newValue)
	if newValue and newValue:IsA("Humanoid") and newValue ~= PetHumanoid then
		NextTargetHumanoid = newValue
		if PetMode == 0 and (time() - StopTime > MIN_GAP) then
			print("Manual Start")
			Start()
		end
	end
end)

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

-- Coroutine to decide when to automatically start
coroutine.resume(coroutine.create(function()
	wait(4)
	while Pet do
		if PetMode == 0 and math.random() < 0.33 then
			NextTargetHumanoid = FindClosestHumanoid(MyHumanoid.Torso.Position, {MyHumanoid, PetHumanoid})
			if NextTargetHumanoid and NextTargetHumanoid.Torso then
				local myDistanceToTarget = (NextTargetHumanoid.Torso.Position - MyHumanoid.Torso.Position).magnitude
				if myDistanceToTarget <= MAX_DISTANCE then
					Start(1)
				end
			end
		end
		wait(6)
	end
end))

-- Rotates the pet horizontally to face the target
local function FaceTarget()
	if PetHumanoid and PetHumanoid.Torso then
		local position = PetHumanoid.Torso.Position
		local lookPoint = TargetHumanoid.Torso.Position
		PetHumanoid.Torso.CFrame = CFrame.new(position, Vector3.new(lookPoint.x, position.y, lookPoint.z)) -- Face target but stay horizontal
	end
end

-- Returns total mass of instance and all children
local function GetMassRecursive(instance)
	local mass = 0
	if instance:IsA('BasePart') then
		mass = mass + instance:GetMass()
	end
	for _, child in pairs(instance:getChildren()) do
		if child then
			mass = mass + GetMassRecursive(child)
		end
	end
	return mass
end

local function Throw(part)
	--local distanceToTarget = (TargetHumanoid.Torso.Position - PetHumanoid.Torso.Position).magnitude

	--local angle = math.asin((RBX_GRAVITY * distanceToTarget) / (LAUNCH_SPEED * LAUNCH_SPEED)) / 2
	--print(math.deg(angle), "degrees")

	local relativePositionsTable = {}
	for _, child in pairs(part:GetChildren()) do
		if child and child:IsA('Part') then
			relativePositionsTable[child] = child.Position - part.Position
		end
	end
	
	part.CFrame = CFrame.new(RightArm.Position, TargetHumanoid.Torso.Position)
	--part.Velocity = PetHumanoid.Torso.CFrame.lookVector * LAUNCH_SPEED

	for child, relativePosition in pairs(relativePositionsTable) do
		child.CFrame = part.CFrame + relativePosition
	end

	local mass =  GetMassRecursive(part)
	local bodyForce = Instance.new('BodyForce', part)
	bodyForce.force = Vector3.new(0, mass * 196.2, 0) -- Antigravity

	if part.Name ~= 'Dynamite' then -- pleaselookawaypleaselookawaypleaselookawaypleaselookaway
		local launchForce = (TargetHumanoid.Torso.Position - part.Position).unit * LAUNCH_SPEED
		bodyForce.force = bodyForce.force + launchForce
		if part.Name == 'PickleJar' then bodyForce.force = bodyForce.force + (launchForce * 3) end
		if part.Name == 'NinjaStar' then bodyForce.force = bodyForce.force + (launchForce * 5) end
		Delay(0.3, function() bodyForce.force = bodyForce.force - launchForce end)
	else
		bodyForce.force = (bodyForce.force * 6) + (PetHumanoid.Torso.CFrame.lookVector * 100)
		Delay(0.1, function() bodyForce:Destroy() end)
	end

	local partScript = part:FindFirstChild('Script')
	if partScript then
		partScript.Disabled = false
	end

	SwooshSound:Play()

	DebrisService:AddItem(part, 10)
	part.Parent = Workspace
end

------------------------
--| Main Pet AI Loop |--
------------------------

while true do
	if not MyHumanoid or not MyHumanoid.Torso or not PetHumanoid or not PetHumanoid.Torso then break end

	-- Jumping over obstacles
	local hit = Game.Workspace:FindPartOnRay(Ray.new(PetHumanoid.Torso.Position, PetHumanoid.Torso.CFrame.lookVector * 3.0), MyModel)
	if hit then
		PetHumanoid.Jump = true
	end

	if not TargetHumanoid or not TargetHumanoid.Torso then
		print("TargetHumanoid is nil")
		PetMode = 0
	end

	if PetMode == 0 then -- Default: Follow the player
		PetHumanoid:MoveTo(MyHumanoid.Torso.Position + OFFSET, MyHumanoid.Torso)
	elseif PetMode == 1 then -- Mode 1: Give the target a noogie
		local distanceToPlayer = (MyHumanoid.Torso.Position - PetHumanoid.Torso.Position).magnitude
		local distanceToTarget = (TargetHumanoid.Torso.Position - PetHumanoid.Torso.Position).magnitude
		if distanceToPlayer > MAX_DISTANCE then -- Give up trying to get to target
			Stop()
		elseif distanceToTarget > OFFSET.magnitude then -- Get up close
			PetHumanoid:MoveTo(TargetHumanoid.Torso.Position, TargetHumanoid.Torso)
		else -- We've reached the player, noogie 'em
			PetHumanoid.Jump = true
			wait(0.25) -- Airtime
			if TargetHumanoid and TargetHumanoid.Torso then
				TargetHumanoid.Torso.Anchored = true
				PetHumanoid.Torso.Anchored = true
				local height = (TargetHumanoid.Torso.Size.y / 2)
				if TargetHumanoid.Parent and TargetHumanoid.Parent:FindFirstChild('Head') then
					height = height + (TargetHumanoid.Parent.Head.Size.y / 2)
				end
				local position = TargetHumanoid.Torso.CFrame:pointToWorldSpace(Vector3.new(0, height + 0.3, 1))
				local facing = TargetHumanoid.Torso.CFrame.lookVector
				PetHumanoid.Torso.CFrame = CFrame.new(position, position + facing)
				AnimationToPlayObject.Value = 'NewNoogieLoop'
				wait(3)
				AnimationToPlayObject.Value = ''
				if TargetHumanoid and TargetHumanoid.Torso then
					TargetHumanoid.Torso.Anchored = false
					local targetHeight = 0 do -- get target height
						targetHeight = TargetHumanoid.Torso.Size.y / 2
						if TargetHumanoid.RightLeg then
							targetHeight = targetHeight + TargetHumanoid.RightLeg.Size.y
						elseif TargetHumanoid.LeftLeg then
							targetHeight = targetHeight + TargetHumanoid.LeftLeg.Size.y
						end
					end
					local crashHeight = 0 do -- get Crash height
						crashHeight = PetHumanoid.Torso.Size.y / 2
						if PetHumanoid.RightLeg then
							crashHeight = crashHeight + PetHumanoid.RightLeg.Size.y
						elseif PetHumanoid.LeftLeg then
							crashHeight = crashHeight + PetHumanoid.LeftLeg.Size.y
						end
					end
					position = TargetHumanoid.Torso.CFrame:pointToWorldSpace(Vector3.new(0, (-targetHeight + crashHeight), 1.7))
					PetHumanoid.Torso.CFrame = CFrame.new(position, position + facing)
				end
				PetHumanoid.Torso.Anchored = false
			end
			Stop()
		end
	elseif PetMode == 2 then -- Mode 2: Throw pickle jars (or ninja stars!)
		for i = 1, JARS_TO_THROW do
			FaceTarget()
			if math.random(2) == 1 then
				Throw(PickleJar:Clone())
			else -- Throw a ninja star instead!
				local ninjaStarClone = NinjaStar:Clone()
				Throw(ninjaStarClone)
				--[[ninjaStarClone.Touched:connect(function(otherPart)
					if otherPart then
						if Pet and Pet:IsAncestorOf(otherPart) then return end
						Delay(1, function() ninjaStarClone:Destroy() end)
					end
				end)]]
				ninjaStarClone.CFrame = CFrame.Angles(math.pi/2, 0, 0) + ninjaStarClone.Position
			end
			wait(1)
		end
		Stop()
	elseif PetMode == 3 then -- Mode 3: Throw Dynamite
		for i = 1, DYNAMITE_TO_THROW do
			FaceTarget()
			Throw(Dynamite:Clone())
			wait(1)
		end
		Stop()
	end

	wait(ONE_STEP)
end

DebrisService:AddItem(script.Parent, 5)
