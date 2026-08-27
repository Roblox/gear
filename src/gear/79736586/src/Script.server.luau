--[[
	Fixed by ArceusInator 1/23/2015
	
	This seriously needs to be rewritten
--]]

-- Tiny Event Manager; Add: [[Event.EventName = (event)]]; Remove: [[Disconnect("EventName",...)]]
local Event = {}

-- wait until child exists; return child
local function WaitForChild(parent,name)
	while not parent:FindFirstChild(name) do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end

-- get a sibling humanoid of object; by humanoid, not by name
local function GetHumanoid(object)
	if object and object.Parent then
		for i,v in pairs(object.Parent:GetChildren()) do
			if v:IsA"Humanoid" then
				return v
			end
		end
	end
	return nil
end

-- get the parent character from an object; verified by GetHumanoid
local function GetCharacter(object)
	local humanoid = GetHumanoid(object)
	if humanoid then
		return object.Parent,humanoid
	end
	return nil
end

function tagHumanoid(humanoid, Player)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = Player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag.Parent = nil
		end
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local damage = 6
local reloadTime = 2
local jumpTime = 4
local swingTime = 4
local growSpeed = 20
local updateFrequency = 1/30

local Tool = script.Parent
local Handle = WaitForChild(Tool,"Handle")
local Character,Humanoid
local localMouse

local defaultWidth = 1.75
local defaultHeight = 1.27
local meshScaleMultiplier = .2522
local toolGrip = nil

local holdAnim
local jumpAnim 
local swingAnim
local equipAnim

local isSwinging = false
local isJumping = false
local isEquiped = false

local SwooshSound = Instance.new("Sound")
SwooshSound.SoundId = "http://www.roblox.com/asset/?id=46760716"
SwooshSound.Parent = Handle
SwooshSound.Volume = .8

-- if theres a character, get a body part from it
local function GetBodyPart(name)
	local character = Character or GetCharacter(Tool)
	if character then
		local object = character:FindFirstChild(name)
		if object then
			return object
		end
	end
	return nil
end

function setMeshLength( length )
	Handle.Mesh.Scale = Vector3.new(defaultWidth, defaultWidth, length * meshScaleMultiplier)
end

local damageEvent = Instance.new("BindableEvent",script)

local taggedHum = nil
function doDamage(hum)
	if hum == Humanoid then return end
	tagHumanoid(hum)
	hum:TakeDamage(damage)
	wait(1)
	untagHumanoid(hum)
end
	
damageEvent.Event:connect(function(hum) doDamage(hum) end)

function getMaxExtension(vector)
	local ray = Ray.new(Handle.Position, vector)
	if Tool.Parent == nil then return end
	local hit,Position = game.Workspace:FindPartOnRay(ray, Tool.Parent)
	local i = 0
	while hit and hit.Parent and i < 10 do
		i = i + 1
		hum = hit.Parent:FindFirstChild("Humanoid")
		if hum then
			--hum:TakeDamage(damage)
			damageEvent:Fire(hum)
			hit.Velocity = hit.Velocity + vector.unit * 100
		end
		vecSoFar = (Handle.Position - Position)

		if hit.CanCollide then
			return vecSoFar.magnitude
		else
			distance = vector.magnitude
			ray = Ray.new(hit.Position, vector.unit * (vector.magnitude - vecSoFar.magnitude) )
			hit,Position = game.Workspace:FindPartOnRay(ray, Tool.Parent)
		end
	end
	return vector.magnitude
end

function doJump()
	local bv = Instance.new("BodyVelocity")
	bv.velocity = Vector3.new(0,20,0)
	bv.maxForce = Vector3.new(10000000,10000000,10000000)

	local counter = 0
	local radius  = 2.5
	while isJumping and counter < jumpTime and Tool.Parent and Tool.Parent:FindFirstChild("Torso") do     -- and bv and bv.Parent do
		
		radius = radius + updateFrequency * 25
		local radiusCopy = radius
		radius = getMaxExtension(- Handle.CFrame.lookVector.unit *radius) --other direction
		if radius +.01 < radiusCopy then 
			if bv then bv.Parent = Tool.Parent:FindFirstChild("Torso") end
		else
			if bv then bv.Parent = nil end
		end
		getMaxExtension(Handle.CFrame.lookVector.unit *radius) --damage anything above
		setMeshLength(radius * 2)
		counter = counter + updateFrequency
		wait(updateFrequency)
	end
	setMeshLength(5)
	if bv ~= nil then bv.Parent = nil end
	Tool.Animate:FireAllClients('UpStaff4', 'Stop')
	if isEquiped then Tool.Animate:FireAllClients('HoldingStaff3', 'Play') end

	isJumping = false
end



function onKeyDown( key )
	if key == " " then
		--print("jumper")
		if isJumping or isSwinging then return end
		isJumping = true
		SwooshSound:play()
		Tool.Animate:FireAllClients('HoldingStaff3', 'Stop')
		Tool.Animate:FireAllClients('UpStaff4', 'Play')	
		wait(.3)
		doJump()
	end
end

function onKeyUp( key )
	if key == " " then
		isJumping = false
	end
end

function doSwing()
	local counter = 0
	local radius = 2.5
	wait(.3)
	while isSwinging and counter < swingTime do--  and bv and bv.Parent do
		--print(radius)
		wait(updateFrequency)
		counter = counter + updateFrequency
		radius = radius + updateFrequency * growSpeed
		radius = getMaxExtension(Handle.CFrame.lookVector.unit *radius)
		radius = getMaxExtension(- Handle.CFrame.lookVector.unit *radius) --other direction
		setMeshLength(radius*2)
	end
	setMeshLength(5)
	Tool.Animate:FireAllClients('SwingStaff2', 'Stop')
	if isEquiped then Tool.Animate:FireAllClients('HoldingStaff3', 'Play') end
	onMouseUp()
end


function onMouseDown()
	if not localMouse or isSwinging or isJumping or not Tool.Enabled then return end
	Tool.Enabled = false
	isSwinging = true
	SwooshSound:play()
	Tool.Animate:FireAllClients('HoldingStaff3', 'Stop')
	Tool.Animate:FireAllClients('SwingStaff2', 'Play')
	doSwing()
end

function onMouseUp()
	if not isSwinging then return end
	isSwinging = false
	Tool.SetIcon:FireAllClients"rbxasset://textures\\GunWaitCursor.png"
	wait(reloadTime)
	Tool.Enabled = true
	Tool.SetIcon:FireAllClients"rbxasset://textures\\GunCursor.png"
end



Tool.Equipped:connect(function(Mouse)
	isEquiped = true
	localMouse = Mouse
	Character,Humanoid = GetCharacter(Tool)
	if not Character then return end

	Tool.SetIcon:FireAllClients"rbxasset://textures\\GunWaitCursor.png"
	local Torso = GetBodyPart("Torso")
	local rightArm = GetBodyPart("Right Arm")
	toolGrip = rightArm.RightGrip
	Tool.Animate:FireAllClients('HoldingStaff3', 'Play')
	Tool.Animate:FireAllClients('EquipStaff', 'Play')
	local counter = 0
	while counter < .45 do
		counter = counter + updateFrequency
		setMeshLength(counter * 10)
		wait(updateFrequency)
	end

	Tool.Animate:FireAllClients('EquipStaff', 'Stop')
	Tool.SetIcon:FireAllClients"rbxasset://textures\\GunCursor.png"
	local clicktime = 0

	Event.Died = Humanoid.Died:connect(function()
	end)

	Event.Touched = Handle.Touched:connect(function(hit)
		if not hit:IsDescendantOf(Character) then
			local humanoid = GetHumanoid(hit)
			if humanoid then
				damageEvent:Fire(humanoid)
				--humanoid:TakeDamage(damage)
			end
		end
	end)

	--wait(.3)
	--Handle.CanCollide = true
end)

Tool.MouseUp.OnServerEvent:connect(function(client)
	if client.Character == Tool.Parent then
		onMouseDown()
	end
end)

Tool.MouseDown.OnServerEvent:connect(function(client)
	if client.Character == Tool.Parent then
		onMouseDown()
	end
end)

Tool.Jump.OnServerEvent:connect(function(client, on)
	if client.Character == Tool.Parent then
		(on and onKeyDown or onKeyUp)(' ')
	end
end)

Tool.Unequipped:connect(function()
	isEquiped = false
	isJumping = false
	isSwinging = false
	Tool.Enabled = true
	if Event.Died then Event.Died:disconnect() end
	if Event.Touched then Event.Touched:disconnect() end
end)