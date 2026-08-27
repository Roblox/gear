--Created by StarWars
local Airstrike = {}

local Jet = require(script.Jet)

function Airstrike:Spawn(player, location)
	local LocationPart = Instance.new("Part")
	LocationPart.Name = "Effect"
	LocationPart.Anchored = true
	LocationPart.CanCollide = false
	LocationPart.Size = Vector3.new(0, 0, 0)
	LocationPart.BrickColor = BrickColor.new("Lime green")
	LocationPart.CFrame = CFrame.new(location) * CFrame.Angles(math.pi/2, 0, 0)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshId = "rbxassetid://3270017"
	Mesh.Scale = Vector3.new(40, 40, 1)
	Mesh.Parent = LocationPart
	
	game:GetService("Debris"):AddItem(LocationPart, 5)
	LocationPart.Parent = workspace
	spawn(function()
		while LocationPart and LocationPart.Transparency < 1 do
			LocationPart.Transparency = LocationPart.Transparency + 0.025
			wait(0.15)
		end
		
		if LocationPart then
			LocationPart:Destroy()
		end
	end)
	
	local NewJet = Jet.new(player, location)
	NewJet:Fly()
end

return Airstrike