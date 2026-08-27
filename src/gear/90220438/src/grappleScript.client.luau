--Edited by QS

local maxDistance = 300
local canFireWhileGrappling = false


local Tool = script.Parent;
local torso = nil
local human = nil
local bolt = nil
local targetPos = Vector3.new(0,0,0)
local boltconnect = nil
local holdweld = nil

local defaultPos = Vector3.new(0,-.09,1.1)
local adjustedPos = Vector3.new(0,0,.605)

local rope = Instance.new("Part")
--rope.BrickColor = BrickColor.new("Black")
rope.TopSurface = 0
rope.BottomSurface = 0
rope.formFactor = "Symmetric"
rope.Name = "Rope"
rope.CanCollide = false
rope.Anchored = true
local mesh = Instance.new("CylinderMesh")
mesh.Parent = rope
mesh.Scale = Vector3.new(0.1,1,0.1)

local RetractionSpeed = 45
local StartDistance = 100

local PlayerBodyVelocity = Instance.new("BodyVelocity")
PlayerBodyVelocity.maxForce = Vector3.new(1e+006, 1e+006, 1e+006)
local ObjectBodyVelocity = Instance.new("BodyVelocity")
ObjectBodyVelocity.maxForce = Vector3.new(5000,5000,5000) --force necessary to forcefully grab a player

local bodyPos = Instance.new("BodyPosition")
bodyPos.D = 1e+003
bodyPos.P = 3e+003
bodyPos.maxForce = Vector3.new(1e+006, 1e+006, 1e+006)

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.maxTorque = Vector3.new(math.huge,math.huge,math.huge)

function BreakRope()
	if human then
		human.Sit = false
	end
	rope.Parent = nil
	if PlayerBodyVelocity then PlayerBodyVelocity.Parent = nil end
	if ObjectBodyVelocity then ObjectBodyVelocity.Parent = nil end
	bodyGyro.Parent = nil
	if bolt ~= nil then
		bolt.Parent = nil
	end
	if holdweld ~= nil then
		holdweld.Parent = nil
	end
	holdweld = nil
	bolt = nil
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=89987774"
	Tool.GripPos = defaultPos
	
	wait(.45)
	if bolt == nil then
		bodyGyro.Parent = nil --keep the gyro a little longer so retracted object doesnt ragdoll player
	end
	--script.Parent.Bolt.Transparency =  0
end

function adjustRope()
	if bolt and torso then
		if (torso.Position - bolt.Position).magnitude > maxDistance then BreakRope() end
	end
	if rope.Parent == nil  or bolt == nil then return end
	local pos1 = Tool.Handle.Position + Tool.Handle.CFrame.lookVector*.7
	local pos2 = bolt.Position
	rope.Size = Vector3.new(0, 1, 0)
	rope.Mesh.Scale = Vector3.new(0.1, (pos1-pos2).magnitude, 0.1)
	rope.CFrame = CFrame.new((pos1 + pos2)/2, pos2) * CFrame.fromEulerAnglesXYZ(-math.pi/2,0,0)
end

function updateVelocities()
	if bolt and torso and ObjectBodyVelocity then 
		local grappleVector = (torso.Position - bolt.Position)
		if grappleVector.magnitude > maxDistance then 
			BreakRope()
			return
		end
		if bolt.Velocity.magnitude < 3 and -1* torso.Velocity:Dot(grappleVector.unit) < 5 and grappleVector.magnitude < .75 * StartDistance then	
			print("hop up")
			PlayerBodyVelocity.velocity = PlayerBodyVelocity.velocity + Vector3.new(0,20,0)
			wait(.25)
			BreakRope()
			return
		end
		if grappleVector.magnitude < 3.5 then
			print("grapple end")
			wait(.20)
			BreakRope()
			return
		else
			ObjectBodyVelocity.velocity = grappleVector.unit * RetractionSpeed
			local boltRetraction = math.max(grappleVector.unit:Dot(bolt.Velocity),0) --no negative speed
			local playerSpeed = math.max(0, RetractionSpeed - 5 - boltRetraction)
			if playerSpeed == 0 then 
				PlayerBodyVelocity.Parent = nil 
			else
				PlayerBodyVelocity.Parent = torso
				PlayerBodyVelocity.velocity = grappleVector.unit * playerSpeed * -1
			end
		end
	else
		BreakRope()
	end
end

function onBoltHit(hit)
	if bolt == nil or hit == nil or hit.Parent == nil or hit == rope or bolt.Name ~= "Bolt" or hit.Parent == Tool or hit.Parent == Tool.Parent or hit.Parent.Parent == Tool.Parent or hit.Parent.Name == "Attached Bolt" then 
		return 
	end
	local grappleVector = (torso.Position - bolt.Position)
	StartDistance = grappleVector.magnitude
	if StartDistance > maxDistance then 
		bolt.Parent = nil 
		bolt = nil 
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


	ObjectBodyVelocity = Instance.new("BodyVelocity")
	ObjectBodyVelocity.maxForce = Vector3.new(5000,5000,5000)
	ObjectBodyVelocity.velocity = grappleVector.unit * RetractionSpeed
	ObjectBodyVelocity.Parent = bolt
	
	wait(0.4)
	if bolt == nil or bolt ~= backupbolt then return end
	bolt.ConnectSound:play()
	Tool.Handle.ConnectSound:play()

	targetPos = bolt.Position
	backupPos = bolt.Position

	--bodyPos.position = targetPos
	--bodyPos.Parent = torso
	PlayerBodyVelocity.Parent = torso
	PlayerBodyVelocity.velocity = Vector3.new(0,0,0)
	bodyGyro.cframe = torso.CFrame
	bodyGyro.Parent = torso

	while bolt ~= nil do
		--bodyPos.position = bolt.Position
		updateVelocities()
		wait(1/30)
	end
end

enabled = true
local canReset = true

function onButton1Down(mouse)

	if bolt and canReset then 
		BreakRope()
	end
	if not enabled then 
		return 
	end

	if bolt ~= nil and not canFireWhileGrappling then return end
	if bolt ~= nil then
		if boltconnect ~= nil then
			print("Disconnecting")
			boltconnect:disconnect()
		end
		bolt:remove()
		targetPos = Vector3.new(0,0,0)
	end

	Tool.Handle.FireSound:play()

	enabled = false

	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	--bolt = game:GetService("InsertService"):LoadAsset(33393977)

	bolt = Tool.Handle:Clone()
	bolt.Name = "Bolt"
	bolt.Size = Vector3.new(1,.4,1)
	bolt.Locked = false
	bolt.Mesh.MeshId = "http://www.roblox.com/asset/?id=89989174"

	--local instances = bolt:GetChildren()
	--if #instances == 0 then
	--	bolt:Remove()
	--	return
	--end
	
	--bolt = bolt:FindFirstChild("Bolt")
	--local boltMesh = bolt:FindFirstChild("Mesh")

	bolt.CFrame = CFrame.new(Tool.Handle.Position + (mouse.Hit.p - Tool.Handle.Position).unit * 5,mouse.Hit.p) --* CFrame.fromEulerAnglesXYZ(0,math.pi,0)
	bolt.Transparency = 0
	bolt.CanCollide = false
	bolt.Velocity = bolt.CFrame.lookVector * 80
	if bolt:findFirstChild("BodyPosition") ~= nil then
		bolt.BodyPosition:remove()
	end
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,bolt:GetMass() * 196.1,0)
	force.Parent = bolt
	bolt.Parent = workspace
	boltconnect = bolt.AncestryChanged:connect(function() onKeyDown("q") end)
	bolt.Touched:connect(onBoltHit)

	rope.Parent = Tool

	bolt.Parent = game.Workspace

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=89988787"
	Tool.GripPos = adjustedPos
	canReset = false
	wait(.5)
	canReset = true
	wait(1)

	mouse.Icon = "rbxasset://textures\\GunCursor.png"

	enabled = true
end

function onKeyDown(key)
	key = key:lower()
	if key == "q" then
		BreakRope()
	end
end

function getHumanoid(obj)
	for i,child in pairs(obj:getChildren()) do
		if child.className == "Humanoid" then
			return child
		end
	end
end

function onEquippedLocal(mouse)
	if mouse == nil then
		print("Mouse not found")
		return 
	end

	torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
	human = Tool.Parent:FindFirstChild("Humanoid")--getHumanoid(Tool.Parent)
	if torso == nil or human == nil then return end
	human.Jumping:connect(function() onKeyDown("q") end)

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	mouse.KeyDown:connect(onKeyDown)
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(function() onKeyDown("q") end)

while true do
	adjustRope()
	wait(1/60)
end
