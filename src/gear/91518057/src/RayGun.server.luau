local Tool = script.Parent;

enabled = true

local spark = Instance.new("Sparkles")
spark.Color = Color3.new(0,1,0)

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	
	--spark:Clone().Parent = missile

	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=91453412"
		PewPew.Parent = Tool.Handle
		PewPew.Volume = 1
	end
	

	spawnPos  = spawnPos + (v * 10)

	
	missile.CFrame = CFrame.new(spawnPos,spawnPos+v)
	missile.Size = Vector3.new(.1,.1,2)
	--missile.Velocity = v * 150
	missile.BrickColor = BrickColor.new(1020)
	missile.Shape = 1
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Name = "Spark"
	missile.Reflectance = 1


	local force = Instance.new("BodyVelocity")
	force.maxForce = Vector3.new(9999999,99999999,9999999)
	force.velocity=v * 150
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
	--Tool.GripForward = Vector3.new(0,.981,-.196)
	--Tool.GripRight = Vector3.new(1,0,0)
	--Tool.GripUp = Vector3.new(0,.196,.981)
	Tool.GripForward = Vector3.new(0, -.196,-.981)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0,.981, -.196)
end

function gunOut()
	Tool.GripForward = Vector3.new(0, 0, -1)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1, 0)
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
