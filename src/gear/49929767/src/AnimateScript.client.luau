-- Sword and shield

local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local shieldWeld

local shieldWalkAnim
local slashAnim
local bashAnim
local time

local shieldActive
local lastAttack = 0

local bashDamage = 12
local connection

function bash(hit)
	print("Bashing")
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

local runService = game:service("RunService")

function onActivatedLocal()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return 	
	end

	shieldActive = Tool:FindFirstChild("ShieldActive")

	shield = vCharacter:FindFirstChild("Shield")

	slashAnim = myHumanoid:LoadAnimation(Tool.QuickSlash)
	bashAnim = myHumanoid:LoadAnimation(Tool.ShieldBash)

	time = runService.Stepped:wait()
	if time - lastAttack < 0.2 and shieldActive.Value == 1 then 
		if bashAnim then bashAnim:Play() end
		if shield then connection = shield.Touched:connect(bash) end
	else 
		if connection then connection:disconnect() end
		if slashAnim then slashAnim:Play() end
	end	
	lastAttack = time
	wait(0.5)
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

				shieldWeld.C1 = (shieldWeld.C1 + Vector3.new(0.0, 0.2, 0.5)) * CFrame.Angles(-math.pi/5, math.pi, math.pi/5)	
				if Tool.ShieldActive then Tool.ShieldActive.Value = 1 end
				ratio = myHumanoid.Health/myHumanoid.MaxHealth
				print(ratio)
				myHumanoid.MaxHealth = 175
				print(myHumanoid.MaxHealth)			
				print(myHumanoid.Health)
				myHumanoid.WalkSpeed = 14
				wait(0.2)
				myHumanoid.Health = myHumanoid.Health + (ratio * 75)
			else
				shieldWeld = leftArm:FindFirstChild("ShieldHolder")
				if shieldWeld then
					shieldWeld.Parent = torso
					shieldWeld.Part0 = torso 							
					shieldWeld.C1 = CFrame.new(Vector3.new(0, 0.7, 0)) * CFrame.Angles(math.pi/2, 0, 0)				
				end
				if shieldWalkAnim then shieldWalkAnim:Stop() end
				if Tool.ShieldActive then Tool.ShieldActive.Value = 0 end
				if myHumanoid.MaxHealth > 100 then 
					ratio = myHumanoid.Health/myHumanoid.MaxHealth 
					myHumanoid.Health = ratio * 100
					myHumanoid.MaxHealth = 100
					myHumanoid.WalkSpeed = 16
				end
			end
			
		end
	end
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
		end
	end
	if connection then connection:disconnect() end		
	if shield then shield:Remove() end
	if shieldWeld then shieldWeld:Remove() end
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivatedLocal)