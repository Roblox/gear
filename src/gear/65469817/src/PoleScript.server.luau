local Tool = script.Parent
local Pole = Tool.Handle

local vCharacter 
local myTorso
local myHumanoid 
local vPlayer

Tool.Enabled = true 

local debris = game:GetService("Debris")

local spikePart = Instance.new("Part")
spikePart.FormFactor = 3
spikePart.Size = Vector3.new(1, 2, 1)
spikePart.Shape = "Block"
spikePart.Name = "Spike"
spikePart.CanCollide = false

local spikeMesh = Instance.new("SpecialMesh")
spikeMesh.MeshId = "http://www.roblox.com/asset/?id=59092052"
spikeMesh.TextureId = "http://www.roblox.com/asset/?id=59801821"
spikeMesh.Parent = spikePart

orbPart = Instance.new("Part")
orbPart.Size = Vector3.new(0.5, 0.5, 0.5)
orbPart.Transparency = 0.8
orbPart.Shape = "Ball"
orbPart.FormFactor = 3
orbPart.Name ="Orb"
orbPart.CanCollide = false

local orbPartMesh = Instance.new("SpecialMesh")
orbPartMesh.MeshType = "FileMesh"
orbPartMesh.Name = "Mesh"
orbPartMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
orbPartMesh.TextureId = "http://www.roblox.com/asset/?id=48598142"
orbPartMesh.Scale = Vector3.new(0.04, 0.04, 0.04)
orbPartMesh.Parent = orbPart

local fire = Instance.new("Fire")
fire.Size = 0.1
fire.Heat = 5.0
fire.Color = Color3.new(0, 139/255, 139/255)
fire.Parent = orbPart 

local float = Instance.new("BodyForce")
float.force = Vector3.new(0.0, orbPart:GetMass() * workspace.Gravity, 0.0)
float.Name = "Floating"

local orbDamage = 25
local spikeDamage = 40 
local lightningDamage = 50

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
		end			
	end
end

function shootSpikes()	
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vCharacter == nil or vPlayer == nil then
		return
	end

	for i = 1, 12 do
		local pos = CFrame.Angles(0, i * math.pi/6, 0) * myTorso.CFrame.lookVector

		local spawnPos = myTorso.Position
		spawnPos = spawnPos + (pos * 5.0)

		spikeProjectile = spikePart:Clone()
		spikeProjectile.Name = "rope"
		spikeProjectile.CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-math.pi/2, 0, 0)
		local floatForce = float:Clone()
		floatForce.force = Vector3.new(0, spikePart:GetMass() * 196.1, 0)
		floatForce.Parent = spikeProjectile
		spikeProjectile.Velocity = pos * 75.0
		spikeProjectile.Parent = game.Workspace
		spikeProjectile.Touched:connect(function(hit) blow(spikeProjectile, spikeDamage,  hit) end)
		debris:addItem(spikeProjectile, 4)
		end
end 

function shootOrb(pos)
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	local vTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if vCharacter == nil or vPlayer == nil or vTorso == nil then
		return
	end

	local spawnPos = vTorso.Position
	spawnPos = spawnPos + (pos * 5.0)

	orbProjectile = orbPart:Clone()
	orbProjectile.Name = "Orb"
	orbProjectile.CFrame = CFrame.new(spawnPos, spawnPos + pos)

	floatForce = float:Clone()
	floatForce.Parent = orbProjectile
	orbProjectile.Velocity = pos * 65.0     

	orbProjectile.Parent = game.Workspace

	orbProjectile.Touched:connect(function(hit) blow(orbProjectile, orbDamage,  hit) end)

	debris:addItem(orbProjectile, 4)
end

function shootLightning()	
	local AOE = Vector3.new(14, 14, 14)
	local tempTorsos= {}
	if myTorso then 
		local parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - AOE, myTorso.Position + AOE), vCharacter, 100)
		for i = 1, #parts do 
			if parts and parts[i].Parent then 
				local character = parts[i].Parent
				local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") 
				if torso and character:FindFirstChild("Humanoid") then
					if not tempTorsos[torso] then 
						character.Humanoid:TakeDamage(lightningDamage)
						tempTorsos[torso] = torso
					end
				end
			end
		end

		for i, v in pairs(tempTorsos) do 
			local lightningPart = Instance.new("Part")
			lightningPart.Name = "Lightning"
			lightningPart.FormFactor = 3
			lightningPart.Size = Vector3.new(1, 1, 1)
			lightningPart.Anchored = true

			local lightningMesh = Instance.new("SpecialMesh")
			lightningMesh.Scale = Vector3.new(1, 1, 1)
			lightningMesh.MeshId = "http://www.roblox.com/asset/?id=65419828"
			lightningMesh.TextureId = "http://www.roblox.com/asset/?id=65419395"
			lightningMesh.Parent = lightningPart

			lightningPart.Size = Vector3.new(2, 2, (Pole.Position - v.Position).magnitude + 1) 
			local tempCFrame = CFrame.new(Pole.Position, v.Position)
			lightningPart.CFrame = tempCFrame + tempCFrame:vectorToWorldSpace(Vector3.new(1, 1, 1) - lightningPart.Size/2.0) 
			lightningMesh.Scale = Vector3.new(1, 1, lightningPart.Size.Z * 1/14)

			lightningPart.Parent = game.Workspace

			debris:AddItem(lightningPart, 0.75)
		end
	end
end

function staffUp() 
	Tool.GripForward = Vector3.new(0, 1, 0) 
	Tool.GripRight = Vector3.new(1, 0, 0) 
	Tool.GripUp = Vector3.new(0, 0, 1) 
end 

function staffDown() 
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

	staffDown()
	wait(0.1)	
	local spell = math.random(1, 3)
	if spell == 1 then 
		local target = myHumanoid.TargetPoint
		local lookAt = (target - myTorso.Position).unit 
		shootOrb(lookAt) 		
	elseif spell == 2 then
		shootSpikes()
	else 
		shootLightning()
	end

	wait(0.2)
	staffUp()

	wait(7.0)
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
