--Stickmasterluke

local fairy = script.Parent
local targetTag = fairy:WaitForChild('TargetTag', 1)
local bodyPosition = fairy:WaitForChild('BodyPosition', 1)
local bodyGyro = fairy:WaitForChild('BodyGyro', 1)
local healingParticleEmitter = fairy:WaitForChild('BitHealingParticleEmitter')
local leftWing = fairy:WaitForChild('LeftWing', 1)
local leftWingJoint = leftWing:WaitForChild('LeftWingJoint', 1)
local rightWing = fairy:WaitForChild('RightWing', 1)
local rightWingJoint = rightWing:WaitForChild('RightWingJoint', 1)
local navi1 = fairy:WaitForChild('Navi1', 1)
local navi1Joint = navi1:WaitForChild('NaviJoint', 1)
local navi2 = fairy:WaitForChild('Navi2', 1)
local navi2Joint = navi2:WaitForChild('NaviJoint', 1)
local characterHealingParticles = nil


local HEALING_RATE = 2
local flapRate = 3	--1/2
local waveRange = math.pi*.25


local flapCount = 0

spawn(function()
	local startTime = tick()
	while true do
		if fairy and fairy.Parent and navi1 and navi1.Parent and navi1Joint and navi1Joint.Parent and navi2 and navi2.Parent and navi2Joint and navi2Joint.Parent then
			local wiggle1 = math.sin((tick()-startTime)*math.pi*2*.8)
			local wiggle2 = math.sin((tick()-startTime)*math.pi*2*.8*.618)
			navi1Joint.DesiredAngle = wiggle1 * math.pi*.1
			navi2Joint.DesiredAngle = wiggle2 * math.pi*.1
		else
			break
		end
		wait(.1)
	end
end)

while true do
	if fairy and fairy.Parent and leftWingJoint and leftWingJoint.Parent and rightWingJoint and rightWingJoint.Parent then
		flapCount = flapCount + 1
		local wave = (flapCount%2) *2 - 1
		leftWingJoint.DesiredAngle = wave * waveRange
		rightWingJoint.DesiredAngle = -wave * waveRange
	else
		break
	end

	if targetTag and targetTag.Parent and targetTag.Value and targetTag.Value.Parent and bodyPosition and bodyGyro then
		local hrp = targetTag.Value:FindFirstChild('HumanoidRootPart')
		local humanoid = targetTag.Value:FindFirstChild('Humanoid')
		if hrp and humanoid and humanoid.Health > 0 then
			bodyPosition.position = (hrp.CFrame * CFrame.new(3, 4, 2)).p
			bodyGyro.CFrame = hrp.CFrame
			local healing = humanoid.Health < humanoid.MaxHealth
			healingParticleEmitter.Enabled = healing
			if healing then
				humanoid.Health = math.min(humanoid.Health+(.5/flapRate)*HEALING_RATE, humanoid.MaxHealth)
			end
			if lastHealing ~= healing then
				if healing then
					-- Starting Healing
					if not (characterHealingParticles and characterHealingParticles.Parent) then
						characterHealingParticles = healingParticleEmitter:clone()
						characterHealingParticles.Parent = hrp
					end
					characterHealingParticles.Enabled = true
				else
					-- Ending Healing
					if characterHealingParticles and characterHealingParticles.Parent then
						characterHealingParticles.Enabled = false
					end
				end
			end
			lastHealing = healing
		else
			break
		end
	else
		break
	end

	wait(.5/flapRate)
end

if characterHealingParticles and characterHealingParticles.Parent then
	characterHealingParticles:Destroy()
end


if fairy and fairy.Parent then
	fairy:Destroy()
end




