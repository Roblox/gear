local Tool = script.Parent;

Tool.Enabled = true

local fCols = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(0,1,1)}

local spark = Instance.new("Sparkles")
local flame = Instance.new("Fire")

local timeUntilConvergence = 3

local BurnSound = Tool.Handle:FindFirstChild("BurnSound")
if BurnSound == nil then
	BurnSound = Instance.new("Sound")
	BurnSound.Name = "BurnSound"
	BurnSound.SoundId = "http://www.roblox.com/asset/?id=32791565"
	BurnSound.Parent = Tool.Handle
	BurnSound.Volume = 1
end
--http://www.roblox.com/asset/?id=31758982

function fire(dPos, whichOne, mode)
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

--	local missile = Instance.new("Part")
	-- begin asset insertion
	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(34815459)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	root = root:FindFirstChild("OrbOfPower")
	if root == nil then return end

	local missile = root:Clone()
	-- end asset insertion

	
	littleSpark = spark:Clone()
	littleSpark.Parent = missile
	
	--littleSpark.Color = Color3.new(math.random(), math.random(), math.random())
	littleSpark.Color = fCols[math.random(1, #fCols)]

	littleFlame = flame:Clone()
	littleFlame.Parent = missile
	--littleFlame.Color = Color3.new(math.random(), math.random(), math.random())
	littleFlame.Color = fCols[math.random(1, #fCols)]
	--littleFlame.SecondaryColor = Color3.new(math.random(), math.random(), math.random())

	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	local OrbitSound = Tool.Handle:FindFirstChild("OrbitSound")
	local OrbitSound2 = Tool.Handle:FindFirstChild("OrbitSound2")
	local WhooshSound = Tool.Handle:FindFirstChild("WhooshSound")

	if (OrbitSound == nil) then
		OrbitSound = Instance.new("Sound")
		OrbitSound.Name = "OrbitSound"
		OrbitSound.SoundId = "http://www.roblox.com/asset/?id=10756118"
		OrbitSound.Parent = Tool.Handle
		OrbitSound.Volume = 0
	end

	if (OrbitSound2 == nil) then
		OrbitSound2 = Instance.new("Sound")
		OrbitSound2.Name = "OrbitSound2"
		OrbitSound2.SoundId = "http://www.roblox.com/asset/?id=10756118"
		OrbitSound2.Parent = Tool.Handle
		OrbitSound2.Volume = 0
	end

	if WhooshSound == nil then
		WhooshSound = Instance.new("Sound")
		WhooshSound.Name = "WhooshSound"
		WhooshSound.SoundId = "http://www.roblox.com/asset/?id=31758982"
		WhooshSound.Parent = Tool.Handle
		WhooshSound.Volume = 1 
	end
	
	
	--spawnPos = spawnPos + dPos.unit*5
	--dPos = dPos - dPos.unit * 5
	
	local orbitingVelocity = 15
	if (mode == 1) then orbitingVelocity = 7 end
		
	radius_tag = vCharacter:FindFirstChild("Radius")
	if radius_tag == nil then
		radius_tag = Instance.new("NumberValue")
		radius_tag.Name = "Radius"
		radius_tag.Value = 7
		radius_tag.Parent = vCharacter
	end

	radius = radius_tag.Value

	--if radius_tag == nil then
	--	radiusTag = Instance.new("NumberValue")
	--	radiusTag.Name = "RadiusTag"
	--	radiusTag.Value = radius
	--	radiusTag.Parent = vPlayer
	--end

	theta = whichOne/20*2*math.pi
	missile.Position = Vector3.new(spawnPos.X+radius*math.cos(theta), spawnPos.Y, spawnPos.Z+radius*math.sin(theta))
	missile.Size = Vector3.new(0.01,0.01,0.01)
	
	gravity = 196.1643
	--missile.Velocity = Vector3.new(math.random()*100-50, math.random()*50+10, math.random()*100-50)
	newVelocity = Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5)
	
	-- find unit vector towards us
	unitVectorTowardsUs = Vector3.new(radius*math.cos(theta), 0, radius*math.sin(theta)).unit

	-- take away component towards us
	newVelocity = newVelocity - unitVectorTowardsUs*newVelocity:Dot(unitVectorTowardsUs)
	missile.Velocity = newVelocity.unit * orbitingVelocity

	missile.RotVelocity = Vector3.new((math.random()-.5)*10, (math.random()-.5)*10, (math.random()-.5)*10)

	missile.BrickColor = BrickColor.Random()
	missile.Shape = 1

--	missile.BottomSurface = 0
--	missile.TopSurface = 0
	missile.Name = "Spark"
	missile.Reflectance = 1
	missile.Transparency = 0
	missile.CanCollide = false


	local force = Instance.new("BodyForce")
	local radiusSq = radius*radius
	force.force = Vector3.new(-missile:getMass()*orbitingVelocity*orbitingVelocity*math.cos(theta)/radiusSq, gravity*missile:getMass(), -missile:getMass()*orbitingVelocity*orbitingVelocity*math.sin(theta)/radiusSq)
	force.Parent = missile
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = nil
	if (mode == 0) then 
		new_script = script.Parent.LaserBlast:clone()
		--se new_script = script.Parent.LaserBlastLarge:clone() end
		new_script.Disabled = false
		new_script.Parent = missile

		OrbitSound.Volume = 1
		OrbitSound:Play()

		WhooshSound:Play()
	end
	if (mode == 1) then 
		new_script = script.Parent.LaserBlast2:clone()
		new_script.Disabled = false
		new_script.Parent = missile

		OrbitSound2.Volume = 1
		OrbitSound2:Play()

		WhooshSound:Play()
	end

	missile.Parent = game.Workspace
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


function stormFire(dPos, whichOne)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	--local missile = Instance.new("Part")
	-- begin asset insertion
	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(34815459)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	root = root:FindFirstChild("OrbOfPower")
	if root == nil then return end

	local missile = root:Clone()
	-- end asset insertion

	
	littleSpark = spark:Clone()
	littleSpark.Parent = missile
	--littleSpark.Color = Color3.new(math.random(), math.random(), math.random())
	littleSpark.Color = fCols[math.random(1, #fCols)]
	littleFlame = flame:Clone()
	littleFlame.Parent = missile
	--littleFlame.Color = Color3.new(math.random(), math.random(), math.random())
	littleFlame.Color = fCols[math.random(1, #fCols)]

	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	local StormSound = Tool.Handle:FindFirstChild("StormSound")
	local WhooshSound = Tool.Handle:FindFirstChild("WhooshSound")

	if (StormSound == nil) then
		StormSound = Instance.new("Sound")
		StormSound.Name = "StormSound"
		StormSound.SoundId = "http://www.roblox.com/asset/?id=10756118"
		StormSound.Parent = Tool.Handle
		StormSound.Volume = 0
	end
	
	if WhooshSound == nil then
		WhooshSound = Instance.new("Sound")
		WhooshSound.Name = "WhooshSound"
		WhooshSound.SoundId = "http://www.roblox.com/asset/?id=31758982"
		WhooshSound.Parent = Tool.Handle
		WhooshSound.Volume = 1 
	end
	
	--spawnPos = spawnPos + dPos.unit*5
	--dPos = dPos - dPos.unit * 5
	
	missile.Position = spawnPos
	missile.Size = Vector3.new(math.random()*0.01,math.random()*0.01,math.random()*0.01)
	
	gravity = 196.1643
	--missile.Velocity = Vector3.new(math.random()*100-50, math.random()*50+10, math.random()*100-50)
	missile.Velocity = Vector3.new(math.random()*100-50, math.random()*50+10, math.random()*100-50)
	
	missile.RotVelocity = Vector3.new((math.random()-.5)*10, (math.random()-.5)*10, (math.random()-.5)*10)
	
	missile.BrickColor = BrickColor.Random()
	missile.Shape = 1

--	missile.BottomSurface = 0
--	missile.TopSurface = 0
	missile.Name = "Spark"
	missile.Reflectance = 1
	missile.Transparency = 0
	missile.CanCollide = false

	-- 3 - ...
	timeDelay = timeUntilConvergence-whichOne*.1  --time left until they converge on the hapless victim >:D
	fireForce = missile:getMass()*2*(dPos - missile.Velocity*timeDelay)/(timeDelay*timeDelay) -- F = ma

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(fireForce.X, fireForce.Y + gravity*missile:getMass(), fireForce.Z)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.StormBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	StormSound.Volume = 1
	StormSound:Play()

	WhooshSound:Play()
end

function staffFire()
	--lower staff
	for i = 1,10 do
		angle = i*math.pi/20
		Tool.GripForward = Vector3.new(0,math.cos(angle),math.sin(angle))
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0,-math.sin(angle),math.cos(angle))
		Tool.GripPos = Vector3.new(0,0,-.65)
		wait(.02)
	end

	--spin staff
	for i = 1,20 do
		firstAngle = math.pi/2
		secondAngle = i*math.pi/5
		Tool.GripForward = Vector3.new(0,math.cos(firstAngle),math.sin(firstAngle))
		Tool.GripRight = Vector3.new(math.cos(secondAngle),math.sin(secondAngle),0)
		Tool.GripUp = Vector3.new(math.sin(secondAngle),-math.sin(firstAngle)*math.cos(secondAngle),math.cos(firstAngle))
		Tool.GripPos = Vector3.new(0,0,-.65)
		wait(.01)
	end
end

function staffReturn()
	for i = 1,10 do
		angle = (10-i)*math.pi/20
		Tool.GripForward = Vector3.new(0,math.cos(angle),math.sin(angle))
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0,-math.sin(angle),math.cos(angle))
		Tool.GripPos = Vector3.new(0,0,-.65)
		wait(.04)
	end
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

	local shieldReloadTime = 25
	local stormReloadTime = 8
	local mode = Tool.Mode.Value

	staffFire()
	if (mode == 2) then
		for i = 0,19 do
			local targetPos = humanoid.TargetPoint
			local lookAt = targetPos - character.PrimaryPart.Position
			stormFire(lookAt, i)
			wait(.1)
		end
		--wait(timeUntilConvergence - 2)
		wait(.75)
		BurnSound:Play()
		staffReturn()
		--wait(stormReloadTime+2-timeUntilConvergence)
		wait(stormReloadTime-.75)
	else
		for i = 0,19 do --for i = 0, 19
			local targetPos = humanoid.TargetPoint
			--local lookAt = (targetPos - character.Head.Position)
			local lookAt = targetPos - character.PrimaryPart.Position
			--if (lookAt.magnitude > 1000) then lookAt = lookAt.unit * 1000 end
			fire(lookAt, i, mode) 
			wait(.1)
		end
		staffReturn()
		wait(shieldReloadTime)
	end

	Tool.Enabled = true
end

function onEquipped()
	Tool.Handle.EquipSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
