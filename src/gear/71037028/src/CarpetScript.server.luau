local Tool = script.Parent
local Carpet = Tool.Handle

function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		print("Waiting for" ..  instance)
		wait()
	end
end 

waitForChild(Tool, "CarpetB1Weld")
waitForChild(Tool, "CarpetB2Weld")
waitForChild(Tool, "CarpetTailWeld")
waitForChild(Carpet, "CarpetB1")
waitForChild(Carpet, "CarpetB2")
waitForChild(Carpet, "CarpetTail")

local carpetB1Weld = Tool.CarpetB1Weld
local carpetB2Weld = Tool.CarpetB2Weld
local carpetTailWeld = Tool.CarpetTailWeld 

local carpetB1 = Carpet.CarpetB1
local carpetB2 = Carpet.CarpetB2
local carpetTail = Carpet.CarpetTail


local sparkles
local flightSpin 
local flightPower 
local flightHold 

local cooldownCo

local vCharacter
local myTorso
local myHumanoid

local fire 

local carpetActive 

local debris = game:GetService("Debris")

Tool.Enabled = true

local santaSound

local giftAssets = {6125503, 6203087, 66897125, 41452698}

function cooldown()	
	Carpet.Transparency = 1.0
	if carpetTail then 
		sparkles = Instance.new("Sparkles")
		sparkles.Parent = carpetTail
	end 
	local duration = 40.0
	local sign = -1
	local count = 0
	local initTailC1
	local initB1C1 
	local initB2C1
	if carpetTailWeld then 
		initTailC1 = carpetTailWeld.C1 
	end 
	if carpetB1Weld then 
		initB1C1 = carpetB1Weld.C1
	end 
	if carpetB2Weld then 
		initB2C1 = carpetB2Weld.C1 
	end 

	if carpetB1 then 
		carpetB1.Mesh.MeshId = "http://www.roblox.com/asset/?id= 71034996"
	end 
	
	while duration > 0 do 
		duration = duration - wait()
		if carpetTailWeld and carpetB1Weld and carpetB2Weld then 
			carpetTailWeld.C1 = CFrame.Angles(-sign * math.pi/100, 0, 0) * carpetTailWeld.C1 
			carpetB1Weld.C1 = CFrame.Angles(-sign * math.pi/100, 0, 0) * carpetB1Weld.C1 
			carpetB2Weld.C1 = CFrame.Angles(sign * math.pi/100, 0, 0) * carpetB2Weld.C1 					
			if count%8 == 0 then 
				sign = sign * -1 
			end 
			count = count + 1
		end 
		wait()
	end 
	if carpetTailWeld then 
		carpetTailWeld.C1 = initTailC1 
	end 
	if carpetB1Weld then 
		carpetB1Weld.C1 = initB1C1
	end 
	if carpetB2Weld then 
		carpetB2Weld.C1 = initB2C1
	end 	
	if flightSpin then flightSpin:Remove() end
	if flightPower then flightPower:Remove() end
	if flightHold then flightHold:Remove() end
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 100
	wait(0.1)
	myHumanoid.Health = ratio * 100
	Tool.Enabled = false 
	if fire then fire:Remove() end
	if sparkles then sparkles:Remove() end
	carpetUp()
	wait(15.0)	
	Tool.Enabled = true 	
	if carpetActive then carpetActive.Value = 0 end	
	if carpetB1 then 
		carpetB1.Mesh.MeshId = "http://www.roblox.com/asset/?id=70989652"
	end 
	Carpet.Transparency = 0.0
end

function carpetUp()
	Tool.GripForward = Vector3.new(1, 0, 0)
	Tool.GripPos = Vector3.new(-1.5, -0.5, -3)
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0, 0)		
end 

function carpetMid()	
	Tool.GripForward = Vector3.new(0, 0, 1)	
	Tool.GripUp = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(-1, 0, 0)		
	Tool.GripPos =  Vector3.new(-1.5, 1.8, -2.4)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripRight = Vector3.new(-1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1, 0)
end 

function onActivated()
	vCharacter = Tool.Parent
	if vCharacter ~= nil then
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			myTorso = vCharacter:FindFirstChild("HumanoidRootPart")
			carpetActive = Tool:FindFirstChild("CarpetActive")			
			if myTorso then
				if cooldownCo == nil or coroutine.status(cooldownCo) == 'dead' then
					--Carpet.Transparency = 1.0	
					carpetMid()
					
					ratio = myHumanoid.Health/myHumanoid.MaxHealth
					myHumanoid.MaxHealth = 200
					wait(0.1)
					myHumanoid.Health = ratio * 200
					
					flightSpin = myTorso:FindFirstChild("FlightSpin")
					flightPower = myTorso:FindFirstChild("FlightPower")
					flightHold = myTorso:FindFirstChild("FlightHold")
					if flightSpin ~= nil or flightPower ~= nil or flightHold ~= nil then debounce = false return end					
					if carpetActive then print("Setting Carpet Active") carpetActive.Value = 1 end				
					flightSpin = Instance.new("BodyGyro")
					flightPower = Instance.new("BodyVelocity")

					flightHold = Instance.new("BodyPosition")
					flightHold.Name = "FlightHold"
					flightHold.P = 100000
					flightHold.maxForce = Vector3.new(0,0,0)


					flightPower.Name = "FlightPower"
					flightPower.velocity = Vector3.new(0,0,0)
					flightPower.P = 1000000
					flightPower.maxForce = Vector3.new(flightPower.P, flightPower.P, flightPower.P)
					flightPower.P = 10000

					flightSpin.Name = "FlightSpin"
					flightSpin.P = 1000000
					flightSpin.maxTorque = Vector3.new(flightSpin.P, flightSpin.P, flightSpin.P)

					flightSpin.cframe = myTorso.CFrame
					flightSpin.Parent = myTorso
					flightHold.position = myTorso.Position
					flightHold.Parent = myTorso
					flightPower.Parent = myTorso

					myTorso.Velocity = Vector3.new(0,0,0)
					myTorso.RotVelocity = Vector3.new(0,0,0)	

					myHumanoid.Sit = true 
					
					cooldownCo = coroutine.create(cooldown)
					coroutine.resume(cooldownCo)									
				end
			end
		end
	end
end

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("HumanoidRootPart")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	if carpetB1Weld then carpetB1Weld.Parent = Tool end 
	if carpetB2Weld then carpetB2Weld.Parent = Tool end 
	if carpetTailWeld then carpetTailWeld.Parent = Tool end 
end 

function onUnequipped()		
	if flightPower then flightPower:remove() end
	if flightSpin then flightSpin:remove() end
	if flightHold then flightHold:remove() end

	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 100
		wait(0.1)
		myHumanoid.Health = ratio * 100
	end
	carpetUp()
	if santaSound then santaSound:Stop() end 
	if sparkles then sparkles:Remove() end
	Carpet.Transparency = 0.0
	if carpetB1 then 
		carpetB1.Mesh.MeshId = "http://www.roblox.com/asset/?id=70989652"
	end 
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

