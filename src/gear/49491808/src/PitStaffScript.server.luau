local Tool = script.Parent
local Staff = Tool.Handle

Tool.Enabled = true

local debris = game:GetService("Debris")

fireball = Instance.new("Part")
fireball.Size = Vector3.new(4.0, 4.0, 4.0)
fireball.Transparency = 0.8
fireball.Shape = "Ball"
fireball.FormFactor = 3
fireball.Name ="HC"
fireball.CanCollide = false

local fireballMesh = Instance.new("SpecialMesh")
fireballMesh.MeshType = "FileMesh"
fireballMesh.Name = "Mesh"
fireballMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
fireballMesh.TextureId = "http://www.roblox.com/asset/?id=48598142"
fireballMesh.Scale = Vector3.new(0.13, 0.13, 0.13)
fireballMesh.Parent = fireball

fire = Instance.new("Fire")
fire.Parent = fireball

local numFire = 12
local fireballs = {}
local vCharacter
local immolate
local connection

local staffAnim

local count = 0
local staffSound

function blast(part, hit)	
	if hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")
	end
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	
	if humanoid ~= myHumanoid and humanoid ~= nil and myHumanoid ~= nil then 
		tagHumanoid(humanoid, vPlayer)
		humanoid:TakeDamage(30)
		if hit.Parent:FindFirstChild("PitInsertScript") == nil then 
			newScript = Tool.PitInsertScript:Clone()
			newScript.Parent = hit.Parent
			newScript.Disabled = false
		end		
	end	
	part:Destroy()
end

function burn(hit)	
	if hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")	
	end
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then 
		tagHumanoid(humanoid, vPlayer)
		humanoid:TakeDamage(14)
		wait(1.0)
		untagHumanoid(humanoid)
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Parent = humanoid
		creatorTag.Name = "creator"	
		creatorTag.Value = player
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then tag:Destroy() end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myTorso == nil then 
		return
	end
	
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then return end

	staffSound = Tool:FindFirstChild("StaffSound")
	if staffSound then staffSound:Play() end

	myTorso.Anchored = true

	immolate = Instance.new("Fire")
	immolate.Parent = myTorso
	connection = myTorso.Touched:connect(burn)

	for i = 1, numFire do 
		fireballs[i] = fireball:Clone()
		fireballs[i].Parent = workspace		
		offset = 3.5
		if i < 4 then
			fireballs[i].Position = myTorso.Position + Vector3.new(i * offset, 20.0, 0.0)
		elseif i < 7 then
			fireballs[i].Position = myTorso.Position + Vector3.new(0.0, 20.0, (i - 3)* offset) 
		elseif i < 10 then
			fireballs[i].Position = myTorso.Position + Vector3.new(0.0, 20.0, (i-6) * -offset)
		else
			fireballs[i].Position = myTorso.Position + Vector3.new((i-9) * -offset, 20.0, 0.0)
		end
		
		debris:addItem(fireballs[i], 7.5)		
		fireballs[i].Anchored = true
	end

	wait(1.5)

	print(#fireballs)
	
	for i = 1, #fireballs do
		randPos = math.random(0, 3.0)
		fireballs[i].RotVelocity = Vector3.new(0.0, 5.0, 0.0)
		--fireballs[i].Velocity = Vector3.new(0.0, 0.1, 0.0)
		fireballs[i].Touched:connect(function(hit) blast(fireballs[i], hit) end)
		fireballs[i].Anchored = false
	end
	myTorso.Anchored = false
	
	wait(7.0)
	
	Tool.Enabled = true
	if immolate then immolate:Destroy() end
	if connection then connection:disconnect() end
end

function onEquipped()
	
end

function onUnequipped()
	fireballs = {}
	if immolate then immolate:Destroy() end
	if connection then connection:disconnect() end
	count = 0	
	if staffSound then staffSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)