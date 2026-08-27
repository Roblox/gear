local debris = game:service("Debris")
pellet = script.Parent
local plantScript = pellet.PlantScript
damage = 8


function onTouched(hit)

	pellet.PlantSound:Play()

	local plant = Instance.new("Part")
	plant.Position = pellet.Position
	plant.Size = Vector3.new(1,1.2,1)
	plant.CanCollide = true
	plant.Locked = true
	plant.Anchored = false

	local plantMesh = Instance.new("SpecialMesh")
	plantMesh.Name = "Plant Mesh"
	plantMesh.MeshId = "http://www.roblox.com/asset/?id=1091940"
	plantMesh.TextureId = "http://www.roblox.com/asset/?id=1091942"
	plantMesh.Parent = plant

	plant.Parent = game.Workspace

	ps = plantScript:clone()
	ps.Parent = plant

	debris:AddItem(plant, 100)

	pellet.Parent = nil

end



connection = pellet.Touched:connect(onTouched)

r = game:service("RunService")
t, s = r.Stepped:wait()
d = t + 2.0 - s
while t < d do
	t = r.Stepped:wait()
end

pellet.Parent = nil