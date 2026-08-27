--Made by Luckymaxer

creator = script:WaitForChild("creator")

Debris = game:GetService("Debris")

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function GatherAllInstances(Parent)
	local Instances = {}
	local function GatherInstances(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			GatherInstances(v)
			table.insert(Instances, v)
		end
	end
	GatherInstances(Parent)
	return Instances
end

humanoid = script.Parent
character = humanoid.Parent
torso = character.Torso
if humanoid and humanoid.Parent and torso and torso.Parent then
	Character = creator.Value.Character
	
	for i,v in pairs(humanoid:GetChildren()) do
		if v.Name == "creator" then
			v:Destroy()
		end
	end

	local creator_tag = creator:Clone()
	creator_tag.Value = creator.Value
	creator_tag.Parent = humanoid	
	
	Hit, Pos = RayCast(torso.Position, Vector3.new(0, -1, 0), 6, {Character, character})
	BlackHole = Instance.new("Part")
	BlackHole.TopSurface = Enum.SurfaceType.Smooth
	BlackHole.BottomSurface = Enum.SurfaceType.Smooth
	BlackHole.FormFactor = Enum.FormFactor.Custom
	BlackHole.Size = Vector3.new(6, 0.2, 6)
	BlackHole.Anchored = true
	BlackHole.BrickColor = BrickColor.new("Really black")
	Instance.new("CylinderMesh", BlackHole)
	Debris:AddItem(BlackHole, 10)
	local Instances = GatherAllInstances(character)
	local Parts = {}
	BlackHole.Parent = character
	BlackHole.CFrame = ((Hit and CFrame.new(Pos)) or torso.CFrame - Vector3.new(0, 6, 0))
	for i, v in pairs(Instances) do
		if v:IsA("BasePart") then
			table.insert(Parts, v)
			v.Anchored = true
			v.BrickColor = BrickColor.new("Institutional white")
			if v.Transparency <= 0 then
				v.Transparency = 0.5
			end
		elseif v:IsA("CharacterMesh") then
			v.BaseTextureId = 0
			v.OverlayTextureId = 0
		elseif v:IsA("DataModelMesh") then
			if v:IsA("SpecialMesh") then
				v.TextureId = ""
			end
			local BrickColor = BrickColor.new("Institutional white")
			local Color = BrickColor.Color
			local r, g, b = Color.r, Color.g, Color.b
			v.VertexColor = Vector3.new(r, g, b)
		elseif v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("Decal") and v.Name ~= "face" then
			v:Destroy()
		end
	end
	Spawn(function()
		while #Parts > 0 do
			for i, v in pairs(Parts) do
				v.CFrame = v.CFrame - Vector3.new(0, 0.25, 0)
				if v.CFrame.y <= BlackHole.CFrame.y then
					v:Destroy()
					table.remove(Parts, i)
				end
			end
			wait(0.1)
		end
		BlackHole:Destroy()
	end)
end