--Fixed by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

AtomoSound = Handle:WaitForChild("AtomoSound")

ToolGrip = CFrame.new(0, -0.300000012, -0.699999988, 1, -9.79685083e-016, 0, 0, 0, -1, 9.79685083e-016, 1, 0)

Tool.Grip = ToolGrip
Tool.Enabled = true

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function SpinParts()

	
	--local vParts = {Character:FindFirstChild("Torso"), Character:FindFirstChild("Left Arm"), Character:FindFirstChild("Right Arm"), Character:FindFirstChild("Left Leg"), Character:FindFirstChild("Right Leg")}
	--local startPos = {vParts[1].Position, vParts[2].Position, vParts[3].Position, vParts[4].Position, vParts[5].Position}
	--local startFrames = {vParts[1].CFrame, vParts[2].CFrame, vParts[3].CFrame, vParts[4].CFrame, vParts[5].CFram
	local vParts = {Torso, Head, Character:FindFirstChild("Left Arm"), Character:FindFirstChild("Right Arm"), Character:FindFirstChild("Left Leg"), Character:FindFirstChild("Right Leg")}

	for i = 2,#vParts do
		myPart = vParts[i]
		if myPart ~= nil then
			myPart.Transparency = 1
			myPart.CanCollide = false
		end
	end

	local clonedParts = {}

	--just need to add hats to dummy head	
	newHats = {}
	newHatTransforms = {}
	oldHats = {}
	charParts = Character:GetChildren()
	numHatsSoFar = 1
	for i = 1,#charParts do
		if charParts[i].className == "Hat" then
			myHat = charParts[i]
			newHandle = myHat.Handle:Clone()
			newHandle.Name = "Part"
			newHandle.Parent = Character
			newHats[numHatsSoFar] = newHandle
			oldHats[numHatsSoFar] = myHat.Handle

			--newHatTransforms[numHatsSoFar] = myHat.Handle.CFrame:inverse()*vParts[2].CFrame
			--newHatTransforms[numHatsSoFar] = myHat.Handle.CFrame*(vParts[2].CFrame:inverse())
			newHatTransforms[numHatsSoFar] = vParts[2].CFrame:inverse()*myHat.Handle.CFrame
			newHats[numHatsSoFar].Anchored = true

			myHat.Handle.Transparency = 1
			numHatsSoFar = numHatsSoFar + 1
		end
	end

--	for i = 1,#vParts do
	randAng = math.random()*2*math.pi
	for i = 2,#vParts do
		myPart = vParts[i]
		if myPart ~= nil then
			clonedParts[i] = myPart:Clone()
			clonedParts[i].Name = "Part"
			clonedParts[i].CanCollide = true
			clonedParts[i].Transparency = 0
			clonedParts[i].Parent = Character
			newBP = Instance.new("BodyPosition")
			newBP.Parent = clonedParts[i]
			newBP.position = vParts[1].Position+(i-1)*Vector3.new(0,1,0)+i*2*Vector3.new(math.sin(randAng+i/2), 0, math.cos(randAng+i/2))
		end
	end

	-- and one more for the Torso
	newBP = Instance.new("BodyPosition")
	newBP.Parent = vParts[1]
	newBP.position = vParts[1].Position+Vector3.new(0,6,0) -- was 6
	newBP.maxForce = Vector3.new(0,10000,0)

	myFace = Character.Head.face
	myFace.Parent = nil
	--oldFace = Character.Head.face
	--Character.Head.face.Texture = "http://www.roblox.com/asset/?id=0"

	--vParts[1].Name = "A"
	--vParts[2].Name = "B"
	vParts[3].Name = "C"
	vParts[4].Name = "D"
	vParts[5].Name = "E"
	vParts[6].Name = "F"
	--vParts[1].CFrame = vParts[1].CFrame + Vector3.new(0,10,0)
	
	-- float the limbs to the workspace
	vParts[3].Parent = Character.Parent
	vParts[4].Parent = Character.Parent
	vParts[5].Parent = Character.Parent
	vParts[6].Parent = Character.Parent

	
	for j = 1,20 do --1 to 20

		--below function will put hats on top of dummy head
		--do hat calcs first, for less lag there
			--if j <= 10 then clonedParts[2].BodyPosition.position = vParts[1].Position+Vector3.new(0,1,0)+4*Vector3.new(math.sin(randAng+1), 0, math.cos(randAng+1)) end
			--if j == 15 then vParts[1].BodyPosition.Parent = nil end
			--if j > 15 then clonedParts[2].BodyPosition.position = vParts[2].Position
			--elseif j > 10 then clonedParts[2].BodyPosition.position = vParts[1].Position+Vector3.new(0,2-j/10,0)+4*(2-j/10)*Vector3.new(math.sin(randAng+1), 0, math.cos(randAng+1)) end

		cloneHead = clonedParts[2]
		for i = 1,#newHats do
			--newHats[i].CFrame = CFrame.new(cloneHeadPos)*CFrame.Angles(0,0,0)
			--newHats[i].CFrame = newHatTransforms[i]*cloneHead.CFrame
			newHats[i].CFrame = cloneHead.CFrame*newHatTransforms[i]
		end

		randAng = randAng + .5
		for i = 2,#vParts do
			--randArg was here, and i went from 2 to #vParts
			if j <= 10 then clonedParts[i].BodyPosition.position = vParts[1].Position+(i-1)*Vector3.new(0,1,0)+i*2*Vector3.new(math.sin(randAng+i/2), 0, math.cos(randAng+i/2)) end
			if j == 15 and i == 2 then vParts[1].BodyPosition.Parent = nil end
			if j > 15 then clonedParts[i].BodyPosition.position = vParts[i].Position
			elseif j > 10 then clonedParts[i].BodyPosition.position = vParts[1].Position+(i-1)*Vector3.new(0,2-j/10,0)+i*2*(2-j/10)*Vector3.new(math.sin(randAng+i/2), 0, math.cos(randAng+i/2)) end
		end

		angle = 2*j*math.pi/5
		--Tool.GripRight = Vector3.new(math.cos(angle),math.sin(angle),0)
		--Tool.GripForward = Vector3.new(-math.sin(angle),math.cos(angle),0)
		Tool.GripRight = Vector3.new(math.cos(angle),0,-math.sin(angle))
		Tool.GripUp = Vector3.new(math.sin(angle),0,math.cos(angle))
		--if j <= 10 then Tool.GripPos = Vector3.new(0, 0.7, -.3+j/5+2) end
		if j <= 10 then Tool.GripPos = Vector3.new(0, 0.7, -.3+j/5+.6) end
		--if j > 10 then Tool.GripPos = Vector3.new(0,0.7-.1*(j-10),3.7-.3*(j-10)) end
		if j > 10 then Tool.GripPos = Vector3.new(0,0.7-.1*(j-10),2.3-.3*(j-10)) end

	wait(.05)

	end

		--if charParts[i].className == "CharacterMesh" then
			--for j = 1,#vParts do
				--if vParts[j].Name == tostring(charParts[i].BodyPart) then
					--charParts[i].BodyPart = clonedParts[j]
				--end
			--end
		--end
	--end

	--for i = 1, #charParts do
	--	if charParts[i].className == "CharacterMesh" then
	--		for j = 1, #vParts do
	--			if vParts[j].Name == tostring(charParts[i].BodyPart) then
	--				charParts[i].BodyPart = vParts[j]
	--			end
	--		end
	--	end
	--end

	--vParts[1].Name = "Head"
	--vParts[2].Name = "Torso"
	vParts[3].Name = "Left Arm"
	vParts[4].Name = "Right Arm"
	vParts[5].Name = "Left Leg"
	vParts[6].Name = "Right Leg"

	-- bring back mah limbs
	vParts[3].Parent = Character
	vParts[4].Parent = Character
	vParts[5].Parent = Character
	vParts[6].Parent = Character

	-- if right hand clone has stuff, transfer over to true right hand
	--[[grabbedStuff = clonedParts[4]:GetChildren()
	for i = 1,#grabbedStuff do
		if (grabbedStuff[i].Name == "RightGrip") then 
			grabbedStuff[i].Part0 = vParts[4]
			grabbedStuff[i].Parent = vParts[4]
		end
	end]]

	for i = 2,#vParts do
		clonedParts[i].Parent = nil
	end

	for i = 1,#vParts do
		vParts[i].Transparency = 0
		vParts[i].CanCollide = true
	end
	myFace.Parent = Character.Head -- put back face
	for i = 1,#newHats do
		newHats[i].Parent = nil
	end
	for i = 1,#oldHats do
		oldHats[i].Transparency = 0
	end
end


function AtomSpin()
	for i = 1, 20 do
		local Angle = (i * math.pi / 5)
		Tool.GripRight = Vector3.new(math.cos(Angle), math.sin(Angle), 0)
		Tool.GripForward = Vector3.new(-math.sin(Angle), math.cos(Angle), 0)
		Tool.GripPos = Vector3.new(0, (-0.3 + i / 10), -0.7)
		wait(0.02)
	end
end

function Activated()
	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false
	
	local TargetPos = Humanoid.TargetPoint
	local LookAt = (TargetPos - Head.Position).unit

	local reload = 3
	
	AtomoSound:Play()

	AtomSpin()
	SpinParts()
	
	Tool.Grip = ToolGrip
	
	wait(ReloadTime)

	Tool.Enabled = true

end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Head or not Torso then
		return
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)