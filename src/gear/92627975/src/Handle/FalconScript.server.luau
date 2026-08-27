--Falcon settings are here
local Aggressive = true --Falcon will attack enemies
local SmallDamage = 8
local LargeDamage = 16 --Does more damage while tool is equipped
local ShortReload = 1.5 --Shoots faster if given an assigned area to move to
local LongReload = 2.25
local EquipReloadBonus = -1.25 --Shoots faster when tool is equipped
local AssignmentDuration = 8
local MaxSpeed = 100
local Acceleration = 40
local SubAcceleration = 7 --Relative speed when approaching target

local SearchRangeXZ = 35
local SearchRangeY = 15
local ChaseRange = 60

local LastShotStart = "left"

function WaitForChild(parent, child)
	local result = parent:FindFirstChild(child)
	delay(3, function() if not result then print("Probably Stuck", child) end end)
	while not result do
		parent.ChildAdded:wait()
		result = parent:FindFirstChild(child)
	end
	return result
end

local debris = game:GetService("Debris")

function getMassOfObject(obj)
	local children
	local mass = 0
	if type(obj) == "userdata" then
		children = obj:GetChildren()
	elseif type(obj) == "table" then
		children = obj
	end
	if children then
		for i = 1, #children do
			if children[i]:IsA("BasePart") then
				mass = mass + children[i]:GetMass()
			end
			if #children[i]:GetChildren() > 1 then
				mass = mass + getMassOfObject(children[i])
			end
		end
	end
	return mass
end




local Falcon = script.Parent
Falcon.CanCollide = true

local leftWing = WaitForChild(Falcon, "LeftWing")
local rightWing = WaitForChild(Falcon, "RightWing")
local leftWeld = WaitForChild(Falcon, "LeftWingWeld")
local rightWeld = WaitForChild(Falcon, "RightWingWeld")
local Owner = WaitForChild(Falcon, "OwnerRef")
local TargetPoint = WaitForChild(Falcon, "TargetPoint")
local SpawnSound = WaitForChild(Falcon, "SpawnSound")
SpawnSound:Play()

local MoveToPoint = Vector3.new(0,0,0)
local EnemyTarget = nil

local LastAssignment = tick() - 1000


function IsToolEquipped()
	local char = Owner.Value
	if char and char.Parent then
		local refObject = char:FindFirstChild("FalconRefObject")
		local tool = char:FindFirstChild("FalconPet")
		if refObject and refObject.Value == Falcon.Parent and tool then
			return true
		end
	end
	return false
end



function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function blow(proj, hit)

	local damage = SmallDamage
	if IsToolEquipped() then
		damage = LargeDamage
	end

	if hit and hit.Parent and proj then
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		local vCharacter = Owner.Value
		local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid ~= nil and Owner.Value ~= hit.Parent then
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
		end
	end
end


local shooting = false

function shoot(object)
	if Falcon == nil or Falcon.Parent == nil then return false end
	shooting = true
	--local bodyGyro = Falcon:FindFirstChild("BodyGyro")
	local startPosition = Falcon.Position
	--direction = (object.Position - Falcon.Position).unit
	--if bodyGyro then
		--bodyGyro.cframe = CFrame.new(startPosition, startPosition + direction)
	--end
	--wait(.2)

	if Falcon == nil or Falcon.Parent == nil or not object then return false end
	local startPosition = Falcon.Position
	--[[if LastShotStart == "left" then
		startPosition = startPosition + Falcon.CFrame:vectorToWorldSpace(Vector3.new(1,0,0))
		LastShotStart = "right"
	else
		startPosition = startPosition - Falcon.CFrame:vectorToWorldSpace(Vector3.new(-1,0,0))
		LastShotStart = "left"
	end]]

	local direction = (object.Position - startPosition).unit

	shootSound = Falcon:FindFirstChild("ShootSound")
	if shootSound then
		shootSound:Play()
	end


	local beamstart = startPosition
	local beamend = beamstart + direction * 2

	local dist=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Effect"
	--laser.Anchored=true
	laser.CanCollide=false
	laser.Shape="Block"
	laser.formFactor="Custom"
	laser.Size=Vector3.new(.2,.2,.2)
	laser.Transparency=0
	laser.Material=Enum.Material.Plastic
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=BrickColor.new("Really red")
	--laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dist/2)*CFrame.Angles(math.pi/2,0,0)
	laser.CFrame=CFrame.new(startPosition,object.Position)*CFrame.new(0,0,-dist/2)*CFrame.Angles(math.pi/2,0,0)
	local m=Instance.new("SpecialMesh")
	m.Scale=Vector3.new(1,dist*5,1)
	m.Parent=laser
	debris:AddItem(laser,3)

	laser.Parent=Workspace

	laser.Touched:connect(function(hit) blow(laser, hit) end)

	local laserBurn = Falcon:FindFirstChild('LaserBurn')
	if laserBurn then
		burnScriptClone = laserBurn:Clone()
		burnScriptClone.Parent = laser
		if burnScriptClone:FindFirstChild('Creator') then
			burnScriptClone.Creator.Value = Falcon
		end
		burnScriptClone.Disabled = false
	end

	laser.Velocity = direction * 100

	Instance.new('BodyForce', laser).force = Vector3.new(0, laser:GetMass() * 196.2, 0) -- Antigravity

	--wait(.3)

	shooting = false
	local reloadTime
	if tick() - LastAssignment < AssignmentDuration then
		reloadTime = ShortReload
	else
		reloadTime = LongReload
	end
	if IsToolEquipped() then
		reloadTime = reloadTime + EquipReloadBonus
	end
	wait(reloadTime - .8)
	return true
end


function FlapWings()
	local sign = 1
	local count = 0

	local initLC1
	local initRC1

	leftWeld = Falcon:FindFirstChild("LeftWingWeld")
	rightWeld = Falcon:FindFirstChild("RightWingWeld")
	if leftWeld and rightWeld then
		initLC1 = leftWeld.C1
		initRC1 = rightWeld.C1
		while Falcon.Parent and leftWeld and rightWeld do
			leftWeld.C1 = leftWeld.C1 * CFrame.Angles(0, -sign * math.pi/30, 0 )
			rightWeld.C1 = rightWeld.C1 * CFrame.Angles(0, sign * math.pi/30, 0)
			count = count + 1
			if count > 7 then
				sign = sign * -1
				count = count%6
			end
			wait(1/15)
		end
	end
end

local MoveDelay = .1
local CircleCounter = 0
function MoveToTarget()
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.velocity = Vector3.new(0,0,0)
	bodyVelocity.Parent = Falcon
	bodyVelocity.maxForce = Vector3.new(10000,20000,10000) --It's strong enough to support your weight
	local bodyGyro = Instance.new('BodyGyro')
	bodyGyro.Name = "BodyGyro"
	bodyGyro.maxTorque = Vector3.new(3000,3000,3000)
	bodyGyro.Parent = Falcon
	while Falcon and Falcon.Parent do
		if Owner.Value == nil or Owner.Value.Parent == nil or Owner.Value:FindFirstChild("FalconRefObject") == nil then
			debris:AddItem(Falcon.Parent, 3.5) --Kill the falcon if the owner dies
			Delay(1.5, function()
				Aggressive = false
			end)
		end
		if not shooting then
			if tick() - LastAssignment > AssignmentDuration and Owner.Value then
				local torso = Owner.Value:FindFirstChild("Torso") or Owner.Value:FindFirstChild("UpperTorso")
				if torso then
					MoveToPoint = torso.Position
				end
			end
			CircleCounter = CircleCounter+1

			local adjustedMovePoint = MoveToPoint + CFrame.Angles(0,CircleCounter/7,0) * Vector3.new(10,15,0)
			local furtherAdjustedMovePoint = MoveToPoint + CFrame.Angles(0,CircleCounter/7 + math.pi/10,0) * Vector3.new(10,15,0)
			local moveVector = adjustedMovePoint - Falcon.Position
			local targetSpeed = math.min(MaxSpeed, SubAcceleration * math.sqrt(moveVector.magnitude))
			local curMag = bodyVelocity.velocity.magnitude
			local newSpeed
			if targetSpeed > curMag then
				newSpeed = math.min(targetSpeed, curMag + Acceleration * MoveDelay)
			else
				newSpeed = math.max(targetSpeed, curMag - Acceleration * MoveDelay)
			end
			bodyVelocity.velocity = moveVector.unit * newSpeed
			--print("target, vel", MoveToPoint, bodyVelocity.velocity)
			bodyGyro.cframe = CFrame.new(Falcon.Position, furtherAdjustedMovePoint)
		end
		wait(MoveDelay)
	end
end

delay(0, FlapWings)
delay(0, MoveToTarget)

TargetPoint.Changed:connect(function(val)
	--print("target updated")
	LastAssignment = tick()
	MoveToPoint = val
end)

wait(1)

while Falcon and Falcon.Parent do
	if Aggressive and (not EnemyTarget or (tick() - LastAssignment < AssignmentDuration)) then
		local pxPos = Falcon.Position + Vector3.new(0,-8,0)
		local searchVec = Vector3.new(SearchRangeXZ, SearchRangeY, SearchRangeXZ)
		local searchRegion = Region3.new(pxPos - searchVec, pxPos + searchVec)
		local partList = game.Workspace:FindPartsInRegion3(searchRegion, Owner.Value, 50)
		local closestPart
		local closestDistance = ChaseRange
		for i,part in pairs(partList) do
			local partDistance = (part.Position - pxPos).magnitude
			local hum = part.Parent:FindFirstChild("Humanoid")
			if partDistance < closestDistance and hum and hum:IsA("Humanoid") and hum.Health>0 then
				closestPart = part
				closestDistance = partDistance
			end
		end
		if closestPart then
			EnemyTarget = closestPart.Parent
			--print("found attack target")
		end
	end
	if Aggressive and EnemyTarget then
		local hum = EnemyTarget:FindFirstChild("Humanoid")
		local torso = EnemyTarget:FindFirstChild("Torso") or EnemyTarget:FindFirstChild("UpperTorso")
		while EnemyTarget and hum and torso and (Falcon and Falcon.Parent) do
			local attackVec = torso.Position - Falcon.Position
			if hum.Parent and hum.Health > 0 and attackVec.magnitude < ChaseRange then
				local success = shoot(torso)
				if not success then break end
			else
				EnemyTarget = nil
			end
			wait(.0001)
		end
	end

	wait(1)
end
