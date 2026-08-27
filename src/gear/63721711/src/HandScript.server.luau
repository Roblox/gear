-- Default number of bats is 3
-- Depending on the number of players in the vicinity this might increase to about 6
-- bats do tons of damage to the enemies and chase them around for a while
-- 10% lifesteal back to the hand wielder

-- Should each bat be able to pick on a different character?


local Tool = script.Parent
local Hand = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true

local numBats = 3

local numActiveBats = 0

local duration = 30

local damage = 14

local bats = {}

local meshes = {63693995, 63694839, 63694853}

local debris = game:GetService("Debris")

local bat = Instance.new("Part")
bat.FormFactor = 3
bat.Size = Vector3.new(0.6, 0.6, 0.6)
bat.CanCollide = true
bat.Transparency = 0.0
bat.Name = "Bat"

local batMesh = Instance.new("SpecialMesh")
batMesh.MeshId = "http://www.roblox.com/asset/?id=63693995" -- front, 63694839  --back, 63694853  
batMesh.TextureId = "http://www.roblox.com/asset/?id=63694777"
batMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
batMesh.Parent = bat

local AOE = Vector3.new(20, 20, 20) 

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function blow(hit, batObj)
	if hit and hit.Parent and vCharacter and myHumanoid then 
		local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and myHumanoid and myHumanoid ~= humanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
			if myHumanoid.Health + 0.3 * damage < myHumanoid.MaxHealth then 
				myHumanoid.Health = myHumanoid.Health + 0.3 * damage
			end			
			if humanoid.Health < 30 then batObj.Target = myTorso end -- Just to save the guy from a crazy bat death
		end
	end
end

function chaseEnemies()
	print("Commencing Chase")
	while duration > 0 do 
		for i = 1, #bats do
			local distance = 0
			if bats[i] then				
				if bats[i] then distance = (bats[i].Target.Position - bats[i][1].Position).magnitude end
				if bats[i] and bats[i].Target == myTorso then		
					if distance and distance > 5.0 then       													
						if bats[i] then bats[i].BV.Parent = bats[i][1] end						
						bats[i].BV.velocity = (myTorso.Position - bats[i][1].Position).unit * 20.0
						bats[i][1].CFrame = CFrame.new(bats[i][1].Position, bats[i].Target.Position)
					else
						if bats[i] then							
							bats[i].BV.velocity = Vector3.new(0, 0 ,0)
							bats[i].BV.Parent = nil					
						end
					end 
				else	
					if distance > 1 and bats[i] then 						
						bats[i].BV.Parent = bats[i][1]
						bats[i].BV.velocity = (bats[i].Target.Position - bats[i][1].Position).unit * 18.0
						bats[i][1].CFrame = CFrame.new(bats[i][1].Position, bats[i].Target.Position)
					else 
						if bats[i] then							
							bats[i].BV.velocity = Vector3.new(0, 0 ,0)
							bats[i].BV.Parent = nil		
						end
					end	
				end		
			end
		end
		duration = duration - wait()
		wait()
	end
	for i = #bats, 1 do 		
		if bats[i] and bats[i][1] then bats[i][1]:Destroy() bats[i][1] = nil end
	end
	bats = {}	
	Hand.Transparency = 0.0
	wait(3.0)
	Tool.Enabled = true
	duration = 30
end

function markEnemies()
	local noTarget = false
	for i = 1, #bats do 				
		local parts = game.Workspace:FindPartsInRegion3(Region3.new(bats[i][1].Position - AOE, bats[i][1].Position + AOE), vCharacter, 100)
		for j = 1, #parts do 
			if parts[j] and parts[j].Parent then
				local torso = parts[j].Parent:FindFirstChild("Torso") parts[j].Parent:FindFirstChild("UpperTorso")
				if torso then 
					bats[i].Target = torso 
				end
			end
		end
		if bats[i].Target == nil then bats[i].Target = myTorso end 		
	end	
	for i = 1, #bats do 
		print(bats[i].Target.Parent)
	end
	chaseEnemies()
end

function flapWings(bat)	
	local meshCount = 1
	while bat and #bats > 0 do 
		local mesh = bat:FindFirstChild("Mesh")
		if mesh then 
			mesh.MeshId = "http://www.roblox.com/asset/?id=" .. meshes[meshCount]
			meshCount = meshCount + 1 
			meshCount = meshCount%3 + 1
		end
		wait(0.1)
	end
end

function spawnBats()
	for i = 1, numBats do 
		tick()
		local batObj = {}
		local batClone = bat:Clone()
		batClone.CFrame = Hand.CFrame + Vector3.new(math.random(-3, 3), 1, math.random(-3, 3)) 		
		
		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, bat:GetMass() * workspace.Gravity, 0)	
		floatForce.Parent = batClone

		local bv = Instance.new("BodyVelocity")
		bv.P = 400
		bv.maxForce = Vector3.new(bv.P, bv.P, bv.P)
		bv.Parent = batClone
		bv.Name = "BV"
		bv.velocity = Vector3.new(0, 0, 0)

		batClone.Parent = game.Workspace			

		batObj.Target = nil
		batObj.Duration = 30
		batObj.BV = bv
	
		table.insert(batObj, batClone)		
		table.insert(bats, batObj)

		batClone.Touched:connect(function(hit) blow(hit, batObj)	end)

		coroutine.resume(coroutine.create(function() flapWings(batClone) end))
	end
	print("Number of bats", #bats)	
	markEnemies()
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	
	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false 

	Hand.Transparency = 1.0

	local players = game.Players:GetChildren()
	local count = 1
	for i = 1, #players do 
		if players[i] and players[i].Character and players[i].Character ~= vCharacter then 
			local torso = players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")
			if torso then
				local distance = (myTorso.Position - torso.Position).magnitude 
				if distance < 25 then
					count = count + 1
					if count/2 > 1 then 
						numBats = numBats + math.ceil(count/2)
					end
				end
			end
		end
	end
	if numBats > 6 then numBats = 6 end 
	spawnBats()		
end

function onEquipped()	
end

function onUnequipped()
	numBats = 3
	for i = 1, #bats do 		
		if bats[i] and bats[i][1] then bats[i][1]:Destroy() bats[i][1] = nil end
	end
	bats = {}
	Hand.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
