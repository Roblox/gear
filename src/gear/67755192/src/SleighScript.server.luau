local Tool = script.Parent
local Sleigh = Tool.Handle

local flightSpin 
local flightPower 
local flightHold 

local cooldownCo

local vCharacter
local myTorso
local myHumanoid

local fire 

local sleighActive 

local debris = game:GetService("Debris")

Tool.Enabled = true

local santaSound

local giftAssets = {6125503, 6203087, 66897125, 41452698}

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creator = Instance.new("ObjectValue")
		creator.Parent = humanoid
		creator.Value = player
		creator.Name = "creator"
		debris:AddItem(creator, 1)
	end
end

function cooldown()
	wait(40.0)	
	if flightSpin then flightSpin:Destroy() end
	if flightPower then flightPower:Destroy() end
	if flightHold then flightHold:Destroy() end
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 100
	wait(0.1)
	myHumanoid.Health = ratio * 100
	Tool.Enabled = false 
	if fire then fire:Destroy() end
	sleighUp()
	wait(15.0)	
	Tool.Enabled = true 
	Sleigh.Transparency = 0.0
	if sleighActive then sleighActive.Value = 0 end	
end

function sleighUp()
	Tool.GripForward = Vector3.new(1, 0, 0)
	Tool.GripPos = Vector3.new(-0.8, 0, -1)
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0, 0)	
	Sleigh.Mesh.Scale = Vector3.new(0.7, 0.7, 0.7)
end 

function sleighMid()
	Tool.GripForward = Vector3.new(1, 0, 0)
	Tool.GripPos = Vector3.new(1.2, -1.5, 1.7)
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0, 0)	
	Sleigh.Mesh.Scale = Vector3.new(1.4, 1.4, 1.4)
end 

function onActivated()
	vCharacter = Tool.Parent
	if vCharacter ~= nil then
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
			sleighActive = Tool:FindFirstChild("SleighActive")			
			if myTorso then
				if cooldownCo == nil or coroutine.status(cooldownCo) == 'dead' then
					--Sleigh.Transparency = 1.0	

					sleighMid()
					
					ratio = myHumanoid.Health/myHumanoid.MaxHealth
					myHumanoid.MaxHealth = 200
					wait(0.1)
					myHumanoid.Health = ratio * 200
					
					flightSpin = myTorso:FindFirstChild("FlightSpin")
					flightPower = myTorso:FindFirstChild("FlightPower")
					flightHold = myTorso:FindFirstChild("FlightHold")
					if flightSpin ~= nil or flightPower ~= nil or flightHold ~= nil then debounce = false return end					
					if sleighActive then print("Setting Sleigh Active") sleighActive.Value = 1 end				
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

				elseif Tool.Enabled then
					if sleighActive and sleighActive.Value == 1 then 
						local players = game.Players:GetChildren() 
						for i = 1, #players do 
							if players[i] and players[i].Character and (players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")) and players[i] ~= vPlayer then 
								local torso = players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")
								local distance = (torso.Position - myTorso.Position).magnitude 
								if distance < 25 then 
									print("Close enough")
									local asset = game:GetService("InsertService"):LoadAsset(giftAssets[math.random(1, #giftAssets)]):GetChildren()[1]
									print(asset, #asset:GetChildren())
									if asset and asset:FindFirstChild("Handle") then 
										santaSound = Sleigh:FindFirstChild("SantaSound")
										if santaSound then santaSound:Play() end 
										asset.Parent = game.Workspace
										asset.Handle.CFrame = myTorso.CFrame + myTorso.CFrame.lookVector * 5.0 
										asset.Handle.Velocity = (torso.Position - myTorso.Position).unit * 40.0 
										Tool.Enabled = false 
										debris:AddItem(asset, 20)
										wait(5.5)
										Tool.Enabled = true 
										break 
									end 
								end 
							end 
						end 
					end 					
				end
			end
		end
	end
end

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end 

function onUnequipped()		
	if flightPower then flightPower:Destroy() end
	if flightSpin then flightSpin:Destroy() end
	if flightHold then flightHold:Destroy() end

	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 100
		wait(0.1)
		myHumanoid.Health = ratio * 100
	end
	sleighUp()
	if santaSound then santaSound:Stop() end 
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

