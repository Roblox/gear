--Made by Luckymaxer
--Updated for R15 avatar by StarWars

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Animate = script:WaitForChild("Animate")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

Dragon = Create("Model"){
	Name = "KorbloxDragon",
}

Body = BasePart:Clone()
Body.Name = "Body"
Body.Size = Vector3.new(0.2, 0.2, 0.2)
BodyMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "395086727"),
	TextureId = (BaseUrl .. "395086967"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Body,
}

BoundaryParts = {
	{Size = Vector3.new(1.5, 1.5, 5.5), C0 = CFrame.new(-0.0798035264, -6.28961086, -4.58834839, 1, 0, 0, 0, 1, 0, 0, 0, 1), C1 = CFrame.new(-0.0798035264, -5.99730825, -2.22450972, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
	{Size = Vector3.new(1, 1.7, 2.3), C0 = CFrame.new(-0.0798035264, -6.28961086, -4.58834839, 1, 0, 0, 0, 1, 0, 0, 0, 1), C1 = CFrame.new(-0.0798040032, -7.49732161, 1.17549062, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
	{Size = Vector3.new(1, 0.7, 6.3), C0 = CFrame.new(-0.0798035264, -6.28961086, -4.58834839, 1, 0, 0, 0, 1, 0, 0, 0, 1), C1 = CFrame.new(-0.0798035264, -4.89730883, -8.02450943, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
}

LeftWing = Body:Clone()
LeftWing.Name = "LeftWing"
LeftWing.Size = Vector3.new(0.2, 0.2, 0.2)
LeftWing.Mesh.MeshId = (BaseUrl .. "395086788")

RightWing = Body:Clone()
RightWing.Name = "RightWing"
RightWing.Size = Vector3.new(0.2, 0.2, 0.2)
RightWing.Mesh.MeshId = (BaseUrl .. "395086834")

Joints = {
	{Name = "Left Wing", Class = "Motor6D", Properties = {Part0 = Body, Part1 = LeftWing, MaxVelocity = 0.1, C0 = CFrame.new(-0.484679878, -0.100065708, -3.59071827, 1, 0, 7.4505806e-009, -9.31322575e-010, 1.00000048, 0, 0, 0, 1.00000048), C1 = CFrame.new(2.8150723, 0.203055143, 0.150001541, 0.999999285, -4.65661287e-010, 1.49011612e-008, -1.86264515e-009, 1.00000238, 1.49011612e-008, 7.4505806e-009, 0, 1.00000238)}},
	{Name = "Right Wing", Class = "Motor6D", Properties = {Part0 = Body, Part1 = RightWing, MaxVelocity = 0.1, C0 = CFrame.new(0.513690293, -0.10998261, -3.59236598, 1.00000167, 0, 7.4505806e-009, 3.7252903e-009, 1.00000107, 0, -7.4505806e-009, 0, 1.00000107), C1 = CFrame.new(-2.78931069, 0.203355223, 0.150006786, 1.0000062, -1.02445483e-008, 0, 2.56113708e-008, 1.00000405, -2.98023224e-008, -7.4505806e-009, 4.47034836e-008, 1.00000405)}},
}

for i, v in pairs(Joints) do
	local Joint = Create(v.Class){
		Name = v.Name,
	}
	for i, v in pairs(v.Properties) do
		pcall(function()
			Joint[i] = v
		end)
	end
	Joint.Parent = Joint.Part0
end

for i, v in pairs({Body, LeftWing, RightWing}) do
	v.Parent = Dragon
end

for i, v in pairs(BoundaryParts) do
	local BoxPart = BasePart:Clone()
	BoxPart.Name = "BoxPart"
	BoxPart.Transparency = 1
	BoxPart.Size = v.Size
	BoxPart.CanCollide = true
	local Weld = Create("Weld"){
		Name = "Weld",
		Part0 = Body,
		Part1 = BoxPart,
		C0 = v.C0,
		C1 = v.C1,
		Parent = BoxPart,
	}
	BoxPart.Parent = Dragon
end

AnimateCopy = Animate:Clone()
AnimateCopy.Disabled = false
AnimateCopy.Parent = Dragon

return Dragon