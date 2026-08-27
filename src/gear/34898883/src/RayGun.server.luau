local Tool = script.Parent;

Tool.Enabled = true

local spark = Instance.new("Sparkles")
spark.Color = Color3.new(1,1,0)

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	
	spark:Clone().Parent = missile

	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		--PewPew.SoundId = "http://www.roblox.com/asset/?id=16433315"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=34365512"
		PewPew.Parent = Tool.Handle
		PewPew.Volume = 1
	end
	

	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.Size = Vector3.new(7,1,7)
	--missile.Velocity = v * 200
	missile.Velocity = v*50
	missile.BrickColor = BrickColor.new(1020)
	missile.Shape = 1
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Name = "StickyStep"
	missile.Reflectance = .5
	--missile.CanCollide = true
	missile.CanCollide = false
	missile.Elasticity = 0


	missile.Material = "DiamondPlate"
	--missile.Material = "Foil"

	--local force = Instance.new("BodyForce")
	--force.force = Vector3.new(0,98,0)
	--force.Parent = missile
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, missile:GetMass()*170, 0)
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


function onActivated(targetPos)
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local lookAt = (targetPos - character.Head.Position).unit

	local reload = .5

	gunUp()
	fire(lookAt)
	wait(reload)
	gunOut()
	wait(reload)

	Tool.Enabled = true

end

script.Parent:WaitForChild'Shoot'.OnServerEvent:connect(function(client, pos)
	if client.Character == script.Parent.Parent then
		onActivated(pos)
	end
end)