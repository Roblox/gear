-- SLIDING MAN!!! OMG!! --
local canSlide = true
local Tool = script.Parent
local slidePotion = Tool.Handle

Tool.Enabled = true

-- Animation
local penguinSlide
local JumpAnim

--Forces
local bodyVelocity
local bodyGyro

-- Sound --Fix implemented by Luckymaxer
local slideSound = Tool:WaitForChild("SlideSound")
local jumpSound = Tool:WaitForChild("JumpSound")

function onActivated()	
		
	if not Tool.Enabled then 
		return 
	end

	print("IN ACTIVATE")

	Tool.Enabled = false

	local myHumanoid = Tool.Parent:FindFirstChild("Humanoid")
	if not myHumanoid then 
		print("NO HUMANOID")
		return
	end

	penguinSlide = myHumanoid:LoadAnimation(Tool.PenguinSlide)
	penguinSlide:Play()

	local myTorso = Tool.Parent:FindFirstChild("Torso")
	if not myTorso then 
		print("NO TORSO")
		return
	end		
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.P = 100000
 	bodyVelocity.maxForce = Vector3.new(bodyVelocity.P, 0.0, bodyVelocity.P)
	bodyVelocity.velocity = Vector3.new(0,0,0)
	bodyVelocity.Parent = myTorso
	slideSound:Play()

	torsoFrame = myTorso.CFrame
	torsoFrame_1 = myTorso.CFrame * CFrame.Angles(-math.pi/3.0, 0.0, 0.0)
	
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 10000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)
	bodyGyro.cframe = torsoFrame_1
	bodyGyro.Parent = myTorso

	chargeTime = -100
	didAJump = false
	local lastdirection = myHumanoid.TargetPoint-myTorso.Position * Vector3.new(1.0,0.0,1.0)
	jumpSound.Volume = 1
	for i  = 1, 50, 1 do		
		local target = myHumanoid.TargetPoint
		local direction = (target - myTorso.Position) * Vector3.new(1.0, 0.0, 1.0)
		-- Pushing the body in the direction of the targetPoint
		if direction.magnitude > .1 then 
			direction = direction.unit
			bodyVelocity.velocity = direction * 32.0	
			-- calculate bank here
			bank = myTorso.CFrame:vectorToObjectSpace(lastdirection - direction).X / 2
			-- Body Gyro to shift the body's rotation
			torsoFrame = CFrame.new(myTorso.Position, myTorso.Position + direction)
			torsoFrame_1 = torsoFrame * CFrame.Angles(-math.pi/3.0, -bank*math.pi/2, 0.0)
			bodyGyro.cframe = torsoFrame_1					
			lastdirection = direction
		end
		
		-- To stop edge case, where jump occurs twice if space is pressed long enough
		if didAJump and i - chargeTime == 9 then
			myHumanoid.Jump = false
			didAJump = false
		end

		-- The character can jump once in every 1.2 seconds
		if myHumanoid.Jump and i - chargeTime > 12 then						
			myHumanoid.Jump = false
			didAJump = true
			myTorso.Velocity = myTorso.Velocity + Vector3.new(0, 50, 0)
			if canSlide then slideSound.Volume = 0.2 end
			jumpSound:Play()			
			chargeTime = i 
			if canSlide then slideSound.Volume = 1.0 end
		end
		wait(0.1)
	end
	-- Reset everything
	bodyGyro.cframe = torsoFrame
	if bodyGyro ~= nil then bodyGyro:Remove() end
	if bodyVelocity ~= nil then bodyVelocity:Remove() end
	if penguinSlide then penguinSlide:Stop() end
	slideSound:Stop()	
	wait(0.5)
	Tool.Enabled = true
end	

-- On Equipping the potion
function onEquippedLocal(mouse)	
	canSlide = true
end

-- On Unequipping the potion
function onUnequippedLocal()
	if bodyVelocity then bodyVelocity:Remove() end
	if bodyGyro then bodyGyro:Remove() end
	if penguinSlide then penguinSlide:Stop() end
	slideSound:Stop()	
	jumpSound:Stop()
	jumpSound.Volume = 0
	canSlide = false
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

