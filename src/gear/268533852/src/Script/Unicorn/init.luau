--Made by Luckymaxer

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

Unicorn = Create("Model"){
	Name = "Unicorn",
}

Body = BasePart:Clone()
Body.Name = "Body"
Body.Size = Vector3.new(1, 3, 8)
BodyMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "268594511"),
	TextureId = (BaseUrl .. "268594629"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Body,
}

LeftArm = Body:Clone()
LeftArm.Name = "LeftArm"
LeftArm.Size = Vector3.new(1, 3.5, 2)
LeftArm.Mesh.MeshId = (BaseUrl .. "268594468")

RightArm = Body:Clone()
RightArm.Name = "RightArm"
RightArm.Size = Vector3.new(1, 3.5, 2)
RightArm.Mesh.MeshId = (BaseUrl .. "268588796")


LeftLeg = Body:Clone()
LeftLeg.Name = "LeftLeg"
LeftLeg.Size = Vector3.new(1, 4.5, 3.5)
LeftLeg.Mesh.MeshId = (BaseUrl .. "268588770")

RightLeg = Body:Clone()
RightLeg.Name = "RightLeg"
RightLeg.Size = Vector3.new(1, 4.5, 3.5)
RightLeg.Mesh.MeshId = (BaseUrl .. "268594406")

Tail = Body:Clone()
Tail.Name = "Tail"
Tail.Size = Vector3.new(0.2, 0.2, 0.2)
Tail.Mesh.MeshId = (BaseUrl .. "267659727")

ParticlePart = BasePart:Clone()
ParticlePart.Name = "ParticlePart"
ParticlePart.Transparency = 1
ParticleWeld = Create("Weld"){
	Part0 = Body,
	Part1 = ParticlePart,
	C0 = (CFrame.new(0, 0, 3) * CFrame.Angles((math.pi / 2), 0, 0)),
	C1 = CFrame.new(0, 0, 0),
	Parent = ParticlePart,
}

Joints = {
	{Name = "ParticleWeld", Class = "Weld", Properties = {Part0 = Body, Part1 = ParticlePart, C0 = (CFrame.new(0, 0, 3) * CFrame.Angles((math.pi / 2), 0, 0)), C1 = CFrame.new(0, 0, 0)}},
	{Name = "Tail", Class = "Motor", Properties = {Part0 = Body, Part1 = Tail, MaxVelocity = 0.015, C0 = CFrame.new(0.365923166, -0.727078259, 5.21935654, 1, 0, 0, 0, 1, 0, 0, 0, 1), C1 = CFrame.new(0.0859200954, 1.52292633, 0.0193252563, 1, 2.30967999e-007, -5.66244125e-007, 2.30967999e-007, 1.00000048, 2.98023224e-007, -5.96046448e-008, 3.57627869e-007, 1)}},
	{Name = "Left Shoulder", Class = "Motor6D", Properties = {Part0 = Body, Part1 = LeftArm, MaxVelocity = 0.1, C0 = CFrame.new(1.92124736, -1.41252208, -0.642749071, -4.37113883e-008, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-008), C1 = CFrame.new(0.901232004, 1.53744125, -0.14269352, 0, 5.21540642e-008, 1, -1.34110451e-007, 1, 9.68575478e-008, -1, 4.76837158e-007, -5.96046448e-008)}},
	{Name = "Right Shoulder", Class = "Motor6D", Properties = {Part0 = Body, Part1 = RightArm, MaxVelocity = 0.1, C0 = CFrame.new(0.671006262, -1.22540283, -0.888130188, -2.98023224e-008, 1.49011612e-008, -1, 1.49011612e-008, 1, -1.49011612e-008, 1, 1.49011612e-008, 0), C1 = CFrame.new(1.02978861, 1.69379532, -0.313370168, -8.94069672e-008, 3.65078449e-007, -0.99999994, 5.21540642e-007, 1.00000048, -3.65078449e-007, 1, 7.59959221e-007, 2.68220901e-007)}},
	{Name = "Left Hip", Class = "Motor6D", Properties = {Part0 = Body, Part1 = LeftLeg, MaxVelocity = 0.1, C0 = CFrame.new(3.03076577, -2.07473755, 3.62987709, -2.98023224e-008, 2.23517418e-008, -1, 2.98023224e-008, 1, -2.98023224e-008, 1, 4.47034836e-008, 0), C1 = CFrame.new(3.45085025, 1.7358228, -0.809954643, 2.98023224e-008, 1.02818012e-006, -0.999999881, 1.5348196e-006, 1.00000203, -9.90927219e-007, 1, 1.47521496e-006, 7.4505806e-007)}},
	{Name = "Right Hip", Class = "Motor6D", Properties = {Part0 = Body, Part1 = RightLeg, MaxVelocity = 0.1, C0 = CFrame.new(4.33719444, -2.07716751, 3.49755383, -2.98023224e-008, 1.49011612e-008, 1, -1.49011612e-008, 1, 7.4505806e-009, -1, 1.49011612e-008, -5.96046448e-008), C1 = CFrame.new(3.3072443, 1.75290704, -1.00250554, 8.64267349e-007, 2.68220901e-007, 1, -1.49011612e-007, 1, 9.68575478e-008, -1, 5.21540642e-007, -8.94069672e-008)}},
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

for i, v in pairs({Body, Tail, LeftArm, RightArm, LeftLeg, RightLeg, ParticlePart}) do
	v.Parent = Unicorn
end

AnimateCopy = Animate:Clone()
AnimateCopy.Disabled = false
AnimateCopy.Parent = Unicorn

return Unicorn