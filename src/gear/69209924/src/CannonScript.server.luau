local Tool = script.Parent
local Cannon = Tool.Handle

local debris = game:GetService("Debris")

Tool.Enabled = true 

local r80 = Instance.new("Part")
r80.Size = Vector3.new(0.5, 0.5, 0.5)
r80.Transparency = 0.0
r80.Shape = "Ball"
r80.FormFactor = 3
r80.Name ="Toe"

local r80Mesh = Instance.new("SpecialMesh")
r80Mesh.MeshType = "FileMesh"
r80Mesh.Name = "Mesh"
r80Mesh.MeshId = "http://www.roblox.com/asset/?id=12551202"
r80Mesh.TextureId = "http://www.roblox.com/asset/?id=12551163"
r80Mesh.Scale = Vector3.new(1, 1, 1)
r80Mesh.Parent = r80

local sparkles = Instance.new("Sparkles")
sparkles.SparkleColor = Color3.new(1, 0, 0)
sparkles.Parent = r80

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

local r80Clone = {}
local r80Clones = {}

local cooldown = false

local damage = 15

function blow(part, hit)
	if hit and hit.Parent and hit.Name ~= "r80Clone" and hit.Parent ~= vCharacter and hit.Parent ~= Tool and part then	
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
		r80Clone[i] = r80:Clone()
		r80Clone[i].CanCollide = false		

		local spawnPos = Cannon.Position
		spawnPos = spawnPos + pos.unit * 5.0
		if numToes > 1 then spawnPos = spawnPos + (CFrame.Angles(math.random(), 0, math.random()) * pos + Vector3.new(0, 0.15, 0)).unit * 7.0 end 				
		
		r80Clone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-math.pi/2, 0, 0) --+ radius * Vector3.new(0, 1, 0)				
		r80Clone[i].Velocity = pos * 60.0	
		r80Clone[i].Name ="r80Clone"
		r80Clone[i].Parent = game.Workspace					

		local toeCloneFloat = Instance.new("BodyForce")
		toeCloneFloat.force =  Vector3.new(0.0, r80Clone[i]:GetMass() * workspace.Gravity, 0.0)
		toeCloneFloat.Parent = r80Clone[i]

		r80Clone[i].Touched:connect(function(hit) blow(r80Clone[i], hit) end)
	
		debris:AddItem(r80Clone[i], 5)
		wait(0.25)
	end
end

function shootAnything(pos)
	vCharacter = Tool.Parent

	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then	
		return
	end

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then		
		return
	end

	if fireSound then fireSound:Play()end

	for i = 1, 9 do
	tick()
	r80Clones[i] = r80:Clone()
	r80Clones[i].CanCollide = false

	local spawnPos = vCharacter.PrimaryPart.Position
	spawnPos = spawnPos + pos.unit * 8.0

	r80Clones[i].CFrame = (CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-math.pi/2, 0, 0)) + Vector3.new(math.random() * 2.5, math.random() * 2.5, math.random() * 2.5) 
	r80Clones[i].Velocity = pos * 40.0
	r80Clones[i].Name ="r80Clone"
	r80Clones[i].Parent = game.Workspace                 

	local rocketCloneFloat = Instance.new("BodyForce")
	rocketCloneFloat.force = Vector3.new(0.0, r80Clones[i]:GetMass() * workspace.Gravity, 0.0)
	rocketCloneFloat.Parent = r80Clones[i]

	r80Clones[i].Touched:connect(function(hit) blow(r80Clones[i], hit) end)

	debris:AddItem(r80Clones[i], 6.0)
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
		shootAnything(lookAt)	
		wait(0.5) 
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
	wait(1.5)	
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


