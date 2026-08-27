local Tool = script.Parent
local Bolt = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

Tool.Enabled = true 

local activateWrathOfGod 

local debris = game:GetService("Debris")

local boltDamage = 30 

local lightningPart = Instance.new("Part")
lightningPart.Name = "Lightning"
lightningPart.FormFactor = 3
lightningPart.Size = Vector3.new(1, 1, 10)
lightningPart.Anchored = true

local lightningMesh = Instance.new("SpecialMesh")
lightningMesh.Scale = Vector3.new(1, 1, 1)
lightningMesh.MeshId = "http://www.roblox.com/asset/?id=65419828"
lightningMesh.TextureId = "http://www.roblox.com/asset/?id=65419395"
lightningMesh.Parent = lightningPart

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = player
		creator.Parent = humanoid
		debris:AddItem(creator, 1)
	end
end

function blow(parent, dmg,  hit)
	if parent then 		
		if hit.Parent then 
			humanoid = hit.Parent:FindFirstChild("Humanoid")
		end
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid ~= nil and myHumanoid ~= humanoid and myHumanoid ~= nil then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(dmg)
			if dmg > 30 then humanoid.Sit = true  end
			if humanoid.WalkSpeed >= 16.0 then 
				humanoid.WalkSpeed = 9.0  
				coroutine.resume(coroutine.create(function() 
					wait(3.0)
					if humanoid then humanoid.WalkSpeed = 16.0  end
				end)) 
			end 
		end			
	end
end

while Tool:FindFirstChild("WrathOfGod") == nil do 
	wait()
end 
activateWrathOfGod = Tool.WrathOfGod
activateWrathOfGod.Changed:connect(function()
	if activateWrathOfGod and activateWrathOfGod.Value == true then 
		-- Activate the powar!		
		local tempHeads = {}
		local players = game.Players:GetChildren()
		for i = 1, #players do 
			if players[i] and players[i] ~= vPlayer and players[i].Character and (players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")) and players[i].Character:FindFirstChild("Humanoid") then -- and players[i] ~= vPlayer
				local head = players[i].Character:FindFirstChild("Head")
				if head and (head.Position - myTorso.Position).magnitude < 80 then 
					tempHeads[head] = head 
				end 
			end 
		end 

		for i, head in pairs(tempHeads) do 
			tick()
			local lPart = lightningPart:Clone() 			
			local spawnPos = head.Position + Vector3.new(math.random(), 40, math.random())
			lPart.Size = Vector3.new(2, 2, (spawnPos - head.Position).magnitude + 1) 
			local tempCFrame = CFrame.new(spawnPos, head.Position)
			lPart.CFrame = tempCFrame + tempCFrame:vectorToWorldSpace(Vector3.new(1, 1, 1) - lPart.Size/2.0) 
			lPart.Mesh.Scale = Vector3.new(1, 1, lPart.Size.Z * 1/14)
			lPart.Parent = game.Workspace
			blow(head, 80, head)
			debris:AddItem(lPart, 0.75)						
		end 
		tempHeads = {}
		wait(25)
		activateWrathOfGod.Value = false		
	end 
end)



function summonBoltShield()	
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vCharacter == nil or vPlayer == nil then
		return
	end

	for i = 1, 16 do
		local pos = CFrame.Angles(0, i * math.pi/8, 0) * myTorso.CFrame.lookVector

		local spawnPos = myTorso.Position
		spawnPos = spawnPos + (pos * 4.25)

		lightningProjectile = lightningPart:Clone()
		lightningProjectile.Name = "rope"
		lightningProjectile.CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-math.pi/2, 0, 0)
		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, lightningPart:GetMass() * 196.1, 0)
		floatForce.Parent = lightningProjectile
		lightningProjectile.Velocity = pos * 75.0
		lightningProjectile.Parent = game.Workspace
		lightningProjectile.Touched:connect(function(hit) blow(lightningProjectile, boltDamage,  hit) end)
		debris:addItem(lightningProjectile, 4)
	end
end

function shootBolts()	
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vCharacter == nil or vPlayer == nil then
		return
	end

	for i = 1, 16 do
		local pos = CFrame.Angles(0, i * math.pi/8, 0) * myTorso.CFrame.lookVector

		local spawnPos = myTorso.Position
		spawnPos = spawnPos + (pos * 5.0)

		lightningProjectile = lightningPart:Clone()
		lightningProjectile.Name = "rope"
		lightningProjectile.CFrame = CFrame.new(spawnPos, spawnPos + pos) --* CFrame.Angles(-math.pi/2, 0, 0)
		lightningProjectile.Anchored = false 
		lightningProjectile.CanCollide = false 

		lightningProjectile.Size = Vector3.new(1, 1, 4)

		if lightningProjectile:FindFirstChild("Mesh") then lightningProjectile.Mesh.Scale = lightningProjectile.Mesh.Scale * 0.75 end 

		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, lightningProjectile:GetMass() * workspace.Gravity, 0)
		floatForce.Parent = lightningProjectile
		lightningProjectile.Velocity = pos * 50.0
		lightningProjectile.Parent = game.Workspace
		lightningProjectile.Touched:connect(function(hit) blow(lightningProjectile, boltDamage,  hit) end)
		debris:addItem(lightningProjectile, 4)
	end
end 

function boltUp() 
	Tool.GripForward = Vector3.new(0, 1, 0) 
	Tool.GripRight = Vector3.new(1, 0, 0) 
	Tool.GripUp = Vector3.new(0, 0, 1) 
end 

function boltDown() 
	Tool.GripForward = Vector3.new(0, 0.848, 0.53)      
	Tool.GripRight = Vector3.new(1, 0, 0) 
	Tool.GripUp = Vector3.new(0, -0.53, 0.848) 
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

	boltDown()

	wait(0.25)
	
	if math.random() < 0.4 then 
		summonBoltShield()
	else
		shootBolts()
	end

	wait(0.5)
	boltUp()

	wait(4.0)
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


