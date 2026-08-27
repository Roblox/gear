local Tool = script.Parent
-- Sound Object
PenguinSound = script.PenguinSound 

--Animation 
local walkAnim
local JumpAnim

-- Reduce the walking speed of the character
walkSpeed = Tool:FindFirstChild("Humanoid").WalkSpeed
walkSpeed = walkSpeed/2.0

-- If the character jumps switch the animation
function onJump()		
	--if walkAnim then
		--walkAnim:Stop()
	--end	
	JumpAnim = Tool:FindFirstChild("Humanoid"):LoadAnimation(script.PenguinJump)
	JumpAnim:Play()
	print("PENGUIN JUMP")
	wait(0.4)
	JumpAnim:Stop()
	--walkAnim:Play()
	Tool:FindFirstChild("Humanoid").WalkSpeed = 8.0
	wait(0.7)
	--walkAnim:Stop()	
	Tool:FindFirstChild("Humanoid").WalkSpeed = 16.0
end

-- Listen for the jump event of the character
Tool:FindFirstChild("Humanoid").Jumping:connect(onJump)

-- Animation + Gyro logic
if Tool ~= nil then 
	local myHumanoid = Tool:FindFirstChild("Humanoid")	
	if myHumanoid ~= nil then 		
		local myTorso = Tool:FindFirstChild("Torso")
		if not myTorso then 
			return
		end
			
		walkAnim = myHumanoid:LoadAnimation(script.PenguinWalk)
		-- Create the 3 frames for the gyro
		torsoFrame_1 = myTorso.CFrame
		torsoFrame_2 = myTorso.CFrame * CFrame.Angles(0.0, 0.0, math.pi/18)
		torsoFrame_3 = myTorso.CFrame * CFrame.Angles(0.0, 0.0, -math.pi/18)

		-- halve the walking speed
		myHumanoid.WalkSpeed = walkSpeed		
		-- Make a body gyro and attach it to the object
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 100000
		bodyGyro.maxTorque = Vector3.new(0.0, 0.0, bodyGyro.P)
		bodyGyro.cframe = torsoFrame_1
		bodyGyro.Parent = myTorso
		-- Total Animation + Gyro time is  7 * 2.4 = 16.8 seconds
		for j = 1, 7, 1 do
			PenguinSound:Play()	
			walkAnim:Play()		
			-- Apply the gyro for 2.4 seconds, approx time of the animation
			for i = 1, 5, 1 do							
				bodyGyro.cframe = torsoFrame_2
				wait(0.12)
				bodyGyro.cframe = torsoFrame_1
				wait(0.12)
				bodyGyro.cframe = torsoFrame_3					
				wait(0.12)
				bodyGyro.cframe = torsoFrame_1
				wait(0.12)
			end					
		end
		-- Remove the Gyro
		bodyGyro:remove()
		walkAnim:Stop()
		PenguinSound:Stop()
	end	
end 

-- Reset the humanoid's speed
Tool:FindFirstChild("Humanoid").WalkSpeed = 16.0

wait(0.5)
script:remove() 

