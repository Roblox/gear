-- Sword and shield

local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local shieldWeld

local shieldWalkAnim
local slashAnim
local bashAnim
local lungeAnim
local time

local shieldActive
local lastAttack = 0

local bashDamage = 12
local connection

local dashTime = 0
local lastKeyDown = 0

Tool.Enabled = true

local runService = game:service("RunService")

function slashIt(hum, torso) 
	lungeAnim = hum:LoadAnimation(Tool["LungeAnim"]) 
	if lungeAnim == nil then Tool.Enabled = true return end 
	lungeAnim:Play()  
	local target = hum.TargetPoint 
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1) 
	newBV = nil 
	if direction.magnitude > .01 then 		
		direction = direction.unit 
		newBV = Instance.new("BodyVelocity") 
		newBV.P = 100000 
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P) 
		newBV.velocity = direction * 50 
		newBV.Parent = torso 
		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0)) 
	end 
	wait(.5) 	
	if newBV ~= nil then newBV:remove() end 
	wait(.5) 
end 

function onKeyDown(key)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	if key:lower() == "q" then 
		if vCharacter:FindFirstChild("Shield") then 
			print("Found Shield")

			torso = vCharacter.Torso
			shieldWeld = torso:FindFirstChild("ShieldHolder")
			leftArm = vCharacter:FindFirstChild("Left Arm")
			if shieldWeld then 
				shieldWeld.Parent = leftArm
				shieldWeld.Part0 = leftArm				
				
				shieldWalkAnim = myHumanoid:LoadAnimation(Tool.ShieldWalk)
				shieldWalkAnim:Play()

				shieldWeld.C1 = (shieldWeld.C1 + Vector3.new(0.0, -0.25, 0.5)) * CFrame.Angles(-math.pi/5, math.pi, math.pi/5)	
				if Tool.ShieldActive then Tool.ShieldActive.Value = 1 end
				ratio = myHumanoid.Health/myHumanoid.MaxHealth
				print(ratio)
				myHumanoid.MaxHealth = 120			
				wait(0.2)
				myHumanoid.Health = myHumanoid.Health + (ratio * 20)
				myHumanoid.WalkSpeed = 18.0
			else
				shieldWeld = leftArm:FindFirstChild("ShieldHolder")
				if shieldWeld then
					shieldWeld.Parent = torso
					shieldWeld.Part0 = torso 							
					shieldWeld.C1 = CFrame.Angles(math.pi/2, math.pi, 0) * CFrame.new(Vector3.new(0, 0.2, -0.7))				
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
	if key == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
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

	slashAnim = myHumanoid:LoadAnimation(Tool.QuickSlash)
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
end

function onUnequippedLocal()
	if shieldWalkAnim then shieldWalkAnim:Stop() end
	if slashAnim then slashAnim:Stop() end
	if bashAnim then bashAnim:Stop() end

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
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivatedLocal)