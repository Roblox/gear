local Tool = script.Parent;

Tool.Enabled = true


function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(34384720)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	root = root:FindFirstChild("Cupcake")
	if root == nil then return end

	local missile = root:Clone()
	missile.RotVelocity = Vector3.new((math.random()-.5)*20, (math.random()-.5)*20, (math.random()-.5)*20)

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

	-- pick a random medium angle (45 +- 45/2 degrees)
	alpha = math.random()*math.pi/4 + math.pi/8
	--alpha = math.pi / 4

	missile.Position = spawnPos
	missile.Size = Vector3.new(2, 2, 2)
	
	
	-- back-solve for the velocity required to hit the target point
	--gravity = 196.1643
	gravity = 196.1643
	numerator = -0.5*gravity*deltaXZSquared
	denominator = math.cos(alpha)*math.cos(alpha)*(deltaY - math.tan(alpha)*deltaXZ)

	--[[print("numerator: ")
	print(numerator)
	print("denominator: ")
	print(denominator)]]--
	
	if denominator == 0 then return end
	missileSpeed = math.sqrt(numerator / denominator)
	if missileSpeed > 200 then missileSpeed = 200 end
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
	
	missile.BrickColor = BrickColor.Random()
	missile.Shape = 0

--	missile.BottomSurface = 0
--	missile.TopSurface = 0
	missile.Name = "Spark"
	missile.Reflectance = .5
	missile.Transparency = 0
	missile.CanCollide = false


	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,0,0)
	--force.force = Vector3.new(0,98,0)
	--force.force = Vector3.new(0, missile:getMass()*200,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	local cakeBang = Tool.Handle:FindFirstChild("CakeBang")
	if cakeBang ~= nil then 
		cakeBang.Volume = 0.5
		cakeBang:Play() 
	end
end



function gunUp()
	--Tool.GripForward = Vector3.new(0,.196, -.981)
	--Tool.GripRight = Vector3.new(1,0,0)
	--Tool.GripUp = Vector3.new(0,.981, -.196)

	for i = 1,15 do
		upAngle = math.cos(i*math.pi/60)
		downAngle = math.sin(i*math.pi/60)
		Tool.GripForward = Vector3.new(0, downAngle, -upAngle)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0, upAngle, -downAngle)
		wait(.02)
	end
end

function gunOut()

	for i = 1,15 do
		upAngle = math.cos((15-i)*math.pi/60)
		downAngle = math.sin((15-i)*math.pi/60)
		Tool.GripForward = Vector3.new(0, downAngle, -upAngle)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0, upAngle, -downAngle)
		wait(.02)
	end

	--Tool.GripForward = Vector3.new(0,0,-1)
	--Tool.GripRight = Vector3.new(1,0,0)
	--Tool.GripUp = Vector3.new(0,1,0)
end

function onEquip()
	Tool.GripUp = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripForward = Vector3.new(0, 0, -1)
	Tool.GripPos = Vector3.new(0, -.8, .8)
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

	local reload = 1.5


	gunUp()
	for i = 1,5 do 
		local targetPos = humanoid.TargetPoint
		--local lookAt = (targetPos - character.Head.Position)
		local lookAt = targetPos - character.PrimaryPart.Position
		--if (lookAt.magnitude > 1000) then lookAt = lookAt.unit * 1000 end
		fire(lookAt) 
		wait(.6)
	end
	wait(reload)
	gunOut()
	wait(reload)

	cakeBang = Tool.Handle:FindFirstChild("CakeBang")
	if cakeBang ~= nil then cakeBang.Volume = 0 end

	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquip)