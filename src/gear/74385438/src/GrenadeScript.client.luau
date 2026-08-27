local Tool = script.Parent
local Grenade = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer

local throwAnim

Tool.Enabled = true 

local boomSound 

local debris = game:GetService("Debris")

local spikePart = Instance.new("Part")
spikePart.FormFactor = 3
spikePart.Size = Vector3.new(0.5, 0.5, 0.5)
spikePart.Shape = "Block"
spikePart.Name = "Spike"
spikePart.CanCollide = true 

local spikeMesh = Instance.new("SpecialMesh")
spikeMesh.MeshId = "http://www.roblox.com/asset/?id=59092052"
--spikeMesh.TextureId = "http://www.roblox.com/asset/?id=59091614"
spikeMesh.Parent = spikePart

function computeMass(obj)
	local children
	local mass
	if type(obj) == "userdata" then
		children = obj:GetChildren() 
	else 
		children = obj 
	end 

	for i = 1, #children do 
		if children[i]:IsA("BasePart") then 
			mass = mass + children[i]:GetMass()
		end 
		mass = computeMass(children[i]) + mass 		
	end
	return mass
end

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1.25)
	end  
end 

function blow(hit)
	if hit and hit.Parent and hit.Parent ~= vCharacter then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid") 
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			humanoid:TakeDamage(20) 
			tagHumanoid(humanoid, vPlayer)
		end 
	end  
end 

function spike(hit, grenadeClone)
	if hit and hit.Parent and grenadeClone then 		

		boomSound = Grenade:FindFirstChild("Boom")
		if boomSound then boomSound:Play() end 

		local e = Instance.new("Explosion")
		local initPos = grenadeClone.Position
		e.Position = grenadeClone.Position
		e.BlastPressure = 0 
		e.BlastRadius = 10 
		e.Parent = game.Workspace 	
		debris:AddItem(e, 1)
		if grenadeClone then grenadeClone:Destroy() end 			
		
		local players = game.Players:GetPlayers()
		for i = 1, #players do 
			if players[i] and players[i] ~= vPlayer and players[i].Character ~= nil and players[i].Character:FindFirstChild("Torso") and players[i].Character:FindFirstChild("Humanoid") then 
				local distance = (myTorso.Position - players[i].Character.Torso.Position).magnitude  
				if distance < 30 then 
					local floatScript = Tool.FloatScript:Clone()
					floatScript.Parent = players[i].Character
					floatScript.Disabled = false 
				end 
			end 
		end 	
	end
end

function shoot(direction, grenadeClone)
	if myTorso and myHumanoid then 
		local spawnPos = Grenade.Position + direction * 4.0 
		grenadeClone.CFrame = CFrame.new(spawnPos, spawnPos + direction) 
	
		grenadeClone.Velocity = (direction + Vector3.new(0, 2, 0)).unit * 55.0
		grenadeClone.RotVelocity = Vector3.new(0, 10, 0)

		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, grenadeClone:GetMass() * 88.1, 0)
		floatForce.Parent = grenadeClone 
		
		grenadeClone.Parent = game.Workspace
	
		grenadeClone.Touched:connect(function(hit)  spike(hit, grenadeClone) end)

		debris:AddItem(grenadeClone, 2.5)
	end	
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false

	local grenadeClone = Grenade:Clone()
	grenadeClone.CanCollide = true 
	
	Grenade.Transparency = 1.0
	
	local target = myHumanoid.TargetPoint 
	local direction = (target - Grenade.Position).unit 
	
	shoot(direction, grenadeClone)

	wait(4.75)
	Grenade.Transparency = 0.0
	Tool.Enabled = true 
end

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
end

function onUnequipped()
	if throwAnim then throwAnim:Stop() end
	if boomSound then boomSound:Stop() end 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Grenade.Touched:connect(spike)