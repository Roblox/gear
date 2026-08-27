--Updated for R15 avatars by StarWars
local Tool = script.Parent

local handle = Tool:WaitForChild("Handle")

local EngineSound = handle:WaitForChild("Running")

local HoldAni = Tool:WaitForChild("holdAni")
local R15Sit = Tool:WaitForChild("R15Sit")

local Remote = Tool:WaitForChild("Remote")


local left=false
local right=false
local up=false
local down=false
local forward=false
local back= false
local mouse
local Character
local key_down_connect
local key_up_connect

local thrustForce
local thrustMagnitude
local thrustDirection
local RotationForce
local TurnGyro

local torsoWeld

local acceleration = 10
local deceleration = 10
local turnAlpha = .5
local alphaDampening = .2

local Equipped = false

local LastPosition = nil
local ActualVelocity = Vector3.new(0,0,0)

local CurrentSpeed=0
local turnSpeed=0
local turnSpeedAim=5
local pitchSpeed=0
function ThrustUpdater()
	while Equipped do
		local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
		if math.abs(turnSpeed)>alphaDampening	 then
			turnSpeed= turnSpeed-((alphaDampening)*(math.abs(turnSpeed)/turnSpeed))
		else 
			turnSpeed = 0		
		end
		if math.abs(pitchSpeed)>alphaDampening	 then
			pitchSpeed= pitchSpeed-((alphaDampening)*(math.abs(pitchSpeed)/pitchSpeed))
		else 
			pitchSpeed = 0		
		end
		local leanAmount= -turnSpeed*(math.pi/6)/1.5
		local direction = handle.CFrame.lookVector
		local xzdirection = Vector3.new(direction.x,0,direction.z).unit
		thrustForce.velocity = direction*(CurrentSpeed)
		EngineSound.Pitch =	1+(math.abs(CurrentSpeed/50)*1)
		xznormal= CFrame.Angles(0,math.pi/2,0)*xzdirection
		if math.abs(direction.y)>.99 then
			RotationForce.angularvelocity = TurnGyro.cframe*Vector3.new(0, turnSpeed, 0)
			pitchSpeed=0
		elseif not up and not down and not left and not right then
			local tforce =(pitchSpeed+(math.sin(tick()*4)*3))
			RotationForce.angularvelocity = TurnGyro.cframe*Vector3.new(tforce*xznormal.x, turnSpeed, tforce*xznormal.z)
		else
			RotationForce.angularvelocity = TurnGyro.cframe*Vector3.new(pitchSpeed*xznormal.x, turnSpeed, pitchSpeed*xznormal.z)
		end
		
		TurnGyro.cframe=CFrame.Angles(leanAmount*xzdirection.x,0,leanAmount*xzdirection.z)
		wait(1/60)
		if LastPosition then
			local npos = Vector3.new(torso.CFrame.p.x,0,torso.CFrame.p.z)
			local velocityDifference = math.abs(((npos-LastPosition).magnitude - (thrustForce.velocity.magnitude/30)))
			if velocityDifference> 1 then
				--CurrentSpeed=0
			end
			
		end
		LastPosition = Vector3.new(torso.CFrame.p.x,0,torso.CFrame.p.z)
	end
	
end


function onEquipped()
	Spawn(function()
		if Equipped then
			onUnequipped()
		end
		--
			--ControlsGui.Parent = game.Players.LocalPlayer.PlayerGui
			CurrentSpeed=25
			turnSpeed=0
			handle.Size = Vector3.new(0.2, 4.89, 6.08)
			Equipped = true
			Character=script.Parent.Parent
			local myTorso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
			local humanoid = Character:FindFirstChild("Humanoid")
			handle.CFrame = myTorso.CFrame
			humanoid.PlatformStand = true
			
			
			if TurnGyro then TurnGyro:Destroy() end
			TurnGyro = Instance.new('BodyGyro')
			TurnGyro.maxTorque = Vector3.new(math.huge,0,math.huge)
			TurnGyro.Parent = handle--myTorso			
			
			if thrustForce then thrustForce:Destroy() end
			thrustForce = Instance.new('BodyVelocity')
			thrustForce.maxForce = Vector3.new(math.huge,math.huge,math.huge)
			thrustForce.velocity = Vector3.new(0,0,0)
			thrustForce.Parent = handle--myTorso			
			
			if RotationForce then RotationForce:Destroy() end
			RotationForce = Instance.new('BodyAngularVelocity')
			RotationForce.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			RotationForce.angularvelocity = Vector3.new(0, 0, 0)
			RotationForce.Parent = handle--myTorso
			
			
			
			
			
			Spawn(ThrustUpdater)
			Spawn(function()
				
				myTorso.Anchored = true
				myTorso.CFrame = myTorso.CFrame+Vector3.new(0,3,0)
				
				if torsoWeld then torsoWeld:Destroy() end
				torsoWeld=Instance.new('Weld')
				torsoWeld.C0 = CFrame.new(0, -2.5, -0.2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				torsoWeld.Part0 = myTorso
				torsoWeld.Part1 = handle
				torsoWeld.Parent = myTorso
				handle.CanCollide = true
				
				wait(.1)
				handle.CanCollide = true
				myTorso.Anchored = false
				myTorso.CFrame = myTorso.CFrame+Vector3.new(0,3,0)
				local rightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
				local rgrip = rightArm:FindFirstChild('RightGrip')
				if rgrip then rgrip:Destroy() end
			end)
			
			if key_down_connect then
				key_down_connect = false
				key_up_connect = false
			end
			key_down_connect=true
			key_up_connect=true
		
			EngineSound:Play()
			Character.Humanoid.WalkSpeed = 0
		--end
	end)
end


function onUnequipped()
	Equipped = false
	wait(.3)
	--ControlsGui.Parent =script
	handle.Size = Vector3.new(0.2, 0.2, 0.2)	
	forwards = false
	left = false
	back = false
	right = false
	if RotationForce then
		RotationForce:Destroy()
		RotationForce=nil
	end
	if thrustForce then
		thrustForce:Destroy()
		thrustForce=nil
	end
	if TurnGyro then
		TurnGyro:Destroy()
		TurnGyro=nil
	end
	if torsoWeld then
		torsoWeld:Destroy()
		torsoWeld=nil
	end
	key_down_connect=false
	key_up_connect=false
	EngineSound:Stop()
	local humanoid = Character:FindFirstChild("Humanoid")
	humanoid.WalkSpeed = 16
	humanoid.PlatformStand = false
end

function keyUpFunc(key)	
	if key == nil then return end
	local key = key:lower()
	if key == "w" then
		up = false
	elseif key == "a" then
		left = false
	elseif key == "s" then
		down = false
	elseif key == "d" then
		right = false	
	elseif key == "q" then
		forwards = false
	elseif key == "e" then
		back = false	
	end
end

function keyDownFunc(key)	
	if key == nil then return end
	if inIntro then return end
	local key = key:lower()
	if key == "w" then
		up = true
		while up do
			pitchSpeed= math.min(8,pitchSpeed+(turnAlpha))
			wait(1/30)
		end
	elseif key == "a" then
		left = true
		while left do
			turnSpeed= math.min(3,turnSpeed+(turnAlpha))
			wait(1/30)
		end
	elseif key == "s" then
		down = true
		while down do
			pitchSpeed= math.min(8,pitchSpeed-(turnAlpha))
			wait(1/30)
		end
	elseif key == "d" then
		right = true

		while right do
			turnSpeed= math.max(-3,turnSpeed-(turnAlpha))
			wait(1/30)
		end
			
	elseif key == "q" then
		forwards = true
		while forwards do
			CurrentSpeed = math.max(0,math.min(50,CurrentSpeed+(acceleration*(1/30))))
			wait(1/30)
		end
	elseif key == "e" then
		back = true
		while back do
			CurrentSpeed = math.max(0,math.max(-50,CurrentSpeed-(deceleration*(1/30))))
			wait(1/30)
		end
	end
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

Remote.OnServerEvent:connect(function(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "KeyDown" and key_down_connect then
		keyDownFunc(...)
	end
	
	if func == "KeyUp" and key_up_connect then
		keyUpFunc(...)
	end
end)

script.Parent.Unequipped:connect(onUnequipped)
script.Parent.Equipped:connect(onEquipped)

