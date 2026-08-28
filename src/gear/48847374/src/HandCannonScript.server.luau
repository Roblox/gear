-- Heat Seeker Missiles 1..2..3 --

local Tool = script.Parent
local Cannon = Tool.Handle

local debris = game:GetService("Debris")

Tool.Enabled = true 

rocket = Instance.new("Part")
rocket.Size = Vector3.new(0.5, 0.5, 0.5)
rocket.Transparency = 0.8
rocket.Shape = "Ball"
rocket.FormFactor = 3
rocket.Name ="HC"

local rocketMesh = Instance.new("SpecialMesh")
rocketMesh.MeshType = "FileMesh"
rocketMesh.Name = "Mesh"
rocketMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
rocketMesh.TextureId = "http://www.roblox.com/asset/?id=48598142"
rocketMesh.Scale = Vector3.new(0.02, 0.02, 0.02)
rocketMesh.Parent = rocket

local fire = Instance.new("Fire")
fire.Size = 0.1
fire.Heat = 5.0
fire.Parent = rocket

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

function blow(part, hit)
	if hit.Name ~= "rocketClone" then	
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		print(hit.Name)
		local e = Instance.new("Explosion")
		e.Name = "SPLODE"
		e.BlastPressure = 5000
		e.BlastRadius = 5
		e.Position = hit.Position
		e.Parent = game.Workspace
		debris:AddItem(e, 1.0)
		
		if boom then boom:Play() end	
		if part then part:Remove() end

		vCharacter = Tool.Parent
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and vPlayer then 
			tagHumanoid(humanoid, vPlayer)
			wait(1.0)
			untagHumanoid(humanoid)	
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag:Remove()
		end
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

	for i = 1, 3 do 
		rocketClone[i] = rocket:Clone()
		rocketClone[i].CanCollide = false

		local spawnPos = vCharacter.PrimaryPart.Position
		spawnPos = spawnPos + pos.unit * 5.0

		if i == 1 then 
			rocketClone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) 
			rocketClone[i].Velocity = pos * 30.0		
			rocketClone[i].Name ="rocketClone"
			rocketClone[i].Parent = game.Workspace		
		else
			if i%2 == 0 then sign = 1 else sign = -1 end
			rocketClone[i].CFrame = rocketClone[1].CFrame * CFrame.Angles(sign * math.pi/2, 0.0, 0.0)
			rocketClone[i].Position = rocketClone[i].Position +  Vector3.new(sign * 2.0, 0.0, 0.0)
			rocketClone[i].Velocity = pos * 30.0		
			rocketClone[i].Name ="rocketClone"
			rocketClone[i].Parent = game.Workspace	
			
			cloneBT = newBT:Clone()
			cloneBT.force = (rocketClone[1].Position - rocketClone[i].Position) * 50.0
			cloneBT.location = rocketClone[i].Position
			cloneBT.Parent = rocketClone[i]
		end		

		local rocketCloneFloat = Instance.new("BodyForce")
		rocketCloneFloat.force =  Vector3.new(0.0, rocketClone[i]:GetMass() * 196.1, 0.0)
		rocketCloneFloat.Parent = rocketClone[i]

		rocketClone[i].Touched:connect(function(hit) blow(rocketClone[i], hit) end)
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

	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		print("Torso not found")
		return
	end

	boom = Tool:FindFirstChild("BOOM")
	
	target = myHumanoid.TargetPoint
	lookAt = (target - myTorso.Position).unit

	fireSound = Tool:FindFirstChild("FireSound")	
	shoot(lookAt)	
	wait(4.5)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if fireSound then fireSound:Stop()end
	if boom then boom:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


