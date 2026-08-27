local Tool = script.Parent;

local vChar = Tool.Parent
local torso = nil
local RightShoulder = nil
local RightArm = nil
--while vChar == nil or vChar.Name == "BackPack" or torso == nil or RightShoulder == nil or RightArm == nil do
--	vChar = Tool.Parent
--	if vChar ~= nil and vChar.Name ~= "BackPack" then
--		torso = vChar:FindFirstChild("Torso")
--		if torso ~= nil then
--			RightShoulder = torso:FindFirstChild("Right Shoulder")
--			RightArm = vChar:FindFirstChild("Right Arm")
--		end
--	end
--	wait(1)
--end

--local r = game:service("RunService")


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

	--missile.Position = spawnPos
	--missile.CFrame = CFrame.new(spawnPos)
	--missile.Position = spawnPos
	
	local missile = Tool.Handle:Clone()
	missile.Transparency = 0

	--missile.Position = spawnPos -- breaks the weld
	missile.CFrame = CFrame.new(spawnPos, spawnPos + dPos) * CFrame.Angles(0, 0, math.pi/2)

	missile.Velocity = dPos * 50
	missile.RotVelocity = Vector3.new(0, 0, 0)
	missile.Name = "ThrownKunai"
	missile.CanCollide = true

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, missile:getMass()*workspace.Gravity,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace
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
		confettiBang.Volume = .6
		confettiBang:Play() 
	end

	for i = 1, numNeedles do
			xNoise = (math.random()-.5)*.1
			yNoise = (math.random()-.5)*.1
			zNoise = (math.random()-.5)*.1
			fire(CFrame.Angles(xNoise, yNoise, zNoise) * lookAt)

--			RightShoulder.MaxVelocity = 0.5
--			RightShoulder.DesiredAngle = 1.9 -- 3.14
			wait(.1)
	end 
		
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
	vChar = Tool.Parent
	torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
--	while vChar == nil or vChar.Name == "BackPack" or torso == nil or RightShoulder == nil or RightArm == nil do
--		vChar = Tool.Parent
--		if vChar ~= nil and vChar.Name ~= "BackPack" then
--			torso = vChar:FindFirstChild("Torso")
--			if torso ~= nil then
--				RightShoulder = torso:FindFirstChild("Right Shoulder")
--				RightArm = vChar:FindFirstChild("Right Arm")
--			end
--		end
--		wait(1)
--	end

end

function onUnequipped()
	Tool.Handle.Transparency = 0
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
