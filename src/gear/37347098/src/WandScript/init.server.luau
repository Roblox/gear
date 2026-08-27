local Tool = script.Parent

Tool.Enabled = true
function onActivated()
	vCharacter = Tool.Parent
	if not Tool.Enabled then return end
	Tool.Enabled = false
	--This call will cause a "wait" until the data comes back
	
	-- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35971258"
		magicSound.Name = "MagicSound"
	end
	magicSound:Play()

	wait(.5)
	rArm = vCharacter:FindFirstChild("Right Arm")
	if rArm == nil then return end
	armX = rArm.Position.X
	armY = rArm.Position.Y
	armZ = rArm.Position.Z

	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then return end
	lookAt = (humanoid.TargetPoint - rArm.Position).unit

	for i = -1,1 do
		nextPart = Instance.new("Part")
		nextPart.Name = "WitchMagic"
		nextPart.CanCollide = false
		nextPart.Color = Color3.new(0,1,0)
		nextPart.CFrame = CFrame.new(armX+2*i,armY,armZ)
		nextPart.Size = Vector3.new(.5,.5,.5)
		nextPart.Parent = game.Workspace
		nextPart.Velocity = Vector3.new(i*10, 0, 0)
		nextPart.RotVelocity = 50*Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)
		nextPart.BottomSurface = "Smooth"
		nextPart.TopSurface = "Smooth"

		newBF = Instance.new("BodyVelocity")
		--newBF.velocity = 10*vCharacter.Torso.CFrame:vectorToWorldSpace(Vector3.new(0,0,-1))
		newBF.velocity = 10*lookAt
		newBF.Parent = nextPart
		newBF.Name = "MagicGuider"

		newBlast = script:FindFirstChild("BlastScript"):Clone()
		newBlast.Parent = nextPart
		newBlast.Disabled = false

		if (i ~= 0) then

		nextPart = Instance.new("Part")
		nextPart.Name = "WitchMagic"
		nextPart.CanCollide = false
		nextPart.Color = Color3.new(0,1,0)
		nextPart.CFrame = CFrame.new(armX,armY+2*i,armZ)
		nextPart.Size = Vector3.new(.5,.5,.5)
		nextPart.Parent = game.Workspace
		nextPart.Velocity = Vector3.new(0, i*10, 0)
		nextPart.RotVelocity = 50*Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)
		nextPart.BottomSurface = "Smooth"
		nextPart.TopSurface = "Smooth"

		newBF = Instance.new("BodyVelocity")
		--newBF.velocity = 10*vCharacter.Torso.CFrame:vectorToWorldSpace(Vector3.new(0,0,-1))
		newBF.velocity = 10*lookAt
		newBF.Parent = nextPart
		newBF.Name = "MagicGuider"

		newBlast = script:FindFirstChild("BlastScript"):Clone()
		newBlast.Parent = nextPart
		newBlast.Disabled = false

		nextPart = Instance.new("Part")
		nextPart.Name = "WitchMagic"
		nextPart.CanCollide = false
		nextPart.Color = Color3.new(0,1,0)
		nextPart.CFrame = CFrame.new(armX,armY,armZ+2*i)
		nextPart.Size = Vector3.new(.5,.5,.5)
		nextPart.Parent = game.Workspace
		nextPart.Velocity = Vector3.new(0, 0, i*10)
		nextPart.RotVelocity = 50*Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)
		nextPart.BottomSurface = "Smooth"
		nextPart.TopSurface = "Smooth"

		newBF = Instance.new("BodyVelocity")
		--newBF.velocity = 10*vCharacter.Torso.CFrame:vectorToWorldSpace(Vector3.new(0,0,-1))
		newBF.velocity = 10*lookAt
		newBF.Parent = nextPart
		newBF.Name = "MagicGuider"

		newBlast = script:FindFirstChild("BlastScript"):Clone()
		newBlast.Parent = nextPart
		newBlast.Disabled = false

		end
	end

	--[[local root = game:GetService("InsertService"):LoadAsset(29100449)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	root = root:GetChildren()
	root = root[1]
	print(root)
	root.Parent = Tool.Parent
]]--
	wait(2.5)
	Tool.Enabled = true

end

function onEquipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35971258"
		magicSound.Name = "MagicSound"
	end

-- newt transform sound is 35971304 

end

function onUnequipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then
		magicSound:Stop()
		magicSound.Parent = nil
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
