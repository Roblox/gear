local Tool = script.Parent
local Cannon = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

Tool.Enabled = true

local numNeedles = 6

local spark = Instance.new("Sparkles")
local sparkColors = {Color3.new(1, 0, 0),
				Color3.new(0,1,0),
				Color3.new(0,0,1),
				Color3.new(1,1,0),
				Color3.new(1,0,1),
				Color3.new(0,1,1)}

local dart = Instance.new("Part")
dart.FormFactor = 3
dart.Size = Vector3.new(0.2, 0.2, 2.13)
dart.Shape = "Block"

local dartMesh = Instance.new("SpecialMesh")
dartMesh.Parent = dart
dartMesh.MeshId = "http://www.roblox.com/asset/?id=45728730"
dartMesh.TextureId = "http://www.roblox.com/asset/?id=45728837"
dartMesh.Scale = Vector3.new(1.1, 1.1, 1.1)

local rocket = Instance.new("Part")
rocket.Size = Vector3.new(0.3, 0.3, 0.3)
rocket.Transparency = 0.8
rocket.Shape = "Ball"
rocket.FormFactor = 3
rocket.Name ="HC"

local rocketMesh = Instance.new("SpecialMesh")
rocketMesh.MeshType = "FileMesh"
rocketMesh.Name = "Mesh"
rocketMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
rocketMesh.TextureId = "http://www.roblox.com/asset/?id=48598142"
rocketMesh.Scale = Vector3.new(0.015, 0.015, 0.015)
rocketMesh.Parent = rocket 

local fire = Instance.new("Fire")
fire.Size = 0.1
fire.Heat = 5.0
fire.Parent = rocket
fire.Color = Color3.new(124/255, 252/255, 0)

local newBV = Instance.new("BodyVelocity")
newBV.P = 1000
newBV.maxForce = Vector3.new(newBV.P, newBV.P, newBV.P)
newBV.Name = "BV"

local newBT = Instance.new("BodyThrust")
newBT.Name = "BT"

local newBF = Instance.new("BodyPosition")
newBF.P = 10000
newBF.maxForce = Vector3.new(newBF.P, newBF.P, newBF.P)
newBF.Name = "BF"

local fireSound
local boom

local rocketClone = {}

local debris = game:GetService("Debris")

function blow(part, hit)
	if hit.Name ~= "rocketClone" then     
		humanoid = hit.Parent:FindFirstChild("Humanoid")		
		local e = Instance.new("Explosion")
		e.Name = "SPLODE"
		e.BlastPressure = 5000
		e.BlastRadius = 3
		e.Position = part.Position
		e.Parent = game.Workspace
		debris:AddItem(e, 1.0)

		if boom then boom:Play() end     
		if part then part:Destroy() end

		vCharacter = Tool.Parent
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and vPlayer then
			tagHumanoid(humanoid, vPlayer)		    
		end
	end
end 

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
		debris:AddItem(creatorTag, 1)
	end
end

function shoot(pos)
	vCharacter = Tool.Parent

	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then
		print("Humanoid not found")
		return
	end     

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then
		print("Player not found")
		return
	end

	if fireSound then fireSound:Play()end     

	for i = 1, 9 do
		tick()
		rocketClone[i] = rocket:Clone()
		rocketClone[i].CanCollide = false

		local spawnPos = vCharacter.PrimaryPart.Position
		spawnPos = spawnPos + pos.unit * 8.0 
		
		rocketClone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) + Vector3.new(math.random() * 2, math.random() * 2, math.random() * 2) 
		rocketClone[i].Velocity = pos * 40.0          
		rocketClone[i].Name ="rocketClone"
		rocketClone[i].Parent = game.Workspace          		   	         

		local rocketCloneFloat = Instance.new("BodyForce")
		rocketCloneFloat.force = Vector3.new(0.0, rocketClone[i]:GetMass() * workspace.Gravity, 0.0)
		rocketCloneFloat.Parent = rocketClone[i]

		rocketClone[i].Touched:connect(function(hit) blow(rocketClone[i], hit) end)

		debris:AddItem(rocketClone[i], 6.0)
	end
end 

function pierce(missile, hit)
	if missile and hit and hit.Parent then
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= myHumanoid and myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(13)
		end
	end
end

function fire(dPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")
	
	littleSpark = spark:Clone()
	littleSpark.Parent = missile
	littleSpark.Color = sparkColors[math.random(1,#sparkColors)]	

	if vCharacter.Name == "Backpack" then return end
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos.unit*5
	dPos = dPos - dPos.unit * 5
	
	-- convert to a 2D space
	deltaXZSquared = dPos.X*dPos.X + dPos.Z*dPos.Z
	deltaXZ = math.sqrt(deltaXZSquared)
	deltaY = dPos.Y	
	
	alpha = math.random()*math.pi/8 + math.pi/3	

	missile.Position = spawnPos
	missile.Size = Vector3.new(math.random()*0.01,math.random()*0.01,math.random()*0.01)
	missile.RotVelocity = Vector3.new((math.random()-.5)*20, (math.random()-.5)*20, (math.random()-.5)*20)

	gravity = 196.1643
	numerator = -0.5*gravity*deltaXZSquared
	denominator = math.cos(alpha)*math.cos(alpha)*(deltaY - math.tan(alpha)*deltaXZ)	
	
	if denominator == 0 then return end
	missileSpeed = math.sqrt(numerator / denominator)
	if missileSpeed > 300 then missileSpeed = 300 end
	vXZ = missileSpeed * math.cos(alpha)
	vY = missileSpeed * math.sin(alpha)
	vX = vXZ * dPos.X / deltaXZ
	vZ = vXZ * dPos.Z / deltaXZ
	missile.Velocity = Vector3.new(vX, vY, vZ)	
	
	missile.BrickColor = BrickColor.Random()
	missile.Shape = math.random(0,2)

	missile.Name = "Spark"
	missile.Reflectance = 1
	missile.Transparency = 0
	missile.CanCollide = false	

	missile.Parent = game.Workspace

	confettiBang = Tool.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then 
		confettiBang.Volume = .1
		confettiBang:Play() 
	end
end

function throw(dPos)

	local vCharacter = Tool.Parent
	if vCharacter == nil then return end
	local vHum = vCharacter:FindFirstChild("Humanoid")
	if vHum == nil then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	
	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos*5
	
	local missile = dart:Clone()
	missile.Transparency = 0	
	missile.CFrame = CFrame.new(spawnPos, spawnPos + dPos) * CFrame.Angles(0, 0, math.pi/2)

	missile.Velocity = dPos * 50
	missile.RotVelocity = Vector3.new(0, 0, 0)
	missile.Name = "ThrownKunai"
	missile.CanCollide = true

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, missile:getMass() * workspace.Gravity,0)
	force.Parent = missile	

	missile.Parent = game.Workspace

	debris:AddItem(missile, 4)

	missile.Touched:connect(function(hit) pierce(missile, hit) end)
end


function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	tick()
	local projectileType = math.random(1, 3)

	if projectileType == 1 then
		-- do Confetti
		for i = 1,25 do 
			local targetPos = myHumanoid.TargetPoint		
			local lookAt = targetPos - vCharacter.PrimaryPart.Position		
			fire(lookAt) 
			wait(0.1)
		end
	elseif projectileType == 2 then 
		-- do eneryballs
	  local target = myHumanoid.TargetPoint
     local lookAt = (target - myTorso.Position).unit
     
     shoot(lookAt)      
	else 
		print("Darting")
		-- do darts
	  local target = myHumanoid.TargetPoint
     local lookAt = (target - myTorso.Position).unit
     
		for i = 1, numNeedles do
			xNoise = (math.random()-.5)*.1
			yNoise = (math.random()-.5)*.1
			zNoise = (math.random()-.5)*.1
			throw(CFrame.Angles(xNoise, yNoise, zNoise) * lookAt)		
			wait(0.1)
		end    
	end

	wait(3.0)
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end

function onUnequipped()
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
