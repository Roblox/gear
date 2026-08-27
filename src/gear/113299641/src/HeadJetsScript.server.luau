-----------------
--| Constants |--
-----------------

local DAMAGE = 30
local COOLDOWN = 3

local ATTACK_RADIUS = 30
local ATTACK_SPEED = 100
local ATTACK_TIME_MAX = 3

local ORBIT_RADIUS = 5
local ORBIT_VERTICAL_OFFSET = 3
local ORBIT_SPEED_FACTOR = 2
local ORBIT_GYRO_TORQUE = Vector3.new(400, 400, 400)

local MAX_JETS = 3
local JET_LAUNCH_DELAY = 1

local TIME_TO_LIVE = 30
local ONE_STEP = 1 / 30

-----------------
--| Variables |--
-----------------

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local ToolHandle = Tool:WaitForChild('Handle')

local MyModel = nil
local MyPlayer = nil
local MyHumanoid = nil
local MyTorso = nil

local NumberOfOrbitingJets = 0

-------------------------
--| Utility Functions |--
-------------------------

-- Returns a character ancestor and its Humanoid, or nil
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

-- Removes any old creator tags and applies new ones to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end

	local creatorTag = Instance.new('ObjectValue')
	creatorTag.Value = MyPlayer
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

	local iconTag = Instance.new('StringValue')
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
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

------------------------
--| Helper Functions |--
------------------------

local function OnJetTouched(jet, otherPart)
	if otherPart then
		local character, humanoid = FindCharacterAncestor(otherPart)
		if character and character ~= MyModel then
			ApplyTags(humanoid)
			humanoid:TakeDamage(DAMAGE)
			jet:Destroy()
		end
	end
end

local function OnJetChanged(jet, property)
	if property == 'Parent' and jet.Parent == nil then
		NumberOfOrbitingJets = NumberOfOrbitingJets - 1
	end
end

local function JetLogic(jet, bodyPosition, bodyGyro, jetNumber)
	jet.Touched:connect(function(otherPart)
		OnJetTouched(jet, otherPart)
	end)

	-- Orbit and attack closest player
	while jet and jet.Parent == Workspace and MyHumanoid and MyHumanoid.Health > 0 and MyTorso and MyTorso.Parent ~= nil do
		-- Update orbit
		local thetaLol = (tick() * ORBIT_SPEED_FACTOR) + (jetNumber * (2 * math.pi / MAX_JETS))
		local offset = Vector3.new(ORBIT_RADIUS * math.cos(thetaLol), ORBIT_VERTICAL_OFFSET, ORBIT_RADIUS * math.sin(thetaLol))
		bodyPosition.position = MyTorso.Position + offset
		bodyGyro.cframe = CFrame.new(jet.Position, bodyPosition.position)

		-- Check for targets
		local targetHumanoid = FindClosestHumanoid(jet.Position, {MyHumanoid})
		if targetHumanoid and targetHumanoid.Health > 0 and targetHumanoid.Torso then -- Attack
			local targetTorso = targetHumanoid.Torso
			local distance = (targetTorso.Position - MyTorso.Position).magnitude
			if distance < ATTACK_RADIUS then
				DebrisService:AddItem(jet, ATTACK_TIME_MAX)
				bodyPosition:Destroy()
				bodyGyro:Destroy()
				Instance.new('BodyForce', jet).force = Vector3.new(0, jet:GetMass() * 196.2, 0) -- Antigravity
				jet.CFrame = CFrame.new(jet.Position, targetTorso.Position)
				jet.Velocity = jet.CFrame.lookVector * ATTACK_SPEED
				return
			end
		end
		wait(ONE_STEP)
	end

	-- If we get here, player has died or been deleted
	if jet then
		jet:Destroy()
	end
end

local function AddNewJet(jetNumber)
	local jet = ToolHandle:Clone()
	jet.Name = 'HeadJet'
	jet.CFrame = ToolHandle.CFrame

	local bodyPosition = Instance.new('BodyPosition')
	bodyPosition.position = ToolHandle.Position
	bodyPosition.Parent = jet

	local bodyGyro = Instance.new('BodyGyro')
	bodyGyro.maxTorque = ORBIT_GYRO_TORQUE
	bodyGyro.Parent = jet

	jet.Changed:connect(function(property)
		OnJetChanged(jet, property)
	end)

	DebrisService:AddItem(jet, TIME_TO_LIVE)
	jet.Parent = Workspace
	Spawn(function()
		JetLogic(jet, bodyPosition, bodyGyro, jetNumber)
	end)
end

----------------------
--| Tool Functions |--
----------------------

local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	MyHumanoid = MyModel:WaitForChild('Humanoid')
	MyTorso = MyModel:WaitForChild('Torso')
end

local function OnActivated()
	if Tool.Enabled and MyHumanoid and MyHumanoid.Health > 0 then
		Tool.Enabled = false

		while NumberOfOrbitingJets < MAX_JETS do
			AddNewJet(NumberOfOrbitingJets)
			NumberOfOrbitingJets = NumberOfOrbitingJets + 1
			wait(JET_LAUNCH_DELAY)
		end

		wait(COOLDOWN)
		Tool.Enabled = true
	end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
