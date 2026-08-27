local Tool = script.Parent
local Cannon = Tool.Handle

local debris = game:GetService("Debris")

Tool.Enabled = true 

local rocket = Instance.new("Part")
rocket.Size = Vector3.new(0.5, 3, 0.5)
rocket.Transparency = 0.0
rocket.Shape = "Block"
rocket.FormFactor = 3
rocket.Name ="RocketClone"

local rocketMesh = Instance.new("SpecialMesh")
rocketMesh.MeshType = "FileMesh"
rocketMesh.Name = "Mesh"
rocketMesh.MeshId = "http://www.roblox.com/asset/?id=74333739"
rocketMesh.TextureId = "http://www.roblox.com/asset/?id=74320150"
rocketMesh.Scale = Vector3.new(2, 2, 2)
rocketMesh.Parent = rocket

local propulsion = Instance.new("RocketPropulsion") 
propulsion.CartoonFactor = 1.0 
propulsion.TargetRadius = 5.0 
propulsion.MaxSpeed = 70.0 
propulsion.ThrustD = 0.001
propulsion.ThrustP = 5 
propulsion.MaxTorque = Vector3.new(400000, 400000, 400000)
propulsion.TurnD = 500 
propulsion.TurnP = 3000
propulsion.TargetOffset = Vector3.new(0, 0.1, 0) 

local fireSound
local boom

local rocketClones = {}
local rocketClone 

local cooldown = false

local damage = 15

function blow(part, hit)
	if hit.Name ~= "RocketClone" and hit.Parent ~= vCharacter and hit.Parent ~= Tool and part then	
		print(hit) 
		humanoid = hit.Parent:FindFirstChild("Humanoid")		
		local e = Instance.new("Explosion")
		e.Name = "SPLODE"
		e.BlastPressure = 9999999
		e.BlastRadius = 3.5
		e.Position = part.Position		
		e.Parent = game.Workspace
		debris:AddItem(e, 1.0)				
		vCharacter = Tool.Parent
		if part then part:Remove() end
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and vPlayer then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)			
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

function shoot(pos, numToes, target)
	vCharacter = Tool.Parent	
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 		
		return
	end	

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then 		
		return
	end	

	local radius = 0.25
	local sign = -1	

	if target == nil then
		for i = 1, numToes do 
			if fireSound then fireSound:Play()end	
			rocketClones[i] = rocket:Clone()
			rocketClones[i].CanCollide = false		

			local spawnPos = Cannon.Position
			spawnPos = spawnPos + pos.unit * 5.0
			if numToes > 1 then spawnPos = spawnPos + (CFrame.Angles(math.random(), 0, math.random()) * pos + Vector3.new(0, 0.15, 0)).unit * 7.0 end 				
			
			rocketClones[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) --* CFrame.Angles(-math.pi/2, 0, 0) --+ radius * Vector3.new(0, 1, 0)				
			rocketClones[i].Velocity = pos * 60.0	
			rocketClones[i].Name ="RocketClone"
			rocketClones[i].Parent = game.Workspace					

			local toeCloneFloat = Instance.new("BodyForce")
			toeCloneFloat.force =  Vector3.new(0.0, rocketClones[i]:GetMass() * 196.1, 0.0)
			toeCloneFloat.Parent = rocketClones[i]

			rocketClones[i].Touched:connect(function(hit) blow(rocketClones[i], hit) end)
		
			debris:AddItem(rocketClones[i], 5)
			wait(0.25)
		end
	else  
		rocketClone = rocket:Clone()
		rocket.CanCollide = false 

		local rocketCloneFloat = Instance.new("BodyForce") 
		rocketCloneFloat.force = Vector3.new(0, rocketClone:GetMass() * 196.1, 0)
		--rocketCloneFloat.Parent = rocketClone 

		local spawnPos = Cannon.Position
		spawnPos = spawnPos + pos.unit * 5.0
			
			
		rocketClone.CFrame = CFrame.new(spawnPos, spawnPos + pos)-- * CFrame.Angles(-math.pi/2, 0, 0) --+ radius * Vector3.new(0, 1, 0)		

		local rPropulsion = propulsion:Clone()
		rPropulsion.Parent = rocketClone 
		rPropulsion.Target = target

		rocketClone.Parent = game.Workspace 
		rocketClone.Touched:connect(function(hit) blow(rocketClone, hit) end)
		debris:AddItem(rocketClone, 50)

		rPropulsion:Fire() 
	end 
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		print("Humanoid not found")
		return
	end

	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myTorso == nil then 
		print("Torso not found")
		return
	end

	boom = Tool:FindFirstChild("BOOM")
	
	target = myHumanoid.TargetPoint
	lookAt = (target - Cannon.Position).unit
	local rocketTarget 

	local findPart = game.Workspace:FindPartOnRay(Ray.new(Cannon.Position, lookAt * 500.0), vCharacter)	
	if findPart and findPart:GetMass() > 2000 then findPart = nil end 
	myHumanoid.WalkSpeed = 0.0
	myTorso.Anchored = true

	fireSound = Tool:FindFirstChild("FireSound")	
	local rapidFire = Tool:FindFirstChild("RapidFire")
	if rapidFire and rapidFire.Value == true and not cooldown then
		cooldown = true 
		shoot(lookAt, 6, findPart)	
		wait(1.5) 
		myHumanoid.WalkSpeed = 16.0
		myTorso.Anchored = false
		coroutine.resume(coroutine.create(function() 
			wait(6 * 2.75)
			local rapidFire = Tool:FindFirstChild("RapidFire")
			if rapidFire and rapidFire.Value == true then rapidFire.Value = false end		
			cooldown = false
		end))
		wait(1.0)
	else 
		shoot(lookAt, 1, findPart)
		wait(0.5)
		myHumanoid.WalkSpeed = 16.0
		myTorso.Anchored = false
		wait(2.5)
	end 

	myHumanoid.WalkSpeed = 16.0
	myTorso.Anchored = false
	wait(0.5)	
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 200
		myHumanoid.Health = ratio * 200
		while myHumanoid.Health < ratio * 200 do 
			myHumanoid.Health = ratio * 200
			wait()
		end
	end
end

function onUnequipped()
	if fireSound then fireSound:Stop()end
	if boom then boom:Stop() end

	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.Health = ratio * 100
		myHumanoid.MaxHealth = 100
	end
	if myTorso then myTorso.Anchored = false end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


