local Tool = script.Parent
local Cannon = Tool.Handle

local debris = game:GetService("Debris")

Tool.Enabled = true 

local toe = Instance.new("Part")
toe.Size = Vector3.new(0.5, 0.5, 0.5)
toe.Transparency = 0.0
toe.Shape = "Ball"
toe.FormFactor = 3
toe.Name ="Toe"

local rocketMesh = Instance.new("SpecialMesh")
rocketMesh.MeshType = "FileMesh"
rocketMesh.Name = "Mesh"
rocketMesh.MeshId = "http://www.roblox.com/asset/?id=66865853"
rocketMesh.TextureId = "http://www.roblox.com/asset/?id=66865732"
rocketMesh.Scale = Vector3.new(1, 1, 1)
rocketMesh.Parent = toe

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

local toeClone = {}

local cooldown = false

local damage = 15

function blow(part, hit)
	if hit.Name ~= "toeClone" and hit.Parent ~= vCharacter and hit.Parent ~= Tool and part then	
		humanoid = hit.Parent:FindFirstChild("Humanoid")		
		local e = Instance.new("Explosion")
		e.Name = "SPLODE"
		e.BlastPressure = 9999999
		e.BlastRadius = 3.5
		e.Position = part.Position		
		e.Parent = game.Workspace
		debris:AddItem(e, 1.0)				
		vCharacter = Tool.Parent
		if part then part:Destroy() end
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

function shoot(pos, numToes)
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

	for i = 1, numToes do 
		if fireSound then fireSound:Play()end	
		toeClone[i] = toe:Clone()
		toeClone[i].CanCollide = false		

		local spawnPos = Cannon.Position
		spawnPos = spawnPos + pos.unit * 5.0
		if numToes > 1 then spawnPos = spawnPos + (CFrame.Angles(math.random(), 0, math.random()) * pos + Vector3.new(0, 0.15, 0)).unit * 7.0 end 				
		
		toeClone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-math.pi/2, 0, 0) --+ radius * Vector3.new(0, 1, 0)				
		toeClone[i].Velocity = pos * 60.0	
		toeClone[i].Name ="toeClone"
		toeClone[i].Parent = game.Workspace					

		local toeCloneFloat = Instance.new("BodyForce")
		toeCloneFloat.force =  Vector3.new(0.0, toeClone[i]:GetMass() * workspace.Gravity, 0.0)
		toeCloneFloat.Parent = toeClone[i]

		toeClone[i].Touched:connect(function(hit) blow(toeClone[i], hit) end)
	
		debris:AddItem(toeClone[i], 5)
		wait(0.25)
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
	
	myHumanoid.WalkSpeed = 0.0
	myTorso.Anchored = true

	fireSound = Tool:FindFirstChild("FireSound")	
	local rapidFire = Tool:FindFirstChild("RapidFire")
	if rapidFire and rapidFire.Value == true and not cooldown then
		cooldown = true 
		shoot(lookAt, 6)	
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
		shoot(lookAt, 1)
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


