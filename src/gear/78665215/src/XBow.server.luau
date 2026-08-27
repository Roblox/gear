-- 43645221 : Fired Bow
-- 43645253 : Arrow

local Tool = script.Parent;

Tool.Enabled = true

local spark = Instance.new("Sparkles") 
local sparkColors = {Color3.new(1, 0, 0),
				Color3.new(0,1,0),
				Color3.new(0,0,1),
				Color3.new(1,1,0),
				Color3.new(1,0,1),
				Color3.new(0,1,1)}

function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")
	local missileMesh = Tool.Handle.Mesh:Clone()
	missileMesh.Parent = missile
	missileMesh.MeshId = "http://www.roblox.com/asset/?id=71378055"
	missileMesh.TextureId = "http://www.roblox.com/asset/?id=71377225"
	
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=78620844"
	littleSpark = spark:Clone() 
	littleSpark.Parent = missile 
	littleSpark.Color = sparkColors[math.random(1,#sparkColors)] 
	littleSpark.Color = Color3.new(math.random(), math.random(), math.random()) 

	local function onTouched(hit)
		if hit == nil or hit.Parent == nil or hit.Name == "SwordXBowArrow" or hit.Parent.Name == "SwordXBow" then return end
		missile.Sparkles.Enabled = false
	end

	missile.Touched:connect(onTouched)
	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos.unit*5
	dPos = dPos - dPos.unit * 5
	
	-- convert to a 2D space
	deltaXZSquared = dPos.X*dPos.X + dPos.Z*dPos.Z
	deltaXZ = math.sqrt(deltaXZSquared)
	deltaY = dPos.Y
	
	--[[print("dPos: ")
	print(dPos)
	
	print("deltaY: ")
	print(deltaY)

	print("deltaXZ: ")
	print(deltaXZ)]]--

	-- pick a random medium angle (30-50 degrees)
	alpha = math.random()*math.pi/8 + math.pi/6
	--alpha = math.pi / 4

	missile.Position = spawnPos
	missile.Size = Vector3.new(math.random()*0.01,math.random()*0.01,math.random()*0.01)
	--missile.RotVelocity = Vector3.new((math.random()-.5)*20, (math.random()-.5)*20, (math.random()-.5)*20)
	
	
	-- back-solve for the velocity required to hit the target point
	--gravity = 196.1643
	gravity = 196.1643
	numerator = -0.5*gravity*deltaXZSquared
	denominator = math.cos(alpha)*math.cos(alpha)*(deltaY - math.tan(alpha)*deltaXZ)

	--print("numerator: ")
	--print(numerator)
	--print("denominator: ")
	--print(denominator)
	
	if denominator == 0 then return end
	missileSpeed = math.sqrt(numerator / denominator)
	if missileSpeed > 300 then missileSpeed = 300 end
	vXZ = missileSpeed * math.cos(alpha)
	vY = missileSpeed * math.sin(alpha)
	vX = vXZ * dPos.X / deltaXZ
	vZ = vXZ * dPos.Z / deltaXZ
	missile.Velocity = Vector3.new(vX, vY, vZ)
	--[[print("missileSpeed: ")
	print(missileSpeed)
	print("vY: ")
	print(vY)
	print("vX: ")
	print(vX)
	print("vZ: ")
	print(vZ)]]--
	
	--missile.BrickColor = BrickColor.Random()
	--missile.Shape = math.random(0,2)

--	missile.BottomSurface = 0
--	missile.TopSurface = 0
	missile.Name = "SwordXBowArrow"
	--missile.Reflectance = 1
	--missile.Transparency = 0
	missile.CanCollide = true


	--local force = Instance.new("BodyForce")
	--force.force = Vector3.new(0,98,0)
	--force.force = Vector3.new(0, missile:getMass()*200,0)
	--force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile


	newBG = Instance.new("BodyGyro")
	newBG.cframe = CFrame.new(missile.Position, missile.Position+missile.Velocity)
	newBG.Name = "ArrowGyro"
	newBG.P = 10000
	newBG.D = 1000
	newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P)
	newBG.Parent = missile

	missile.Parent = game.Workspace

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then 
		confettiBang.Volume = .3
		confettiBang:Play() 
	end
end



function gunUp()
	--Tool.GripForward = Vector3.new(0,.196, -.981) --comented
	--Tool.GripRight = Vector3.new(1,0,0)   --comented
	--Tool.GripUp = Vector3.new(0,.981, -.196)  --comented

	for i = 1,20 do
		upAngle = math.cos(i*math.pi/60)
		downAngle = math.sin(i*math.pi/60)
		Tool.GripForward = Vector3.new(0, downAngle, -upAngle)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0, upAngle, -downAngle)
		wait(.02)
	end
end

function gunDown()

	for i = 1,20 do
		upAngle = math.cos((20-i)*math.pi/60)
		downAngle = math.sin((20-i)*math.pi/60)
		Tool.GripForward = Vector3.new(0, downAngle, -upAngle)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0, upAngle, -downAngle)
		wait(.02)
	end

	--Tool.GripForward = Vector3.new(0,0,-1)
	--Tool.GripRight = Vector3.new(1,0,0)
	--Tool.GripUp = Vector3.new(0,1,0)
end
function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end


function onEquip()
--	Tool.GripUp = Vector3.new(0, 1, 0)
--Tool.GripRight = Vector3.new(1, 0, 0)
--	Tool.GripForward = Vector3.new(0, 0, -1)
--	Tool.GripPos = Vector3.new(0, -.75, 1.5)
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

	local reload = .3
	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end

--	gunUp()
	--for i = 1,25 do 
		local targetPos = humanoid.TargetPoint
		--local lookAt = (targetPos - character.Head.Position)
		local lookAt = targetPos - character.PrimaryPart.Position
		--if (lookAt.magnitude > 1000) then lookAt = lookAt.unit * 1000 end
		fire(lookAt) 
		--wait(.1)
	--end
--	gunDown()
	wait(reload)

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=78620844"

	Tool.Enabled = true
end

script.Parent.Equipped:connect(onEquip)
script.Parent.Activated:connect(onActivated)
