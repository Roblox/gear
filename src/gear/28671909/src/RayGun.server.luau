local Tool = script.Parent;
local cardColor = 5
enabled = true

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	if cardColor >= 1 and cardColor <= 17 then
		missile.BrickColor = BrickColor.new("Bright yellow")
		missile.Name = "YellowCard"
	else
		missile.BrickColor = BrickColor.new("Bright red")
		missile.Name = "RedCard"
	end

	local spawnPos = vCharacter.PrimaryPart.Position
	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.formFactor = 2 
	missile.Size = Vector3.new(1,0.4,2)
	missile.Velocity = v * 200
	missile.BottomSurface = 0
	missile.TopSurface = 0

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,98,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.CardScript:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	local timeOutScript = Tool.TimeOutScript:clone()
	timeOutScript.Parent = missile

	missile.Parent = game.Workspace

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

	local reload = 2

	fire(lookAt)
	Tool.Handle.Transparency = 1
	wait(reload)
	Tool.Handle.Transparency = 0
	cardColor = math.random(1,20)
	if cardColor >= 1 and cardColor <= 17 then
		Tool.Handle.Mesh.TextureId = "http://www.roblox.com/asset/?id=28656948"
	else
		Tool.Handle.Mesh.TextureId = "http://www.roblox.com/asset/?id=28658533"
	end

	enabled = true

end

function onEquipped()
	Tool.Handle.EquipSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
