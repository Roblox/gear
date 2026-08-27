local Penguin = script.Parent
local Tool = Penguin:WaitForChild("ToolPointer").Value
local Damage = Penguin:WaitForChild("Damage").Value
local Player = Penguin:WaitForChild("Player").Value

local DamageAble = true
local DamageReload = 1

--stabilize
local Gyro = Instance.new("BodyGyro")
Gyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
Gyro.cframe = Penguin.CFrame
Gyro.Parent = Penguin

local Move = Instance.new("BodyVelocity")
Move.maxForce = Vector3.new(5e3, 0, 5e3)
Move.velocity = Vector3.new()
Move.Parent = Penguin

--some timers
local MoveTime = 0.9
local MoveTimer = 0

function jumpTime()
	return 0.75 + math.random() * 1.25
end

local JumpTimer = jumpTime()

function getRandomTargetPosition()
	local targetPosition = Tool.TargetPosition
	if targetPosition then
		return targetPosition.Value + Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
	end
end

function moveTo(position)
	local delta = position - Penguin.Position
	local distance = delta.magnitude
	local speed = 14
	local t = math.min(distance / speed, MoveTime - 0.1)
		
	Move.velocity = delta.unit * speed
	delay(t, function()
		Move.velocity = Vector3.new()
	end)
	
	local a = Penguin.Position
	local b = Vector3.new(position.X, a.Y, position.Z)
	Gyro.cframe = CFrame.new(a, b)
end

function jump()
	Penguin.Velocity = Penguin.Velocity + Vector3.new(0, 50, 0)
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = Player
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function onTouched(part)
	if not DamageAble then return end
	if part.Parent == Player.Character then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		tagHuman(human)
		human:TakeDamage(Damage)
		
		DamageAble = false
		delay(DamageReload, function()
			DamageAble = true
		end)
	end
end

--begin ai
game:GetService("RunService").Heartbeat:connect(function(dt)
	MoveTimer = MoveTimer - dt
	if MoveTimer <= 0 then
		moveTo(getRandomTargetPosition())
		MoveTimer = MoveTime
	end
	
	JumpTimer = JumpTimer - dt
	if JumpTimer <= 0 then
		jump()
		JumpTimer = jumpTime()
	end
end)

Penguin.Touched:connect(onTouched)
