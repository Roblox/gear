local Tool = script.Parent;


enabled = true

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)


	local thing = Tool:Clone()
	local missile = thing.Handle
	missile.Orientation = Vector3.new(0, 0, -90)


	local spawnPos = vCharacter.PrimaryPart.Position
	
	--local PewPew = Tool.Handle:FindFirstChild("Whoosh")

	--if (PewPew == nil) then
	--	PewPew = Instance.new("Sound")
	--	PewPew.Name = "Whoosh"
	--	PewPew.SoundId = "http://www.roblox.com/asset/?id=13510352"
	--	PewPew.Parent = Tool.Handle
	--	PewPew.Pitch = .85
	--	PewPew.Volume = 1
	--end
	

	spawnPos  = spawnPos + (v * 10)

	targetPos = spawnPos + (v * 100)

	
	missile.Position = spawnPos
	missile.RotVelocity = Vector3.new(0, 10, 0)
	missile.Velocity = v * 150
	missile.CanCollide = true
	missile.Elasticity = .05
	missile.Friction = .7

	
	local bodyp = Instance.new("BodyPosition")
	bodyp.maxForce = Vector3.new(1e3,1e3,1e3)
	bodyp.D = 1.25e3
	bodyp.P = 1e3
	bodyp.position = targetPos
	bodyp.Parent = missile
	
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile

	local new_script = script.Parent.BoomerangControl:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	thing.Parent = game.Workspace

	--PewPew:Play()

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

	Tool.Parent = nil

	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end


script.Parent.Activated:connect(onActivated)

