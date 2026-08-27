local Tool = script.Parent

local broomMode = 1

function broomSetA()
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripPos = Vector3.new(1.5,-3.5,0)
	--Tool.GripPos = Vector3.new(10,10,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,-1)
end

function broomSetB()
	--Tool.GripForward = Vector3.new(0,0,-1)
	--Tool.GripPos = Vector3.new(-1.5,2,1)
	--Tool.GripRight = Vector3.new(1,0,0)
	--Tool.GripUp = Vector3.new(0,1,0)

	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripPos = Vector3.new(1.5,-3.5,0)
	Tool.GripRight = Vector3.new(0,0,1)
	Tool.GripUp = Vector3.new(1,0,0)
end

function broomReset()
	print("broom reset")
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripPos = Vector3.new(0,0,-1)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

broomReset()

Tool.Enabled = true
local started = false
function onActivated()
	vCharacter = Tool.Parent
	if vCharacter == nil then return end
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then return end
	
	if not Tool.Enabled or humanoid.Jump then return end
	Tool.Enabled = false
	started = true
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35886425"
		--  35889747  is witch cackle
		--  35886425 is flying noise
		magicSound.Name = "MagicSound"
	end
	magicSound:Play()
	
	if not started then wait(2) Tool.Enabled = true return end

	newBF = vCharacter.PrimaryPart:FindFirstChild("WitchLift")
	if newBF == nil then
		newBF = Instance.new("BodyPosition")
		newBF.position = vCharacter.PrimaryPart.Position + Vector3.new(0,20,0)
		newBF.Parent = vCharacter.PrimaryPart
		newBF.maxForce = Vector3.new(0, 10000, 0)
		newBF.P = 5000
		newBF.Name = "WitchLift"
		-- maxForce (vector), P(number), D(number)
	end
	--humanoid.Jump = true

	if not started then wait(2) Tool.Enabled = true return end

	wait(1)
	--newBF.maxForce = Vector3.new(30000,10000,30000)
	newBF.maxForce = Vector3.new(50000,30000,50000)
	--humanoid.Jump = true
	broomSetA()
	--broomMode = 1


	-- if started then Tool.Handle.CanCollide = false end

	if not started then wait(2) Tool.Enabled = true return end

	fakeBroom = Tool.Handle:Clone()
	Tool.Handle.Transparency = 1
	fakeBroom.Mesh.Scale = Vector3.new(2.2,2.2,2.2)
	fakeBroom.Parent = vCharacter
	fakeBroom.Name = "myBroom"
		
	broomWeld = Instance.new("Weld")
	broomWeld.Part0 = fakeBroom
	broomWeld.Part1 = vCharacter.Torso
	broomWeld.C0 = fakeBroom.CFrame:inverse()*vCharacter.Torso.CFrame
	broomWeld.Name = "BroomWeld"
	broomWeld.Parent = vCharacter

	if not started then wait(2) Tool.Enabled = true return end

	magicSound.Looped = true
	magicSound:Play()

	witchSound = Tool.Handle:FindFirstChild("WitchSound")
	if witchSound == nil then
		witchSound = Instance.new("Sound")
		witchSound.Parent = Tool.Handle
		witchSound.Volume = 1
		witchSound.SoundId = "http://www.roblox.com/asset/?id=35889747"
		witchSound.Name = "WitchSound"
	end
	witchSound.Looped = false
	witchSound:Play()

	local flightTime = 5 --5 seconds to start off with
	-- see if they have witchWand or witchCauldron or witchHat, in which case increase flight time
	if vPlayer.Backpack:FindFirstChild("WitchWand") ~= nil then flightTime = flightTime + 3 end
	if vPlayer.Backpack:FindFirstChild("WitchCauldron") ~= nil then flightTime = flightTime + 3 end
	if vCharacter:FindFirstChild("WhiteWitchHat") ~= nil then flightTime = flightTime + 5
	elseif vCharacter:FindFirstChild("WitchHat") ~= nil then flightTime = flightTime + 5 end

	if not started then wait(2) Tool.Enabled = true return end

	for i = 1, flightTime*10 do
		if humanoid ~= nil then humanoid.Jump = true end
			newBF = vCharacter.PrimaryPart:FindFirstChild("WitchLift")
			if newBF == nil then
				humanoid.Jump = true
				Tool.Enabled = true
				newBG = vCharacter.Torso:FindFirstChild("WitchWay")
				if newBG ~= nil then newBG.Parent = nil end
				return 
			end
		lookAt = humanoid.TargetPoint - vCharacter.PrimaryPart.Position
		if Tool.WitchGas.Value then 
			newBF.position = newBF.position + lookAt.unit*10 
			magicSound:Play()
		else magicSound:Stop()
		end

		--rightShoulder = vCharacter.Torso:FindFirstChild("Right Shoulder")
		--if rightShoulder ~= nil then
			--[[if rightShoulder.DesiredAngle < 3 and broomMode == 1 then
				broomMode = 0
				--broomSetB()
				rightShoulder.MaxVelocity = 0
				print("broomTwo")
			elseif rightShoulder.DesiredAngle > 3 and broomMode == 0 then
				broomMode = 1
				--broomSetA()
				print("broomOne")
				rightShoulder.MaxVelocity = 1
			end]]--
		--	rightShoulder.DesiredAngle = 3.14
		--	rightShoulder.MaxVelocity = 3.14
		--end

		wait(.1)

		--humanoid.Jump = true
		--humanoid.Parent.Torso.CFrame = CFrame.new(humanoid.Parent.Torso.Position, humanoid.Parent.Torso.Position + lookAt.unit)
		newBG = vCharacter.Torso:FindFirstChild("WitchWay")
		if newBG == nil then
			newBG = Instance.new("BodyGyro")
			newBG.Parent = vCharacter.Torso
			newBG.Name = "WitchWay"
			newBG.maxTorque = Vector3.new(50000,50000,50000)
		end
			newBG.cframe = CFrame.new(vCharacter.Torso.Position, vCharacter.Torso.Position + lookAt.unit)
	end 

	broomReset()

	newBG = vCharacter.Torso:FindFirstChild("WitchWay")
	if newBG ~= nil then newBG.Parent = nil end

	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then
		magicSound.Looped = false
		magicSound:Stop()
	end
	witchSound = Tool.Handle:FindFirstChild("WitchSound")
	if witchSound ~= nil then
		witchSound.Looped = false
		witchSound:Stop()
	end

	broomWeld = vCharacter:FindFirstChild("BroomWeld")
	if broomWeld ~= nil then
		broomWeld.Parent = nil
		fakeBroom.Parent = nil
	end
	fakeBroom = vCharacter:FindFirstChild("myBroom")
	if fakeBroom ~= nil then
		fakeBroom.Parent = nil
	end

	Tool.Handle.Transparency = 0

	Tool.Handle.CanCollide = true
	newBF.Parent = nil
	humanoid.Jump = true
	Tool.Enabled = true
end


function onEquipped()
	broomReset()
	--Tool.Handle.CanCollide = false
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35886425"
		--  35889747  is witch cackle
		--  35886425 is flying noise
		magicSound.Name = "MagicSound"
	end
	witchSound = Tool.Handle:FindFirstChild("WitchSound")
	if witchSound == nil then
		witchSound = Instance.new("Sound")
		witchSound.Parent = Tool.Handle
		witchSound.Volume = 1
		witchSound.SoundId = "http://www.roblox.com/asset/?id=35889747"
		witchSound.Name = "WitchSound"
	end
end

function onUnequipped()
		Tool.Handle.CanCollide = true
		started = false
		broomReset()
		broomWeld = vCharacter:FindFirstChild("BroomWeld")
		if broomWeld ~= nil then
			broomWeld.Parent = nil
		end
		fakeBroom = vCharacter:FindFirstChild("myBroom")
		if fakeBroom ~= nil then
			fakeBroom.Parent = nil
		end

		newBG = vCharacter.Torso:FindFirstChild("WitchWay")
		if newBG ~= nil then newBG.Parent = nil end
		magicSound = Tool.Handle:FindFirstChild("MagicSound")
		witchSound = Tool.Handle:FindFirstChild("WitchSound")
		if magicSound ~= nil then
			magicSound:Stop()
			magicSound.Parent = nil
		end
		if witchSound ~= nil then
			witchSound:Stop()
			witchSound.Parent = nil
		end
		newBF = vCharacter.PrimaryPart:FindFirstChild("WitchLift")
		if newBF ~= nil then newBF.Parent = nil end

		Tool.Handle.Transparency = 0
		Tool.Handle.CanCollide = true
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
