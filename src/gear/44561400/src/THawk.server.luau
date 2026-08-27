local Tool = script.Parent;

Tool.Enabled = true


local chFace = nil
local trollWeld = nil
local headWeld = nil
local hatHandleList = nil
local transparencyList = nil
local closestHead = nil

function onActivated()
	if not Tool.Enabled  then
		return
	end

	local character = Tool.Parent;
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	Tool.Enabled = false

	local targetPos = humanoid.TargetPoint
	--local lookAt = (targetPos - character.Head.Position).unit

	local playaz = game.Players:GetPlayers()
	local closestTarget = nil
	closestHead = nil
	local closestDistanceSq = 100
	for i = 1, #playaz do
		pChar = playaz[i].Character
		if pChar ~= nil and pChar ~= Tool.Parent then
			pHead = pChar:FindFirstChild("Head")
			if pHead ~= nil then
				if (pHead.Position-targetPos).magnitude < closestDistanceSq and pHead.Transparency <= 0 then
					closestTarget = pChar
					closestHead = pHead
					closestDistanceSq = (pHead.Position - targetPos):Dot(pHead.Position - targetPos)
				end
			end
		end
	end

	local reload = 15

	-- hahaha
	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then confettiBang.Volume = 1 confettiBang:Play() end
	

	-- make eyes burnnnn
	local leftEye = Instance.new("Part")
	leftEye.CanCollide = false
	--leftEye.Size = Vector3.new(0.001, 0.001, 0.001)
	--leftEye.Shape = 0
	--leftEye.Color = Color3.new(1, 0, 0)
	--leftEye.Material = "Grass"
	leftEye.Transparency = 1
	leftEye.Name = "LeftTrollEye"
	leftEye.Parent = Tool.Handle

	leftFire = Instance.new("Fire")
	leftFire.Size = .1
	leftFire.Heat = .1
	leftFire.Color = Color3.new(1, 0, 0)
	leftFire.SecondaryColor = Color3.new(1, 0, 1)
	leftFire.Parent = leftEye

	local rightEye = Instance.new("Part")
	rightEye.CanCollide = false
	--rightEye.Size = Vector3.new(0.001, 0.001, 0.001)
	--rightEye.Shape = 0
	--rightEye.Color = Color3.new(1, 0, 0)
	--rightEye.Material = "Grass"
	rightEye.Transparency = 1
	rightEye.Name = "RightTrollEye"
	rightEye.Parent = Tool.Handle

	rightFire = Instance.new("Fire")
	rightFire.Size = .1
	rightFire.Heat = .1
	rightFire.Color = Color3.new(1, 0, 0)
	rightFire.SecondaryColor = Color3.new(1, 0, 1)
	rightFire.Parent = rightEye

	local leftWeld = Instance.new("Weld")
	leftWeld.Part0 = Tool.Handle
	leftWeld.Part1 = leftEye
	leftWeld.C1 = CFrame.new() + Vector3.new(0.25, -0.45, 0.75)
	leftWeld.Parent = Tool.Handle


	local rightWeld = Instance.new("Weld")
	rightWeld.Part0 = Tool.Handle
	rightWeld.Part1 = rightEye
	rightWeld.C1 = CFrame.new() + Vector3.new(-.25, -0.45, 0.75)
	rightWeld.Parent = Tool.Handle

	wait(2)

	leftEye:remove()
	rightEye:remove()
	--leftWeld:remove()
	--rightWeld:remove()
	print('target',closestTarget)
	if closestTarget ~= nil then

		-- switch closestHead for handle
		--local newHead = closestHead:Clone()
		local newHead = Instance.new'Part'
		newHead.FormFactor='Custom'
		newHead.BrickColor = closestHead.BrickColor
		newHead.Size = closestHead.Size
		newHead.TopSurface = 0
		newHead.BottomSurface = 0
		newHead.CFrame = closestHead.CFrame
		for i,v in next, closestHead:GetChildren() do
			a=v:Clone()
			if a and not a:IsA'JointInstance' then
				a.Parent = newHead
			end
		end
		local newTroll = Tool.Handle:Clone()
		newHead.CanCollide = false
		newTroll.CanCollide = false

		newHead.Parent = game.Workspace
		--newTroll.Parent = game.Workspace
		newTroll.Name = "MagicTrollHead"
		newTroll.Parent = closestHead.Parent

		--local newTrollCleanupScript = script.TrollCleanupScript:Clone()
		--newTrollCleanupScript.Parent = closestHead
		--newTrollCleanupScript.Disabled = false

		chFace = closestHead:FindFirstChild("face")
		if chFace ~= nil then chFace.Parent = game.Lighting end
		closestHead.Transparency = 1
		Tool.Handle.Transparency = 1
		

		--newHead.CFrame = newHead.CFrame - newHead.Position + Tool.Handle.Position
		newHead.CFrame = Tool.Handle.CFrame*CFrame.Angles(math.pi/2,0,0)
		--newTroll.CFrame = newTroll.CFrame - newTroll.Position + closestHead.Position + Vector3.new(0, .4, 0)
		newTroll.CFrame = closestHead.CFrame*CFrame.Angles(-math.pi/2,0,0) + Vector3.new(0, .4, 0)

		-- copy hats to new location
		local targetList = closestTarget:GetChildren()
		hatHandleList = {}
		transparencyList = {} -- in case user wears partially transparent hats
		for i = 1, #targetList do
			if targetList[i].className == "Hat" and targetList[i]:FindFirstChild("Handle") and targetList[i].Handle.Transparency < 1 then
				newHat = targetList[i].Handle:Clone()
				newHat.CFrame = newHead.CFrame*closestHead.CFrame:toObjectSpace(newHat.CFrame)
				newHat.CanCollide = false
				newHatWeld = Instance.new("Weld")
				newHatWeld.Part0 = newHat
				newHatWeld.Part1 = newHead
				newHatWeld.C1 = newHead.CFrame:inverse() * newHat.CFrame
				newHatWeld.Parent = newHead
				newHat.Parent = newHead
				table.insert(transparencyList, targetList[i].Handle.Transparency)
				table.insert(hatHandleList, targetList[i].Handle)
				targetList[i].Handle.Transparency = 1
			end
		end

		headWeld = Instance.new("Weld")
		headWeld.Part0 = newHead
		headWeld.Part1 = Tool.Handle
		headWeld.Name = "HeadWeld"
		headWeld.C1 = Tool.Handle.CFrame:inverse() * newHead.CFrame
		headWeld.Parent = Tool.Handle

		trollWeld = Instance.new("Weld")
		trollWeld.Part0 = newTroll
		trollWeld.Part1 = closestHead
		trollWeld.Name = "MagicTrollWeld"
		trollWeld.C1 = closestHead.CFrame:inverse() * newTroll.CFrame
		trollWeld.Parent = closestHead

		wait(reload)

		for i = 1, #hatHandleList do
			if hatHandleList[i] ~= nil then
				hatHandleList[i].Transparency = transparencyList[i]
			end
		end

		headWeld:remove()
		trollWeld:remove()
		closestHead.Transparency = 0
		Tool.Handle.Transparency = 0
		if chFace ~= nil then chFace.Parent = closestHead end

		confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
		if confettiBang ~= nil then confettiBang.Volume = 0 end

	end

	wait(1)

	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end

function onUnequipped()
	if closestHead ~= nil then closestHead.Transparency = 0 end
	if trollWeld ~= nil then trollWeld:remove() end
	if headWeld ~= nil then headWeld:remove() end

	if hatHandleList ~= nil and transparencyList ~= nil then
		for i = 1, #hatHandleList do
			if hatHandleList[i] ~= nil then
				hatHandleList[i].Transparency = transparencyList[i]
			end
		end
	end
	if chFace ~= nil then
		chFace.Parent = closestHead
	end

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang then confettiBang.Volume = 0 end
	
	script.Parent.Handle.Transparency = 0
end

script.Parent.Activated:connect(onActivated)
script.Parent.Unequipped:connect(onUnequipped)

