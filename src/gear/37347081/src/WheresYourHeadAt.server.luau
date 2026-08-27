local Tool = script.Parent;

Tool.Enabled = true

function throwHead()
	local vCharacter = Tool.Parent
	-- animation is below
	-- http://www.roblox.com/Asset?ID=35154961

	headSound = Tool.Handle:FindFirstChild("HeadSound")
	if headSound == nil then
		headSound = Instance.new("Sound")
		headSound.Volume = 1
		headSound.Name = "HeadSound"
		headSound.SoundId = "http://www.roblox.com/asset/?id=35935204"
		headSound.Parent = Tool.Handle
	end
	headSound:Play()

	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then return end
	headshot = humanoid:LoadAnimation(Tool.headThrow)
	--Tool.DanceObject.Value = dancer
	headshot:Play()
	--Tool.Handle.SongLoop:Play()
	wait(2.65)
	--Tool.Handle.SongLoop:Stop()
	--root:remove()

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - vCharacter.Head.Position).unit

--[[function onEquipped()
	Tool.Handle.EquipSound:play()
end

function onUnequipped()
	Tool.Handle.EquipSound:stop()
	if dancer ~= nil then
		dancer:Stop()
		dancer:remove()
	end
end]]--


	-- first we make a fake head and make the real head (and all accompanying accoutrements) disappear
	realHead = vCharacter:FindFirstChild("Head")
	if realHead == nil then return end
	realHead.Transparency = 1
	realHead.CanCollide = false

	fakeHead = realHead:Clone()
	--fakeHead.CanCollide = true --for starters we keep it false, to avoid weird self-collisions
	fakeHead.CanCollide = false
	fakeHead.Transparency = 0
	--fakeHead.Parent = vCharacter
	fakeHead.Parent = vCharacter.Parent
	--fakeHead.Name = "ZOMGITHREWMYHEADATYOU!"

	-- temporarily turn off collision with parts involved in the throwing, so we don't get weird behavior
	--vCharacter.Torso.CanCollide = false
	--rightArm = vCharacter:FindFirstChild("Right Arm")
	--if rightArm ~= nil then rightArm.CanCollide = false end
	--if Tool ~= nil then
		--if Tool.Handle ~= nil then
			--Tool.Handle.CanCollide = false
		--end
	--end
	
	newHats = {}
	newHatTransforms = {}
	oldHats = {}
	
	numHatsSoFar = 1
	charParts = vCharacter:GetChildren()
	for i = 1,#charParts do
		if charParts[i].className == "Hat" then
			myHat = charParts[i]
			myHat = charParts[i]
			newHandle = myHat.Handle:Clone()
			--newHandle.Parent = vCharacter
			newHandle.Parent = vCharacter.Parent
			newHats[numHatsSoFar] = newHandle
			oldHats[numHatsSoFar] = myHat.Handle

			--newHatTransforms[numHatsSoFar] = myHat.Handle.CFrame:inverse()*vParts[2].CFrame
			--newHatTransforms[numHatsSoFar] = myHat.Handle.CFrame*(vParts[2].CFrame:inverse())
			newHatTransforms[numHatsSoFar] = realHead.CFrame:inverse()*myHat.Handle.CFrame
			newHats[numHatsSoFar].Anchored = true

			myHat.Handle.Transparency = 1
			numHatsSoFar = numHatsSoFar + 1
		end
	end


	--myFace = vCharacter.Head.face -- make face go away
	--myFace.Parent = nil
	myFace = vCharacter.Head:FindFirstChild("face")
	if myFace ~= nil then myFace.Parent = nil end

	-- make head FLYYY
	--throwHeadHere(lookAt)
	--wait(2)
	
	boom = Instance.new("BodyForce")
	boom.force = Vector3.new(0,fakeHead:GetMass()*190,0)
	boom.Parent = fakeHead
	fakeHead.Velocity = lookAt*30
	fakeHead.RotVelocity = Vector3.new(10*(math.random()-.5), 10*(math.random()-.5), 10*(math.random()-.5))

	
	for i = 1,5 do
		for j = 1, #newHats do
			newHats[j].CFrame = fakeHead.CFrame*newHatTransforms[j]
			newHats[j].Velocity = fakeHead.Velocity
			newHats[j].RotVelocity = fakeHead.RotVelocity
		end
		wait(.05)
	end

	-- turn back on collision with throwing parts after .5 seconds (can probably cut this down to like .2 seconds)
	--vCharacter.Torso.CanCollide = true
	--rightArm = vCharacter:FindFirstChild("Right Arm")
	--if rightArm ~= nil then rightArm.CanCollide = true end
	--if Tool ~= nil then
		--if Tool.Handle ~= nil then
			--Tool.Handle.CanCollide = false
		--end
	--end

	fakeHead.CanCollide = true --might not want to have this in here, since this means head can pick up items?!

	for i = 6,80 do
		for j = 1, #newHats do
			newHats[j].CFrame = fakeHead.CFrame*newHatTransforms[j]
			newHats[j].Velocity = fakeHead.Velocity
			newHats[j].RotVelocity = fakeHead.RotVelocity
		end
		wait(.05)
	end

--	headshot = script.headScript:Clone()
--	headshot.Parent = fakeHead
--
--	headTransform = Instance.new("CFrameValue")
--	headTransform.Value = 

	-- reset to normal
	fakeHead.Parent = nil -- make fake head disappear
	for i = 1,#newHats do
		newHats[i].Parent = nil -- make fake hats disappear
	end
	for i = 1,#oldHats do
		oldHats[i].Transparency = 0  -- make real hats reappear
	end

	if myFace ~= nil then myFace.Parent = vCharacter.Head end -- put back face on real head
	realHead.Transparency = 0

	headshot:Stop()
	headshot:remove()
end


function gunUp()
	Tool.GripForward = Vector3.new(0,.981,-.196)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,.196,.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
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

	local reload = .5

	gunUp()
	throwHead()
	wait(reload)
	gunOut()
	wait(reload)

	Tool.Enabled = true
end

function onEquipped()
	headSound = Tool.Handle:FindFirstChild("HeadSound")
	if headSound == nil then
		headSound = Instance.new("Sound")
		headSound.Volume = 1
		headSound.Name = "HeadSound"
		headSound.SoundId = "http://www.roblox.com/asset/?id=35935204"
		headSound.Parent = Tool.Handle
	end
end

function onUnequipped()
	headSound = Tool.Handle:FindFirstChild("HeadSound")
	if headSound ~= nil then headSound.Parent = nil end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
