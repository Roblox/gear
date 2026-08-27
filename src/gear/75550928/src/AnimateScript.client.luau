-- Sword and shield

local Tool = script.Parent
local Sword = Tool.Handle

Tool.Enabled = true

local vCharacter
local shieldWeld

local shieldWalkAnim
local slashAnim
local bashAnim
local lungeAnim
local spinAnim
local time

local shieldActive
local lastAttack = 0

local bashDamage = 8
local connection

local dashTime = 0
local lastKeyDown = 0

local torsoCFrames = {}

local runService = game:service("RunService")

local humanoidConnection 

function slashIt(myHumanoid, myTorso) 

	spinAnim = myHumanoid:LoadAnimation(Tool.SpinAnim)
	if spinAnim then spinAnim:Play() end

	bg = Instance.new("BodyGyro") 
	bg.P = 100000 
	bg.maxTorque = Vector3.new(bg.P, bg.P, bg.P) 
	bg.Name = "BG" 

	torsoCFrames[1] = myTorso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0) 
	torsoCFrames[2] = myTorso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0) 
	torsoCFrames[3] = myTorso.CFrame * CFrame.Angles(0, math.pi, 0) 
	torsoCFrames[4] = myTorso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0) 
	torsoCFrames[5] = myTorso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0) 
	torsoCFrames[6] = myTorso.CFrame 

	bg.Parent = myTorso 

	for i = 1, 84 do 
		local c = i%6 + 1 
		if bg then bg.cframe = torsoCFrames[c] end 
		wait(0.025) 
	end      	
 	
	if bg then bg:Remove() end 
	wait(2.0) 	
end 

function onKeyDown(key)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	if key:lower() == "q" then 
		if vCharacter:FindFirstChild("Shield") then 			

			torso = vCharacter.Torso
			shieldWeld = torso:FindFirstChild("ShieldHolder")
			leftArm = vCharacter:FindFirstChild("Left Arm")
			if shieldWeld then 
				shieldWeld.Parent = leftArm
				shieldWeld.Part0 = leftArm				
				
				shieldWalkAnim = myHumanoid:LoadAnimation(Tool.ShieldWalk)
				shieldWalkAnim:Play()

				shieldWeld.C1 = CFrame.new(0.300000072, 0.200000063, -0.850000083, 0.475528151, 0.654508531, -0.587785304, 0.809017122, -0.587785125, 8.10705529e-008, -0.345491409, -0.475528419, -0.809016943)
				if Tool.ShieldActive then Tool.ShieldActive.Value = 1 end
				ratio = myHumanoid.Health/myHumanoid.MaxHealth
				print(ratio)
				myHumanoid.MaxHealth = 125
				wait(0.2)
				myHumanoid.Health = myHumanoid.Health + (ratio * 25)
				myHumanoid.WalkSpeed = 19.0
			else
				shieldWeld = leftArm:FindFirstChild("ShieldHolder")
				if shieldWeld then
					shieldWeld.Parent = torso
					shieldWeld.Part0 = torso 							
					shieldWeld.C1 = CFrame.new(0.100000061, 1.49011612e-008, -0.550000012, 1.31134158e-007, 1, 8.74227837e-008, -1, 1.31134158e-007, -8.74227695e-008, -8.74227766e-008, -8.74227695e-008, 1)
				end
				if shieldWalkAnim then shieldWalkAnim:Stop() end
				if Tool.ShieldActive then Tool.ShieldActive.Value = 0 end
				if myHumanoid.MaxHealth > 100 then 
					ratio = myHumanoid.Health/myHumanoid.MaxHealth 
					myHumanoid.Health = ratio * 100
					myHumanoid.MaxHealth = 100	
					myHumanoid.WalkSpeed = 16.0
				end
			end			
		end
	end
	if key:lower() == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	end 
	if key:lower() == "x" then 
		--if shieldWalkAnim then shielWalkAnim:Stop() end 
		defenseAnim = myHumanoid:LoadAnimation(Tool.ShieldDefense)
		if defenseAnim then defenseAnim:Play() end 
		local currentHealth = myHumanoid.Health 
		myHumanoid.WalkSpeed = 8.0 
		humanoidConnection = myHumanoid.HealthChanged:connect(function()
			if myHumanoid.Health > currentHealth then 
				currentHealth = myHumanoid.Health 
			else 
				myHumanoid.Health = currentHealth 
			end 
		end) 
	end 
end

function onKeyUp(key)
	if key:lower() == "x" then 
		if myHumanoid then 
			if defenseAnim then defenseAnim:Stop() end
			if humanoidConnection then humanoidConnection:disconnect() end 
			if shieldActive and shieldActive.Value == 1 then 
				myHumanoid.WalkSpeed = 19.0
			else 
				myHumanoid.WalkSpeed = 16.0 
			end 
			--if shieldWalkAnim then shielWalkAnim:Play() end 
		end 
	end 
end 

function bash(hit)	
	if hit.Anchored == false then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		vCharacter = Tool.Parent 
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		local opponent = hit.Parent:FindFirstChild("Torso")
		myTorso = vCharacter:FindFirstChild("Torso")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid ~=nil and myHumanoid ~= nil and myHumanoid ~= humanoid then 
			leftArm = vCharacter:FindFirstChild("Left Arm")
			if leftArm then 
				shieldGrip = leftArm:FindFirstChild("ShieldHolder")
				if shieldGrip and shieldGrip.Part1 == shield then
					tagHumanoid(humanoid, vPlayer)
					humanoid:TakeDamage(bashDamage)											
					wait(1.0)
					if bv then bv:Remove() end
					untagHumanoid(humanoid)
					if connection then connection:disconnect() end
				end
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid 
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag:Remove()
		end
	end
end

function onActivatedLocal()
	if Tool.Enabled == false then 
		return 
	end 

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	if myHumanoid == nil or myTorso == nil then 
		return 	
	end
	
	Tool.Enabled = false 

	shieldActive = Tool:FindFirstChild("ShieldActive")

	shield = vCharacter:FindFirstChild("Shield")

	--slashAnim = myHumanoid:LoadAnimation(Tool.QuickSlash)
	bashAnim = myHumanoid:LoadAnimation(Tool.ShieldBash)

	t = runService.Stepped:wait() 
	if t - dashTime < 0.2 and shieldActive.Value == 1 then   		
		slashIt(myHumanoid, myTorso) 
		wait(0.5) 
		amAnimating = false   
	else	
		if bashAnim then bashAnim:Play() end
		if shield then connection = shield.Touched:connect(bash) end
		wait(0.6)
		amAnimating = false
	end
	wait(0.5)
	Tool.Enabled = true
end

function onEquippedLocal(mouse)
	vCharacter = Tool.Parent
	mouse.KeyDown:connect(onKeyDown)
	mouse.KeyUp:connect(onKeyUp)
end

function onUnequippedLocal()
	if shieldWalkAnim then shieldWalkAnim:Stop() end
	if slashAnim then slashAnim:Stop() end
	if bashAnim then bashAnim:Stop() end
	if spinAnim then spinAnim:Stop() end

	if Tool.ShieldActive then Tool.ShieldActive.Value = 0 end

	if vCharacter then
		leftArm = vCharacter:FindFirstChild("Left Arm")
		if leftArm then 
			shield = vCharacter:FindFirstChild("Shield")
			shieldWeld = leftArm:FindFirstChild("ShieldHolder")
		end
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			ratio = myHumanoid.Health/myHumanoid.MaxHealth
			myHumanoid.Health = ratio * 100
			myHumanoid.MaxHealth = 100
			myHumanoid.WalkSpeed = 16.0
		end
	end
	if connection then connection:disconnect() end		
	if shield then shield:Remove() end
	if shieldWeld then shieldWeld:Remove() end
	if defenseAnim then defenseAnim:Stop() end
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivatedLocal)