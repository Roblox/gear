local Tool = script.Parent;

Tool.Enabled = true

local rocketSmoke = Instance.new("Smoke")
rocketSmoke.Color = Color3.new(.5,.5,.5)

local rocketFire = Instance.new("Fire")
rocketFire.Color = Color3.new(1,.3,0)
rocketFire.SecondaryColor = Color3.new(1,0,1)
rocketFire.Heat = 5

local realArm = nil
local fakeArm = nil

function throwArm(lookAt)
	local vCharacter = Tool.Parent
	realArm = vCharacter:FindFirstChild("Right Arm")
	if realArm == nil then return end
	fakeArm = realArm:Clone()
	fakeArm.Parent = vCharacter

	realArm.Transparency = 1
	realArm.Name = "Part"

	-- put roboarm on fake arm  (below loop is what is messing up CFrame assignment later on... stupid welds...)
	m = fakeArm:GetMass()
	grabbedStuff = realArm:GetChildren()
	
	for i = 1,#grabbedStuff do
		if (grabbedStuff[i].Name == "RightGrip") then 
			print("Transfering stuff to fake arm")
			grabbedStuff[i].Part0 = fakeArm
			grabbedStuff[i].Parent = fakeArm

			m = m + grabbedStuff[i].Part1:GetMass()
		end
	end

	print(vCharacter.PrimaryPart.Name)

	-- actually fire the arm away
	fakeArm.Velocity = Vector3.new(0,0,0)
	fakeArm.RotVelocity = Vector3.new(0,0,0)
	newBF = Instance.new("BodyForce")
	--newBF.force = Vector3.new(0,196*fakeArm:GetMass(), 0)
	newBF.force = Vector3.new(0,196*m, 0)
	newBF.Parent = fakeArm
	-- add smoke&fire here
	-- cFrame.Angles(pitch, roll, yaw) for the arm
	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then return end
	--fakeArm.CFrame = CFrame.new(fakeArm.Position)*CFrame.new(Vector3.new(0,0,0), lookAt)*CFrame.Angles(math.pi/2,0,0) is ending point
	--fakeArm.CFrame = CFrame.new(fakeArm.Position)*CFrame.new(Vector3.new(0,0,0), Vector3.new(0,0,1))*CFrame.Angles(math.pi/2, 0, 0) is starting point...
	
	newSmoke = rocketSmoke:Clone()
	newSmoke.Parent = fakeArm

	local numSteps = 20
	--currVect = Vector3.new(0,0,1)
	if fakeArm ~= nil then 
		currVect = fakeArm.CFrame:vectorToWorldSpace(Vector3.new(0,-1,0))
		lookStep = (lookAt - currVect)/numSteps
	end
	print(currVect)
	print(lookAt)
	print(lookStep)
	for i = 1,numSteps do
		if fakeArm == nil then return
		else
			currVect = currVect + lookStep
			fakeArm.CFrame = CFrame.new(fakeArm.Position)*CFrame.new(Vector3.new(0,0,0), currVect)*CFrame.Angles(math.pi/2, 0, 0)
			--fakeArm.CFrame = CFrame.new(fakeArm.Position, realArm.CFrame*currVect)
			--fakeArm.CFrame = realArm.CFrame*CFrame.new(Vector3.new(0,0,0), currVect)
			wait(1/numSteps)
		end
	end
	--wait(1)

	rsound = Tool.Parent:FindFirstChild("RocketSound")
	if rsound == nil then
		rsound = Instance.new("Sound")
		rsound.Name = "RocketSound"
		rsound.Volume = .5
		rsound.SoundId = "http://www.roblox.com/asset/?id=32791582"
		rsound.Parent = Tool.Parent
	end
	
	rsound:Play()


	newFire = rocketFire:Clone()
	newFire.Parent = fakeArm

	--newBF.force = Vector3.new(0, 196*fakeArm:GetMass(),0) + lookAt*fakeArm:GetMass()*5
	newBF.force = Vector3.new(0, 196*m,0) + lookAt*m*5
	wait(1)
	rsound:Play()
	--newBF.force = Vector3.new(0, 196*fakeArm:GetMass(),0) + lookAt*fakeArm:GetMass()*30
	newBF.force = Vector3.new(0, 196*m,0) + lookAt*m*30
	wait(1)
	--newBF.force = Vector3.new(0, 196*fakeArm:GetMass(),0) + lookAt*fakeArm:GetMass()*180
	newBF.force = Vector3.new(0, 196*m,0) + lookAt*m*180
	wait(1)

	-- put things back
	--if realArm == nil then realArm = vCharacter:FindFirstChild("Right Arm") end
	if realArm == nil then return end
	realArm.Name = "Right Arm"
	realArm.Transparency = 0
	if fakeArm ~= nil then 
		grabbedStuff = fakeArm:GetChildren()
		for i = 1,#grabbedStuff do
			if (grabbedStuff[i].Name == "RightGrip") then 
				print("Grabbed Something")
				--grabbedStuff[i]:Clone().Parent = realArm 
				grabbedStuff[i].Part0 = realArm
				grabbedStuff[i].Parent = realArm
			end
		end
		fakeArm.Parent = nil
		fakeArm = nil
	end
end


function gunUp()
	drill = Tool.Parent:FindFirstChild("DrillSound")
	if drill == nil then
		drill = Instance.new("Sound")
		drill.Name = "DrillSound"
		drill.SoundId = "http://www.roblox.com/asset/?id=35275806"
		drill.Parent = Tool.Parent
		drill.Volume = .5
	end

	drill:Play()

	for i = 1,20 do
		angle = i*math.pi/5
		Tool.GripRight = Vector3.new(math.cos(angle),0,math.sin(angle))
		Tool.GripUp = Vector3.new(-math.sin(angle),0,math.cos(angle))
		wait(.04)
	end
end

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = 2

	gunUp()
	throwArm(lookAt)
	wait(reload)

	Tool.Enabled = true
end


function onUnequipped()
	local vCharacter = Tool.Parent
	if fakeArm ~= nil then
		--need to clean up
		grabbedStuff = fakeArm:GetChildren()
		--if realArm == nil then realArm = vCharacter:FindFirstChild("Right Arm") end
		if realArm == nil then return end
		for i = 1,#grabbedStuff do
			if (grabbedStuff[i].Name == "RightGrip") then 
				print("Grabbed Something")
				--grabbedStuff[i]:Clone().Parent = realArm 
				grabbedStuff[i].Part0 = realArm
				grabbedStuff[i].Parent = realArm
			end
		end
		if fakeArm ~= nil then fakeArm.Parent = nil end
		fakeArm = nil
		realArm.Name = "Right Arm"
		realArm.Transparency = 0
	end
end


script.Parent.Activated:connect(onActivated)
script.Parent.Unequipped:connect(onUnequipped)
