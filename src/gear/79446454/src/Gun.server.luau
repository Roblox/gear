local Tool = script.Parent;

local gun = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local leftGun
local leftGunWeld

local holdAnim

local gripCopy = Tool.Grip
local equipped = false

function doubleGun()
	--if true then return end
	if Tool.Parent ~= game.Workspace then return end
	if leftGun then return end
	print("Doubling")
	leftGun = gun:Clone()

	leftGun.Name = "LeftGun"
	leftGun.Parent = Tool --game.Workspace -- Parenting it to the tool causes tons of random problems ;(
												--Workspace is bad too since it wont necessarily get cleaned up properly
	leftGun.CanCollide = true

	leftGunWeld = Instance.new("Weld")		
	leftGunWeld.Part0 = gun
	leftGunWeld.Part1 = leftGun
	leftGunWeld.C1 = Tool.Grip * CFrame.Angles(math.pi *1.25 ,0,math.pi) + Vector3.new(.1,1,0)
	leftGunWeld.Parent = game.Workspace  
	leftGunWeld.Name = "LeftWeld"
end

doubleGun()


enabled = true

function fire(v, part)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	local noise = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5)

	v = (v.unit *10 + noise).unit


	local spawnPos = vCharacter.PrimaryPart.Position
	if part ~= nil then 
		spawnPos = part.Position
	else
		print("missing gun")
		return
	end
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=13510352"
		PewPew.Parent = Tool.Handle
		PewPew.Pitch = .85
		PewPew.Volume = 1
	end
	

	spawnPos  = spawnPos + (v * 6)

	
	missile.Position = spawnPos
	missile.Size = Vector3.new(1,1,1)
	missile.Velocity = v * 200
	missile.BrickColor = BrickColor.new(199)
	missile.Shape = 0
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Material = Enum.Material.CorrodedMetal
	missile.Elasticity = .05
	missile.Friction = .7
	missile.Name = "Bullet"



	local force = Instance.new("BodyForce")
	force.Name = "BulletFloat"
	force.force = Vector3.new(0,98,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.BulletScript:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	PewPew:Play()

end

local currentGun = gun

function gunUp()
	if currentGun == gun then
		Tool.GripForward = Vector3.new(0,.981,-.196)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0,.196,.981)
	else
		if leftGunWeld then leftGunWeld.C1 = gripCopy * CFrame.Angles(math.pi/2 - math.pi/20,0,0) + Vector3.new(0,-1,0) end
	end
end

function gunOut()
	if currentGun == gun then
		Tool.GripForward = Vector3.new(0,1,0)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0,0,1)
	else
		if leftGunWeld then leftGunWeld.C1 = gripCopy * CFrame.Angles(math.pi/2,0,0) + Vector3.new(0,-1,0) end
	end
end

function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end



function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = .1
	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end
	
	if currentGun == gun then currentGun = leftGun else currentGun = gun end

	if currentGun then 
		gunUp()
		fire(lookAt, currentGun)
		wait(reload)
		gunOut()
		wait(reload)
	end

	enabled = true

end

function onEquipped()
	if equipped then return end
	equipped = true
	Tool.Handle.EquipSound:play()

	print("Equipped")
	
	--return
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myLeftArm = vCharacter:FindFirstChild("Left Arm")

	holdAnim = myHumanoid:LoadAnimation(Tool.HoldingGuns2)
	holdAnim:Play()
	
	if leftGun then leftGun:Destroy() leftGun = nil end
	if leftGunWeld then leftGunWeld:Destroy() end
	if myTorso and myLeftArm then 
		print("gun 2")
		wait(0.01) --I don't know why I need this here but it makes it work :(
		local rGun = script.Parent:FindFirstChild("Handle")
		leftGun = rGun:Clone()
		leftGun.Name = "LeftGun"
		leftGun.Parent = Tool

		leftGunWeld = Instance.new("Weld")		
		leftGunWeld.Part0 = myLeftArm
		leftGunWeld.Part1 = leftGun
		leftGunWeld.C1 = gripCopy * CFrame.Angles(math.pi/2,0,0) + Vector3.new(0,-1,0)
		leftGunWeld.Parent = myLeftArm 
		leftGunWeld.Name = "LeftGrip"
		
	end	
end

function onUnequipped()
	equipped = false
	if holdAnim == nil then print("missing animation") end
	if holdAnim then holdAnim:Stop() end

	if leftGun then leftGun:Destroy() leftGun = nil end
	if leftGunWeld then leftGunWeld:Destroy() leftGunWeld = nil end
	wait(.1)
	doubleGun()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
