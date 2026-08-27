local Tool = script.Parent;

enabled = true

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=33285761"
		PewPew.Parent = Tool.Handle
		PewPew.Volume = 1
	end
	
	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.Velocity = v * 250
	missile.BrickColor = BrickColor.new("Dark stone grey")
	missile.Material = Enum.Material.Slate
	missile.Shape = 0
	missile.formFactor = 0
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Size = Vector3.new(1,1,1)
	missile.Name = "Rock"


	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,78,0)
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
	Tool.GripForward = Vector3.new(0,-1,0)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,1,0)
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

	local reload = .4
	Tool.Shooting.Value = true
	wait(0.45)
	gunUp()
	fire(lookAt)
	wait(reload)
	gunOut()
	wait(reload)
	Tool.Shooting.Value = false

	enabled = true

end

script.Parent.Activated:connect(onActivated)
