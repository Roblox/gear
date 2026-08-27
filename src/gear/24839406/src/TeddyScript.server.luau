local Tool = script.Parent;

enabled = true



s1 = Instance.new("Sound")
s1.SoundId = "http://www.roblox.com/asset/?id=24721821"
s1.Parent = Tool.Handle

s2 = Instance.new("Sound")
s2.SoundId = "http://www.roblox.com/asset/?id=24721863"
s2.Parent = Tool.Handle

s3 = Instance.new("Sound")
s3.SoundId = "http://www.roblox.com/asset/?id=24721901"
s3.Parent = Tool.Handle

local sayings = {s1,s2,s3}

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

	Tool.GripForward = Vector3.new(-0, 1, 1)
	Tool.GripPos = Vector3.new(0, -0.6, -0.3)
	Tool.GripRight = Vector3.new(1, 0, -0)
	Tool.GripUp = Vector3.new(0,-0.5, 0.5)

	sayings[math.random(1,#sayings)]:Play()
	plant(Tool.Handle.Position)
	wait(1)

	Tool.GripForward = Vector3.new(-0, 1, 0)
	Tool.GripPos = Vector3.new(0, -0.3, -0.2)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, -0, 1)
	
	enabled = true

end

function plant(pos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position

	-- create bomb

		local bomb = Instance.new("Part")
		bomb.CanCollide = true
		bomb.Transparency = 0
		bomb.Position = Vector3.new(pos.x + 2,pos.y,pos.z )
		bomb.Size = Vector3.new(2,2,2)
		bomb.Shape = 0
		bomb.formFactor = 0
		bomb.Name = "EggBomb"
		bomb.Locked = true

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshId = "http://www.roblox.com/asset/?id=1527559"
		textureNumber = math.random(1,4)
		
		if textureNumber == 1 then
			mesh.TextureId = "http://www.roblox.com/asset/?id=24824915"
		elseif textureNumber == 2 then
			mesh.TextureId = "http://www.roblox.com/asset/?id=24824896"
		elseif textureNumber == 3 then
			mesh.TextureId = "http://www.roblox.com/asset/?id=24824969"
		else
			mesh.TextureId = "http://www.roblox.com/asset/?id=24825714"
		end

		mesh.Scale = Vector3.new(1,1,1)
		mesh.VertexColor = Vector3.new(1,1,1)
		mesh.Parent = bomb
		mesh.Name =  "EggMesh"

		local creator_tag = Instance.new("ObjectValue")
		creator_tag.Value = vPlayer
		creator_tag.Name = "creator"
		creator_tag.Parent = bomb

		bomb.Parent = game.Workspace
		local new_script = Tool.Bomb:clone()
		new_script.Disabled = false
		new_script.Parent = bomb

end

function onEquipped()
	for i=1,#sayings do
		sayings[i].Volume = 1
	end
end

function onUnequipped()
	for i=1,#sayings do
		sayings[i].Volume = 0
	end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
