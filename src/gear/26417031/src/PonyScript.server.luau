local Tool = script.Parent

local neigh = Instance.new("Sound")
neigh.SoundId = "http://www.roblox.com/asset/?id=25697118"
neigh.Parent = Tool.Handle
neigh.Volume = 0.6

function makeRainbow(h, torso,rightLeg)

	redBrick = Instance.new("Part")

	lookVector = torso.CFrame.lookVector
	print(lookVector)
	lookAvg = math.abs(lookVector.x) + math.abs(lookVector.z)
	xLook = lookVector.x / lookAvg
	zLook = lookVector.z / lookAvg

	reflect = 0.2

	yellowBrick = Instance.new("Part")
	yellowBrick.Position = Vector3.new(torso.Position.x + xLook,torso.Position.y - rightLeg.Size.y,torso.Position.z + zLook)
	yellowBrick.BrickColor = BrickColor.new("Bright yellow")
	yellowBrick.Size = Vector3.new(5,1.2,2)
	yellowBrick.TopSurface = 0
	yellowBrick.BottomSurface = 0
	yellowBrick.Reflectance = reflect

	yayRainbow = Instance.new("Sparkles")
	yayRainbow.Parent = yellowBrick

	redBrick = Instance.new("Part")
	redBrick.Position = Vector3.new(yellowBrick.Position.x,yellowBrick.Position.y,yellowBrick.Position.z - 4)
	redBrick.BrickColor = BrickColor.new("Bright red")
	redBrick.Size = Vector3.new(5,1.2,2)
	redBrick.CFrame = CFrame.new(redBrick.Position,lookVector)
	redBrick.TopSurface = 0
	redBrick.BottomSurface = 0
	redBrick.Reflectance = reflect
	
	orangeBrick = Instance.new("Part")
	orangeBrick.Position = Vector3.new(yellowBrick.Position.x,yellowBrick.Position.y,yellowBrick.Position.z - 2)
	orangeBrick.BrickColor = BrickColor.new("Bright orange")
	orangeBrick.Size = Vector3.new(5,1.2,2)
	orangeBrick.TopSurface = 0
	orangeBrick.BottomSurface = 0
	orangeBrick.Reflectance = reflect

	greenBrick = Instance.new("Part")
	greenBrick.Position = Vector3.new(yellowBrick.Position.x,redBrick.Position.y,yellowBrick.Position.z + 2)
	greenBrick.BrickColor = BrickColor.new("Bright green")
	greenBrick.Size = Vector3.new(5,1.2,2)
	greenBrick.TopSurface = 0
	greenBrick.BottomSurface = 0
	greenBrick.Reflectance = reflect

	blueBrick = Instance.new("Part")
	blueBrick.Position = Vector3.new(yellowBrick.Position.x,yellowBrick.Position.y,yellowBrick.Position.z + 4)
	blueBrick.BrickColor = BrickColor.new("Bright blue")
	blueBrick.Size = Vector3.new(5,1.2,2)
	blueBrick.TopSurface = 0
	blueBrick.BottomSurface = 0
	blueBrick.Reflectance = reflect

	purpleBrick = Instance.new("Part")
	purpleBrick.Position = Vector3.new(yellowBrick.Position.x,yellowBrick.Position.y,yellowBrick.Position.z + 6)
	purpleBrick.BrickColor = BrickColor.new("Bright purple")
	purpleBrick.Size = Vector3.new(5,1.2,2)
	purpleBrick.TopSurface = 0
	purpleBrick.BottomSurface = 0
	purpleBrick.Reflectance = reflect

	h.Jump = true
	
	RedOrangeWeld = Instance.new("Weld")
	RedOrangeWeld.Parent = redBrick
	RedOrangeWeld.C0 = CFrame.new(0,0,2)
	RedOrangeWeld.Part0 = redBrick
	RedOrangeWeld.Part1 = orangeBrick

	OrangeYellowWeld = Instance.new("Weld")
	OrangeYellowWeld.Parent = orangeBrick
	OrangeYellowWeld.C0 = CFrame.new(0,0,2)
	OrangeYellowWeld.Part0 = orangeBrick
	OrangeYellowWeld.Part1 = yellowBrick

	YellowGreenWeld = Instance.new("Weld")
	YellowGreenWeld.Parent = yellowBrick
	YellowGreenWeld.C0 = CFrame.new(0,0,2)
	YellowGreenWeld.Part0 = yellowBrick
	YellowGreenWeld.Part1 = greenBrick

	GreenBlueWeld = Instance.new("Weld")
	GreenBlueWeld.Parent = greenBrick
	GreenBlueWeld.C0 = CFrame.new(0,0,2)
	GreenBlueWeld.Part0 = greenBrick
	GreenBlueWeld.Part1 = blueBrick

	BluePurpleWeld = Instance.new("Weld")
	BluePurpleWeld.Parent = blueBrick
	BluePurpleWeld.C0 = CFrame.new(0,0,2)
	BluePurpleWeld.Part0 = blueBrick
	BluePurpleWeld.Part1 = purpleBrick

	rainbowBlock = Instance.new("Model")
	redBrick.Parent = rainbowBlock
	orangeBrick.Parent = rainbowBlock
	yellowBrick.Parent = rainbowBlock
	greenBrick.Parent = rainbowBlock
	blueBrick.Parent = rainbowBlock
	purpleBrick.Parent = rainbowBlock
	rainbowBlock.Parent = game.Workspace

	rainbowMove(rainbowBlock,yellowBrick,torso,rightLeg)

end

function rainbowMove(rainbowBlock,yellowBrick,torso,rightLeg)

	wait(0.1)

	BodyPos = Instance.new("BodyPosition")
	BodyPos.position = Vector3.new(yellowBrick.Position.x, yellowBrick.Position.y + 20, yellowBrick.Position.z)
	BodyPos.P = 100000
	BodyPos.D = 95000
	BodyPos.maxForce = Vector3.new(0,100000,0)
	BodyPos.Parent = yellowBrick

	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.Parent = yellowBrick
	BodyGyro.cframe = yellowBrick.CFrame
	BodyGyro.maxTorque = Vector3.new(10000,10000,10000)
	BodyGyro.P = 10000
	BodyGyro.D = 500

	wait(3)

	lookVector = torso.CFrame.lookVector
	forceToUse = 2000
	force = Instance.new("BodyForce")
	force.force = Vector3.new(forceToUse * lookVector.x, 17000,forceToUse * lookVector.z)
	BodyPos:remove()
	force.Parent = yellowBrick
	wait(2)
	force.force = Vector3.new(-(forceToUse * lookVector.x), 17000,-(forceToUse * lookVector.z))
	wait(2)
	force.force = Vector3.new(0, 14000,0)
	wait(3)
	force:remove()
	wait(1)
	rainbowBlock:remove()

end

function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false
	
	neigh:Play()

	local h = Tool.Parent:FindFirstChild("Humanoid")
	if h ~= nil then
		torso = h.Parent:FindFirstChild("Torso") or h.Parent:FindFirstChild("UpperTorso")
		rightLeg = h.Parent:FindFirstChild("Right Leg") or h.Parent:FindFirstChild("RightUpperLeg")
	end

	makeRainbow(h,torso,rightLeg)

	Tool.Enabled = true

end

Tool.Activated:connect(onActivated)
