function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local NUM_TORNADOS = 5
local TORNADO_SPEED = 20
local TORNADO_DURATION = 6
local TORNADO_WOBBLE_ANGLE = .5 --1.5
local TORNADO_SPIN_SPEED = 10
local TORNADO_SIZE = Vector3.new(6, 10, 6)
local TORNADO_DAMAGE = 20

local Tool = script.Parent
local Handle = WaitForChild(Tool, "Handle")
local TornadoMesh = WaitForChild(Tool, "TornadoMesh")

-- now that we're in game, split staff into two parts, with top part floatin' around:
-- partial staff meshes:
-- top: 102605108
-- bottom: 102605081
local StaffMesh = WaitForChild(Handle, "Mesh")
StaffMesh.MeshId = "http://www.roblox.com/asset/?id=102605081"

local FloatyBall = Instance.new("Part")
FloatyBall.formFactor = "Custom"
FloatyBall.Size = Vector3.new(.2, .2, .2)
FloatyBall.CanCollide = false

local FloatyBallMesh = StaffMesh:Clone()
FloatyBallMesh.MeshId = "http://www.roblox.com/asset/?id=102605108"
FloatyBallMesh.Parent = FloatyBall

local FloatyBallWeld = Instance.new("ManualWeld")
FloatyBallWeld.Part0 = Handle
FloatyBallWeld.Part1 = FloatyBall
FloatyBallWeld.C0 = CFrame.new()
FloatyBallWeld.C1 = CFrame.new() + Vector3.new(0, 1, 0)
FloatyBallWeld.Parent = FloatyBall

function AnimateFloatyBall()
	local timeParam1 = 0
	local timeParam2 = 0
	local timeIncrement
	local rotatedCF
	while true do
		rotatedCF = CFrame.Angles(0, 0, timeParam2)
		FloatyBallWeld.C1 = rotatedCF + rotatedCF:vectorToWorldSpace(Vector3.new(0, -3 + .5 * math.sin(timeParam1), 0))
		timeIncrement = wait(.01)
		if not Tool.Enabled then
			timeParam2 = timeParam2 + 8 * timeIncrement
		else
			timeParam2 = timeParam2 + timeIncrement
		end
		timeParam1 = timeParam1 + timeIncrement
		if timeParam2 > math.pi*12 then
			timeParam2 = timeParam2 - math.pi*12
		end
		if timeParam1 > math.pi*12 then
			timeParam1 = timeParam1 - math.pi*12
		end
	end
end


-- animate floaty ball all the timez
coroutine.resume(coroutine.create(AnimateFloatyBall))

-- make tornado part
local TornadoPrototype = Instance.new("Part")
TornadoPrototype.formFactor = "Custom"
TornadoPrototype.Size = Vector3.new(.2, .2, .2)
TornadoPrototype.TopSurface = "Smooth"
TornadoPrototype.BottomSurface = "Smooth"
TornadoPrototype.CanCollide = false

-- give it mesh
TornadoMesh:Clone().Parent = TornadoPrototype

-- float it
local TornadoFloatForce = Instance.new("BodyForce")
TornadoFloatForce.force = Vector3.new(0, TornadoPrototype:GetMass()*196.2, 0)
TornadoFloatForce.Parent = TornadoPrototype

-- rotate it
local TornadoRotate = Instance.new("BodyAngularVelocity")
TornadoRotate.P = 20
TornadoRotate.maxTorque = TornadoRotate.P * Vector3.new(0, 1, 0)
TornadoRotate.angularvelocity = Vector3.new(0, 0, 0)
TornadoRotate.Parent = TornadoPrototype

-- make it move (but not in the y-axis)
local TornadoVelocity = Instance.new("BodyVelocity")
TornadoVelocity.P = 20
TornadoVelocity.maxForce = TornadoVelocity.P * Vector3.new(1, 0, 1)
TornadoVelocity.velocity = Vector3.new(0, 0, 0)
TornadoVelocity.Parent = TornadoPrototype

-- noisy stormz
local StormSound = Instance.new("Sound")
StormSound.Name = "StormSound"
StormSound.SoundId = "http://www.roblox.com/asset/?id=101173442"
StormSound.Parent = TornadoPrototype
StormSound.Volume = 1

function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
	game.Debris:AddItem(creator_tag, 1)
end


function applyUpwardsForce(part, tornadoVelocity, upwardsForces)
	if upwardsForces[part] then return end
	upwardsForces[part] = true

	local newFloatForce = Instance.new("BodyForce")
	newFloatForce.force = Vector3.new(0, 300*part:GetMass(), 0) + tornadoVelocity * part:GetMass() * Vector3.new(10, 0, 10)
	newFloatForce.Parent = part

	game:GetService("Debris"):AddItem(newFloatForce, .25)
end

function damageChar(part, humanoidsDamaged, playerDamaging)
	local char = part.Parent
	if not char then return end	
	local hum = char:FindFirstChild("Humanoid")
	if not hum then 
		char = char.Parent
		hum = char:FindFirstChild("Humanoid")
		if not hum then return end
	end
	if humanoidsDamaged[hum] then return end
	humanoidsDamaged[hum] = true
	if hum.Health > 0 then
		hum:TakeDamage(TORNADO_DAMAGE)
		tagHumanoid(hum, playerDamaging)
	end
end

function checkPartsHit(position, character, tornadoVelocity)
	local partsHit = workspace:FindPartsInRegion3(Region3.new(position - TORNADO_SIZE/2, position + TORNADO_SIZE/2), character)
	local humanoidsDamaged = {}
	local upwardsForces = {}
	local playerDamaging = game.Players:GetPlayerFromCharacter(character)
	for i = 1, #partsHit do
		if not partsHit[i].Anchored and partsHit[i].CanCollide then
			-- apply upwards force?
			applyUpwardsForce(partsHit[i], tornadoVelocity, upwardsForces)
			damageChar(partsHit[i], humanoidsDamaged, playerDamaging)
		end
	end
end

function handleTornado(tornado, character)
	local tornadoForce = tornado.BodyVelocity
	local randomAngle, rotateCF, newVelocity

	-- play storm sound
	tornado["StormSound"]:Play()

	for i = 0, TORNADO_DURATION, .25 do
		-- handle motion per tick
		randomAngle = (math.random()-.5) * TORNADO_WOBBLE_ANGLE
		rotateCF = CFrame.Angles(0, randomAngle, 0)
		newVelocity = rotateCF:vectorToWorldSpace(tornadoForce.velocity)
		tornadoForce.velocity = newVelocity

		-- handle interactions per tick
		checkPartsHit(tornado.CFrame.p, character, newVelocity)

		wait(.25)
	end
	tornado:Remove()
end

function makeTornado(startPoint, targetPoint, character)
	local newTornado = TornadoPrototype:Clone()
	newTornado.CFrame = CFrame.new(startPoint, targetPoint)
	newTornado.BodyVelocity.velocity = (targetPoint - startPoint).unit * TORNADO_SPEED
	newTornado.BodyAngularVelocity.angularvelocity = Vector3.new(0, TORNADO_SPIN_SPEED, 0)
	newTornado.Parent = workspace

	coroutine.resume(coroutine.create(handleTornado), newTornado, character)
end


Tool.Enabled = true
function onActivated()

	local Character = Tool.Parent
	if not Character then return end

	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	local Humanoid = Character:FindFirstChild("Humanoid")
	if (not Torso) or (not Humanoid) then return end

	if not Tool.Enabled then return end
	Tool.Enabled = false

	wait()

	local torsoPoint = Torso.CFrame.p + Vector3.new(0, 2, 0) -- little above torso
	local targetPoint = Humanoid.TargetPoint * Vector3.new(1, 0, 1) +  torsoPoint * Vector3.new(0, 1, 0)

	for i = 1, NUM_TORNADOS do
		makeTornado(torsoPoint, targetPoint, Character)
	end

	wait(3.5)

	Tool.Enabled = true
end

function onEquipped()
	FloatyBallWeld.Parent = FloatyBall
	FloatyBall.Parent = Tool.Parent
end

function onUnequipped()
	FloatyBallWeld.Parent = FloatyBall
	FloatyBall.Parent = Handle.Parent
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
