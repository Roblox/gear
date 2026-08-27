local Tool = script.Parent
local Elixir = Tool.Handle

local flightSpin 
local flightPower 
local flightHold 

local wing = Instance.new("Part")
wing.CanCollide = false 
wing.Shape = "Block"
wing.FormFactor = 3
wing.Size = Vector3.new(3, 1, 3)

local wingM = Instance.new("SpecialMesh")
wingM.TextureId = "http://www.roblox.com/asset/?id=55821488"
wingM.Scale = Vector3.new(3.5, 3.5, 3.5)
wingM.Parent = wing

local leftWing
local rightWing
local leftWeld
local rightWeld

local leftW1
local rightW1

local wingCo 
local cooldownCo

local vCharacter
local myTorso
local myHumanoid

local wingActive 

local debris = game:GetService("Debris")

Tool.Enabled = true

function blow(hit)
	if hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
	end
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	if humanoid ~= nil and humanoid ~= myHumanoid then 
		tagHumanoid(humanoid, vPlayer)
		humanoid:TakeDamage(5)
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creator = Instance.new("ObjectValue")
		creator.Parent = humanoid
		creator.Value = player
		creator.Name = "creator"
		debris:AddItem(creator, 1)
	end
end

function wingUpdate()	
	local count = 1
	local anglePerFrame = -0.010
	if leftWing and rightWing then 		
		leftWeld = leftWing:FindFirstChild("LeftWeld")
		rightWeld = rightWing:FindFirstChild("RightWeld")				
		if leftWeld then leftW1 = leftWeld.C1  end
		if rightWeld then rightW1 = rightWeld.C1 end
	end
	while leftWeld and rightWeld do
		leftWeld.C1 = leftWeld.C1 * CFrame.Angles(0, anglePerFrame * (count%10), 0)
		rightWeld.C1 = rightWeld.C1 * CFrame.Angles(0, -anglePerFrame * (count%10), 0)		
		if count%10 == 0 then anglePerFrame = -anglePerFrame end 
		count = count + 1
		wait(0.03)
	end
end

function cooldown()
	wait(30.0)
	if leftWing then leftWing:Destroy() end
	if rightWing then rightWing:Destroy() end
	if flightSpin then flightSpin:Destroy() end
	if flightPower then flightPower:Destroy() end
	if flightHold then flightHold:Destroy() end
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 100
	wait(0.1)
	myHumanoid.Health = ratio * 100
	wait(15.0)
	if leftWeld and leftW1 then leftWeld.C1 = leftW1 end
	if rightWeld and rightW1 then rightWeld.C1 = rightW1 end
	Tool.Enabled = true 
	Elixir.Transparency = 0.0
	if wingActive then wingActive.Value = 0 end
end

function onActivated()
	vCharacter = Tool.Parent
	if vCharacter ~= nil then
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
			wingActive = Tool:FindFirstChild("WingActive")			
			if myTorso then
				if cooldownCo == nil or coroutine.status(cooldownCo) == 'dead' then
					Elixir.Transparency = 1.0			

					ratio = myHumanoid.Health/myHumanoid.MaxHealth
					myHumanoid.MaxHealth = 200
					wait(0.1)
					myHumanoid.Health = ratio * 200
					
					flightSpin = myTorso:FindFirstChild("FlightSpin")
					flightPower = myTorso:FindFirstChild("FlightPower")
					flightHold = myTorso:FindFirstChild("FlightHold")
					if flightSpin ~= nil or flightPower ~= nil or flightHold ~= nil then debounce = false return end
					Tool.Enabled = false
					if wingActive then wingActive.Value = 1 end
					leftWing = wing:Clone()
					leftWing.Name = "LeftWing"
					leftWing.Mesh.MeshId = "http://www.roblox.com/asset/?id=55820516"
					leftWing.Parent = vCharacter

					rightWing = wing:Clone()
					rightWing.Name = "RightWing"
					rightWing.Mesh.MeshId = "http://www.roblox.com/asset/?id=55821108"
					rightWing.Parent = vCharacter
				
					leftWeld = Instance.new("Weld")
					leftWeld.Name = "LeftWeld"
					leftWeld.Part0 = myTorso
					leftWeld.Part1 = leftWing
					leftWeld.C1 = CFrame.new(Vector3.new(-2.4, -0.5, -0.5)) * CFrame.Angles(math.pi/2, math.pi, 0)
					leftWeld.Parent = leftWing
		
					rightWeld = leftWeld:Clone()
					rightWeld.Name = "RightWeld"
					rightWeld.Part1 = rightWing
					rightWeld.Parent = rightWing
					rightWeld.C1 = CFrame.new(Vector3.new(2.4, -0.5, -0.5)) * CFrame.Angles(math.pi/2, math.pi, 0)
					
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

					wingCo = coroutine.create(wingUpdate)
					coroutine.resume(wingCo)

					cooldownCo = coroutine.create(cooldown)
					coroutine.resume(cooldownCo)

					leftWing.Touched:connect(blow)
					rightWing.Touched:connect(blow)
				end
			end
		end
	end
end

function onUnequipped()		
	if flightPower then flightPower:Destroy() end
	if flightSpin then flightSpin:Destroy() end
	if flightHold then flightHold:Destroy() end
	
	if leftWing then leftWing:Destroy() end
	if rightWing then rightWing:Destroy() end

	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 100
		wait(0.1)
		myHumanoid.Health = ratio * 100
	end
end


Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

