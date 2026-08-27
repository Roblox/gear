FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()
local Handle = script.Parent

local total_time = 5 -- seconds
local cur_time = 0

local debris = game:GetService("Debris")

function update(frac)
	script.Parent.Fuse.Color = Color3.new(0, 0, 1)
end


function blowUp()
	local sound = Instance.new("Sound")
	sound.SoundId = "http://www.roblox.com/asset/?id=25869492"
	sound.Parent = script.Parent
	sound.Volume = 1
	sound:play()

	for i = 1,12 do

		flower1 = Instance.new("Part")
		flower1Mesh = Instance.new("SpecialMesh")
		if i < 5 then
			flower1.BrickColor = BrickColor.new("Light blue")
		elseif i > 4 and i < 9 then
			flower1.BrickColor = BrickColor.new("Alder")
		else
			flower1.BrickColor = BrickColor.new("Deep orange")
		end
		flower1.Size = Vector3.new(1,1.2,1)
		flower1.formFactor = 2
		flower1.CanCollide = true
		flower1.Locked = true
		flower1Mesh.MeshId = "http://www.roblox.com/asset/?id=16659363"
		flower1Mesh.Scale = Vector3.new(1,2,1)
		flower1Mesh.Parent = flower1

		flowerPos = Vector3.new(Handle.Position.x + math.random(i - 4, i + 4), Handle.Position.y, Handle.Position.z)
		flower1.Position = flowerPos
		flower1.Parent = game.Workspace
		debris:addItem(flower1,60)
		force = Instance.new("BodyForce")
		force.force = Vector3.new(0,math.random(300,500),0)
		force.Parent = flower1
		debris:AddItem(force,0.1)
		debris:AddItem(flower1,30)

	end

	for i= 1,4 do

		flower1 = Instance.new("Part")
		flower1Mesh = Instance.new("SpecialMesh")
		flower1.BrickColor = BrickColor.new("Brown")
		flower1.Size = Vector3.new(2,2.8,2)
		flower1.CanCollide = true
		flower1.Locked = true
		flower1Mesh.MeshId = "http://www.roblox.com/asset/?id=16215991"
		flower1Mesh.TextureId = "http://www.roblox.com/asset/?id=16216333"
		flower1Mesh.Scale = Vector3.new(2,2,2)
		flower1Mesh.Parent = flower1

		flowerPos = Vector3.new(Handle.Position.x + math.random(i - 3, i + 2), Handle.Position.y, Handle.Position.z)
		flower1.Position = flowerPos
		flower1.Parent = game.Workspace
		force = Instance.new("BodyForce")
		force.force = Vector3.new(math.random(-50,50),math.random(3000,4000),math.random(-51,53))
		force.Parent = flower1
		debris:AddItem(force,0.1)
		debris:AddItem(flower1,40)

	end

	Handle.Transparency = 1
end

while cur_time < total_time do
	update(cur_time / total_time)
	local e,g = wait(.5)
	cur_time = cur_time + e
end


blowUp()
wait(.1)
script.Parent:remove()
