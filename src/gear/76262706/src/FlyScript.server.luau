local Tool = script.Parent
local Elixir = Tool.Handle

local flightSpin 
local flightPower 
local flightHold 

local cooldownCo

local vCharacter
local myTorso
local myHumanoid

local fire 

local wingActive 

local debris = game:GetService("Debris")

Tool.Enabled = true

local fireball = Instance.new("Part")
fireball.Size = Vector3.new(5, 5, 5)
fireball.Transparency = 0.5
fireball.Shape = "Ball"
fireball.FormFactor = 3
fireball.Name ="HC"

local fireballMesh = Instance.new("SpecialMesh")
fireballMesh.MeshType = "FileMesh"
fireballMesh.Name = "Mesh"
fireballMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
fireballMesh.TextureId = "http://www.roblox.com/asset/?id=48598142"
fireballMesh.Scale = Vector3.new(0.2, 0.2, 0.2)
fireballMesh.Parent = fireball

local massFire

local fire = Instance.new("Fire")
fire.Size = 20.0
fire.Heat = 5.0
fire.Parent = fireball 
fire.Color = Color3.new(1, 0, 0)
fire.SecondaryColor = Color3.new(1, 0, 0)

local fireballClone

local hunkScript 

function blow(laser, hit)	
	local humanoid 	
	if hit and hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")		
		if hit.Parent.ClassName == "Hat" then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)			
		if humanoid ~= nil and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(20)
			humanoid.Sit = true 		
			local e = Instance.new("Explosion")
			e.BlastRadius = 2
			e.BlastPressure = 0
			e.Position = hit.Position
			e.Parent = game.Workspace 
		end			
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

function cooldown()
	wait(45.0)	
	if flightSpin then flightSpin:Remove() end
	if flightPower then flightPower:Remove() end
	if flightHold then flightHold:Remove() end
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 100
	wait(0.1)
	myHumanoid.Health = ratio * 100
	Tool.Enabled = false 
	if fire then fire:Remove() end
	if hunkScript and hunkScript:FindFirstChild("Unequipped") then 
		hunkScript.Unequipped.Value = true 
	end 
	wait(15.0)
	if leftWeld and leftW1 then leftWeld.C1 = leftW1 end
	if rightWeld and rightW1 then rightWeld.C1 = rightW1 end
	Tool.Enabled = true 
	Elixir.Transparency = 0.0
	if wingActive then wingActive.Value = 0 end
end

function fireBeam(beamStart, beamEnd)
	local distance =(beamStart - beamEnd).magnitude
	if distance > 150 then distance = 150 end
	local laser = Instance.new("Part")
	laser.Name = "Bullet"
	laser.Anchored = true
	laser.CanCollide = false
	laser.Shape = "Block"
	laser.formFactor = "Custom"
	laser.Size = Vector3.new(0.2, 0.2, distance + 0.2)
	laser.Material = Enum.Material.Plastic
	laser.Locked = true
	laser.TopSurface = 0 
	laser.BottomSurface = 0
	laser.BrickColor = BrickColor.new("Bright red")
	laser.CFrame = CFrame.new(beamEnd, beamStart) * CFrame.new(0, 0, -distance/2)
	laser.Parent = game.Workspace
	laser.Touched:connect(function(hit) blow(laser, hit) end)
	debris:AddItem(laser, 0.15)
end

function shoot(pos, size, randVec)		
	fireballClone = fireball:Clone()
	fireballClone.CanCollide = false
	fireballClone.Anchored = false 

	if fireballClone:FindFirstChild("Mesh") then 
		fireballClone.Mesh.Scale = fireballClone.Mesh.Scale * size
	end 

	fireballClone.Size = fireballClone.Size * Vector3.new(size, size, size)

	local spawnPos = vCharacter.PrimaryPart.Position
	spawnPos = spawnPos + pos.unit * 5.0
	
	fireballClone.CFrame = CFrame.new(spawnPos, spawnPos + pos)
	fireballClone.Velocity = pos * 90.0 -- 25.0 -- 0.1 -- 50.0          
	fireballClone.Name = "Fireball"
	fireballClone.Parent = game.Workspace          	

	local fireballCloneFloat = Instance.new("BodyForce")
	fireballCloneFloat.force = Vector3.new(0.0, fireballClone:GetMass() * 196.1, 0.0)
	fireballCloneFloat.Parent = fireballClone

	fireballClone.Touched:connect(function(hit) blow(fireballClone, hit) end)	

	debris:AddItem(fireballClone, 7.0)
end


function onActivated()
	vCharacter = Tool.Parent
	if vCharacter ~= nil then
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			myTorso = vCharacter:FindFirstChild("Torso")
			wingActive = Tool:FindFirstChild("WingActive")			
			if myTorso then
				if cooldownCo == nil or coroutine.status(cooldownCo) == 'dead' then

					hunkScript = Tool.HunkScript:Clone()
					hunkScript.Parent = vCharacter 
					hunkScript.Disabled = false 

					Elixir.Transparency = 1.0			
					
					ratio = myHumanoid.Health/myHumanoid.MaxHealth
					myHumanoid.MaxHealth = 250
					wait(0.1)
					myHumanoid.Health = ratio * 250
					
					flightSpin = myTorso:FindFirstChild("FlightSpin")
					flightPower = myTorso:FindFirstChild("FlightPower")
					flightHold = myTorso:FindFirstChild("FlightHold")
					if flightSpin ~= nil or flightPower ~= nil or flightHold ~= nil then debounce = false return end
					--Tool.Enabled = false
					if wingActive then print("Setting Wing Active") wingActive.Value = 1 end				
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

					fire = Instance.new("Fire")
					fire.Color = Color3.new(1, 0 ,0)
					fire.SecondaryColor = Color3.new(1, 0, 0)
					fire.Heat = 20 
					fire.Size = 6.0
					--fire.Parent = myTorso

					cooldownCo = coroutine.create(cooldown)
					coroutine.resume(cooldownCo)					

				elseif Tool.Enabled then
					Tool.Enabled = false 
					if wingActive and wingActive.Value == 1 then 
						local target = myHumanoid.TargetPoint 
						massFire = Tool:FindFirstChild("MassFire") 
						if massFire and massFire.Value == true then 
							-- do st00f 
							myTorso.Anchored = true 
							playAnim = Tool:FindFirstChild("PlayAnim")
							if playAnim and playAnim.Value == false then playAnim.Value = true end 
							for i = 1, math.random(8, 12) do 
								shoot((myHumanoid.TargetPoint - myTorso.Position).unit, 0.25) 	
								wait(0.2)
							end  
							myTorso.Anchored = false 
							wait(4.0) 
							massFire.Value = false
						else
							myTorso.Anchored = true
							playAnim = Tool:FindFirstChild("PlayAnim")
							if playAnim and playAnim.Value == false then playAnim.Value = true end 
							wait(1.5) 
							shoot((target - myTorso.Position).unit, 1) 								
							myTorso.Anchored = false 
						end 
					end 					
					wait(2.5)
					Tool.Enabled = true 
				end
			end
		end
	end
end

function onUnequipped()		
	if flightPower then flightPower:remove() end
	if flightSpin then flightSpin:remove() end
	if flightHold then flightHold:remove() end
	
	if leftWing then leftWing:Remove() end
	if rightWing then rightWing:Remove() end

	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 100
		wait(0.1)
		myHumanoid.Health = ratio * 100
	end

	if hunkScript and hunkScript:FindFirstChild("Unequipped") then 
		hunkScript.Unequipped.Value = true 
	end  
end


Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

