-- KORBLOX! Sword and shield

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

local bashDamage = 13
local connection

local dashTime = 0
local lastKeyDown = 0

local torsoCFrames = {}

local runService = game:service("RunService")

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
	if key:lower() == "q" then --Fix implemented by Luckymaxer
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

				shieldWeld.C1 = (shieldWeld.C1 + Vector3.new(-0.3, 0.2, -0.60)) * CFrame.Angles(-math.pi/5, math.pi, math.pi/5)	
				if Tool.ShieldActive then Tool.ShieldActive.Value = 1 end
			else
				shieldWeld = leftArm:FindFirstChild("ShieldHolder")
				if shieldWeld then
					shieldWeld.Parent = torso
					shieldWeld.Part0 = torso 							
					shieldWeld.C1 = CFrame.Angles(-math.pi/2, math.pi, 0) * CFrame.new(Vector3.new(0, 0.2, -1.1))				
				end
				if shieldWalkAnim then shieldWalkAnim:Stop() end
				if Tool.ShieldActive then Tool.ShieldActive.Value = 0 end
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
	end
	if connection then connection:disconnect() end		
	if shield then shield:Remove() end
	if shieldWeld then shieldWeld:Remove() end
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivatedLocal)