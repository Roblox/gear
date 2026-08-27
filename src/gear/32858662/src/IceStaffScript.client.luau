local Tool = script.Parent
local debris =game:GetService("Debris")
local keyDown = nil

local gui = nil
local selection = 1
local down = false
local positions = {UDim2.new(0, 25, 1, -150),UDim2.new(0, 25, 1, -100),UDim2.new(0, 25, 1, -50)}

local iceVaporStream = false
local iceVaporRing = false

local humanoid = nil
local torso = nil
local head = nil

local wallWidth = 60
local wallHeight = 25
local brickSpeed = 0.01

local brickWidth = 6
local brickHeight = 4
local brickDepth = 2

local iceVaporStreamAnim = nil
local iceVaporRingAnim = nil
local iceVaporWallAnim = nil

local shieldSound = Instance.new("Sound")
shieldSound.SoundId = "http://www.roblox.com/asset/?id=32788850"
shieldSound.Parent = Tool.Handle

local stormSound = Instance.new("Sound")
stormSound.SoundId = "http://www.roblox.com/asset/?id=32788951"
stormSound.Parent = Tool.Handle

local burnSound = Instance.new("Sound")
burnSound.SoundId = "http://www.roblox.com/asset/?id=32788904"
burnSound.Parent = Tool.Handle

local iceVapor = Instance.new("Part")
iceVapor.Name = "IceVapor"
iceVapor.Transparency = 1
iceVapor.CanCollide = false
iceVapor.Anchored = false
iceVapor.Shape = 0
iceVapor.formFactor = 0
iceVapor.Size = Vector3.new(7,7,7)

local iceVaporParticles = Instance.new("Fire")
iceVaporParticles.Parent = iceVapor
iceVaporParticles.Color = Color3.new(51/255,154/255,1)
iceVaporParticles.SecondaryColor = Color3.new(0,0,112/255)
iceVaporParticles.Heat = -7
iceVaporParticles.Size = 10

local script = Tool.IceScript:clone()
script.Parent = iceVapor

function onEquippedLocal(mouse)

	iceVapor.Name = Tool.Parent.Name .. " iceVapor"
	keyDown = mouse.KeyDown:connect(onKeyDown)
	buttonDown = mouse.Button1Down:connect(onActivated)

	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	torso = Tool.Parent:FindFirstChild("Torso")
	head = Tool.Parent:FindFirstChild("Head")

	gui = Tool.IceStaffGui:clone()
	gui.Parent = game.Players:GetPlayerFromCharacter(Tool.Parent).PlayerGui

	iceVaporStreamAnim = humanoid:LoadAnimation(Tool.firecast)
	iceVaporRingAnim = humanoid:LoadAnimation(Tool.firering)
	iceVaporWallAnim = humanoid:LoadAnimation(Tool.firewall)

	if Tool.Reload.Value > 0 then reloadTime(Tool.Reload.Value) end

end

Tool.Equipped:connect(onEquippedLocal)



function onUnequippedLocal()
	
	if keyDown then keyDown:disconnect() end
	if gui then gui:remove() end
	gui = nil
	selection = 1

	if iceVaporStreamAnim then
		iceVaporStreamAnim:Stop()
		iceVaporStreamAnim:remove()
		iceVaporStreamAnim = nil
	end

	if iceVaporRingAnim then
		iceVaporRingAnim:Stop()
		iceVaporRingAnim:remove()
		iceVaporRingAnim = nil
	end

	if iceVaporWallAnim then
		iceVaporWallAnim:Stop()
		iceVaporWallAnim:remove()
		iceVaporWallAnim = nil
	end

	head.Anchored = false
end

Tool.Unequipped:connect(onUnequippedLocal)

local smoothness = 15
local barSize = 160
local reloading = false
function reloadTime(time)
	reloading = true

	gui.ReloadText.ReloadBar.Size = UDim2.new(0,25,0,0)
	gui.ReloadText.ReloadBar.Position = UDim2.new(0,0,0,160)
	gui.ReloadText.Visible = true
	local step = barSize/time
	local smallStep = step/smoothness
	Tool.Reload.Value = time
	for i = 1, time do
		if gui == nil then return end
		local size = gui.ReloadText.ReloadBar.Size.Y.Offset
		local pos = gui.ReloadText.ReloadBar.Position.Y.Offset
		for j = 1, smoothness do
			if gui == nil then return end
			size = size + smallStep
			pos = pos - smallStep
			gui.ReloadText.ReloadBar.Size = UDim2.new(0,25,0,size)
			gui.ReloadText.ReloadBar.Position = UDim2.new(0,0,0,pos)
			if gui.ReloadText.ReloadBar.Position.Y.Offset < 0 then break end
			wait(1/smoothness)
		end
		Tool.Reload.Value = time - i
	end
	Tool.Reload.Value = 0
	gui.ReloadText.Visible = false
	reloading = false
end

local enabled = false
function onActivated()

	if enabled  or reloading then return end
	enabled = true

	local v = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit

	if selection == 1 then
		iceVaporStreamAnim:Play()
		burnSound:Play()
		freezeBurn()
		reloadTime(8)
	elseif selection == 2 then
		iceVaporRingAnim:Play()
		shieldSound:Play()
		iceShield()
		reloadTime(19)
	elseif selection == 3 then
		iceVaporWallAnim:Play()
		stormSound:Play()
		snowStorm()
		reloadTime(12)
	end

	enabled = false

end

function freezeBurn()

	v = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit
	local dist = v * i
	dist = Vector3.new(torso.Position.x + dist.x,torso.Position.y + dist.y,torso.Position.z + dist.z)

	local fiery = iceVapor:clone()
	fiery.Position = dist
	fiery.Velocity = v * 100

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,35250,0)
	force.Parent = fiery

	fiery.Parent = game.Workspace
	fiery.IceScript.Disabled = false
	debris:AddItem(fiery,10)

end

function snowStorm()

	local radius = 50
	
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local numOfSparks = 16
	
	local increment = (math.pi *2)/numOfSparks

	torsoNormal = torso.CFrame.lookVector
	denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
	posX = radius * (torsoNormal.x/denom)
	posZ = radius * (torsoNormal.z/denom)
	local v = torso.Position
	local pos = Vector3.new(v.x + posX,v.y, v.z + posZ)

	for i = 1, numOfSparks do
	 
		local angle = increment * i
		local ice = iceVapor:clone()
		ice.Position = pos
		ice.Parent = game.Workspace
		local force = Instance.new("BodyForce")
		force.force = Vector3.new(0,35250,0)
		force.Parent = ice
		ice.Velocity = (pos - v).unit * -25
		pos = Vector3.new(((pos.x - v.x) * math.cos(angle)) - ((pos.z - v.z) * math.sin(angle)) + v.x, v.y,((pos.x - v.x) * math.sin(angle)) + ((pos.z - v.z) * math.cos(angle)) + v.z)
		debris:AddItem(ice,4)

	end
	wait(1)
	freezePlayers(v, radius)
	
end

function freezePlayers(v, radius)

	local players = game.Players:GetChildren()
	for i = 1, #players do
		local playerPos = players[i].Character.Torso.Position
		-- make sure player is on roughly the same plane
		if playerPos.y < v.y + 5 and playerPos.y > v.y - 5 and players[i].Character ~= torso.Parent then
			-- check to see if player is within x-z plane range
			local diff = Vector2.new(playerPos.x - v.x,playerPos.z - v.z)
			if diff.magnitude <= radius then
				local freezer = Tool.FreezeScript:clone()
				freezer.Parent = players[i].Character
				freezer.Disabled = false
			end
		end
	end

end

function unAnchor()
	head.Anchored = false
end

local shieldTime = 8
function iceShield()

	local gyro = Instance.new("BodyGyro")
	gyro.P = 10000
	gyro.D = 1000
	gyro.maxTorque = Vector3.new(gyro.P,gyro.P,gyro.P)

	local iceBlock = Tool.IceBlockScript:clone()
	iceBlock.Parent = Tool.Parent
	iceBlock.Disabled = false
	debris:AddItem(iceBlock,shieldTime)

	Tool.Parent.Head.Anchored = true

	-- bottom
	local bottom = Instance.new("Part")
	bottom.Name = "IceShieldBottom"
	bottom.Shape = 1
	bottom.BrickColor = BrickColor.new("Pastel Blue")
	bottom.Material = 1536
	bottom.BottomSurface = 0
	bottom.TopSurface = 0
	bottom.formFactor = 0
	bottom.CanCollide = false
	bottom.Size = Vector3.new(10,1,15)
	bottom.Position = Vector3.new(torso.Position.x,torso.Position.y - 10,torso.Position.z)
	bottom.CFrame = torso.CFrame
	local gOne = gyro:clone()
	gOne.cframe = bottom.CFrame
	gOne.Parent = bottom
	bottom.Touched:connect(function(part)
		if part.Parent == torso.Parent then
			wait(1)
			bottom.CanCollide = true
		elseif string.find("Fire",part.Name) then
			part:remove()
		end
	end)
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.position = Vector3.new(torso.Position.x,torso.Position.y - 2,torso.Position.z)
	bodyPos.P = 100000
	bodyPos.D = 10000
	bodyPos.maxForce = Vector3.new(bodyPos.P,bodyPos.P,bodyPos.P)
	bodyPos.Parent = bottom
	bottom.Parent = game.Workspace
	debris:AddItem(bottom,shieldTime)

	-- left
	local sideOne = Instance.new("Part")
	sideOne.Shape = 1
	sideOne.formFactor = 0
	sideOne.CanCollide = false
	sideOne.BrickColor = BrickColor.new("Pastel Blue")
	sideOne.Material = 1536
	sideOne.BottomSurface = 0
	sideOne.TopSurface = 0
	sideOne.Size = Vector3.new(2,9,15)
	local rightSide = torso.CFrame * CFrame.Angles(0,math.pi/2,0)
	sideOne.CFrame = torso.CFrame
	local gTwo = gyro:clone()
	gTwo.cframe = sideOne.CFrame
	gTwo.Parent = sideOne
	sideOne.Position = Vector3.new(torso.Position.x + (rightSide.lookVector.unit.x * 10),torso.Position.y,torso.Position.z + (rightSide.lookVector.unit.z * 10))
	local bp = bodyPos:clone()
	bp.position = Vector3.new(torso.Position.x + (rightSide.lookVector.unit.x * 5),torso.Position.y,torso.Position.z + (rightSide.lookVector.unit.z * 5))
	bp.Parent = sideOne
	sideOne.Parent = game.Workspace
	sideOne.Touched:connect(function(part)
		if part ==  bottom then
			wait(1)
			sideOne.CanCollide = true
		elseif string.find("Fire",part.Name) then
			part:remove()
		end
	end)
	debris:AddItem(sideOne,shieldTime)

	-- right
	local sideTwo = Instance.new("Part")
	sideTwo.Shape = 1
	sideTwo.formFactor = 0
	sideTwo.BrickColor = BrickColor.new("Pastel Blue")
	sideTwo.Material = 1536
	sideTwo.BottomSurface = 0
	sideTwo.TopSurface = 0
	sideTwo.CanCollide = false
	sideTwo.Size = Vector3.new(2,9,15)
	local leftSide = torso.CFrame * CFrame.Angles(0,-math.pi/2,0)
	sideTwo.CFrame = torso.CFrame
	local gThree = gyro:clone()
	gThree.cframe = sideTwo.CFrame
	gThree.Parent = sideTwo
	sideTwo.Position = Vector3.new(torso.Position.x + (leftSide.lookVector.unit.x * 10),torso.Position.y,torso.Position.z + (leftSide.lookVector.unit.z * 10))
	local bpTwo = bodyPos:clone()
	bpTwo.position = Vector3.new(torso.Position.x + (leftSide.lookVector.unit.x * 5),torso.Position.y,torso.Position.z + (leftSide.lookVector.unit.z * 5))
	bpTwo.Parent = sideTwo
	sideTwo.Parent = game.Workspace
	sideTwo.Touched:connect(function(part)
		if part ==  bottom then
			wait(1)
			sideTwo.CanCollide = true
		elseif string.find("Fire",part.Name) then
			part:remove()
		end
	end)
	debris:AddItem(sideTwo,shieldTime)

	-- front
	local frontSide = Instance.new("Part")
	frontSide.Shape = 1
	frontSide.formFactor = 0
	frontSide.BrickColor = BrickColor.new("Pastel Blue")
	frontSide.Material = 1536
	frontSide.BottomSurface = 0
	frontSide.TopSurface = 0
	frontSide.CanCollide = false
	frontSide.Size = Vector3.new(2,8,8)
	frontSide.CFrame = torso.CFrame * CFrame.Angles(0,math.pi/2,0)
	local gFour = gyro:clone()
	gFour.cframe = frontSide.CFrame
	gFour.Parent = frontSide
	frontSide.Position = Vector3.new(torso.Position.x + (torso.CFrame.lookVector.unit.x * 10),torso.Position.y,torso.Position.z + (torso.CFrame.lookVector.unit.z * 10))
	local bpThree = bodyPos:clone()
	bpThree.position = Vector3.new(torso.Position.x + (torso.CFrame.lookVector.unit.x * 5),torso.Position.y,torso.Position.z + (torso.CFrame.lookVector.unit.z * 5))
	bpThree.Parent = frontSide
	frontSide.Parent = game.Workspace
	frontSide.Touched:connect(function(part)
		if part ==  bottom then
			wait(1)
			frontSide.CanCollide = true
		elseif string.find("Fire",part.Name) then
			part:remove()
		end
	end)
	debris:AddItem(frontSide,shieldTime)

	-- back
	local backSide = Instance.new("Part")
	backSide.Shape = 1
	backSide.formFactor = 0
	backSide.BrickColor = BrickColor.new("Pastel Blue")
	backSide.Material = 1536
	backSide.BottomSurface = 0
	backSide.TopSurface = 0
	backSide.CanCollide = false
	backSide.Size = Vector3.new(2,8,8)
	backSide.CFrame = torso.CFrame * CFrame.Angles(0,math.pi/2,0)
	local gFive = gyro:clone()
	gFive.cframe = backSide.CFrame
	gFive.Parent = backSide
	backSide.Position = Vector3.new(torso.Position.x - (torso.CFrame.lookVector.unit.x * 10),torso.Position.y,torso.Position.z - (torso.CFrame.lookVector.unit.z * 10))
	local bpFour = bodyPos:clone()
	bpFour.position = Vector3.new(torso.Position.x - (torso.CFrame.lookVector.unit.x * 5),torso.Position.y,torso.Position.z - (torso.CFrame.lookVector.unit.z * 5))
	bpFour.Parent = backSide
	backSide.Parent = game.Workspace
	backSide.Touched:connect(function(part)
		if part ==  bottom then
			wait(1)
			backSide.CanCollide = true
		elseif string.find("Fire",part.Name) then
			part:remove()
		end
	end)
	debris:AddItem(backSide,shieldTime)

	-- top
	local top = Instance.new("Part")
	top.Name = "IceShieldTop"
	top.Shape = 1
	top.formFactor = 0
	top.BrickColor = BrickColor.new("Pastel Blue")
	top.Material = 1536
	top.BottomSurface = 0
	top.TopSurface = 0
	top.Size = Vector3.new(10,1,15)
	top.CFrame = torso.CFrame
	local gSix = gyro:clone()
	gSix.cframe = top.CFrame
	gSix.Parent = top
	top.Position = Vector3.new(torso.Position.x,torso.Position.y + 10,torso.Position.z)
	local bpFour = bodyPos:clone()
	bpFour.position = Vector3.new(torso.Position.x,torso.Position.y + 5,torso.Position.z )
	bpFour.Parent = top
	top.Parent = game.Workspace
	debris:AddItem(top,shieldTime)

	delay(shieldTime,unAnchor)

end

		

local keying = false
function onKeyDown(key)

	if keying then return end

	keying = true

	key:lower()
	if key == "f" then
		selection = selection + 1
		if selection == 4 then selection = 1 end
		down = false
		select()
	elseif key == "r" then
		selection = selection -1
		if selection == 0 then selection = 3 end
		down = true
		select()
	end

	keying = false

end

local steps = 10
local moving = false
function select()

	if moving then return end
	moving = true

	local labels = gui:GetChildren()
	for i = 1, #labels do
		if labels[i].Name == "ReloadText" then
			table.remove(labels,i)
			break
		end
	end
	local diff = {}

	if down then
		for i = 1, #labels do
			labels[i].Pos.Value = labels[i].Pos.Value + 1
			labels[i].ZIndex = 2
			if labels[i].Pos.Value == 4 then
				labels[i].Pos.Value = 1
				labels[i].ZIndex = 1
			end
			if labels[i].Pos.Value == 2 then labels[i].ZIndex = 3 end
			labels[i].Diff.Value = labels[i].Position.Y.Offset - positions[labels[i].Pos.Value].Y.Offset
		end
		for j = 1, steps do
			for i = 1, #labels do
				labels[i].Position = UDim2.new(labels[i].Position.X.Scale,labels[i].Position.X.Offset,labels[i].Position.Y.Scale,labels[i].Position.Y.Offset - (labels[i].Diff.Value/steps))
				if labels[i].Pos.Value == 2 then
					labels[i].Size = UDim2.new(0,labels[i].Size.X.Offset + 3,0,labels[i].Size.Y.Offset + 1)
				elseif labels[i].Pos.Value == 3 then
					labels[i].Size = UDim2.new(0,labels[i].Size.X.Offset - 3,0,labels[i].Size.Y.Offset - 1)
				end
			end
			wait()
		end
	else
		for i = 1, #labels do
			labels[i].Pos.Value = labels[i].Pos.Value - 1
			labels[i].ZIndex = 2
			if labels[i].Pos.Value == 0 then
				labels[i].Pos.Value = 3
				labels[i].ZIndex = 1
			end
			if labels[i].Pos.Value == 2 then labels[i].ZIndex = 3 end
			labels[i].Diff.Value = labels[i].Position.Y.Offset - positions[labels[i].Pos.Value].Y.Offset
		end
		for j = 1, steps do
			for i = 1, #labels do
				labels[i].Position = UDim2.new(labels[i].Position.X.Scale,labels[i].Position.X.Offset,labels[i].Position.Y.Scale,labels[i].Position.Y.Offset - (labels[i].Diff.Value/steps))
				if labels[i].Pos.Value == 2 then
					labels[i].Size = UDim2.new(0,labels[i].Size.X.Offset + 3,0,labels[i].Size.Y.Offset + 1)
				elseif labels[i].Pos.Value == 1 then
					labels[i].Size = UDim2.new(0,labels[i].Size.X.Offset - 3,0,labels[i].Size.Y.Offset - 1)
				end
			end
			wait()
		end
	end

	moving = false

end

