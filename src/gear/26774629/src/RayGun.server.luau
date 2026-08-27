local Tool = script.Parent;
local humanoid = nil
enabled = true

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	local noise = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).unit

	v = (v + (noise * .05)).unit


	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=25918812"
		PewPew.Parent = Tool.Handle
		PewPew.Pitch = .85
		PewPew.Volume = 1
	end
	

	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.Size = Vector3.new(1,1,1)
	missile.Velocity = v * 150
	missile.BrickColor = BrickColor.new(49)
	missile.Shape = 0
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Material = Enum.Material.CorrodedMetal
	missile.Elasticity = .05
	missile.Friction = .7
	missile.Name = "Bullet"



	local force = Instance.new("BodyForce")
	force.Name = "BulletFloat"
	force.force = Vector3.new(0,104,0)
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
	humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = .2

	fire(lookAt)
	shootAnim()
	wait(reload)
	wait(reload)

	enabled = true

end

function shootAnim()

	local animer = humanoid:LoadAnimation(Tool.gunshoot)
	animer:Play(0,1,1)
	animer.KeyframeReached:connect(function(string)
		if string == "middle" then
			wait(0.1)
			animer:Stop()
		end
	end)
	animer:remove()

end

function onEquipped()
	Tool.Handle.EquipSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
