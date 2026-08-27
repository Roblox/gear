local Tool = script.Parent;
local bombScript = Tool.Bomb

Tool.Enabled = true

function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local root = game:GetService("InsertService"):LoadAsset(14130887)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	--root = root:FindFirstChild("Cupcake")
	root = instances[1]
	if root == nil then return end

	local missile = root.Handle:Clone()

	missile.CanCollide = true
	missile.Transparency = 0
	missile.Size = Vector3.new(2,2,2)
	missile.Name = "FuseBomb"
	missile.Locked = true
	missile.Elasticity = .9

	local spark = Instance.new("Sparkles")
	spark.Name = "Fuse"
	spark.Parent = missile


	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile

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
	
	-- back-solve for the velocity required to hit the target point
	--gravity = 196.1643
	gravity = workspace.Gravity
	numerator = -0.5*gravity*deltaXZSquared
	denominator = math.cos(alpha)*math.cos(alpha)*(deltaY - math.tan(alpha)*deltaXZ)

	--[[print("numerator: ")
	print(numerator)
	print("denominator: ")
	print(denominator)]]--
	
	if denominator == 0 then return end
	missileSpeed = math.sqrt(numerator / denominator)
	if missileSpeed > 80 then missileSpeed = 80 end
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


	--local force = Instance.new("BodyForce")
	--force.force = Vector3.new(0,0,0)
	--force.force = Vector3.new(0,98,0)
	--force.force = Vector3.new(0, missile:getMass()*200,0)
	--force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	--local new_script = script.Parent.LaserBlast:clone()
	--new_script.Disabled = false
	--new_script.Parent = missile

	local new_script = bombScript:clone()
	new_script.Disabled = false
	new_script.Parent = missile


	missile.Parent = game.Workspace

	local cakeBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if cakeBang ~= nil then 
		cakeBang.Volume = 1
		cakeBang:Play() 
	end
end



function gunUp()
	--Tool.GripForward = Vector3.new(0,.196, -.981)
	--Tool.GripRight = Vector3.new(1,0,0)
	--Tool.GripUp = Vector3.new(0,.981, -.196)

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

	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end

	--gunUp()
	--[[local reload = 3
	for i = 1,5 do 
		local targetPos = humanoid.TargetPoint
		--local lookAt = (targetPos - character.Head.Position)
		local lookAt = targetPos - character.PrimaryPart.Position
		--if (lookAt.magnitude > 1000) then lookAt = lookAt.unit * 1000 end
		fire(lookAt) 
		wait(.1)
	end--]]
	local reload = 8
	local targetPos = humanoid.TargetPoint
	local lookAt = targetPos-character.PrimaryPart.Position
	fire(lookAt)
	--gunDown()
	wait(reload)

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	Tool.Enabled = true
end

script.Parent.Equipped:connect(onEquip)
script.Parent.Activated:connect(onActivated)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	gravity = workspace.Gravity
end)
