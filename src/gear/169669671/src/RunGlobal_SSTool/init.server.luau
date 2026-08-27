local Players = Game:GetService('Players')
local RunService = Game:GetService('RunService')

local Character = script.Parent
local Player = Players:GetPlayerFromCharacter(Character)

local ShootFrom = script:WaitForChild('ShootFrom')
local ShootTo = script:WaitForChild('ShootTo')
local IsShooting = script:WaitForChild('IsShooting')
local HumanoidToDamage = script:WaitForChild('HumanoidToDamage')
local UpdateShoot = script:WaitForChild('UpdateShoot')
--
local UpdateMove = script:WaitForChild('UpdateMove')
local ControlReady = script:WaitForChild('ControlReady')

local PartList = {
	{
		-- 15 degrees
		Sweep = 20;
		Mesh = 'rbxassetid://168892318';
		CFrame = CFrame.new(-2.028, 0.003, 0.063, 0.482962936, -0.258818984, -0.836516321, 0.129409432, 0.965925813, -0.224143848, 0.866025388, 6.70552254e-008, 0.5);
	},
	{
		-- 180 degrees
		Sweep = 180;
		Mesh = 'rbxassetid://168892343';
		CFrame = CFrame.new(-0.500, -0.169, -0.275, -0.546336055, 0.136979967, 0.826288223, -0.0343417339, 0.982042372, -0.185506523, -0.836861134, -0.129725233, -0.531821132);
	},
	{
		-- 30 degrees
		Sweep = 40;
		Mesh = 'rbxassetid://168892363';
		CFrame = CFrame.new(-1.738, -0.056, -0.034, 0.913205206, -0.157400429, -0.375873566, 0.0347544663, 0.949112594, -0.313011229, 0.406014502, 0.272780538, 0.872205615);
	},
	{
		-- 250 degrees
		Sweep = 250;
		Mesh = 'rbxassetid://168892387';
		CFrame = CFrame.new(0.033, -0.053, -0.015, -0.947963715, 0.129520699, 0.290842265, 0.0606384911, 0.970239401, -0.23443158, -0.312550366, -0.20459649, -0.927605391);
	},
	{
		-- 200 degrees
		Sweep = 200;
		Mesh = 'rbxassetid://168892408';
		CFrame = CFrame.new(-0.293, -0.027, -0.226, -0.517871141, -0.154164821, -0.841452301, 0.081988588, 0.970154822, -0.228204504, 0.85152036, -0.187170446, -0.489775389);
	},
}

local MainBodyPartList = {'Head', 'Torso', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg'}

local BREAKOFF_TIME = 1
local FLOAT_FINISH_TIME = 3
local FLOAT_HEIGHT = 10
--
local RISE_VELOCITY = FLOAT_FINISH_TIME / FLOAT_HEIGHT

local function TransformationSequence(character)
	-- Get the stuff
	local torso = character:WaitForChild('HumanoidRootPart')
	local humanoid = character:WaitForChild('Humanoid')
	local dir = torso.CFrame.lookVector
	local transformBase = CFrame.new(torso.Position, torso.Position + Vector3.new(dir.X, 0, dir.Z))

	-- Anchor and ready the character
	if Workspace.FilteringEnabled then
		torso.Anchored = true
		humanoid:ChangeState('Physics')
	end
	
	-- Remove the tools from the character (Under both filtering and non filtering... might as well)
	for _, ch in pairs(Player:WaitForChild('Backpack'):GetChildren()) do
		if ch:IsA('Tool') or ch:IsA('Hopperbin') then
			ch.Parent = nil
		end
	end
	for _, ch in pairs(character:GetChildren()) do
		if ch:IsA('Tool') then
			ch.Parent = nil
		end
	end
	
	--
	local light = Instance.new('PointLight', torso)
	light.Brightness = 2
	light.Range = 6
	light.Color = Color3.new(0/255, 153/255, 255/255)
	
	-- Copy the ViewLocal into the other players
	local addViewCn;
	if Workspace.FilteringEnabled then
		local viewLocal = script:WaitForChild('ViewLocal')
		for _, player in pairs(Players:GetChildren()) do
			if player ~= Player then
				Spawn(function()
					local cl = viewLocal:Clone()
					cl:WaitForChild('TargetCharacter').Value = character
					cl.Disabled = false
					while not player.Character do player.Changed:wait() end
					cl.Parent = player.Character
				end)
			end
		end
		-- .PlayerAdded does not work for other players on the client
		addViewCn = Players.ChildAdded:connect(function(player)
			if not player:IsA('Player') then return end
			Spawn(function()
				local cl = viewLocal:Clone()
				cl:WaitForChild('TargetCharacter').Value = character
				cl.Disabled = false
				while not player.Character do player.Changed:wait() end
				cl.Parent = player.Character
			end)			
		end)
	end

	-- Go into the transformation sequence
	local transformStart = tick()
	local transformLast = transformStart
	local transformBase = character.Torso.CFrame * CFrame.new(0, -3, 0)
	transformBase = CFrame.new(transformBase.p, transformBase.p + Vector3.new(transformBase.lookVector.X, 0, transformBase.lookVector.z))

	-- Main transformation sequence
	while humanoid.Health > 0 and character.Parent do
		-- How much time has elapsed
		local now = tick()
		local dt = now - transformLast
		local elapsed = now - transformStart
		transformLast = now

		-- Main timer
		local frac = math.min(1, elapsed / FLOAT_FINISH_TIME)
		local breakFrac = math.max(0, math.min(1, (elapsed - BREAKOFF_TIME) / (FLOAT_FINISH_TIME - BREAKOFF_TIME)))
		local moveFrac = frac^1.2
		
		-- Float up the torso
		if Workspace.FilteringEnabled then
			torso.Anchored = false
			torso.CFrame = transformBase * CFrame.new(0, 3 + moveFrac * FLOAT_HEIGHT, 0)
			torso.Anchored = true
		end
		
		-- Exit
		if elapsed > FLOAT_FINISH_TIME then
			break
		end
		
		wait()
	end
	
	return addViewCn
end

addViewCn = TransformationSequence(Character)

local lastDamagedHum = nil
local lastDamagedAt = 0
local lastDamagedCreator;
local DamagePerSecond = 70

function RunController(addViewCn, character)	-- Already dead
	if not (character.Parent and character:FindFirstChild('Humanoid') and character.Humanoid.Health > 0) then
		if addViewCn then
			addViewCn:disconnect()
		end
		return nil
	end	
	--
	local torso = character:WaitForChild('HumanoidRootPart')
	local humanoid = character:WaitForChild('Humanoid')
	--
	local turn, move;
	if Workspace.FilteringEnabled then
		turn = Instance.new('BodyGyro')
		turn.maxTorque = Vector3.new(10000, 10000, 10000)
		turn.cframe = torso.CFrame
		turn.Name = 'Turn'
		turn.Parent = torso
		--
		move = Instance.new('BodyPosition')
		move.maxForce = Vector3.new(10000, 10000, 10000)
		move.position = torso.Position
		move.Name = 'Move'
		move.Parent = torso
		--
		humanoid:ChangeState('Physics')
		torso.Anchored = false
		--
		Spawn(function()
			local lastTime = tick()
			while humanoid.Health > 0 and character.Parent do
				local now = tick()
				local dt = (now - lastTime)
				lastTime = now
				--
				if Workspace.FilteringEnabled then
					local newHumanoidToDamage = nil
					if IsShooting.Value and HumanoidToDamage.Value then
						newHumanoidToDamage = HumanoidToDamage.Value
					end
					--
					if lastDamagedHum ~= newHumanoidToDamage then
						if lastDamagedHum then
							if (now - lastDamagedAt) > 0.2 then
								lastDamagedHum:TakeDamage((now - lastDamagedAt)*DamagePerSecond)
							end
							Game:GetService('Debris'):AddItem(lastDamagedCreator, 1)
							lastDamagedCreator = nil
						end
						lastDamagedHum = newHumanoidToDamage
						if lastDamagedHum then
							lastDamagedAt = now
							lastDamagedCreator = Instance.new('ObjectValue')
							lastDamagedCreator.Value = Player
							lastDamagedCreator.Name = 'creator'
							lastDamagedCreator.Parent = lastDamagedHum
						end
					end
					if lastDamagedHum and (now - lastDamagedAt) > 0.1 then
						lastDamagedHum:TakeDamage((now - lastDamagedAt)*DamagePerSecond)
						lastDamagedAt = now
					end
				end
				--
				wait()
			end
			if lastDamagedCreator then
				Game:GetService('Debris'):AddItem(lastDamagedCreator, 1)
			end
			if addViewCn then
				addViewCn:disconnect()
			end
		end)
		--
		local this = {}
		--
		function this:UpdateMove(distributedGameTime, movementPosition, movementVelocity, movementYVelocity)
			if movementVelocity.magnitude > 0.01 then
				turn.cframe = CFrame.new(Vector3.new(), movementVelocity)
			else
				turn.cframe = CFrame.new(Vector3.new(), Vector3.new(torso.CFrame.lookVector.X, 0, torso.CFrame.lookVector.Z))
			end
			move.position = movementPosition
		end
		function this:ShootAt(...)
			
		end
		--	
		return this
	else
		local this = {}
		-- stubs, intentionally unimplemented, the client will do these under non-filtering
		function this:UpdateMove() end
		function this:ShootAt() end
		return this
	end
end

local Controller = RunController(addViewCn, Character)

if Workspace.FilteringEnabled then
	UpdateShoot.OnServerEvent:connect(function(player, active, from, to, hum)
		ShootFrom.Value = from
		ShootTo.Value = to
		HumanoidToDamage.Value = hum
		IsShooting.Value = active
	end)
	UpdateMove.OnServerInvoke = function(player, ...)
		if player == Player then Controller:UpdateMove(...) end
	end
	ControlReady.Value = true
end



















