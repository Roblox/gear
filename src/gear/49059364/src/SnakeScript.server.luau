-- Beware the Snakes! --

local Tool = script.Parent
local Crate = Tool.Handle
local vCharacter

local crateClone
local numberOfSnakes = 6

local crateSound 

local debris = game:GetService("Debris")

local smoke = Instance.new("Smoke")
smoke.Opacity = 0.0
--smoke.RiseVelocity = 1.0
--smoke.Size = 10.0
smoke.Name = "CrateSmoke"


local count = 1

Tool.Enabled = true
local crateAOE = Vector3.new(20.0, 20.0, 20.0)


Snake = Instance.new("Part")
Snake.Size = Vector3.new(2.8, 0.8, 0.2)
Snake.Transparency = 0.0
Snake.Shape = "Block"
Snake.FormFactor = 3
Snake.Name ="SC"
--Snake.CanCollide = true

local SnakeMesh = Instance.new("SpecialMesh")
SnakeMesh.MeshType = "FileMesh"
SnakeMesh.Name = "Mesh"
SnakeMesh.MeshId = "http://www.roblox.com/asset/?id=49046138"
SnakeMesh.TextureId = "http://www.roblox.com/asset/?id=49046409"
SnakeMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
SnakeMesh.Parent = Snake

--Snake.CFrame = Snake.CFrame * CFrame.Angles(math.pi/2, 0.0, math.pi)

bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.P = 10000
bodyVelocity.maxForce = Vector3.new(bodyVelocity.P, 0.0, bodyVelocity.P)

bodyGyro = Instance.new("BodyGyro")
bodyGyro.P = 500000
bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)


function blast(crate, hit)
	if count > 0 then
		count  = 0
		vCharacter = Tool.Parent
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if vCharacter == nil then print("No Character") return end
		smokeClone = Instance.new("Smoke")
		smokeClone.Color = Color3.new(0.0, 0.0, 0.0)
		smokeClone.Size = 2.0
		print("Creating Smoke")
		smokeClone.Parent = crate
		parts = game.Workspace:FindPartsInRegion3(Region3.new(crate.Position - crateAOE, crate.Position + crateAOE), vCharacter, 100)	
		for i = 1, #parts do 
			char = parts[i].Parent
			if char:FindFirstChild("Humanoid") ~= nil then				
				if numberOfSnakes > 0 then		
				snakeClone = Snake:Clone()
				snakeClone.CFrame = snakeClone.CFrame * CFrame.Angles(math.pi/2.0 , 0.0, math.pi/2.0)
				snakeClone.CanCollide = false
				snakeClone.Position = crate.Position - Vector3.new(0.0, 0.0, 0.0)			
				snakeBV = bodyVelocity:Clone()			
			
				snakeBV.velocity = Vector3.new(parts[i].Position.X - snakeClone.Position.X, 0.0, parts[i].Position.Z - snakeClone.Position.Z).unit * 10.0
				snakeBV.Parent = snakeClone
				snakeBV.Name = "snakeBV"
				snakeBG = bodyGyro:Clone()
				snakeBG.cframe = CFrame.new(snakeClone.Position, parts[i].Position) * CFrame.Angles(math.pi/2.0, math.pi, -math.pi/2.0)
				snakeBG.Parent = snakeClone
				snakeBG.Name = "BG"
				snakeClone.Parent = game.Workspace
				creatorTag = Instance.new("ObjectValue")
				creatorTag.Name = "creator"
				creatorTag.Value = vPlayer
				creatorTag.Parent = snakeClone
				newScript = Tool.InsertScript:Clone()
				newScript.Disabled = false
				newScript.Parent = snakeClone				
				debris:addItem(snakeClone)
				numberOfSnakes = numberOfSnakes - 1
				end
			end
		end
		--if crate then crate:Remove() end
	end
end

function throw(crate, direction)
	
	vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 
		return 
	end

	local spawnPos = vCharacter.Head.Position
	spawnPos = spawnPos +  direction.unit * 5.0
	
	crate.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	crate.Parent = game.Workspace
	crate.Name = "Crate"
	crate.Velocity = direction * 20.0

	crateFloat = Instance.new("BodyForce")
	crateFloat.force = Vector3.new(0.0, 98.1 * crate:GetMass(), 0.0)
	crateFloat.Parent = crate

	crate.Touched:connect(function(hit) blast(crate, hit) end) 
	co = coroutine.create(remove)
	coroutine.resume(co, crate)
	
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false
		
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return 
	end

	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		return
	end

	local target = myHumanoid.TargetPoint
	local direction = (target - vCharacter.Head.Position).unit

	crateSound = Tool:FindFirstChild("CrateSound") 

	crateClone = Crate:Clone()
	crateClone.CanCollide = true

	Crate.Transparency = 1.0
	throw(crateClone, direction)
	wait(0.3)
	if crateSound then crateSound:Play() end

	wait(5.7)
	Tool.Enabled = true
	Crate.Transparency = 0.0	
	numberOfSnakes = 6
	count = 1
end

function onEquipped()
end

function onUnequipped()
	if crateSound then crateSound:Stop() end
	if crate then crate:Remove() end
end

function remove(crate)
	wait(3.0)
	if crate then crate.Velocity = Vector3.new(0.0, 0.0, 0.0) end
	--wait(2.0)
	if crate then crate:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
