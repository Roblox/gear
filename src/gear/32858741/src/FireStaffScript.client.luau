local Tool = script.Parent
local debris = game:GetService("Debris")
local keyDown = nil

local gui = nil
local selection = 1
local down = false
local positions = {UDim2.new(0, 25, 1, -150),UDim2.new(0, 25, 1, -100),UDim2.new(0, 25, 1, -50)}

local fireStream = false
local fireRing = false

local humanoid = nil
local torso = nil

local wallWidth = 60
local wallHeight = 25
local brickSpeed = 0.01

local brickWidth = 6
local brickHeight = 4
local brickDepth = 2

local fireStreamAnim = nil
local fireRingAnim = nil
local fireWallAnim = nil

local ringSound = Instance.new("Sound")
ringSound.SoundId = "http://www.roblox.com/asset/?id=32791565"
ringSound.Parent = Tool.Handle

local streamSound = Instance.new("Sound")
streamSound.SoundId = "http://www.roblox.com/asset/?id=32791582"
streamSound.Parent = Tool.Handle

local wallSound = Instance.new("Sound")
wallSound.SoundId = "http://www.roblox.com/asset/?id=32791600"
wallSound.Parent = Tool.Handle

local fire = Instance.new("Part")
fire.Transparency = 1
fire.CanCollide = false
fire.Anchored = true
fire.Size = Vector3.new(1,1,1)

local fireParticles = Instance.new("Fire")
fireParticles.Parent = fire
fireParticles.Color = Color3.new(1,117/255,57/255)

local script = Tool:WaitForChild("BurnScript"):clone() --Fix implemented by Luckymaxer
script.Parent = fire

function onEquippedLocal(mouse)

	fire.Name = Tool.Parent.Name .. " Fire"
	keyDown = mouse.KeyDown:connect(onKeyDown)
	buttonDown = mouse.Button1Down:connect(onActivated)

	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	torso = Tool.Parent:FindFirstChild("Torso")

	gui = Tool.FireStaffGui:clone()
	gui.Parent = game.Players:GetPlayerFromCharacter(Tool.Parent).PlayerGui

	fireStreamAnim = humanoid:LoadAnimation(Tool.firecast)
	fireRingAnim = humanoid:LoadAnimation(Tool.firering)
	fireWallAnim = humanoid:LoadAnimation(Tool.firewall)

	if Tool.Reload.Value > 0 then reloadTime(Tool.Reload.Value) end

end

Tool.Equipped:connect(onEquippedLocal)



function onUnequippedLocal()
	
	keyDown:disconnect()
	gui:remove()
	gui = nil
	selection = 1

	fireStreamAnim:Stop()
	fireStreamAnim:remove()
	fireStreamAnim = nil

	fireRingAnim:Stop()
	fireRingAnim:remove()
	fireRingAnim = nil

	fireWallAnim:Stop()
	fireWallAnim:remove()
	fireWallAnim = nil

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

	if enabled or reloading then return end
	enabled = true

	local v = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit

	if selection == 1 then
		fireRingAnim:Play()
		local spin = Instance.new("BodyAngularVelocity")
		spin.angularvelocity = Vector3.new(0,10,0)
		spin.P = 1000000
		spin.maxTorque = Vector3.new(0,spin.P,0)
		spin.Parent = torso
		debris:AddItem(spin,1.1)
		ringSound:Play()
		Ring(torso.Position)
		reloadTime(16)
	elseif selection == 2 then
		fireStreamAnim:Play()
		streamSound:Play()
		Stream(v) 
		reloadTime(12)
	elseif selection == 3 then
		fireWallAnim:Play()
		wallSound:Play()
		Wall(v)
		reloadTime(20)
	end

	enabled = false

end



function Stream(v)
	for i = 5, 50 do
		 v = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit
		local dist = v * i
		dist = Vector3.new(torso.Position.x + dist.x,torso.Position.y + dist.y,torso.Position.z + dist.z)

		local fiery = fire:clone()
		fiery.Fire.Heat = 25
		fiery.Position = dist
		fiery.Parent = game.Workspace
		fiery.Anchored = false
		fiery.Velocity = v * 5

		local force = Instance.new("BodyForce")
		force.force = Vector3.new(0,200,0)
		force.Parent = fiery

		fiery.BurnScript.Disabled = false
		debris:AddItem(fiery,1)
		wait()
	end
end

function Ring(v)
	local numOfFire = 16
	local increment = (math.pi *2)/numOfFire

	torsoNormal = torso.CFrame.lookVector
	denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
	posX = 15 * (torsoNormal.x/denom)
	posZ = 15 * (torsoNormal.z/denom)

	local pos = Vector3.new(v.x + posX,v.y, v.z + posZ)
	for i = 1, numOfFire do

		local fiery = fire:clone()
		fiery.Fire.Heat = 20
		fiery.Fire.Size = 10
		fiery.Size = Vector3.new(5,fiery.Size.y + 7,fiery.Size.z)
		fiery.Position = pos
		fiery.Parent = game.Workspace
		fiery.BurnScript.Disabled = false
		debris:AddItem(fiery,8)

		local angle = increment * i
		pos = Vector3.new(((pos.x - v.x) * math.cos(angle)) - ((pos.z - v.z) * math.sin(angle)) + v.x, pos.y,((pos.x - v.x) * math.sin(angle)) + ((pos.z - v.z) * math.cos(angle)) + v.z)

	end
end

function Wall(v)
	local lookAt = snap((humanoid.TargetPoint - humanoid.Parent.Head.Position).unit)
	local cf = CFrame.new(humanoid.TargetPoint, humanoid.TargetPoint + v)
	buildWall(cf)
end

function snap(v)
	if math.abs(v.x)>math.abs(v.z) then
		if v.x>0 then
			return Vector3.new(1,0,0)
		else
			return Vector3.new(-1,0,0)
		end
	else
		if v.z>0 then
			return Vector3.new(0,0,1)
		else
			return Vector3.new(0,0,-1)
		end
	end
end

-- places a brick at pos and returns the position of the brick's opposite corner
function placeBrick(cf, pos)
	local brick = fire:clone()
	fire.BurnScript.Disabled = false
	brick.Fire.Size = 11
	brick.Fire.Heat = 15
	brick.Size = Vector3.new(brickWidth, brickHeight, brickDepth)
	brick.CFrame = cf * CFrame.new(pos + brick.size / 2)

	brick.Parent = game.Workspace
	brick:makeJoints()
	return  brick, pos +  brick.size
end

function buildWall(cf)

	local brickNum = 0

	assert(wallWidth>0)
	local y = 0
	while y < wallHeight do
		local p
		local x = -wallWidth/2
		while x < wallWidth/2 do
			local brick
			brick, p = placeBrick(cf, Vector3.new(x, y, 0), color)
			x = p.x
			debris:AddItem(brick, 10 /(1 + (brickSpeed * brickNum)))
			print(5 - (brickSpeed * brickNum))
			brickNum = brickNum + 1
			wait(brickSpeed)
		end
		y = p.y
	end

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

