local Tool = script.Parent

local vChar = Tool.Parent
local torso = nil
local RightShoulder = nil
local RightArm = nil

local debris = game:GetService("Debris")


Tool.Enabled = true
function fire(dPos)

	local vCharacter = Tool.Parent
	if vCharacter == nil then return end
	local vHum = vCharacter:FindFirstChild("Humanoid")
	if vHum == nil then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos*5	
	
	local missile = Tool.Handle:Clone()
	missile.Transparency = 0
	
	missile.CFrame = CFrame.new(spawnPos, spawnPos + dPos) * CFrame.Angles(math.pi*0.5, 0, 0)

	missile.Velocity = dPos * 58
	missile.RotVelocity = Vector3.new(0, 0, 0)
	missile.Name = "ThrownKunai"
	missile.CanCollide = true

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, missile:GetMass()*workspace.Gravity,0)
	force.Parent = missile

	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = vPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = missile
	
	local newScript = Tool.ProjectileScript:clone()
	newScript.Disabled = false
	newScript.Parent = missile

	missile.Parent = game.Workspace

	debris:AddItem(missile, 3.5)
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
	local reload = 3.25
	local numNeedles = 8
	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.PrimaryPart.Position).unit

	confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
	if confettiBang ~= nil then 
		confettiBang.Volume = 0.6
		confettiBang:Play() 
	end

	for i = 1, numNeedles do
		xNoise = (math.random()-.5)*.1
		yNoise = (math.random()-.5)*.1
		zNoise = (math.random()-.5)*.1
		fire(CFrame.Angles(xNoise, yNoise, zNoise) * lookAt)

		RightShoulder.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = 1.9 -- 3.14
		wait(0.1)
	end 
		
	wait(reload)

	confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end

function onEquipped()
	vChar = Tool.Parent
	torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
	RightArm = vChar:FindFirstChild("Right Arm") or vChar:FindFirstChild("RightUpperArm")
	RightShoulder = torso:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")
end

function onUnequipped()
	Tool.Handle.Transparency = 0
	vChar = nil
	torso = nil
	RightArm = nil
	RightShoulder = nil
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
