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

Seahorse = Create("Model"){
	Name = "Seahorse",
}

Body = BasePart:Clone()
Body.Name = "Body"
Body.Size = Vector3.new(1.25, 8.5, 2)
Body.Elasticity = 0
Body.Friction = 2
BodyMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "267669177"),
	TextureId = (BaseUrl .. "267669462"),
	Scale = Vector3.new(1.15, 1.15, 1.15),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Body,
}

Fin = BasePart:Clone()
Fin.Name = "Fin"
Fin.Size = Vector3.new(0.5, 0.5, 0.5)
Fin.CanCollide = false
FinMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "267669305"),
	TextureId = (BaseUrl .. "267669462"),
	Scale = Vector3.new(1.15, 1.15, 1.15),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Fin,
}

LeftFin = Fin:Clone()
LeftFin.Name = "LeftFin"

RightFin = Fin:Clone()
RightFin.Name = "RightFin"

LeftMotor = Create("Motor6D"){
	Name = "LeftMotor",
	Part0 = Body,
	Part1 = LeftFin,
	C0 = CFrame.new(-0.780504644, 0.0476379395, 1.77013373, -4.37113883e-008, 1, 0, -1, -4.37113883e-008, 0, 0, 0, 1),
	C1 = CFrame.new(0.329499543, 0.867839813, 0.510133505, -3.9317456e-008, 1, 0, -1, -6.50361471e-008, 3.84170562e-009, -6.05359674e-009, 0, 1),
	MaxVelocity = 0.15,
	Parent = Body,
}

RightMotor = Create("Motor6D"){
	Name = "RightMotor",
	Part0 = Body,
	Part1 = RightFin,
	C0 = CFrame.new(0.799697399, -0.0318717957, 1.19102478, -4.37113883e-008, 1, 0, -1, -4.37113883e-008, 0, 0, 0, 1),
	C1 = CFrame.new(0.0393314362, 0.135908127, -0.945129395, 0.268211097, -0.883318186, -0.384489357, -0.377644777, 0.270767272, -0.885477543, 0.886259377, 0.382696241, -0.260956287),
	MaxVelocity = 0.15,
	Parent = Body,
}

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

for i, v in pairs({Body, LeftFin, RightFin, ParticlePart}) do
	v.Elasticity = 0
	v.Friction = 2
	v.CanCollide = false
	v.Parent = Seahorse
end

Body.CanCollide = true

AnimateCopy = Animate:Clone()
AnimateCopy.Disabled = false
AnimateCopy.Parent = Seahorse

return Seahorse