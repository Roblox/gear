function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Tool = script.Parent;
Tool.Enabled = true

local MouseInput = (Tool:FindFirstChild("MousePos") or Create("RemoteFunction"){
	Name = "MousePos",
	Parent = Tool
})

local vChar = Tool.Parent
local torso = nil
local RightShoulder = nil
while not vChar or vChar.Name == "BackPack" or not torso or not RightShoulder do
	vChar = Tool.Parent
	if vChar and vChar.Name ~= "BackPack" then
		torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
		if torso then
			RightShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
		end
	end
	wait(1)
end

Tool.Enabled = true

--local spark = Instance.new("Sparkles")
local sparkColors = {Color3.new(1, 0, 0),
				Color3.new(0,1,0),
				Color3.new(0,0,1),
				Color3.new(1,1,0),
				Color3.new(1,0,1),
				Color3.new(0,1,1)}

function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	gunDown()

	--local missile = Instance.new("Part")
	local missile = Tool.Handle:Clone()
	Tool.Handle.Transparency = 1
	
	--littleSpark = spark:Clone()
	--littleSpark.Parent = missile
	--littleSpark.Color = sparkColors[math.random(1,#sparkColors)]
	--littleSpark.Color = Color3.new(math.random(), math.random(), math.random())

	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos.unit*5
	dPos = dPos - dPos.unit * 5
	
	-- convert to a 2D space
	local deltaXZSquared = dPos.X*dPos.X + dPos.Z*dPos.Z
	local deltaXZ = math.sqrt(deltaXZSquared)
	local deltaY = dPos.Y
	
	--[[print("dPos: ")
	print(dPos)
	
	print("deltaY: ")
	print(deltaY)

	print("deltaXZ: ")
	print(deltaXZ)]]--

	-- pick a random high angle for each shot (60-80 degrees)
	local alpha = math.random()*math.pi/8 + math.pi/3
	--alpha = math.pi / 4

	missile.Position = spawnPos
	--missile.Size = Vector3.new(math.random()*0.01,math.random()*0.01,math.random()*0.01)
	missile.RotVelocity = Vector3.new((math.random()-.5)*20, (math.random()-.5)*20, (math.random()-.5)*20)
	
	-- back-solve for the velocity required to hit the target point
	--gravity = 196.1643
	gravity = workspace.Gravity
	local numerator = -0.5*gravity*deltaXZSquared
	local denominator = math.cos(alpha)*math.cos(alpha)*(deltaY - math.tan(alpha)*deltaXZ)

	--print("numerator: ")
	--print(numerator)
	--print("denominator: ")
	--print(denominator)
	
	if denominator == 0 then return end
	local missileSpeed = math.sqrt(numerator / denominator)
	if missileSpeed > 300 then missileSpeed = 300 end
	local vXZ = missileSpeed * math.cos(alpha)
	local vY = missileSpeed * math.sin(alpha)
	local vX = vXZ * dPos.X / deltaXZ
	local vZ = vXZ * dPos.Z / deltaXZ
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
	missile.Name = "Spark"
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
	
	local new_script = script.Parent.LaserBlast:Clone()
	Create("ObjectValue"){
		Name = "Creator",
		Value = vPlayer,
		Parent = new_script,
	}
	new_script.Parent = missile
	new_script.Disabled = false
	

	missile.Parent = workspace
	missile:SetNetworkOwner(nil)

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang then 
		confettiBang.Volume = .6
		confettiBang:Play() 
	end
end



function gunUp()
	--RightShoulder.MaxVelocity = 0.5
	--RightShoulder.DesiredAngle = 2*3.14
end

function gunDown()
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3.14
end


function onEquip()
	gunUp()
	--Tool.GripUp = Vector3.new(0, 1, 0)
	--Tool.GripRight = Vector3.new(1, 0, 0)
	--Tool.GripForward = Vector3.new(0, 0, -1)
	--Tool.GripPos = Vector3.new(0, -.75, 1.5)
end

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false


	local character = Tool.Parent;
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		--print("Humanoid not found")
		return 
	end

	local reload = 4
	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end

	--gunUp()
	--for i = 1,25 do 
		local sucess,MousePosition = pcall(function() return MouseInput:InvokeClient(game.Players:GetPlayerFromCharacter(character)) end)
		MousePosition = (sucess and MousePosition) or Vector3.new(0,0,0)
		local targetPos = MousePosition
		--local lookAt = (targetPos - character.Head.Position)
		local lookAt = targetPos - character.PrimaryPart.Position
		--if (lookAt.magnitude > 1000) then lookAt = lookAt.unit * 1000 end
		fire(lookAt) 
		wait(.1)
	--end
	--gunDown()
	wait(reload)
	gunUp()

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang then confettiBang.Volume = 0 end

	Tool.Handle.Transparency = 0

	Tool.Enabled = true
end

script.Parent.Equipped:Connect(onEquip)
script.Parent.Activated:Connect(onActivated)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	gravity = workspace.Gravity
end)
