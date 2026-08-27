local Tool = script.Parent
local Potion = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid
local myRightLeg
local myLeftLeg

local torsoFrames = {}

local attackGyro 
local bodyPosition

local debris = game:GetService("Debris")

local damage = 15

local attackAnim
local attackType = 0

Tool.Enabled = true

function changeAttack(key)
	if key then 
		key = key:lower()
		if key == "q" then 
			attackType = 1 
		elseif key == "e" then 
			attackType = 2
		elseif key == "r" then 
			attackType = 3
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
	end
end

function blow(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
		tagHumanoid(humanoid, vPlayer)				
		humanoid:TakeDamage(damage)					
	end	
end

function flashKick()
	local lookVector
	attackAnim = myHumanoid:LoadAnimation(Tool:FindFirstChild("FlashKickAnim"))
	if attackAnim then attackAnim:Play() end
	if myTorso then 
		myRightLeg = vCharacter:FindFirstChild("Right Leg")
		myLeftLeg = vCharacter:FindFirstChild("Left Leg")
		if myRightLeg and myLeftLeg then 
			torsoFrames = {}
			attackGyro = Instance.new("BodyGyro")
			attackGyro.P = 50000
			attackGyro.maxTorque = Vector3.new(attackGyro.P, attackGyro.P, attackGyro.P)
		
			torsoFrames[1] = myTorso.CFrame * CFrame.Angles(1*math.pi/3, 0, 0) 
			torsoFrames[2] = myTorso.CFrame * CFrame.Angles(2*math.pi/3, 0, 0) 
			torsoFrames[3] = myTorso.CFrame * CFrame.Angles(math.pi, 0, 0) 
			torsoFrames[4] = myTorso.CFrame * CFrame.Angles(4*math.pi/3, 0, 0) 
			torsoFrames[5] = myTorso.CFrame * CFrame.Angles(5*math.pi/3, 0, 0) 
			torsoFrames[6] = myTorso.CFrame		

			bodyPosition = Instance.new("BodyPosition")
			bodyPosition.P = 100000
			bodyPosition.maxForce = Vector3.new(50000, 50000, 50000)
			bodyPosition.position = myTorso.Position
			bodyPosition.Parent = myTorso			

			attackGyro.Parent = myTorso	
			lookVector = myTorso.CFrame.lookVector
			
			rightLegConnection = myRightLeg.Touched:connect(blow)
			leftLegConnection = myLeftLeg.Touched:connect(blow)
			for i = 1, 48 do 
			local c = i%6 + 1 
			if attackGyro then attackGyro.cframe = torsoFrames[c] end 			
			if bodyPosition then bodyPosition.position = myTorso.Position + lookVector * 1.0 + myTorso.CFrame.lookVector * 1.0 end
			wait(0.08) 
			end 
			attackGyro.cframe = torsoFrames[6]
			if bodyPosition then bodyPosition:Remove() end
			if rightLegConnection then rightLegConnection:disconnect() end
			if leftLegConnection then leftLegConnection:disconnect() end
			wait(0.4)
			if attackGyro then attackGyro:Remove() end									
		end
	end
end

function chargeKick()
	print(2.1)
	attackAnim = myHumanoid:LoadAnimation(Tool:FindFirstChild("ChargeKickAnim"))
	if attackAnim == nil then Tool.Enabled = true return end 
	if myHumanoid == nil or myTorso == nil then Tool.Enabled = true return end
	attackAnim:Play()
	local target = myHumanoid.TargetPoint 
	myHumanoid.Jump = true
	local direction = (target - myTorso.Position) * Vector3.new(1, 0, 1)
	myRightLeg = vCharacter:FindFirstChild("Right Leg")
	myLeftLeg = vCharacter:FindFirstChild("Left Leg")
	if myRightLeg == nil or myLeftLeg == nil then return end
	damage = 25
	rightLegConnection = myRightLeg.Touched:connect(blow)
	leftLegConnection = myLeftLeg.Touched:connect(blow)
	if direction.magnitude > .01 then     
		print(2.2)
		direction = direction.unit 
		chargeBV = Instance.new("BodyVelocity") 
		chargeBV.P = 100000 
		chargeBV.maxForce = Vector3.new(chargeBV.P, 0, chargeBV.P) 
		chargeBV.velocity = direction * 50 
		chargeBV.Parent = myTorso 
		myTorso.CFrame = CFrame.new(myTorso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, myTorso.Position.Y, 0)) 
	end 
	wait(0.75)       
	if rightLegConnection then rightLegConnection:disconnect() end
	if leftLegConnection then leftLegConnection:disconnect() end
	if chargeBV ~= nil then chargeBV:Remove() end 
	wait(.5) 
	damage = 15
end

function spinKick()	
	if myHumanoid == nil or myTorso == nil then return end
	myLeftLeg = vCharacter:FindFirstChild("Left Leg")
	if myLeftLeg == nil then return end
	torsoFrames = {}
	spinKickAnim = myHumanoid:LoadAnimation(Tool.SpinKickAnim)		
	if spinKickAnim then spinKickAnim:Play()	end

	damage = 50
	
	-- Here, we are creating different frames of reference for our character's
	-- torso, so that we can rotate him 360 degrees. 6 steps of 60 deg each 
	torsoFrames[1] = myTorso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0)
	torsoFrames[2] = myTorso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0)
	torsoFrames[3] = myTorso.CFrame * CFrame.Angles(0, math.pi, 0)
	torsoFrames[4] = myTorso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0)
	torsoFrames[5] = myTorso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0)
	torsoFrames[6] = myTorso.CFrame

	-- Applying a force in the direction that we require on the body
	attackGyro = Instance.new("BodyGyro")
	attackGyro.P = 100000
	attackGyro.D = 3000
	attackGyro.maxTorque = Vector3.new(attackGyro.P, attackGyro.P, attackGyro.P)
	attackGyro.cframe = torsoFrames[1]
	attackGyro.Parent = myTorso
	wait(.4/3)
	attackGyro.cframe = torsoFrames[2]
	wait(.4/3)	
	myHumanoid.Jump = true
	leftLegConnection = myLeftLeg.Touched:connect(blow)	
	spinKickAnim:Play()
	attackGyro.cframe = torsoFrames[3]	
	wait(.4/3)
	attackGyro.cframe = torsoFrames[4]
	wait(.4/3)
	attackGyro.cframe = torsoFrames[5]
	wait(.4/3)
	attackGyro.cframe = torsoFrames[6]
	wait(.4/3)	
	if leftLegConnection then leftLegConnection:disconnect() leftLegConnection = nil end
	if attackGyro then  attackGyro:Remove() end
	damage = 15
	wait(.5)
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	vCharacter  = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false 		
		
	if attackType == 0 then
		potionAnim = myHumanoid:LoadAnimation(Tool.PotionAnim)
		if potionAnim then potionAnim:Play() end	
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.MaxHealth = 190                
		while myHumanoid.MaxHealth ~= 190 do print("1") myHumanoid.MaxHealth = 190 wait() end
		while myHumanoid.Health < ratio * myHumanoid.MaxHealth do 
			myHumanoid.Health = ratio * myHumanoid.MaxHealth 	
			wait()
		end
		wait(1.0)
		attackType = 1
	end
	Potion.Transparency = 1.0		
	if attackType == 1 then 
		flashKick()
	elseif attackType == 2 then 
		print(2)
		chargeKick() 
	elseif attackType == 3 then 
		spinKick()
	end

	wait(3.0)
	Potion.Transparency = 0.0	
	Tool.Enabled = true
end

function onEquipped(mouse)
	if mouse then 
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		
		mouse.KeyDown:connect(changeAttack)
	end
end

function onUnequipped()
	attackType = 0
	damage = 15
	if attackAnim then attackAnim:Stop() end
	Potion.Transparency = 0.0	
	if attackGyro then attackGyro:Remove() end
	if bodyPosition then bodyPosition:Remove() end
	if rightLegConnection then rightLegConnection:disconnect() end
	if leftLegConnection then leftLegConnection:disconnect() end
	if chargeBV then chargeBV:Remove() end
	--if potionAnim then potionAnim:Stop() end	
	print(myHumanoid, myHumanoid.MaxHealth)
	while myHumanoid.MaxHealth ~= 100 do myHumanoid.MaxHealth = 100 wait() end
	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.Health = ratio * 100 
		myHumanoid.MaxHealth = 100      	
	end 
	torsoFrames = {}
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)