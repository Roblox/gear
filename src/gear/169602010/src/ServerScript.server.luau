-- A hacked together modification of the Grapple Hook Shot gear
-- 

local bolts = {}
local maxBolts = 8
local boltLifetime = 10

local currentBolt = nil

local UserInputTypes = {
	CreateRope = 1;
	BreakRope = 2;
}

local UserInputRemoteEvent = script.Parent:WaitForChild("UserInput")

local maxDistance = 200
local hopUpVelocity = 20
local boltSpeed = 120
local RetractionSpeed = 60
local StartDistance = 100

local canFireWhileGrappling = true

local Tool = script.Parent;
local torso = nil
local human = nil
--local boltconnect = nil
--local holdweld = nil

local defaultPos = Vector3.new(0,-.09,1.1)
local adjustedPos = Vector3.new(0,0,.605)

--local rope = Instance.new("Part")

--rope.BrickColor = BrickColor.new("Black")

--[[rope.TopSurface = 0
rope.BottomSurface = 0
rope.formFactor = "Symmetric"
rope.Name = "Rope"
rope.CanCollide = false
rope.Anchored = true
local mesh = Instance.new("CylinderMesh")
mesh.Parent = rope
mesh.Scale = Vector3.new(0.1,1,0.1)--]]

local PlayerBodyVelocity = Instance.new("BodyVelocity")
PlayerBodyVelocity.maxForce = Vector3.new(1e+006, 1e+006, 1e+006)
local ObjectBodyVelocities = {} 
local ObjectBodyVelocityBackup = Instance.new("BodyVelocity")
ObjectBodyVelocityBackup.maxForce = Vector3.new(5000,5000,5000) --force necessary to forcefully grab a player


local bodyGyro = Instance.new("BodyGyro")
bodyGyro.maxTorque = Vector3.new(math.huge,math.huge,math.huge)

function BreakRope(bolt)
	if not bolt then return end
	if human then
		human.Sit = false
	end
	
	local rope = bolt:FindFirstChild("Rope")
	if rope then
		rope:Destroy()
	end
	
	destroyBolt(bolt)
	
	--wait(.45)
	if bolt == nil then
		bodyGyro.Parent = nil --keep the gyro a little longer so retracted object doesnt ragdoll player
	end
	--script.Parent.Bolt.Transparency =  0
end

function adjustRope()
	for i,v in pairs(bolts) do
		if v and torso then
			if (torso.Position - v.Position).magnitude > maxDistance then BreakRope(v) end
		end
	end
end

function updateVelocities()
	local bolt = currentBolt
	if bolt and torso then 
		local grappleVector = (torso.Position - bolt.Position)
		local distanceToBolt = grappleVector.magnitude
		if distanceToBolt > maxDistance then 
			BreakRope(bolt)
			return
		end
		if bolt.Velocity.magnitude < 3 and -1* torso.Velocity:Dot(grappleVector.unit) < 5 and grappleVector.magnitude < .75 * StartDistance then	
			--print("hop up")
			--PlayerBodyVelocity.velocity = PlayerBodyVelocity.velocity + Vector3.new(0,hopUpVelocity,0)
			wait(.25)
			BreakRope(bolt)
			return
		end
		if grappleVector.magnitude < 3.5 then
			--print("grapple end")
			wait(.20)
			BreakRope(bolt)
			return
		else
			if (ObjectBodyVelocities[bolt] ~= nil) then
				ObjectBodyVelocities[bolt].velocity = grappleVector.unit * RetractionSpeed
			end
			local boltRetraction = math.max(grappleVector.unit:Dot(bolt.Velocity),0) --no negative speed
			local playerSpeed = math.max(0, RetractionSpeed - 5 - boltRetraction)
			if playerSpeed == 0 then 
				PlayerBodyVelocity.Parent = nil 
			else
				PlayerBodyVelocity.Parent = torso
				local xzMultiplier = 0.7
				local yMultiplier = ((distanceToBolt / StartDistance))
				local velocityWeightedByDistance = grappleVector.unit * playerSpeed * -1
				velocityWeightedByDistance = Vector3.new(velocityWeightedByDistance.x * xzMultiplier, velocityWeightedByDistance.y * yMultiplier, velocityWeightedByDistance.z * xzMultiplier)
				PlayerBodyVelocity.velocity = velocityWeightedByDistance
			end
		end
	else
		BreakRope(bolt)
	end
end

function destroyBolt(bolt)
	if (bolt == currentBolt) then
		currentBolt = nil
		if PlayerBodyVelocity then PlayerBodyVelocity.Parent = nil end
		bodyGyro.Parent = nil
	end
	if ObjectBodyVelocities[bolt] then ObjectBodyVelocities[bolt]:Destroy() end
	
	for i,v in pairs(bolts) do
		if v == bolt then
			table.remove(bolts, i)
		end
	end
	
	bolt:Destroy()
	--print("Bolt destroyed")
	
	--[[local bolt = getPrimaryBolt()
	if (bolt ~= nil) then
		PlayerBodyVelocity.Parent = torso
		PlayerBodyVelocity.velocity = Vector3.new(0,0,0)
		bodyGyro.cframe = torso.CFrame
		bodyGyro.Parent = torso
	end--]]
end

function destroyOldBolts(retainThis)
	for i,v in pairs(bolts) do
		if (v ~= retainThis) then
			table.remove(bolts, i)
			v:Destroy()
		end
	end
end

function addBolt(bolt)
	table.insert(bolts, bolt)
	game:GetService("Debris"):AddItem(bolt, boltLifetime)
end

function canFireBolt()
	local numBolts = 0
	for _,v in pairs(bolts) do
		numBolts = numBolts + 1
	end
	return (numBolts < maxBolts)
end

function getPrimaryBolt()
	return currentBolt
end

function isPrimaryBolt(bolt)
	return (bolt == currentBolt)
end

function onBoltHit(bolt, hit)
	if bolt == nil or hit == nil or hit.Parent == nil or hit == rope or bolt.Name ~= "Bolt" or hit.Parent == Tool or hit.Parent == Tool.Parent or hit.Parent.Parent == Tool.Parent or hit.Parent.Name == "Attached Bolt" then 
		return 
	end
	
	--print("onBoltHit")
	
	currentBolt = bolt
	destroyOldBolts(bolt)
	
	local grappleVector = (torso.Position - bolt.Position)
	StartDistance = grappleVector.magnitude
	if StartDistance > maxDistance then 
		destroyBolt(bolt)
		return 
	end
	
	bolt.Name = "Attached Bolt"
	local boltFrame = CFrame.new(hit.Position)

	local C0 = hit.CFrame:inverse() * boltFrame
	local C1 = bolt.CFrame:inverse() * boltFrame
	local weld = Instance.new("Weld")
	weld.Part0 = hit
	weld.Part1 = bolt
	weld.C0 = C0
	weld.C1 = C1
	weld.Parent = bolt

	local hum = hit.Parent:FindFirstChild("Humanoid")
	if hum then hum.Sit = true end

	if bolt:FindFirstChild("HitSound") then bolt.HitSound:play() end
	local backupbolt = bolt


	local ObjectBodyVelocity = Instance.new("BodyVelocity")
	ObjectBodyVelocities[bolt] = ObjectBodyVelocity
	ObjectBodyVelocity.maxForce = Vector3.new(5000,5000,5000)
	ObjectBodyVelocity.velocity = grappleVector.unit * RetractionSpeed
	ObjectBodyVelocity.Parent = bolt
	
	--wait(0.4)
	if bolt == nil or bolt ~= backupbolt then return end
	bolt.ConnectSound:play()
	Tool.Handle.ConnectSound:play()

	if isPrimaryBolt(bolt) then
		PlayerBodyVelocity.Parent = torso
		PlayerBodyVelocity.velocity = Vector3.new(0,0,0)
		bodyGyro.cframe = torso.CFrame
		bodyGyro.Parent = torso
	end

end

enabled = true
local canReset = true

function onButton1Down(pos)
	--print("onMouseDown server handler")
	
	if not enabled then return end
	if not canFireBolt() then --[[print("Cannot fire another bolt")--]] return end
	
	Tool.Handle.FireSound:play()

	enabled = false

	--print("Creating new bolt")
	local bolt = Instance.new("Part")
	bolt.Archivable = false
	Tool.Handle.ConnectSound:Clone().Parent = bolt
	bolt.FormFactor = Enum.FormFactor.Symmetric
	bolt.Name = "Bolt"
	bolt.Size = Vector3.new(1,1,1)
	bolt.Locked = false
	bolt.Transparency = 1
	addBolt(bolt)
	
	local rope = Instance.new("SelectionPartLasso")
	rope.Name = "Rope"
	rope.Color = BrickColor.new("White")
	rope.Parent = bolt
	rope.Part = bolt
	rope.Humanoid = Tool.Parent:FindFirstChild("Humanoid")
	rope.Visible = true

	bolt.CFrame = CFrame.new(Tool.Handle.Position + (pos - Tool.Handle.Position).unit * 5,pos) --* CFrame.fromEulerAnglesXYZ(0,math.pi,0)
	bolt.Transparency = 1
	bolt.CanCollide = false
	
	bolt.Velocity = bolt.CFrame.lookVector * boltSpeed
	
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,bolt:GetMass() * 196.1,0)
	force.Parent = bolt
	bolt.Parent = Tool.Parent
	--bolt.AncestryChanged:connect(function() onKeyDown("q") end)
	bolt.Touched:connect(function(hit) onBoltHit(bolt, hit) end)


	bolt.Parent = Tool.Parent
	
	
	--oo rebel
	

	--Tool.GripPos = adjustedPos
	canReset = false
	wait(.3)
	enabled = true
	canReset = true
	wait(1)
end

function getHumanoid(obj)
	for i,child in pairs(obj:getChildren()) do
		if child.className == "Humanoid" then
			return child
		end
	end
end

function onEquippedLocal(mouse)
	--print("onEquippedLocal")
	if mouse == nil then
		--print("Mouse not found")
		return 
	end

	torso = Tool.Parent:findFirstChild("Torso")
	human = Tool.Parent:FindFirstChild("Humanoid")
	if torso == nil or human == nil then return end
	--human.Jumping:connect(function() onKeyDown("q") end)

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
end


Tool.Equipped:connect(onEquippedLocal)
--Tool.Unequipped:connect(function() onKeyDown("q") end)

function PlayerIsOwnerOfTool(player)
	if Tool and Tool.Parent then
		local plyr = game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
		if plyr == player then return true end
	end
	print("Player not owner of tool")
	return false
end

UserInputRemoteEvent.OnServerEvent:connect(function(player, ...)
	--print("Server received event from client")
	if (PlayerIsOwnerOfTool(player)) then
		local userInputType = select(1, ...)
		local data = select(2, ...)
		
		if (userInputType == UserInputTypes.CreateRope) then
			local targetPosition = data
			onButton1Down(targetPosition)
		elseif (userInputType == UserInputTypes.BreakRope) then
			--disabled
		end
	end
end)

while true do
	adjustRope()
	updateVelocities()
	wait(1/60)
end
