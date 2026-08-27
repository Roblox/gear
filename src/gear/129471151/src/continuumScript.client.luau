function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do print("roped waiting for " .. child) wait() end
	return parent[child]
end

local handle = WaitForChild(script.Parent,'Handle')

local EngineSound = WaitForChild(handle,'Running')
local HonkSound = WaitForChild(handle,'Honk')


local HoldAni = WaitForChild(script.Parent,'holdAni')

local left=false
local right=false
local up=false
local down=false
local mouse
local Character
local key_down_connect
local key_up_connect

local thrustForce
local thrustMagnitude
local thrustDirection
local RotationForce
local TurnGyro

local HoldAniTrack

local torsoWeld

local SmokePart = Instance.new('Part')
SmokePart.Transparency = 1
SmokePart.Size = Vector3.new(0,0,0)
local ExhaustSmoke = Instance.new('Smoke')
ExhaustSmoke.Parent = SmokePart
ExhaustSmoke.Size = .1
ExhaustSmoke.RiseVelocity = .01
ExhaustSmoke.Color = Color3.new(.5,.5,.5)

local acceleration = 10
local deceleration = 10
local turnAlpha = .30
local alphaDampening = .2

local Equipped = false

local LastPosition = nil
local ActualVelocity = Vector3.new(0,0,0)

local FakeHandle = nil
local FrontWheel = Instance.new('Part')
FrontWheel.FormFactor = 'Custom'
FrontWheel.CanCollide = false
FrontWheel.Size = Vector3.new(2,1,1)
FrontWheel.Transparency = .5
FrontWheel.BrickColor = BrickColor.new('New Yeller')
FrontWheel.TopSurface = 'Smooth'
FrontWheel.BottomSurface = 'Smooth'

local WheelMesh = Instance.new('SpecialMesh')
WheelMesh.MeshId = "http://www.roblox.com/asset/?id=122202439"
WheelMesh.TextureId = "http://www.roblox.com/asset/?id=122185866"
WheelMesh.Scale = Vector3.new(2.5,2.5,2.5)

	
local LightLeft = FrontWheel:Clone()
local LightRight = FrontWheel:Clone()
local LightWeldLeft = nil
local LightWeldRight = nil

local CurrentSpeed=0
local turnSpeed=0
local turnSpeedAim=5
function ThrustUpdater()
	while Equipped do
		local direction = Character:FindFirstChild("Torso").CFrame.lookVector
		direction = Vector3.new(direction.x,0,direction.z).unit
		thrustForce.velocity = direction*(CurrentSpeed)
		EngineSound.Pitch =	1+(math.abs(CurrentSpeed/50)*1)
		

		RotationForce.angularvelocity = Vector3.new(0, turnSpeed, 0)
		if math.abs(turnSpeed)>alphaDampening	 then
			turnSpeed= turnSpeed-((alphaDampening)*(math.abs(turnSpeed)/turnSpeed))
		else 
			turnSpeed = 0		
		end
		local leanAmount= -turnSpeed*(math.pi/6)/4
		
		if not forwards or back then
			CurrentSpeed = CurrentSpeed*.99			
		end		
		
		local xzAngle = math.atan2(Character.Torso.CFrame.lookVector.z,0, Character.Torso.CFrame.lookVector.x)
		TurnGyro.cframe=CFrame.Angles(leanAmount*direction.x,0,leanAmount*direction.z)
		ExhaustSmoke.Opacity = (math.min(math.abs(CurrentSpeed),10)/10)*.5
		if LastPosition then
			local npos = Vector3.new(Character.Torso.CFrame.p.x,0,Character.Torso.CFrame.p.z)
			--(npos-LastPosition).magnitude
			local myspeed =Vector3.new(FakeHandle.Velocity.X,0,FakeHandle.Velocity.Z).magnitude
			local velocityDifference = math.abs((myspeed - (thrustForce.velocity.magnitude)))
			if myspeed>3 and thrustForce.velocity.magnitude>3 and velocityDifference> .7*thrustForce.velocity.magnitude then
				print('stopping: '..myspeed.." : " .. thrustForce.velocity.magnitude)
				CurrentSpeed=CurrentSpeed*.9
			end
			
		end
		LastPosition = Vector3.new(Character.Torso.CFrame.p.x,0,Character.Torso.CFrame.p.z)
		wait(1/60)
	end
	
end


function onEquipped(nmouse)
	print('got to equipped')
	Spawn(function()
		if Equipped then
			return
		end
		--
			Character=script.Parent.Parent
			local myTorso = WaitForChild(Character,'Torso')
			if not FakeHandle then
				FakeHandle = handle:Clone()
				FakeHandle.Name = 'FakeHandle'
				FakeHandle.Size = Vector3.new(9.47, 0.64, 19.02)--1, 4.89, 6.08)
				FakeHandle.Transparency = 1
				FakeHandle:WaitForChild('Mesh').MeshId = ""
				
			end
			FakeHandle.Parent = script.Parent
			FakeHandle.CFrame = myTorso.CFrame

			Spawn(function()
				

				LightLeft.Parent = FakeHandle
					LightWeldLeft = Instance.new('Weld')
					LightWeldLeft.C0 = CFrame.new(0, 0, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
					LightWeldLeft.C1 = CFrame.new(5.5, -.7, 8, 0, 0, -1, 0, 1, 0, 1, 0, 0)
					LightWeldLeft.Part0 = FakeHandle
					LightWeldLeft.Part1 = LightLeft
					LightWeldLeft.Parent = FakeHandle
					local tlight = Instance.new('SpotLight')
					tlight.Brightness = 5
					tlight.Angle=45
					tlight.Color = Color3.new(255/255,252/255,153/255)
					tlight.Parent = LightLeft
					tlight.Range = 40
					
				LightRight.Parent = FakeHandle
					LightWeldRight = Instance.new('Weld')
					LightWeldRight.C0 = CFrame.new(0, 0, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
					LightWeldRight.C1 = CFrame.new(-5.5, -.7, 8, 0, 0, -1, 0, 1, 0, 1, 0, 0)
					LightWeldRight.Part0 = FakeHandle
					LightWeldRight.Part1 = LightRight
					LightWeldRight.Parent = FakeHandle
					tlight = Instance.new('SpotLight')
					tlight.Brightness = 5
					tlight.Angle=45
					tlight.Color = Color3.new(255/255,252/255,153/255)
					tlight.Parent = LightRight
					tlight.Range = 40
					
			end)
			
			CurrentSpeed=0
			turnSpeed=0
			print('got in if')
			mouse=nmouse
			Equipped = true
			
			handle.CFrame = myTorso.CFrame
			WaitForChild(Character,'Humanoid').PlatformStand = true
			
			if RotationForce then RotationForce:Destroy() end
			RotationForce = Instance.new('BodyAngularVelocity')
			RotationForce.maxTorque = Vector3.new(0, math.huge, 0)
			RotationForce.angularvelocity = Vector3.new(0, 0, 0)
			RotationForce.Parent = myTorso
			
			if thrustForce then thrustForce:Destroy() end
			thrustForce = Instance.new('BodyVelocity')
			thrustForce.maxForce = Vector3.new(math.huge,0,math.huge)
			thrustForce.velocity = Vector3.new(0,0,0)
			thrustForce.P = 100
			thrustForce.Parent = FakeHandle--myTorso
			
			if TurnGyro then TurnGyro:Destroy() end
			TurnGyro = Instance.new('BodyGyro')
			TurnGyro.maxTorque = Vector3.new(5000,0,5000)
			TurnGyro.P = 300
			TurnGyro.D=100
			TurnGyro.Parent = myTorso
			
			Spawn(ThrustUpdater)
			if HoldAniTrack then HoldAniTrack:Stop() end
			HoldAniTrack = WaitForChild(Character,'Humanoid'):LoadAnimation(HoldAni)
			HoldAniTrack:Play()
			Spawn(function()
				
				
				myTorso.Anchored = true
				myTorso.CFrame = myTorso.CFrame+Vector3.new(0,3,0)
				
				if torsoWeld then torsoWeld:Destroy() end
				torsoWeld=Instance.new('Weld')
				torsoWeld.C0 = CFrame.Angles(0,0,0) + Vector3.new(3.5, -3, -1)
				torsoWeld.Part0 = myTorso
				torsoWeld.Part1 = FakeHandle
				torsoWeld.Parent = FakeHandle
				FakeHandle.CanCollide = true
				
				wait(.1)
				FakeHandle.CanCollide = true
				myTorso.Anchored = false
				myTorso.CFrame = myTorso.CFrame+Vector3.new(0,3,0)
			end)
			
			if key_down_connect then
				key_down_connect:disconnect()
				key_up_connect:disconnect()
			end
			key_down_connect=mouse.KeyDown:connect(keyDownFunc)
			key_up_connect=mouse.KeyUp:connect(keyUpFunc)
		
			SmokePart.Parent = FakeHandle

			local tweld=Instance.new('Weld')
			tweld.C0 = CFrame.new(4, -1.10000014, -13, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			tweld.Part0 = SmokePart
			tweld.Part1 = FakeHandle
			tweld.Parent = SmokePart
			
			EngineSound:Play()
			Character.Humanoid.WalkSpeed = 0
		--end
	end)
end


function onUnequipped()
	Equipped = false
	if SmokePart then
		SmokePart.Parent = nil
	end
	if FakeHandle then
		FakeHandle:Remove()
		FakeHandle = nil
	end
	handle.Transparency = 0
	--handle.Size = Vector3.new(0.2, 0.2, 0.2)
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
	if HoldAniTrack then
		HoldAniTrack:Stop()
	end
	if torsoWeld then
		torsoWeld:Destroy()
		torsoWeld=nil
	end 
	if key_down_connect then
		key_down_connect:disconnect()
		key_down_connect=nil
	end
	if key_up_connect then
		key_up_connect:disconnect()
		key_up_connect=nil
	end
	if EngineSound then
		EngineSound:Stop()
	end
	if Character and Character:FindFirstChild('Humanoid') then
		Character.Humanoid.WalkSpeed = 16
		Character.Humanoid.PlatformStand = false
	end
	print("I unequipped!")
end




function keyUpFunc(key)	
	if key == nil then return end
	local key = key:lower()
	if key == "w" then
		forwards = false
	elseif key == "a" then
		left = false
	elseif key == "s" then
		back = false
	elseif key == "d" then
		right = false	
	end
end
local LastSpace = tick()
function keyDownFunc(key)	
	if key == nil then return end
	if inIntro then return end
	local key = key:lower()
	if key == "w" then
		forwards = true
		while forwards do
			CurrentSpeed = math.min(70,CurrentSpeed+(acceleration*(1/30)))
			wait(1/30)
		end
	elseif key == "a" then
		left = true
		while left do
			turnSpeed= math.min(5,turnSpeed+(turnAlpha))
			wait(1/30)
		end
	elseif key == "s" then
		back = true
		while back do
			if CurrentSpeed>0 then
				CurrentSpeed = math.max(-20,CurrentSpeed-(deceleration*2.8*(1/30)))
			else
				CurrentSpeed = math.max(-20,CurrentSpeed-(deceleration*(1/30)))
			end
			wait(1/30)
		end
	elseif key == "d" then
		right = true

		while right do
			turnSpeed= math.max(-5,turnSpeed-(turnAlpha))
			wait(1/30)
		end
	elseif key == ' ' then

			LastSpace = tick()
			HonkSound:Play()

	end
	print( ("The '%s' key was pressed"):format(key) )
end

script.Parent.Unequipped:connect(onUnequipped)
script.Parent.Equipped:connect(onEquipped)

