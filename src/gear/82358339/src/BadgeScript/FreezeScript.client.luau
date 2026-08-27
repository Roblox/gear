local duration = 4.5

local RightShoulder
local LeftShoulder
local RightHip
local LeftHip

function moveJump()
	if RightShoulder then 
		--RightShoulder.CurrentAngle = 3.14+math.random()-.5
		RightShoulder.MaxVelocity = 0.5
		RightShoulder:SetDesiredAngle(3.14)
	end
	if LeftShoulder then
		--LeftShoulder.CurrentAngle = 3.14+math.random()-.5
		LeftShoulder.MaxVelocity = 0.5
		LeftShoulder:SetDesiredAngle(-3.14)
	end
	if RightHip then
		RightHip:SetDesiredAngle(0)
	end
	if LeftHip then
		LeftHip:SetDesiredAngle(0)
	end
end

local char = script.Parent

local hum = char:FindFirstChild("Humanoid")
local torso = char:FindFirstChild("Torso")

if hum and torso then
	RightShoulder = torso:FindFirstChild("Right Shoulder")
	LeftShoulder = torso:FindFirstChild("Left Shoulder")
	RightHip = torso:FindFirstChild("Right Hip")
	LeftHip = torso:FindFirstChild("Left Hip")
	if hum and torso then
		local anim = char:FindFirstChild("Animate")
		hum.WalkSpeed = 0

		if anim and anim:IsA("Script") then 
			anim.Disabled = true 
			--hum.Jump = true
			moveJump()
			local startTime = tick()
			while true do
				--if hum then hum.PlatformStand=true end
				local time = tick()
				if time-startTime > duration then break end
				moveJump()
				wait()
			end
			if anim then anim.Disabled = false end
		else
			local startTime = tick()
			while true do
				local time = tick()
				if time-startTime > duration then break end
				moveJump()
				wait()
			end
		end

		if torso then torso.Anchored = false end
		if hum then hum.WalkSpeed = 16 end
		
	end

end

script:Destroy()
