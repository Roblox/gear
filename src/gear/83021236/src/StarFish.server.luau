local Tool = script.Parent

local Char = Tool.Parent
local torso = nil
local RightShoulder = nil
local RightArm = nil

local reload = 1
local numNeedles = 5

local debris = game:GetService("Debris")

Tool.Enabled = true

function fire(dPos)
	local character = Tool.Parent
	if character == nil then 
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid == nil then
		return
	end
	local player = game.Players:playerFromCharacter(character)
	local spawnPosition = Tool.Handle.Position
	spawnPosition = spawnPosition + dPos*5

	local shuriken = Tool.Handle:Clone()
	shuriken.Transparency = 0
	shuriken.CFrame = CFrame.new (spawnPosition, spawnPosition + dPos) 

	shuriken.Velocity = dPos * 50
	shuriken.RotVelocity = Vector3.new(0, 0, 0)
	shuriken.Name = "ThrownFish"
	shuriken.CanCollide = false

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, shuriken:GetMass()*196.1,0)
	force.Parent = shuriken

	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = vPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = shuriken
	
	local newScript = Tool.ProjectileScript:Clone()
	newScript.Parent = shuriken
	newScript.Disabled = false
	shuriken.Parent = game.Workspace
	
	debris:AddItem(shuriken, 3.5)

	wait(0.5)

	if shuriken ~= nil and shuriken.Parent ~= nil then
		shuriken.Anchored = true
		local smoke = Instance.new("Smoke")
		smoke.Size = 0.1
		smoke.Color = Color3.new(1,(153/255), (51/255))
		smoke.Opacity = 1
		smoke.Parent = shuriken
		shuriken.Transparency = 1
		wait(.8)
		if shuriken ~= nil and shuriken.Parent ~= nil then
			local shotPos = shuriken.Position
			local splitFish = {}
			shuriken.CanCollide = false
			
			for i = 1, numNeedles do
				splitFish[i] = shuriken:Clone()				
				splitFish[i].CanCollide = true
				splitFish[i].Transparency = 0
				splitFish[i].Smoke.Enabled = false
				splitFish[i].Anchored = false
				splitFish[i].CFrame = CFrame.new (shotPos) * CFrame.Angles((math.pi * 2) * (i/numNeedles), 0, 0) * CFrame.new(0,0,2)

				splitFish[i].Parent = game.Workspace
				debris:AddItem(splitFish[i], 3.5)
			end 
		end
		wait(0.5)
	end
end

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false
	Tool.Handle.Transparency = 1

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		Tool.Enabled = true
		return 
	end
	
	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - Tool.Handle.Position).unit

	confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
	if confettiBang ~= nil then 
		confettiBang.Volume = 0.6
		confettiBang:Play() 
	end

	xNoise = (math.random()-.5)*.1
	yNoise = (math.random()-.5)*.1
	zNoise = (math.random()-.5)*.1
	fire(CFrame.Angles(xNoise, yNoise, zNoise) * lookAt)

	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 1.9 -- 3.14
	wait(0.5)

	wait(reload)

	confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end

function onEquipped()
	vChar = Tool.Parent
	torso = nil
	RightShoulder = nil
	RightArm = nil
	while vChar == nil or vChar.Name == "BackPack" or torso == nil or RightShoulder == nil or RightArm == nil do
		vChar = Tool.Parent
		if vChar ~= nil and vChar.Name ~= "BackPack" then
			torso = vChar:FindFirstChild("Torso")
			if torso ~= nil then
				RightShoulder = torso:FindFirstChild("Right Shoulder")
				RightArm = vChar:FindFirstChild("Right Arm")
			end
		end
		wait(1)
	end
end


function onUnequipped()
	Tool.Handle.Transparency = 0
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
