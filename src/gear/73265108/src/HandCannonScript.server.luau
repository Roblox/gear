local Tool = script.Parent
local Cannon = Tool.Handle

local debris = game:GetService("Debris")

Tool.Enabled = true 

rocket = Instance.new("Part")
rocket.Size = Vector3.new(0.5, 0.5, 0.5)
rocket.Transparency = 0.4
rocket.Shape = "Ball"
rocket.FormFactor = 3
rocket.Name ="HC"

local rocketMesh = Instance.new("SpecialMesh")
rocketMesh.MeshType = "FileMesh"
rocketMesh.Name = "Mesh"
rocketMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
rocketMesh.TextureId = "http://www.roblox.com/asset/?id=48598142"
rocketMesh.Scale = Vector3.new(0.005, 0.005, 0.005)
rocketMesh.Parent = rocket

local newBV = Instance.new("BodyVelocity")
newBV.P = 1000
newBV.maxForce = Vector3.new(newBV.P, newBV.P, newBV.P)
newBV.Name = "BV"

local newBT = Instance.new("BodyThrust")
newBT.Name = "BT"

local newBF = Instance.new("BodyPosition")
newBF.P = 10000
newBF.maxForce = Vector3.new(newBF.P, newBF.P, newBF.P)
newBF.Name = "BF"

local fireSound
local boom

local rocketClone = {}

local damage = 15

local chargeCannon 

local vCharacter 
local myTorso
local myHumanoid

local adornmentPart = Instance.new("Part")
adornmentPart.FormFactor = 3
adornmentPart.Size = Vector3.new(0.2, 0.2, 8)
adornmentPart.BrickColor = BrickColor.new("Bright green") 
adornmentPart.Name = "Ray"
adornmentPart.Anchored = true

while Tool:FindFirstChild("CannonPartWeld") == nil or Tool:FindFirstChild("CannonPart2Weld") == nil do 
	wait()
end 

local cannonPartWeld = Tool.CannonPartWeld 
local cannonPart2Weld = Tool.CannonPart2Weld 
local cannonPart = cannonPartWeld.Part1
local cannonPart2 = cannonPart2Weld.Part1

function fireBeam(beamStart, beamEnd)
	local distance =(beamStart - beamEnd).magnitude
	if distance > 150 then distance = 150 end
	local laser = Instance.new("Part")
	laser.Name = "Bullet"
	laser.Anchored = true
	laser.CanCollide = false
	laser.Shape = "Block"
	laser.formFactor = "Custom"
	laser.Size = Vector3.new(0.2, 0.2, distance + 0.2)
	laser.Material = Enum.Material.Plastic
	laser.Locked = true
	laser.TopSurface = 0
	laser.BottomSurface = 0
	laser.BrickColor = BrickColor.new("Bright green")	
	laser.CFrame = CFrame.new(beamStart, beamStart + beamEnd.unit) * CFrame.new(0, 0, -distance/2)		
	laser.Parent = game.Workspace
	laser.Touched:connect(function(hit) blow(laser, hit) end)
	debris:AddItem(laser, 0.25)
end 


function blow(laser, hit)     
	local humanoid      
	if hit and hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")          
		if hit.Parent.ClassName == "Hat" then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)               
		if humanoid ~= nil and humanoid ~= myHumanoid then
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(20)
			humanoid.Sit = true           
			local e = Instance.new("Explosion")
			e.BlastRadius = 2
			e.BlastPressure = 0
			e.Position = hit.Position
			e.Parent = game.Workspace
		end               
	end
end 
function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
		debris:AddItem(creatorTag, 1)
	end
end

function shoot(target)
	vCharacter = Tool.Parent	
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 		
		return
	end	

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then 		
		return
	end	

	local pos1 =  target - cannonPart.Position 
	local pos2 =  target - cannonPart2.Position 
	
	local f1 = cannonPart2:FindFirstChild("Fire")
	local f2 = cannonPart:FindFirstChild("Fire")

	Tool.GripPos = Vector3.new(-1.5, 0.25, -2)
	fireBeam(cannonPart.Position , pos1.unit * 150.0)
	if f2 then f2.Enabled = true end
	wait(0.15)
	if f2 then f2.Enabled = false end
	Tool.GripPos = Vector3.new(-1.5, 0.35, -2)
	wait(0.35) 
	Tool.GripPos = Vector3.new(-1.5, 0.25, -2)
	fireBeam(cannonPart2.Position , pos2.unit * 150.0)
	if f1 then f1.Enabled = true end
	wait(0.15)
	if f1 then f1.Enabled = false end
	Tool.GripPos = Vector3.new(-1.5, 0.35, -2)
	wait(0.35) 
	Tool.GripPos = Vector3.new(-1.5, 0.25, -2)
	fireBeam(cannonPart.Position , pos1.unit * 150.0)
	if f2 then f2.Enabled = true end
	wait(0.15)
	if f2 then f2.Enabled = false end
	Tool.GripPos = Vector3.new(-1.5, 0.35, -2)
	wait(0.35) 
	Tool.GripPos = Vector3.new(-1.5, 0.25, -2)
	fireBeam(cannonPart2.Position , pos2.unit * 150.0)
	if f1 then f1.Enabled = true end
	wait(0.15)
	if f1 then f1.Enabled = false end
	Tool.GripPos = Vector3.new(-1.5, 0.35, -2)
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		print("Humanoid not found")
		return
	end

	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		print("Torso not found")
		return
	end

	boom = Tool:FindFirstChild("BOOM")
	
	target = myHumanoid.TargetPoint
	lookAt = (target - Cannon.Position).unit
	
	myHumanoid.WalkSpeed = 0.0
	myTorso.Anchored = true

	fireSound = Tool:FindFirstChild("FireSound")	
	--shoot(lookAt)	
	shoot(target)
	myHumanoid.WalkSpeed = 16.0
	myTorso.Anchored = false
	wait(4.5)	
	Tool.Enabled = true
end

function onEquipped()
	Cannon.Mesh.MeshId = "http://www.roblox.com/asset/?id=73230895"
	Tool.Grip = CFrame.new(-1.5, 0.35, -2, -1, 0, 0, 0, -1, 0, 0, 0, 1)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 200
		myHumanoid.Health = ratio * 200
		while myHumanoid.Health < ratio * 200 do 
			myHumanoid.Health = ratio * 200
			wait()
		end
	end

	if cannonPartWeld then 
		cannonPartWeld.Parent = Tool
	end 
	
	if cannonPart2Weld then 
		cannonPart2Weld.Parent = Tool
	end 
end

function onUnequipped()
	if fireSound then fireSound:Stop()end
	if boom then boom:Stop() end

	Tool.Grip = CFrame.new(-1.5, -1.14999998, -0.75, -1, 0, -0, 0, 0, 1, 0, 1, -0)

	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.Health = ratio * 100
		myHumanoid.MaxHealth = 100
	end
	if myTorso then myTorso.Anchored = false end	
	Cannon.Mesh.MeshId = "http://www.roblox.com/asset/?id=73261035"
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

while Tool:FindFirstChild("ChargeCannon") == nil do wait() end 
chargeCannon = Tool.ChargeCannon

chargeCannon.Changed:connect(function()
	if chargeCannon and chargeCannon.Value == true and myHumanoid and myTorso and cannonPart and cannonPart2 then 
		Tool.Enabled = false 
		myHumanoid.WalkSpeed = 0.0
		myTorso.Anchored = true 

		local duration = 2.0  

		local p1 = adornmentPart:Clone()
		local p2 = adornmentPart:Clone() 

		p1.CFrame = CFrame.new(cannonPart.CFrame.p, myTorso.Position + myTorso.CFrame.lookVector * 10.0) * CFrame.new(0, 0, -4)
		p2.CFrame = CFrame.new(cannonPart2.CFrame.p, myTorso.Position + myTorso.CFrame.lookVector * 10.0) * CFrame.new(0, 0, -4)

		p1.Parent = game.Workspace
		p2.Parent = game.Workspace 

		local chargeSphere = Instance.new("Part")
		chargeSphere.CanCollide = false 
		chargeSphere.Size = Vector3.new(0.4, 0.4, 0.4)
		chargeSphere.Shape = "Ball"
		chargeSphere.Anchored = true 
		chargeSphere.CFrame = CFrame.new(myTorso.Position + myTorso.CFrame.lookVector * 8.0) --+ Vector3.new(0, -2, 0)
		chargeSphere.Parent = game.Workspace
		chargeSphere.BrickColor = BrickColor.new("Bright green")
		chargeSphere.Name = "DeathStar"		

		while duration > 0.0 do 
			chargeSphere.Size = chargeSphere.Size + Vector3.new(1.4, 1.4, 1.4)
			chargeSphere.CFrame = CFrame.new(myTorso.Position + myTorso.CFrame.lookVector * 8.0) --+ Vector3.new(0, -2, 0)
			print("Resizing", chargeSphere.Size)
			duration = duration - wait(0.4) 
			wait(0.4)
		end 

		local bf = Instance.new("BodyForce")
		bf.force = Vector3.new(0, chargeSphere:GetMass() * 196.1 , 0)
		bf.Parent = chargeSphere 

		chargeSphere.Anchored = false 
		chargeSphere.Velocity = myTorso.CFrame.lookVector * 50.0 
		
		chargeSphere.Touched:connect(function(hit) blow(chargeSphere, hit) end) 

		debris:AddItem(chargeSphere, 4.5)
		
		if p1 then p1:Destroy() end 
		if p2 then p2:Destroy() end 

		wait(0.5)

		Tool.Enabled = true
	
		myHumanoid.WalkSpeed = 16.0
		myTorso.Anchored = false
		
		wait(10.0) 
		chargeCannon.Value = false
	else
		print(chargeCannon, myHumanoid, myTorso)
	end 
end) 


