---------------------------------------------------
-- This script is being added to the characer --
---------------------------------------------------
local character = script.Parent
local torso = character:FindFirstChild('Torso')
local DebrisService = game:GetService('Debris')
local GyserSound = script:WaitForChild('GyserSound')

---------------------------------------------------
				-- Constants --
---------------------------------------------------
local GYSER_EFFECT_LEN = 5
local VELOCITY = Vector3.new(0, 50, 0)
local GYSER_DMG_PER_TICK = 10

---------------------------------------------------
				-- Helper Functions --
---------------------------------------------------
-- Ping pongs between 0 and length
local function pingPong(t, length)
	local l = 2 * length
	local s = t % l
	
	local result = l - s
	
	if result < length then
		return result
	else
		return l - result
	end
end

local function createSteamEffect(position)
	local part = Instance.new('Part')
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(position)	
	
	local smoke = Instance.new('Smoke')
	smoke.RiseVelocity = 10
	smoke.Size = 10
	smoke.Opacity = 1
	smoke.Parent = part
	
	part.Parent = game.Workspace
	DebrisService:AddItem(part, GYSER_EFFECT_LEN)
end

---------------------------------------------------
				-- Effect --
---------------------------------------------------
if torso then
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.velocity = Vector3.new(0, 20, 0)
	bodyVelocity.P = 4000
	bodyVelocity.maxForce = Vector3.new(1000000, 1000000, 1000000)
	bodyVelocity.Parent = torso
	GyserSound.Parent = torso
	GyserSound:Play()
	
	createSteamEffect(torso.Position - Vector3.new(0, 3, 0))
	wait(0.4)
	
	local dmgTick = 1
	local humanoid = character:FindFirstChild('Humanoid')
	local t = 0
	local deltaTime = tick()
	while t < GYSER_EFFECT_LEN do
		local yScalar = pingPong(deltaTime * 3, 1) - 0.5 -- range from -0.5 to 0.5
		bodyVelocity.velocity = VELOCITY * yScalar
		t = t + (tick() - deltaTime)
		deltaTime = tick()
		wait()
		if humanoid then
			if humanoid.Health < 1 then
				break
			elseif t > dmgTick then
				humanoid:TakeDamage(GYSER_DMG_PER_TICK)
				dmgTick = dmgTick + 1
			end
		end
	end
	
	GyserSound:Stop()
	GyserSound.Parent = script
	bodyVelocity.velocity = Vector3.new()
	bodyVelocity:Destroy()
	bodyVelocity.Parent = nil
	
	script:Destroy()
	script.Parent = nil
end
