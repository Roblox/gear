local Tool = script.Parent;
local reloading = 0

enabled = true

local reloadSound = Instance.new("Sound")
reloadSound.Name = "reloadSound"
reloadSound.SoundId = "http://www.roblox.com/asset/?id=25299064"
reloadSound.Parent = Tool.Handle
reloadSound.Volume = 2

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	local noise = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).unit

	v = (v + (noise * .1)).unit


	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=13510352"
		PewPew.Parent = Tool.Handle
		PewPew.Pitch = .85
		PewPew.Volume = 1
	end
	

	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.Size = Vector3.new(1,1,1)
	missile.Velocity = v * 150
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
	
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	PewPew:Play()

end



function gunUp()
	Tool.GripForward = Vector3.new(0,.981,-.196)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,.196,.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
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

	gunUp()
	fire(lookAt)

	reloading = reloading + 1
	if reloading >= 6 then
		if reloadSound ~= nil then
			reloadSound:Play()
		end
		reloading = 0
		Tool.GripUp = Vector3.new(0,-0.5,1)
		wait(0.5)
		Tool.GripUp = Vector3.new(0,0,1)
	end

	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end

function onEquipped()
	Tool.Handle.EquipSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
