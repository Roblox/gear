-----------------
--| Constants |--
-----------------

local RBX_GRAVITY = -9.81 * 20
local ONE_STEP = .5--1 / 30
local OFFSET = Vector3.new(5, 0, 5) -- Distance from player or target
local MAX_DISTANCE = 240 -- The pet will stay within this distance of player
local JARS_TO_THROW = 3 -- Number of jars to throw
local DYNAMITE_TO_THROW = 1 -- Number of dynamite to throw
local MIN_GAP = 1.5 -- Seconds that must pass before the next mode can begin
local LAUNCH_SPEED = 150

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do print('waiting for '..childName) parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local DebrisService = Game:GetService('Debris')

local Pet = script.Parent
local PetHumanoid = WaitForChild(Pet, 'Humanoid')

local Torso = Pet:WaitForChild('Torso')
local Sounds ={}

local LastSoundTime = 0

local MyModel = WaitForChild(script, 'Owner').Value
local MyHumanoid = WaitForChild(MyModel, 'Humanoid')


local RightArm = WaitForChild(Pet, 'Right Arm')
local SwooshSound = WaitForChild(RightArm, 'Swoosh')

local AnimationScript = WaitForChild(MyModel, 'PetAnimation')
local AnimationToPlayObject = WaitForChild(AnimationScript, 'AnimationToPlay')

local PetMode = 0
local StopTime = time()


-----------------
--| Functions |--
-----------------

function GenerateBanana()
	local Part = Instance.new("Part")
	Part.Name = 'Banana'
	--Part.CanCollide = false
	Part.Anchored = false
	Part.Color = Color3.new(0.88627457618713, 0.60784316062927, 0.25098040699959)
	Part.Material = Enum.Material.Wood
	Part.Size = Vector3.new(1, 1.2000000476837, 1)
	Part.Locked = false
	Part.BrickColor = BrickColor.new("Br. yellowish orange")

		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshId = "http://www.roblox.com/asset/?id=119574562"
		Mesh.TextureId = "http://www.roblox.com/asset/?id=64374853"
		Mesh.Parent = Part
		Mesh.MeshType = Enum.MeshType.FileMesh

	Part.Touched:connect(function(npart)
		local hum = npart.Parent:FindFirstChild('Humanoid')
		if hum and hum~=PetHumanoid then
			if hum==MyHumanoid then
				hum:TakeDamage(-10)
			else
				hum:TakeDamage(-20)
			end
			Part.Parent=nil
		end
	end)
	return Part

end

local function Start(modeOverride)
	PetMode = modeOverride or math.random(3)


	if NextTargetHumanoid then
		TargetHumanoid = NextTargetHumanoid
	end
end

local function Stop()
	PetMode = 0
	StopTime = time()
end


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

	part.CFrame = CFrame.new(RightArm.Position+Torso.CFrame.lookVector*2, TargetHumanoid.Torso.Position)
	--part.Velocity = PetHumanoid.Torso.CFrame.lookVector * LAUNCH_SPEED

	local mass =  GetMassRecursive(part)
	local bodyForce = Instance.new('BodyForce', part) 
	bodyForce.force = Vector3.new(0, mass/2 * 196.2, 0) -- Antigravity


	local launchForce = (TargetHumanoid.Torso.Position - part.Position).unit * LAUNCH_SPEED		
	
	--bodyForce.force = (bodyForce.force * 6) + (PetHumanoid.Torso.CFrame.lookVector * 100)
	
	bodyForce.force = bodyForce.force + (launchForce * 5)
	--Delay(0.3, function() bodyForce.force = bodyForce.force - launchForce end)
	
	Delay(0.1, function() bodyForce:Destroy() end)

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

Delay(1,function()
	for _,i in pairs(Torso:GetChildren()) do
		if i:IsA('Sound') then
			table.insert(Sounds,i)
		end
	end
end)

PetHumanoid.Changed:connect(function(prop)
	if prop =='Jump' and tick()-LastSoundTime >2 and #Sounds>1 then
		LastSoundTime=tick()
		Sounds[math.random(#Sounds)]:Play()
	end
end)

PetHumanoid.Running:connect(function(speed)
	if speed>0 and tick()-LastSoundTime >5 and #Sounds>1 then
		LastSoundTime=tick()
		Sounds[math.random(#Sounds)]:Play()
	elseif tick()-LastSoundTime >5 and #Sounds>1 then
		LastSoundTime=tick()
		Sounds[math.random(#Sounds)]:Play()
	end
end)

MyHumanoid.Changed:connect(function(prop)
	if prop =='Jump' then
		if MyHumanoid.Jump then
			wait(.2)
			PetHumanoid.Jump=true
		end
	end
		
end)

while MyHumanoid and MyHumanoid.Torso and MyModel.Parent and PetHumanoid and PetHumanoid.Torso do


	-- Jumping over obstacles
	local hit = Game.Workspace:FindPartOnRay(Ray.new(PetHumanoid.Torso.Position, PetHumanoid.Torso.CFrame.lookVector * 3.0), MyModel)
	if hit then
		PetHumanoid.Jump = true
	end

	if TargetHumanoid and TargetHumanoid.Torso and math.random(1,15) == 4 then
		Throw(GenerateBanana())
	else
		print("TargetHumanoid is nil")
		PetMode = 0
	end
	print('in ai loop')
	
	PetHumanoid:MoveTo(MyHumanoid.Torso.Position + OFFSET, MyHumanoid.Torso)
	

	wait(ONE_STEP)
end

DebrisService:AddItem(script.Parent, 5)
