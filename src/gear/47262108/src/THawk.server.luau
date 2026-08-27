local Tool = script.Parent;

local vChar = Tool.Parent
local torso = nil
local RightShoulder = nil
local RightArm = nil
while vChar == nil or vChar.Name == "BackPack" or torso == nil or RightShoulder == nil or RightArm == nil do
	vChar = Tool.Parent
	if vChar ~= nil and vChar.Name ~= "BackPack" then
		torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
		if torso ~= nil then
			RightArm = vChar:FindFirstChild("Right Arm") or vChar:FindFirstChild("RightHand")
			RightShoulder = torso:FindFirstChild("Right Shoulder") or vChar:FindFirstChild("RightUpperArm"):FindFirstChild("RightShoulder")
		end
	end
	wait(1)
end

local r = game:service("RunService")


Tool.Enabled = true
function fire(dPos, missile)

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
	
	missile.Weld:Destroy()
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

local kunais = {}
local last_attack = 0
local state = 0 -- state: 0 means "ready to start", 1 means "adding more kunais", 2 means "throw kunais"
local switchEvenOddParity = -1
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

	local firing = false
	local t = r.Stepped:wait()
	if state == 0 then
		kunais = {}
		-- start the kunai adding process
		local newKunai = Tool.Handle:Clone()
		newKunai.Transparency = 0

		local newKunaiWeld = Instance.new("Weld")
		newKunaiWeld.Part0 = newKunai
		newKunaiWeld.Part1 = RightArm
		local Offset = RightArm and RightArm.Name == "RightHand" and -0.2 or -1.2
		newKunaiWeld.C1 = (CFrame.new() + Vector3.new(0, Offset, -0.5))*CFrame.Angles(0, 0, 0) + Vector3.new(0, 0, -0.35)
		newKunaiWeld.Parent = newKunai

		newKunai.Parent = game.Workspace

		table.insert(kunais, newKunai)
		last_attack = t
		state = 1
		clinkSound = Tool.Handle:FindFirstChild("ClinkSound")
		if clinkSound ~= nil then
			clinkSound.Volume = .5
			clinkSound:Play()
		end
	elseif (t - last_attack < .70) and #kunais < 5 then
		-- add a kunai

		local newKunai = Tool.Handle:Clone()
		newKunai.Transparency = 0

		local newKunaiWeld = Instance.new("Weld")
		newKunaiWeld.Part0 = newKunai
		newKunaiWeld.Part1 = RightArm
		switchEvenOddParity = -switchEvenOddParity
		angle = math.ceil(#kunais/2)*math.pi/8*switchEvenOddParity
		local Offset = RightArm and RightArm.Name == "RightHand" and -0.2 or -1.2
		newKunaiWeld.C1 = (CFrame.new() + Vector3.new(0, Offset, -0.5))*CFrame.Angles(0, angle, 0) + Vector3.new(-.75*math.sin(angle), 0, -.75*math.cos(angle)+.4)
		newKunaiWeld.Parent = newKunai

		newKunai.Parent = game.Workspace

		table.insert(kunais, newKunai)

		clinkSound = Tool.Handle:FindFirstChild("ClinkSound")
		if clinkSound ~= nil then
			clinkSound.Volume = .5
			clinkSound:Play()
		end

	elseif (t - last_attack > 1.45) then
		-- throw the kunais
		local reload = 1.5
		local targetPos = humanoid.TargetPoint
		local lookAt = (targetPos - character.PrimaryPart.Position).unit

		confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
		if confettiBang ~= nil then 
			confettiBang.Volume = .6
			confettiBang:Play() 
		end


		if state ~= 0 then
			firing = true
			switchEvenOddParity = 1
			for i = 1, #kunais do
				angle = math.ceil((i-1)/2)*math.pi/12*switchEvenOddParity
				switchEvenOddParity = -switchEvenOddParity
				fire(CFrame.Angles(0, angle, 0) * lookAt, kunais[i])
				kunais[i] = nil

				RightShoulder.MaxVelocity = 0.5
				RightShoulder.DesiredAngle = 0 -- 3.14
			end 
			firing = false
		end

		wait(reload)

		confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
		if confettiBang ~= nil then confettiBang.Volume = 0 end
		clinkSound = Tool.Handle:FindFirstChild("ClinkSound")
		if clinkSound ~= nil then clinkSound.Volume = 0 end

		state = 0
	end

	Tool.Enabled = true
end

function onEquipped()
	Tool.Handle.Transparency = 1

	vChar = Tool.Parent
	torso = nil
	RightShoulder = nil
	RightArm = nil
	while vChar == nil or vChar.Name == "BackPack" or torso == nil or RightShoulder == nil or RightArm == nil do
		vChar = Tool.Parent
		if vChar ~= nil and vChar.Name ~= "BackPack" then
			torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
			if torso ~= nil then
				RightArm = vChar:FindFirstChild("Right Arm") or vChar:FindFirstChild("RightHand")
				RightShoulder = torso:FindFirstChild("Right Shoulder") or vChar:FindFirstChild("RightUpperArm"):FindFirstChild("RightShoulder")
			end
		end
		wait(1)
	end

end

function onUnequipped()
	state = 0
	if not firing then
		for i = 1, #kunais do
			if kunais[i] ~= nil then kunais[i]:Destroy() end
		end
		kunais = {}
	end
	Tool.Handle.Transparency = 0
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
