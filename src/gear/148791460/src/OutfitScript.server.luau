--Made by Luckymaxer
--Update for R15 avatar by StarWars

Character = script.Parent
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
Duration = 30

Meshes = {
	{MeshId = 125732887, TextureId = 125728597, Scale = Vector3.new(5, 5, 5), Angle = CFrame.Angles(0, 0, 0)},
	{MeshId = 18417911, TextureId = 18417918, Scale = Vector3.new(3, 3, 3), Angle = CFrame.Angles((math.pi / 2), 0, 0)},
	{MeshId = 40312463, TextureId = 40311968, Scale = Vector3.new(7.5, 7.5, 7.5), Angle = CFrame.Angles(-(math.pi / 2), 0, 0)},
	{MeshId = 40312463, TextureId = 40311869, Scale = Vector3.new(7.5, 7.5, 7.5), Angle = CFrame.Angles(-(math.pi / 2), 0, 0)},
	{MeshId = 143518445, TextureId = 143499030, Scale = Vector3.new(5, 5, 5), Angle = CFrame.Angles(0, 0, 0)},
	{MeshId = 65950268, TextureId = 65950352, Scale = Vector3.new(7.5, 7.5, 7.5), Angle = CFrame.Angles(-(math.pi / 2), 0, 0)},
	{MeshId = 18453224, TextureId = 18453205, Scale = Vector3.new(3, 3, 3), Angle = CFrame.Angles((math.pi / 2), 0, 0)}
}

BaseUrl = "http://www.roblox.com/asset?id="

Objects = {}
function SetTransparency(Parent, Transparency, SaveTransparency)
	for i, v in pairs(Parent:GetChildren()) do
		SetTransparency(v, Transparency, SaveTransparency)
		if v:IsA("BasePart") or v:IsA("FaceInstance") then
			if SaveTransparency then
				table.insert(Objects, {v, v.Transparency})
			end
			v.Transparency = Transparency
		end
	end
end

SetTransparency(Character, 1, true)

local RandomMesh = Meshes[math.random(1, #Meshes)]

MeshPart = Instance.new("Part")
MeshPart.FormFactor = Enum.FormFactor.Custom
MeshPart.Size = Vector3.new(0.2, 0.2, 0.2)
MeshPart.CanCollide = false
MeshPart.Name = "MeshPart"
MeshPart.TopSurface = Enum.SurfaceType.Smooth
MeshPart.BottomSurface = Enum.SurfaceType.Smooth

Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.FileMesh
Mesh.MeshId = BaseUrl .. tostring(RandomMesh.MeshId)
Mesh.TextureId = BaseUrl .. tostring(RandomMesh.TextureId)
Mesh.Scale = RandomMesh.Scale
Mesh.Parent = MeshPart

MeshPart.Parent = Character

Weld = Instance.new("Weld")
Weld.Part0 = Torso
Weld.Part1 = MeshPart
Weld.C0 = Weld.C0 * RandomMesh.Angle + Vector3.new(0, 0, 0)
Weld.Parent = MeshPart

wait(Duration)

MeshPart:Destroy()

for i, v in pairs(Objects) do
	if v and v[1] and v[1].Parent then
		v[1].Transparency = v[2]
	end
end

script:Destroy()