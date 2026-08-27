local Tool = script.Parent;

enabled = true

local reloadCount = 0

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=16433315"
		PewPew.Parent = Tool.Handle
		PewPew.Volume = 1
	end

	local missile = Instance.new("Part")

	missile.Size = Vector3.new(1,1,1)
	missile.BrickColor = BrickColor.new(199)
	missile.Shape = 0
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Name = "lead"
	missile.Reflectance = .5

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,98,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
		
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	for i = 1, 8 do
		local missileClone= missile:clone()
		local spawnPos = vCharacter.PrimaryPart.Position
		local fireDirect = Vector3.new(v.x + math.random(-5,5)/50,v.y + math.random(-5,5)/50,v.z + math.random(-5,5)/50)
		spawnPos  = spawnPos + (fireDirect * 10)

		missile.Position = spawnPos
		missile.Velocity = fireDirect * 200

		missileClone.Parent = game.Workspace
	end

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

	local reload = .7

	gunUp()
	fire(lookAt)
	wait(0.1)
	gunOut()
	wait(reload)

	reloadCount = reloadCount + 1
	if reloadCount > 3 then
		Tool.Handle.Reload:Play()
		reloader()
		reloadCount = 0
	end

	enabled = true

end

function reloader()

	Tool.GripUp = Vector3.new(0,1,0)
	Tool.GripForward = Vector3.new(0,0,-1)
	Tool.GripPos = Vector3.new(0,0,0)
	Tool.GripRight = Vector3.new(1,0,0)

	wait(0.3)
	Tool.GripPos = Vector3.new(0,-0.1,0)
	wait(0.3)
	Tool.GripPos = Vector3.new(0,0.1,0)
	wait(0.3)

	Tool.GripUp = Vector3.new(0,0,1)
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripPos = Vector3.new(0,-0.5,-0.4)
	Tool.GripRight = Vector3.new(1,0,0)

end

function onEquipped()
	Tool.Handle.Reload:Stop()
	Tool.Handle.PewPew:Stop()
end

function onUnequipped()
	Tool.Handle.Reload:Stop()
	Tool.Handle.PewPew:Stop()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
