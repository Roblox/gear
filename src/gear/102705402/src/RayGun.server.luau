function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local ICE_BALL_SPEED = 40
local FREEZE_CHANCE = .10
local SLOW_PERCENTAGE = .15
local ICE_BALL_DAMAGE = 10
local NUM_SPIKES = 3
local ICE_BALL_SPIN_SPEED = 5

local Tool = script.Parent
local Handle = WaitForChild(Tool, "Handle")
local Icify = WaitForChild(Tool, "Icify")
local Character, Torso, Humanoid

local BlastSound = WaitForChild(Tool, "BlastSound")

local SnowflakeMesh = WaitForChild(Tool, "SnowflakeMesh")

local ballPrototype = Instance.new("Part")
ballPrototype.formFactor = "Custom"
ballPrototype.Shape = "Ball"
ballPrototype.Size = Vector3.new(1.5, 1.5, 1.5)
ballPrototype.BrickColor = BrickColor.new("Toothpaste")
ballPrototype.TopSurface = "Smooth"
ballPrototype.BottomSurface = "Smooth"
ballPrototype.Transparency = 1
ballPrototype.CanCollide = false

local ballFloat = Instance.new("BodyForce")
ballFloat.force = Vector3.new(0, ballPrototype:GetMass() * 196.2, 0)
ballFloat.Parent = ballPrototype

local ballRotate = Instance.new("BodyAngularVelocity")
ballRotate.P = 500
ballRotate.maxTorque = ballRotate.P * Vector3.new(0, 1, 0)
ballRotate.angularvelocity = Vector3.new(0, ICE_BALL_SPIN_SPEED, 0)
ballRotate.Parent = ballPrototype

local ballSpike = ballPrototype:Clone()
ballSpike.Size = Vector3.new(.2, .2, .2)
ballSpike.Transparency = 0
ballSpike.BodyForce.force = Vector3.new(0, ballSpike:GetMass() * 196.2, 0)
SnowflakeMesh:Clone().Parent = ballSpike

for i = 1, NUM_SPIKES do
	local newBallSpike = ballSpike:Clone()
	local spikeWeld = Instance.new("ManualWeld")
	spikeWeld.Name = "SpikeWeld"
	spikeWeld.Part0 = ballPrototype
	spikeWeld.Part1 = newBallSpike
	spikeWeld.C0 = CFrame.new()
	spikeWeld.C1 = CFrame.Angles(i*math.pi*2/NUM_SPIKES, 0, 0)

	spikeWeld.Parent = newBallSpike
	newBallSpike.Parent = ballPrototype
end

function gunUp()
	Tool.Grip = Tool.Grip * CFrame.Angles(-0.2, 0, 0)
end

function gunOut()
	Tool.Grip = CFrame.new(0, -0.5, 1, 1, -2.62268344e-007, -1.74845511e-007, 2.62268344e-007, 1, -1.31134215e-007, 1.74845553e-007, 1.31134158e-007, 1)
end

function freezeCharacter(character)
	if character:FindFirstChild("Icify") then return end
	local newIcify = Icify:Clone()
	newIcify.Parent = character
	newIcify.Disabled = false
end


local HitHumTimes = {}
local HumSlows = {}

function slowCharacter(humanoid)
	if not HumSlows[humanoid] then HumSlows[humanoid] = 0 end
	local newHumSlows = HumSlows[humanoid] + 1
	HumSlows[humanoid] = newHumSlows

	local newWalkSpeed = 16
	for i = 1, HumSlows[humanoid] do
		newWalkSpeed = newWalkSpeed * (1 - SLOW_PERCENTAGE)
	end

	humanoid.WalkSpeed = newWalkSpeed

	delay(4, function() 
		if HumSlows[humanoid] == newHumSlows then
			HumSlows[humanoid] = 0
			humanoid.WalkSpeed = 16
		end 
	end) -- if haven't been hit for 4 seconds, they're back to normal
end

function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
	game.Debris:AddItem(creator_tag, 1)
end

function onIceballHit(hitPart)
	local vPlayer = nil
	if Character then vPlayer = game.Players:GetPlayerFromCharacter(Character) end
	local safeHumanoid = nil
	if Character then safeHumanoid = Character:FindFirstChild("Humanoid") end

	if not hitPart then return end
	local hitChar = hitPart.Parent
	if not hitChar then return end
	local hitHum = hitChar:FindFirstChild("Humanoid")
	-- in case it hit a hat, wanna check the hit hat's hit
	if not hitHum then
		hitChar = hitChar.Parent
		if not hitChar then return end
		hitHum = hitChar:FindFirstChild("Humanoid")
		if not hitHum then return end
	end

	if hitHum == safeHumanoid then return end -- don't hurt shooter

	local currTime = tick()
	if not HitHumTimes[hitHum] or HitHumTimes[hitHum] < currTime then
		HitHumTimes[hitHum] = currTime + .5
		if hitHum.Health > 0 then
			hitHum:TakeDamage(ICE_BALL_DAMAGE)
			
			-- slow down humanoid here
			slowCharacter(hitHum)
			
			-- maybe freeze them too, if not already frozen
			if math.random() < FREEZE_CHANCE then
				freezeCharacter(hitChar)
			end

			tagHumanoid(hitHum, vPlayer)
		end
	end
end

function fireAt(startPos, targetPos)
	local newBall = ballPrototype:Clone()
	newBall.CFrame = CFrame.new(startPos)
	newBall.Velocity = (targetPos - startPos).unit * ICE_BALL_SPEED
	newBall.Parent = workspace

	newBall.Touched:connect(onIceballHit)
	game:GetService("Debris"):AddItem(newBall, 4)
end


Tool.Enabled = true
function onActivated()
	Character = Tool.Parent
	if not Character then return end

	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Humanoid = Character:FindFirstChild("Humanoid")
	if (not Torso) or (not Humanoid) then return end

	if not Tool.Enabled then return false end
	Tool.Enabled = false

	wait() -- for .TargetPoint replication?

	gunUp()
	fireAt(Handle.CFrame.p, Humanoid.TargetPoint)
	BlastSound:Play()

	wait(.5)
	gunOut()
	wait(.5)
	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)
