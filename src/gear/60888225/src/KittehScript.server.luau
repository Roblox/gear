local Tool = script.Parent
local Kitteh = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local kittehClone

local healthConnection

local kittehCo

local enemyChar

local prevHealth = 100 -- maxHealth, so that the kitteh doesn't go all out

local kittehDamage = 40

local kittehAOE = Vector3.new(20, 20, 20)

local angrySound
local meowSound

function bite()
	if kittehClone and enemyChar then 
		enemyHumanoid = enemyChar:FindFirstChild("Humanoid")
		if enemyHumanoid and enemyHumanoid ~= myHumanoid and myHumanoid then 
			enemyHumanoid:TakeDamage(kittehDamage)
		end
		enemyChar = nil 		
		if enemyConnection then enemyConnection:disconnect() end
	end
end

function doSt00f()
	if kittehClone then kittehClone.Transparency = 0.0 end
	local sign = 1
	while kittehClone and myTorso do 
		if enemyChar then -- Attack the guy until he cries! 		
			angrySound = Kitteh:FindFirstChild("AngrySound")
			if angrySound and angrySound.IsPlaying == false then 
				angrySound:Play() 
			end
			enemyTorso = enemyChar:FindFirstChild("Torso") or enemyChar:FindFirstChild("UpperTorso")
			if enemyTorso then					
				kittehClone.Velocity = (enemyTorso.Position - kittehClone.Position).unit * 55.0
				enemyConnection = kittehClone.Touched:connect(bite)
			end
			wait()
		else -- just look cool, by warping around our guy
			tick()
			kittehClone.Velocity = Vector3.new(0, 0, 0) -- This is bad
			kittehClone.Transparency = kittehClone.Transparency + sign
			sign = sign * -1
			local direction = CFrame.Angles(0, math.random(1, 30) * math.pi/30, 0) * myTorso.CFrame.lookVector
			local pos = (myTorso.Position - Vector3.new(0, 2.10, 0)) + direction * 4.0
			kittehClone.CFrame = CFrame.new(pos, pos + direction) * CFrame.Angles(-math.pi/2, 0, 0)
			wait(1.0)
		end		
	end
	print("Coroutine is yielding")
end

function logDamage()
	if myHumanoid and myTorso then 
		local currentHealth = myHumanoid.Health 
		if currentHealth < prevHealth then -- Someone hit the guy! and our kitteh doesn't have a target already
			prevHealth = currentHealth -- do this immediately to limit the kitteh's actions 
			-- Now find the enemy that hit our d00d
			local tag = myHumanoid:FindFirstChild("creator")
			if tag and tag.Value and tag.Value.className == "Player" then 
				enemyChar = tag.Value.Character
			else 
				-- No tag is present, comb the area 
				local parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - kittehAOE, myTorso.Position + kittehAOE), vCharacter, 100)
				print(#parts)
				for i = 1, #parts do 
					if parts[i].Parent and parts[i].Parent:FindFirstChild("Humanoid") and not enemyChar then 
						print("Found enemy")
						print(parts[i].Parent)
						enemyChar = parts[i].Parent
					end
				end			
			end
		else 
			prevHealth = currentHealth -- Need this
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	myHumanoid.HealthChanged:connect(logDamage)

	Tool.Enabled = false 

	kittehClone = Kitteh:Clone()
	kittehClone.CanCollide = false 
	
	local floatForce = Instance.new("BodyForce")
	floatForce.force = Vector3.new(0, kittehClone:GetMass() * workspace.Gravity, 0)
	floatForce.Parent = kittehClone

	local direction = CFrame.Angles(0, math.pi/2, 0) * myTorso.CFrame.lookVector
	local pos = (myTorso.Position - Vector3.new(0, 2.10,0)) + direction * 4.0
	kittehClone.CFrame = CFrame.new(pos, pos + direction) * CFrame.Angles(-math.pi/2, 0, 0)

	kittehClone.Parent = game.Workspace

	meowSound = Kitteh:FindFirstChild("MeowSound")
	if meowSound then meowSound:Play() end

	kittehCo = coroutine.create(doSt00f) 
	coroutine.resume(kittehCo)

	Kitteh.Transparency = 1.0

	wait(18.0)
	if kittehClone then 
		kittehClone:Destroy()		
	end
	Kitteh.Transparency = 0.0
	wait(2.0)
	Tool.Enabled = true 
end

function onEquipped()
end

function onUnequipped()
	if kittehClone then kittehClone:Destroy() end
	Kitteh.Transparency = 0.0
	if enemyConnection then enemyConnection:disconnect() end
	if meowSound then meowSound:Stop() end
	if angrySound then angrySound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)