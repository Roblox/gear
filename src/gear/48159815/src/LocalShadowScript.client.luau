Tool = script.Parent
Sword = Tool.Handle

local shadowActive = Tool:FindFirstChild("ShadowActive")

-- Animations
local initiateCloneAnim
local shadowLungeAnim
local slashAnim
local dualSlashAnim

-- swordClone
local swordClone

-- To gauge key presses
local lungeTime = 0
local spinTime = 0

-- game service
local r = game:GetService("RunService")

local lastKeyDown = 0
local dashTime = 0
local lastSlash = 0

local newBV = nil

local connection

local dashSound = Tool.Handle.SlashSound
keyConnection = nil

local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
slashSound.Parent = Sword
slashSound.Volume = 1

local dualSlashSound

function slashIt(hum, torso)
	nsAnim = hum:LoadAnimation(Tool["Shadow Slash"])
	if nsAnim == nil then Tool.Enabled = true return end
	
	nsAnim:Play()

	local target = hum.TargetPoint
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1)
	newBV = nil
	if direction.magnitude > .01 then 
		-- make 'em dash forwards too
		direction = direction.unit
		newBV = Instance.new("BodyVelocity")
		newBV.P = 100000
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
		newBV.velocity = direction * 50
		newBV.Parent = torso

		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0))
	end
	
	wait(.5)
	dashSound:Play()
	if newBV ~= nil then newBV:remove() end
	wait(.5)
end


function initiateShadowBlade(key)
	key = key:lower()
	if key == "q" then		
		vChar = Tool.Parent
		myHumanoid = vChar:FindFirstChild("Humanoid")
		if myHumanoid == nil then 
			print("Humanoid not found")		
			return
		end
		
		if shadowActive.Value == 0 then 			
			initiateCloneAnim = myHumanoid:LoadAnimation(Tool.initiateCloneAnim)
			initiateCloneAnim:Play(0, 1.0, 1.0)
			wait(0.4)
			swordClone = Sword:Clone()
			swordClone.CanCollide = false
			swordClone.Name = "ShadowSwordClone"
			swordClone.Parent = vChar

			Sword.Transparency = 0.20
			swordClone.Transparency = 0.20

			leftArm = vChar:FindFirstChild("Left Arm")
			
			if Tool.Parent:FindFirstChild("Humanoid") ~= nil then
				local leftWeld = Instance.new("Weld")
				leftWeld.Name = "LeftGrip"
				leftWeld.Parent = leftArm
				leftWeld.Part0 = leftArm
				leftWeld.Part1 = swordClone
				leftWeld.C1 =  CFrame.new(Vector3.new(-0.75, 0.0, 1.75))  * CFrame.Angles(0.0, 0.0, math.pi/2.0)
				shadowActive.Value = 1
				--connection = swordClone.Touched:connect(blow)
			else	
				swordClone:Remove()
				--if connection then connection:disconnect() end
			end	
		end
	end

	if key == "w" then 
		t = r.Stepped:wait()
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t
	end
end

function attack()	
	slashSound:Play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end


amAnimating = false
function onActivatedL()
	vCharacter = Tool.Parent
	if vCharacter == nil then 
		return
	end
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end

	if amAnimating then return end
	Tool.Enabled = false
	amAnimating = true
	
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then Tool.Enabled = true return end	

	if Tool:FindFirstChild("ShadowActive").Value == 1 then
		t = r.Stepped:wait()
		if t - dashTime < 0.2 then 		
			slashIt(myHumanoid, myTorso)
			wait(0.5)
			amAnimating = false	
		else
			dualSlashAnim = myHumanoid:LoadAnimation(Tool.DualSlash)
			dualSlashAnim:Play()
			dualSlashSound = Tool:FindFirstChild("DualSlashSound")
			if dualSlashSound then dualSlashSound:Play() end
			wait(1.0)
			amAnimating = false
		end
	else
		--slashAnim = myHumanoid:LoadAnimation(Tool.Slash)
		--slashAnim:Play()
		attack()
		wait(0.3)
		amAnimating = false
	end
	if not amAnimating then Tool.Enabled = true end
end


function onEquippedL(mouse)
	print("IN EQUIP")
	shadowActive = Tool:FindFirstChild("ShadowActive")
	shadowActive.Value = 0
	if mouse then 
		keyConnection = mouse.KeyDown:connect(initiateShadowBlade) 		
	else 
		print("No Mouse") 
	end
end

function onUnequippedL()
	amAnimating = false
	if swordClone then 
		swordClone:Remove() 
		Tool:FindFirstChild("ShadowActive").Value = 0
	end	
	if connection then connection:disconnect() end
	Sword.Transparency = 0.0
	if dashSound then dashSound:Stop() end
	if slashSound then slashSound:Stop() end
	if dualSlashSound then dualSlashSound:Stop() end
	if newBV ~= nil then newBV:Remove() end
	
end


Tool.Equipped:connect(onEquippedL)
Tool.Unequipped:connect(onUnequippedL)
Tool.Activated:connect(onActivatedL)

