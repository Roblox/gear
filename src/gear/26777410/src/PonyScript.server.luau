local Tool = script.Parent
local platforming = false
local BodyPos = nil
local force = nil
local moving = true

local neigh = Instance.new("Sound")
neigh.SoundId = "http://www.roblox.com/asset/?id=26415782"
neigh.Parent = Tool.Handle
neigh.Volume = 0.6

function makeRainbow(h, torso,rightLeg)

	lookVector = torso.CFrame.lookVector
	print(lookVector)
	lookAvg = math.abs(lookVector.x) + math.abs(lookVector.z)
	xLook = lookVector.x / lookAvg
	zLook = lookVector.z / lookAvg
	

	--This call will cause a "wait" until the data comes back
		local root = game:GetService("InsertService"):LoadAsset(26415955)

		local instances = root:GetChildren()
		if #instances == 0 then
			root:Remove()
			return
		end


		platform = root:FindFirstChild("Part",true)
		
		spikes = root:FindFirstChild("spikes",true)
		spikes = spikes:GetChildren()
		spiker = script.Parent.SpikeScript

		for i =1, #spikes do
			
			newSpikeScript = spiker:clone()
			newSpikeScript.Parent = spikes[i]
			newSpikeScript.Disabled = false

			welder = Instance.new("Weld")
			welder.Parent = spikes[i]
			welder.C0 = CFrame.new(spikes[i].Position.x - platform.Position.x,-2,spikes[i].Position.z - platform.Position.z) * CFrame.Angles(0,0,math.pi)
			welder.Part0 = spikes[i]
			welder.Part1 = platform
			spikes[i].CanCollide = false
			spikes[i].Owner.Value = h.Parent.Name

		end

		platform.Position = Vector3.new(torso.Position.x + xLook,torso.Position.y - rightLeg.Size.y,torso.Position.z + zLook)

		root.Parent = game.Workspace

		if moving == true then

			BodyPos = Instance.new("BodyPosition")
			BodyPos.position = platform.Position
			BodyPos.P = 100000
			BodyPos.D = 95000
			BodyPos.maxForce = Vector3.new(0,100000,0)
			BodyPos.Parent = platform

			BodyGyro = Instance.new("BodyGyro")
			BodyGyro.Parent = platform
			BodyGyro.cframe = platform.CFrame
			BodyGyro.maxTorque = Vector3.new(1000000,1000000,1000000)
			BodyGyro.P = 1000000
			BodyGyro.D = 5000

			wait(1)

			BodyPos:remove()

			rainbowMove(platform)

		end

end

function pwnyUp()

	Tool.GripForward = Vector3.new(-0.302,0.905,-0.302)
	Tool.GripRight = Vector3.new(0.816,0.408,0.408)
	Tool.GripUp = Vector3.new(-0.492,0.123,0.862)

end

function pwnyNorm()

	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)

end

function rainbowMove(rainbowBlock)

	wait(0.1)

	if moving == true then
		BodyPos = Instance.new("BodyPosition")
		BodyPos.position = Vector3.new(rainbowBlock.Position.x, rainbowBlock.Position.y + 15, rainbowBlock.Position.z)
		BodyPos.P = 1000000
		BodyPos.D = 950000
		BodyPos.maxForce = Vector3.new(0,1000000,0)
		BodyPos.Parent = rainbowBlock
	end

	wait(3)

	if moving == true then
		lookVector = torso.CFrame.lookVector
		forceToUse = 20000
		force = Instance.new("BodyForce")
		force.force = Vector3.new(forceToUse * lookVector.x, 80000,forceToUse * lookVector.z)
		BodyPos:remove()
		force.Parent = rainbowBlock
		wait(2)
		force.force = Vector3.new(-(forceToUse * lookVector.x), 80000,-(forceToUse * lookVector.z))
		wait(2)
		force.force = Vector3.new(0, 59000,0)
		wait(3)
		force:remove()
		wait(1)
	else
		wait(8)
	end
	if rainbowBlock ~= nil and rainbowBlock.Parent ~= nil and rainbowBlock.Parent.Parent ~= nil then
		rainbowBlock.Parent.Parent:remove()
	end
	moving = true

end

function dropPlatform()

	moving = false
	if BodyPos ~= nil then
		BodyPos.Parent = nil
	end
	if force ~= nil then
		force.Parent = nil
	end

end

function onActivated()

	if not Tool.Enabled then
		if platforming == true then
			dropPlatform()
		end
		return
	end

	Tool.Enabled = false
	
	neigh:Play()
	pwnyUp()
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if h ~= nil then
		torso = h.Parent:FindFirstChild("Torso") or h.Parent:FindFirstChild("UpperTorso")
		rightLeg = h.Parent:FindFirstChild("Right Leg") or h.Parent:FindFirstChild("RightUpperLeg")
	else
		return
	end
	wait(0.5)
	pwnyNorm()
	platforming = true
	makeRainbow(h,torso,rightLeg)
	platforming = false

	Tool.Enabled = true

end

Tool.Activated:connect(onActivated)
