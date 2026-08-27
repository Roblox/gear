
local Rocket = script.Parent
local CreatorTag = Rocket:WaitForChild('creator')
while not CreatorTag.Value do CreatorTag.Changed:wait() end
local CreatorCharacter = CreatorTag.Value.Character
local CreatedAt = tick()

local Firing = false


Spawn(function()
	wait(20)
	if not Firing then
		Rocket:Destroy()
	end
end)

--

Rocket:WaitForChild('Place'):Play()

--

Rocket.Touched:connect(function(part)
	if Firing then return end
	if not part.Parent then return end
	local hum = part.Parent:FindFirstChild('Humanoid')
	if not hum and part.Parent.Parent then
		hum = part.Parent.Parent:FindFirstChild('Humanoid')
	end
	-- don't shoot ourselves while placing
	if hum and hum.Parent == CreatorCharacter and (tick()-CreatedAt) < 1.2 then return end
	--
	if hum then
		Firing = true
		DoEffect(hum.Parent)
	end
end)

--

function DoEffect(character)
	-- Failsafe remove us
	game.Debris:AddItem(Rocket, 10)

	-- Sound
	Rocket:WaitForChild('Swoosh'):Play()

	-- light our fire
	Rocket.Fire.Enabled = true

	-- Platform stand them in preparation
	character.Humanoid.PlatformStand = true

	--
	local torso = character:FindFirstChild('Torso')
	if not torso then return end

	-- Attach the rocket to them
	local w = Instance.new('Weld', torso)
	w.Part0 = w.Parent
	w.Part1 = Rocket
	w.C0 = CFrame.new(0,0.6,1.2)

	-- Rocket them up
	local pushforce = Instance.new('BodyVelocity', torso)
	pushforce.maxForce = Vector3.new(0, 10000, 0)
	pushforce.velocity = Vector3.new(0, 20, 0)

	-- Wait for them to go up a bit
	wait(3)

	-- Detach ourself and make us fly away
	w:Destroy()
	Rocket.Velocity = Vector3.new(0, Rocket.Velocity.y, 0) - torso.CFrame.lookVector*20
	Rocket.RotVelocity = Vector3.new(math.random(-2,2), math.random(-2,2), math.random(-2,2))
	Rocket.Fire.Enabled = false

	-- Stop the rocket sound
	Rocket:WaitForChild('Swoosh'):Stop()

	-- Kill the effects on the character
	pushforce:Destroy()

	-- Make them glide
	local glideScript = script:FindFirstChild('GlideScript')
	if glideScript then
		local sc = glideScript:Clone()
		sc.Parent = character
		sc.Disabled = false
	end

	-- Fade us out
	for i = 1, 0, -0.1 do
		wait()
		Rocket.Transparency = i
	end

	Rocket:Destroy()
end
