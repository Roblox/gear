Humanoid = script.Parent
Character = Humanoid.Parent
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

OriginalWalkSpeed = Humanoid.WalkSpeed

SavedInstances = {}

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

for i, v in pairs(GatherAllInstances(Character)) do
	if not v.Parent:IsA("Tool") and not v.Parent.Parent:IsA("Tool") then
		if v:IsA("BasePart") then
			table.insert(SavedInstances, {v, v.Parent, v.BrickColor})
			v.BrickColor = BrickColor.new("Bright violet")
		elseif v:IsA("CharacterMesh") then
			table.insert(SavedInstances, {v, v.Parent, v:Clone()})
			v.BaseTextureId = 0
			v.OverlayTextureId = 0
		elseif v:IsA("DataModelMesh") then
			table.insert(SavedInstances, {v, v.Parent, v:Clone()})
			if v:IsA("SpecialMesh") then
				v.TextureId = ""
			end
			local BrickColor = BrickColor.new("Bright violet")
			local Color = BrickColor.Color
			local r, g, b = Color.r, Color.g, Color.b
			v.VertexColor = Vector3.new(r, g, b)
		elseif v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("Decal") and v.Name ~= "face" then
			table.insert(SavedInstances, {v, v.Parent, v:Clone()})
			v:Destroy()
		end
	end
end

Sparkles = Instance.new("Sparkles")
Sparkles.Parent = Torso

Humanoid.WalkSpeed = 50

wait(30)

for i, v in pairs(SavedInstances) do
	if v[1]:IsA("BasePart") then
		v[1].BrickColor = v[3]
	elseif v[1]:IsA("CharacterMesh") or v[1]:IsA("DataModelMesh") or v[1]:IsA("Clothing") or v[1]:IsA("ShirtGraphic") or v[1]:IsA("Decal") then
		v[1]:Destroy()
		v[3].Parent = v[2]
	end
end

Humanoid.WalkSpeed = OriginalWalkSpeed
Sparkles:Destroy()

script:Destroy()