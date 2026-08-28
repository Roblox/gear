--[[
	Fixed by ArceusInator
	- Mac users can now see the mesh
	- The gear works in FE games
--]]

Tool = script.Parent
Pistol = Tool.Handle

local pistolClone
local newWeld
local dualActive
local dualWalk
local vCharacter

local bulletSound

Tool.Enabled = true

local damage = 10
local bulletClone

local debris = game:GetService("Debris")

bullet = Instance.new("Part")
bullet.Size = Vector3.new(0.3, 0.3, 0.3)
bullet.Transparency = 0.3
bullet.Shape = "Ball"
bullet.FormFactor = 3
bullet.Name ="HC"
bullet.CanCollide = false

local bulletMesh = Instance.new("SpecialMesh")
bulletMesh.MeshType = "FileMesh"
bulletMesh.Name = "Mesh"
bulletMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
bulletMesh.TextureId = "http://www.roblox.com/asset/?id=49040283"
bulletMesh.Scale = Vector3.new(0.003, 0.003, 0.003)
bulletMesh.Parent = bullet

local newBF = Instance.new("BodyForce")
newBF.Name = "BF"

function blow(bullet, hit)	
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	bullet:Remove()
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then		
		tagHumanoid(humanoid, vPlayer)
		if hit.Name == "Head" then damage = 35 end
		humanoid:TakeDamage(damage)		
		damage = 10
		wait(1.0)
		untagHumanoid(humanoid)		
	end	
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
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

function shoot(direction)
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		print("Torso NO")
		return
	end
	
	local spawnPos = vCharacter.Head.Position
	spawnPos = spawnPos + direction.unit * 5.0
	
	bulletClone = bullet:Clone()
	bulletClone.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	bulletClone.Parent = game.Workspace
	bulletClone.Velocity = direction * 50.0	

	bulletFloat = newBF:Clone()
	bulletFloat.force = Vector3.new(0.0, 196.1 * bulletClone:GetMass(), 0.0)
	bulletFloat.Parent = bulletClone

	bulletClone.Touched:connect(function(hit) if hit.Parent then blow(bulletClone, hit) end end)
	
	debris:addItem(bulletClone, 4)
end

function onActivatedL(hit)
	if not Tool.Enabled then 
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

	bulletSound = Tool:FindFirstChild("BulletSound")

	local target = hit.p
	local direction = (target - vCharacter.Head.Position).unit
	dualActive = Tool:FindFirstChild("DualActive")
	if dualActive.Value == 0 then 
		shoot(direction)
		if bulletSound then bulletSound:Play() end
		wait(0.2)
	else
		shoot(direction)
		if bulletSound then bulletSound:Play() end
		wait(0.1)
		shoot(direction)
		if bulletSound then bulletSound:Play() end
	end
	wait(0.3)
	Tool.Enabled = true
end

function onKeyDown(key)
	dualActive = Tool:FindFirstChild("DualActive")
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if key:lower() == "q" and dualActive.Value == 0 then 	
		if myTorso then
			pistolClone = Pistol:Clone()
			pistolClone.Parent = vCharacter
			pistolClone.Name = "Pistol"			
			newWeld = Instance.new("Weld")
			leftArm = vCharacter:FindFirstChild("Left Arm")
			newWeld.Parent = leftArm
			newWeld.Name = "LeftGrip"
			newWeld.Part0 = leftArm
			newWeld.Part1 = pistolClone
			newWeld.C1 = CFrame.new(Vector3.new(0.0, -1.45, 0.0)) * CFrame.Angles(math.pi, 0.0, 0.0)
			dualActive.Value = 1
			if myHumanoid then 
				if dualWalk == nil then dualWalk = myHumanoid:LoadAnimation(Tool.DualWalk) end
				dualWalk:Play()
			end
		end	
	elseif key:lower()=="q" and dualActive.Value == 1 then 
		if myTorso then 				
			leftArm = vCharacter:FindFirstChild("Left Arm")
			leftGrip = vCharacter:FindFirstChild("LeftGrip")
			if leftGrip then leftGrip:Remove() end
			pistol = vCharacter:FindFirstChild("Pistol")
			if pistol then pistol:Remove() end
			dualActive.Value = 0
			if dualWalk then dualWalk:Stop() end
		end
	end
end

function onEquippedL()
	vCharacter = Tool.Parent
end

function onUnequippedL()
	dualActive =  Tool:FindFirstChild("DualActive") 
	if dualActive then dualActive.Value = 0 end
	if dualWalk then dualWalk:Stop() end
	leftArm = vCharacter:FindFirstChild("Left Arm")
	leftGrip = vCharacter:FindFirstChild("Left Grip")
	if leftGrip then leftGrip:Remove() end
	pistol = vCharacter:FindFirstChild("Pistol")
	if pistol then pistol:Remove() end

	if bulletSound then bulletSound:Stop() end
end


--Tool.Activated:connect(onActivatedL)
Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'Mouse1' then
			local down, hit = ...
			
			if down then
				onActivatedL(hit)
			end
		elseif action == 'Key' then
			local down, key = ...
			
			if down then
				onKeyDown(key)
			end
		end
	end
end)
Tool.Equipped:connect(onEquippedL)
Tool.Unequipped:connect(onUnequippedL)
