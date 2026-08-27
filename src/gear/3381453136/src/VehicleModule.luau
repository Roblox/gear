--Made by Luckymaxer

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

MeshData = {
	TextureId = "rbxassetid://3241340598",
	Meshes = {
		Body = "rbxassetid://3241338757",
		FrontWheel = "rbxassetid://3241340051",
		BackWheel = "rbxassetid://3241340051",
	},
	Scale = Vector3.new(1, 1, 1)
}

Body = BasePart:Clone()
Body.Name = "FakeHandle"
Body.Size = Vector3.new(3.054, 5.143, 6.232)
Body.CanCollide = false
BodyMesh = Instance.new("SpecialMesh")
BodyMesh.MeshType = Enum.MeshType.FileMesh
BodyMesh.MeshId = MeshData.Meshes.Body
BodyMesh.TextureId = MeshData.TextureId
BodyMesh.Scale = MeshData.Scale
BodyMesh.Parent = Body

Wheel = BasePart:Clone()
Wheel.Size = Vector3.new(0.67, 2.189, 2.2)
Wheel.CanCollide = false
WheelMesh = Instance.new("SpecialMesh")
WheelMesh.MeshType = Enum.MeshType.FileMesh
WheelMesh.TextureId = MeshData.TextureId
WheelMesh.Scale = MeshData.Scale
WheelMesh.Parent = Wheel
FrontWheel = Wheel:Clone()
FrontWheel.Name = "FrontWheel"
FrontWheel.Mesh.MeshId = MeshData.Meshes.FrontWheel
BackWheel = Wheel:Clone()
BackWheel.Name = "BackWheel"
BackWheel.Mesh.MeshId = MeshData.Meshes.BackWheel

FakeHandle = Body:Clone()
FakeHandle.CanCollide = false
		
FrontWheelClone = FrontWheel:Clone()
FrontMotor = Instance.new("Motor6D")
FrontMotor.Name = "FrontMotor"
FrontMotor.Part0 = FakeHandle
FrontMotor.Part1 = FrontWheelClone
FrontMotor.C0 = CFrame.new(-0.00812149048, -1.35494089, -2.40127563, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
FrontMotor.C1 = CFrame.new(0, 0, 0, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
FrontMotor.Parent = FakeHandle
FrontWheelClone.Parent = FakeHandle
		
BackWheelClone = BackWheel:Clone()
BackMotor = Instance.new("Motor6D")
BackMotor.Name = "BackMotor"
BackMotor.Part0 = FakeHandle
BackMotor.Part1 = BackWheelClone
BackMotor.C0 = CFrame.new(-0.00812911987, -1.35494089, 1.69862366, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
BackMotor.C1 = CFrame.new(0, 0, 0, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
BackMotor.Parent = FakeHandle
BackWheelClone.Parent = FakeHandle

return FakeHandle:Clone()