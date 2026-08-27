--Fixed by Luckymaxer

local Tool = script.Parent
local Handle = Tool.Handle

Players = game:GetService("Players")

WingActive = Tool:WaitForChild("WingActive")

local flightSpin 
local flightPower 
local flightHold 

local cooldownCo

local vCharacter
local myTorso
local myHumanoid

local fire

local debris = game:GetService("Debris")

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

WingActive.Value = 0
Handle.Transparency = 0
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

local fire = Instance.new("Fire")
fire.Size = 20.0
fire.Heat = 5.0
fire.Parent = fireball 
fire.Color = Color3.new(1, 0, 0)
fire.SecondaryColor = Color3.new(1, 0, 0)

local fireballClone

function blow(laser, hit)	
	local humanoid 	
	if hit and hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")		
		if hit.Parent.ClassName == "Hat" then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if vPlayer and (not vPlayer.Neutral and vPlayer.TeamColor == Player.TeamColor) then
			return
		end
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
	wait(30.0)
	for i, v in pairs({flightPower, flightSpin, flightHold, leftWing, rightWing, fire}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 100
	myHumanoid.Health = ratio * 100
	Tool.Enabled = false 
	wait(15.0)
	if leftWeld and leftW1 then leftWeld.C1 = leftW1 end
	if rightWeld and rightW1 then rightWeld.C1 = rightW1 end
	Tool.Enabled = true 
	Handle.Transparency = 0.0
	WingActive.Value = 0
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
	laser.CFrame = CFrame.new(beamStart, beamEnd) * CFrame.new(0, 0, -distance/2)
	laser.Parent = game.Workspace
	laser.Touched:connect(function(hit) blow(laser, hit) end)
	debris:AddItem(laser, 0.15)
end

function shoot(pos)		
	fireballClone = fireball:Clone()
	fireballClone.CanCollide = false
	fireballClone.Anchored = true 

	local spawnPos = vCharacter.PrimaryPart.Position
	spawnPos = spawnPos + pos.unit * 10.0
	
	fireballClone.CFrame = CFrame.new(spawnPos, spawnPos + pos)
	fireballClone.Velocity = pos * 10.0 -- 25.0 -- 0.1 -- 50.0          
	fireballClone.Name = "Fireball"
	fireballClone.Parent = game.Workspace          	

	local fireballCloneFloat = Instance.new("BodyForce")
	fireballCloneFloat.force = Vector3.new(0.0, fireballClone:GetMass() * 196.1, 0.0)
	fireballCloneFloat.Parent = fireballClone

	fireballClone.Touched:connect(function(hit) blow(fireballClone, hit) end)	

	debris:AddItem(fireballClone, 200.0)
end


function onActivated()
	vCharacter = Tool.Parent
	Player = Players:GetPlayerFromCharacter(vCharacter)
	if vCharacter ~= nil then
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")		
			if myTorso then
				if cooldownCo == nil or coroutine.status(cooldownCo) == 'dead' then
					Handle.Transparency = 1.0			
					
					ratio = myHumanoid.Health/myHumanoid.MaxHealth
					myHumanoid.MaxHealth = 200
					myHumanoid.Health = ratio * 200
					
					flightSpin = myTorso:FindFirstChild("FlightSpin")
					flightPower = myTorso:FindFirstChild("FlightPower")
					flightHold = myTorso:FindFirstChild("FlightHold")
					if flightSpin ~= nil or flightPower ~= nil or flightHold ~= nil then debounce = false return end
					--Tool.Enabled = false
					WingActive.Value = 1
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
					fire.Parent = myTorso

					cooldownCo = coroutine.create(cooldown)
					coroutine.resume(cooldownCo)

				elseif Tool.Enabled then
					Tool.Enabled = false 
					WingActive.Value = 1
					local target = InvokeClient("MousePosition")
					if math.random() <= 1.0 then 
						fireBeam(vCharacter.Head.Position + Vector3.new(0, 0.5, 0) , target)					
						fireBeam(vCharacter.Head.Position + Vector3.new(0, -0.5, 0) , target)		
					else 
						shoot(target - myTorso.Position) 
					end	
					wait(3.5)
					Tool.Enabled = true 
				end
			end
		end
	end
end

function onUnequipped()
	for i, v in pairs({flightPower, flightSpin, flightHold, leftWing, rightWing, fire}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 100
		myHumanoid.Health = ratio * 100
	end
end

function OnServerInvoke(player, mode, value)
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

