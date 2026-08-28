r = game:GetService("RunService")

local debris = game:GetService("Debris")

local Tool = script.Parent
local Ball = Tool.Handle

local vCharacter

Tool.Enabled = true

local ballAnim
local ballClone

local float = Instance.new("BodyForce") 
float.force = Vector3.new(0.0, Ball:GetMass() * 196.1, 0.0) 

local storedHumanoid = nil

local last_attack = 0 

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end

	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		return
	end

	parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - Vector3.new(10, 10, 10), myTorso.Position + Vector3.new(10, 10, 10)), vCharacter, 100)
	for i = 1, #parts do 
		tempChar = parts[i].Parent
		tempHumanoid = tempChar:FindFirstChild("Humanoid")
		if tempHumanoid then 
			storedHumanoid = tempHumanoid
		end
	end


	ballClone = Ball:Clone()
	ballClone.Parent = game.Workspace
	ballClone.CanCollide = false

	floatOn = float:Clone()
	floatOn.Parent = ballClone

	Ball.Transparency = 1.0
	
	if storedHumanoid ~= nil then 
		torso = storedHumanoid.Parent:FindFirstChild("Torso")
		distance = (torso.Position - ballClone.Position).magnitude
		ballClone.Velocity = (torso.Position - ballClone.Position).unit * distance * 2.0
		debris:AddItem(ballClone, 0.65)
		wait(0.65)
		Tool.Parent = storedHumanoid.Parent	
		storedHumanoid = nil
	else

		rightLeg = vCharacter:FindFirstChild("Right Leg")
		leftLeg = vCharacter:FindFirstChild("Left Leg")
		rightArm = vCharacter:FindFirstChild("Right Arm")
		leftArm = vCharacter:FindFirstChild("Left Arm")

		ballAnim = myHumanoid:LoadAnimation(Tool.BallAnim)
		if ballAnim then ballAnim:Play() end

		ballClone.Velocity = (((rightLeg.Position + rightLeg.CFrame.lookVector * 2.0) - ballClone.Position)).unit * 10.0
		wait(0.2)
		ballClone.Velocity = (rightArm.Position - ballClone.Position).unit * 10.0
		wait(0.15)
		ballClone.Velocity = (((rightLeg.Position + rightLeg.CFrame.lookVector * 2.0) - ballClone.Position)).unit * 10.0
		wait(0.15)
		ballClone.Velocity = (rightArm.Position - ballClone.Position).unit * 10.0
		wait(0.2)
		ballClone.Velocity = (((myTorso.Position + myTorso.CFrame.lookVector * - 2.0) + Vector3.new(0, -2, 0)) - ballClone.Position).unit * 10.0
		wait(0.35)
		ballClone.Velocity = (leftArm.Position - ballClone.Position).unit * 10.0
		wait(0.35)
		ballClone.Velocity = (((leftLeg.Position + leftLeg.CFrame.lookVector * 2.0) - ballClone.Position)).unit * 10.0
		wait(0.15)
		ballClone.Velocity = (leftArm.Position - ballClone.Position).unit * 10.0
		wait(0.2)
		ballClone.Velocity = (rightArm.Position - ballClone.Position).unit * 10.0
		wait(0.1)
		ballClone:Remove() 	
		Ball.Transparency = 0.0
	end

	wait(2.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if ballAnim then ballAnim:Stop() end
	if ballClone then ballClone:Remove() end
	Ball.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)