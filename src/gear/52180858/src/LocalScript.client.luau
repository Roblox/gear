-- HACKY SACK UMG -- 
local Tool = script.Parent
local HackySack = Tool.Handle

local vCharacter

local hackyAnim
local hackySound 

local sackClone 

local float = Instance.new("BodyForce")
float.force = Vector3.new(0.0, HackySack:GetMass() * 196.1, 0.0)


Tool.Enabled = true

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end

	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		return
	end

	myTorso.Anchored = true
	myHumanoid.Jump = true

	rightLeg = vCharacter:FindFirstChild("Right Leg")
	leftLeg = vCharacter:FindFirstChild("Left Leg")
	head = vCharacter:FindFirstChild("Head")
	
	hackySound = Tool:FindFirstChild("HackySound")
	hackyAnim = myHumanoid:LoadAnimation(Tool.HackyAnim)

	sackClone = HackySack:Clone()
	sackClone.CFrame = HackySack.CFrame
	HackySack.Transparency = 1.0

	floatOn = float:Clone()
	floatOn.Parent = sackClone

	sackClone.Parent = game.Workspace
	sackClone.CanCollide = false	

	if hackySound then hackySound:Play() end
	if hackyAnim then hackyAnim:Play() end
	
	sackClone.Velocity = ((rightLeg.Position + rightLeg.CFrame.lookVector * 1.4) - sackClone.Position).unit * 9.0
	wait(0.25)
	sackClone.Velocity = ((head.Position + head.CFrame.lookVector * 1.4) - sackClone.Position).unit * 9.0
	wait(0.45)
	sackClone.Velocity = ((leftLeg.Position + leftLeg.CFrame.lookVector * 1.0) - sackClone.Position).unit * 9.0
	wait(0.45)
	sackClone.Velocity = ((head.Position + head.CFrame.lookVector * 0.5) - sackClone.Position).unit * 10.5
	wait(0.45)
	sackClone.Velocity = ((head.Position + head.CFrame.lookVector * -1.5) - sackClone.Position).unit * 9.0
	wait(0.15)
	sackClone.Velocity = ((rightLeg.Position + rightLeg.CFrame.lookVector * -1.5) - sackClone.Position).unit * 9.0
	wait(0.4)
	sackClone.Velocity = ((leftLeg.Position + leftLeg.CFrame.lookVector * -1.7) - sackClone.Position).unit * 9.0
	wait(0.15)
	sackClone.Velocity = ((rightLeg.Position + rightLeg.CFrame.lookVector * -1.5) - sackClone.Position).unit * 9.0
	wait(0.15)
	sackClone.Velocity = ((head.Position + head.CFrame.lookVector * -1.5) - sackClone.Position).unit * 10.5
	wait(0.45)
	sackClone.Velocity = ((head.Position + head.CFrame.lookVector* 1.5) - sackClone.Position).unit * 9.0
	wait(0.15)
	sackClone.Velocity = ((leftLeg.Position + leftLeg.CFrame.lookVector * 1.5) - sackClone.Position).unit * 9.0
	wait(0.5)
	sackClone.Velocity = Vector3.new(0, 0, 0)
	wait(0.25)
	sackClone:Remove()	
	wait(2.0)
	Tool.Enabled = false
	if myTorso then myTorso.Anchored = false end

	--wait(5)
	HackySack.Transparency = 0.0
	if sackClone then sackClone:Remove() end
	if BV then BV:Remove() end
	Tool.Enabled = true 
end

function onEquipped()
	vCharacter = Tool.Parent
end

function onUnequipped()
	if hackySound then hackySound:Stop() end
	if hackyAnim then hackyAnim:Stop() end

	HackySack.Transparency = 0.0
	if sackClone then sackClone:Remove() end

	if vCharacter then vCharacter.Torso.Anchored = false end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)
