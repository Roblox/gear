local Tool = script.Parent;

Tool.Enabled = true

function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	--local missile = Instance.new("Part")

	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(1158038)
	random = math.random(1,10)
	if (random == 10) then root = game:GetService("InsertService"):LoadAsset(4765323) end

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	--root = root:FindFirstChild("Cupcake")
	root = instances[1]
	if root == nil then return end

	local missile = root.Handle:Clone()
	
	--missile.RotVelocity = Vector3.new((math.random()-.5)*20, (math.random()-.5)*20, (math.random()-.5)*20)

	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos.unit*10
	dPos = dPos - dPos.unit * 10
	

	missile.Position = spawnPos
	missile.Size = Vector3.new(1,1,1)

	-- back-solve for the velocity required to hit the target point
	gravity = workspace.Gravity
	missile.Velocity = dPos.unit*20
	
	missile.BrickColor = BrickColor.Random()
	missile.Shape = 1

--	missile.BottomSurface = 0
--	missile.TopSurface = 0
	missile.Name = "PumpkinFloater"
	missile.Reflectance = 1
	missile.Transparency = 0
	missile.CanCollide = false

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,gravity*missile:getMass(),0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.LaserBlast:clone()
	if random == 10 then  new_script = script.Parent.DarkLaserBlast:clone() end
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then 
		confettiBang.Volume = .1
		confettiBang:Play() 
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


function pumpkinSpin()
	for i = 1, 20 do
		angle = -i*math.pi/5
		Tool.GripForward = Vector3.new(math.sin(angle),math.cos(angle),0)
		Tool.GripRight = Vector3.new(math.cos(angle),math.sin(angle),0)
		wait(.1)
	end
	--Tool.GripUp = Vector3.new(0,0,1)
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
	local reload = 5
	pumpkinSpin()
	for i = 1, 6 do
		local targetPos = humanoid.TargetPoint
		local lookAt = targetPos-character.PrimaryPart.Position
		fire(lookAt)
		wait(.2)
	end
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
