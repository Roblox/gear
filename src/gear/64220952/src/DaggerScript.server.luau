local Tool = script.Parent
local Dagger = Tool.Handle

local damage = 22

local vCharacter 
local myTorso 
local rightShoulder 
local rightArm 

Tool.Enabled = true

local myHumanoid 
local storeWeld 

local r = game:service("RunService")
local debris = game:GetService("Debris")

local hitSound = Instance.new("Sound")
hitSound.Name = "hitSound"
hitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
hitSound.Parent = ball
hitSound.Volume = 1

local daggers = {}
local last_attack = 0
local state = 0 -- state: 0 means "ready to start", 1 means "adding more daggers", 2 means "throw daggers"
local switchEvenOddParity = -1

function burn(humanoid)
	if humanoid then
		local character = humanoid.Parent
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if torso and humanoid and torso:FindFirstChild("GhostFire") == nil then 
			local fire = Instance.new("Fire")
			fire.Color = Color3.new(0, 0, 102/255)
			fire.SecondaryColor = Color3.new(102/255, 1, 1)
			fire.Name = "GhostFire"
			fire.Parent = torso 

			local duration = 5 
			while duration > 0 do 
				if humanoid then humanoid:TakeDamage(4) end
				duration = duration - 1
				wait(1)
			end
		
			if fire then fire:Destroy() end
		end
	end
end


function blow(dagger, hit)
	if hit == nil or hit.Parent == nil or dagger == nil then return end	
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if hit.Parent:IsA("Accessory") then 
		humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
	end	
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then		
		if hitSound then hitSound:Play() end
		humanoid:TakeDamage(damage)
		coroutine.resume(coroutine.create(function() burn(humanoid) end))
	end
	if connection then connection:disconnect() end
	if hit.Name ~= "ThrownDagger" then
		dagger.Velocity = Vector3.new(0, 0, 0) -- have the dagger drop dead upon impact
		daggerFloat = dagger:FindFirstChild("BodyForce")
		if daggerFloat ~= nil then daggerFloat:Destroy() end
	end
end

function shoot(dPos, missile)

	local vCharacter = Tool.Parent
	if vCharacter == nil then return end
	local vHum = vCharacter:FindFirstChild("Humanoid")
	if vHum == nil then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos * 5.0 
	
	missile.Weld:Destroy()	
	missile.CFrame = CFrame.new(spawnPos, spawnPos + dPos) * CFrame.Angles(0, 0, math.pi/2)

	missile.Velocity = dPos * 70
	missile.RotVelocity = Vector3.new(0, 0, 0)
	missile.Name = "ThrownDagger"
	missile.CanCollide = true

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, missile:getMass()*workspace.Gravity,0)
	force.Parent = missile

	missile.Touched:connect(function(hit) blow(missile, hit) end)	
	missile.Parent = game.Workspace
	debris:AddItem(missile, 7)
end

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false

	Dagger.Transparency = 1	

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	
	if myHumanoid == nil or myTorso == nil then		
		Tool.Enabled = true
		return 
	end
	rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
	if rightArm == nil then 
		return 
	end
	rightShoulder = myTorso:FindFirstChild("Right Shoulder")
	if not rightShoulder then
		local RightUpperArm = vCharacter:FindFirstChild("RightUpperArm")
		if RightUpperArm then
			rightShoulder = RightUpperArm:FindFirstChild("RightShoulder")
		end
	end

	local firing = false
	local t = r.Stepped:wait()
	local DaggerOffset = myHumanoid and ((myHumanoid.RigType == Enum.HumanoidRigType.R15 and -0.2) or -1.2)
	if state == 0 then
		daggers = {}
		-- start the dagger adding process
		local newDagger = Tool.Handle:Clone()
		newDagger.Transparency = 0

		local newDaggerWeld = Instance.new("Weld")
		newDaggerWeld.Part0 = newDagger
		newDaggerWeld.Part1 = rightArm
		newDaggerWeld.C1 = (CFrame.new() + Vector3.new(0, DaggerOffset, -0.5)) * CFrame.Angles(0, 0, 0) + Vector3.new(0, 0, -0.35)
		newDaggerWeld.Parent = newDagger

		newDagger.Parent = game.Workspace

		table.insert(daggers, newDagger)
		last_attack = t
		state = 1
		clinkSound = Tool.Handle:FindFirstChild("ClinkSound")
		if clinkSound ~= nil then
			clinkSound.Volume = .5
			clinkSound:Play()
		end
	elseif (t - last_attack < .70) and #daggers < 7 then
		-- add a dagger

		local newDagger = Tool.Handle:Clone()
		newDagger.Transparency = 0

		local newDaggerWeld = Instance.new("Weld")
		newDaggerWeld.Part0 = newDagger
		newDaggerWeld.Part1 = rightArm
		switchEvenOddParity = -switchEvenOddParity
		angle = math.ceil(#daggers/2)*math.pi/8*switchEvenOddParity
		newDaggerWeld.C1 = (CFrame.new() + Vector3.new(0, DaggerOffset, -0.5))*CFrame.Angles(0, angle, 0) + Vector3.new(-.75*math.sin(angle), 0, -.75*math.cos(angle)+.4)
		newDaggerWeld.Parent = newDagger

		newDagger.Parent = game.Workspace

		table.insert(daggers, newDagger)

		clinkSound = Tool.Handle:FindFirstChild("ClinkSound")
		if clinkSound ~= nil then
			clinkSound.Volume = 0.5
			clinkSound:Play()
		end

	elseif (t - last_attack > 1.45) then
		-- throw the daggers
		local reload = 1.5
		local targetPos = myHumanoid.TargetPoint
		local lookAt = (targetPos - vCharacter.PrimaryPart.Position).unit

		confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
		if confettiBang ~= nil then 
			confettiBang.Volume = .6
			confettiBang:Play() 
		end

		if state ~= 0 then
			firing = true
			switchEvenOddParity = 1
			for i = 1, #daggers do
				angle = math.ceil((i-1)/2)*math.pi/12*switchEvenOddParity
				switchEvenOddParity = -switchEvenOddParity
				shoot(CFrame.Angles(0, angle, 0) * lookAt, daggers[i])
				daggers[i] = nil

				rightShoulder.MaxVelocity = 0.5
				rightShoulder.DesiredAngle = 0 -- 3.14
			end 
			firing = false
		end

		wait(reload)
		Dagger.Transparency = 0.0
		confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
		if confettiBang ~= nil then confettiBang.Volume = 0 end
		clinkSound = Tool.Handle:FindFirstChild("ClinkSound")
		if clinkSound ~= nil then clinkSound.Volume = 0 end
		state = 0
	end

	Tool.Enabled = true		
end

function onEquipped()	
	if fireWeld then fireWeld.Parent = Dagger end
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	rightShoulder = myTorso:FindFirstChild("Right Shoulder")
	if not rightShoulder then
		local RightUpperArm = vCharacter:FindFirstChild("RightUpperArm")
		if RightUpperArm then
			rightShoulder = RightUpperArm:FindFirstChild("RightShoulder")
		end
	end	
	rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
end

function onUnequipped()
	Dagger.Transparency = 0.0
	state = 0
	if not firing then
		for i = 1, #daggers do
			if daggers[i] ~= nil then daggers[i]:Destroy() end
		end
		daggers = {}
	end	
	if fire then fire.Enabled = true end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Dagger.Touched:connect(function() blow(Dagger, hit) end)