-- Updated for R15 avatars by StarWars
local Players = game:GetService("Players")

local Tool = script.Parent
local spark = nil
local numOfSparks = 8

local ServerControls = Tool:FindFirstChild("ServerControls") or Instance.new("RemoteEvent")
ServerControls.Name = "ServerControls"
ServerControls.Parent = Tool

function createSpark(v, pos, vCharacter)

	local missile = Instance.new("Part")

	local spark = Instance.new("Sparkles")

	local SparkSound = Instance.new("Sound")
	SparkSound.Name = "SparkSound"
	SparkSound.SoundId = "http://www.roblox.com/asset/?id=10756104"
	SparkSound.Parent = missile
	SparkSound.Volume = 1
	SparkSound.Looped = true
        
	spark.Parent = missile

	missile.Position = pos
	missile.Size = Vector3.new(1,1,1)
	missile.Velocity = (pos - v).unit * 50
	missile.BrickColor = BrickColor.new(26)
	missile.Shape = 0
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Name = "Spark"
	missile.Reflectance = 1

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,missile:GetMass() * workspace.Gravity,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = Tool.Spark:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = workspace
	SparkSound:Play()
end

function fire(v, humanoid)

	local vCharacter = Tool.Parent
	local vPlayer = Players:GetPlayerFromCharacter(vCharacter)

	local numOfSparks = 8
	
	local increment = (math.pi *2)/numOfSparks
	local torso = humanoid.Parent:FindFirstChild("Torso") or humanoid.Parent:FindFirstChild("UpperTorso")

	torsoNormal = torso.CFrame.lookVector
	denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
	posX = 15 * (torsoNormal.x/denom)
	posZ = 15 * (torsoNormal.z/denom)
	local pos = Vector3.new(v.x + posX,v.y, v.z + posZ)
	
	local hat = humanoid.Parent:FindFirstChild("Electrifying")
	-- really make sure they have the right hat :)
	if hat ~= nil and hat:IsA("Accessory") and hat.Handle.Mesh.TextureId == "http://www.roblox.com/asset/?id=15881128" then
		numOfSparks = 16
		increment = (math.pi * 2)/numOfSparks
	end

	for i = 1, numOfSparks do
		local angle = increment * i
		createSpark(v, pos, vCharacter)
		pos = Vector3.new(((pos.x - v.x) * math.cos(angle)) - ((pos.z - v.z) * math.sin(angle)) + v.x, pos.y,((pos.x - v.x) * math.sin(angle)) + ((pos.z - v.z) * math.cos(angle)) + v.z)
	end
end

function staffUp()
	Tool.GripForward = Vector3.new(0,0,-1)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,1,0)
end

function staffOut()
	Tool.GripForward = Vector3.new(.0976, .00976, -.995)
	Tool.GripRight = Vector3.new(.195, -.981, .00952)
	Tool.GripUp = Vector3.new(.976, .195, .0976)
end

function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end

function onActivated()
	if not Tool.Enabled then return end

	Tool.Enabled = false

	local character = Tool.Parent;
	local player = Players:GetPlayerFromCharacter(character)
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local bodyPos = Instance.new("BodyPosition")
	bodyPos.position = Vector3.new(rootPart.Position.x, rootPart.Position.y + 10 , rootPart.Position.z)
	bodyPos.maxForce = Vector3.new (10000,10000,10000)
	bodyPos.P = 10000
	bodyPos.D = 5000
	bodyPos.Parent = torso

	Tool.Handle.ActivateSound:Play()
	if player then
		ServerControls:FireClient(player)
	end

	local spark = Instance.new("Sparkles")
	spark.Parent = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")

	wait(1.5)

	spark:Destroy()
	bodyPos:Destroy()

	local targetPos = humanoid.TargetPoint
	local lookAt = torso.Position

	local reload = 2
	if (isTurbo(character)) then
		reload = .25
		print("turbo")
	end

	fire(lookAt, humanoid)
	wait(reload)
	wait(reload)

	Tool.Enabled = true
end

function onEquipped()
	Tool.Handle.EquipSound:play()
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
