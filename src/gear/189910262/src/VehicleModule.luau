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
	TextureId = "http://www.roblox.com/asset/?id=189753994",
	Meshes = {
		Body = "http://www.roblox.com/asset/?id=189852085",
		FrontWheel = "http://www.roblox.com/asset/?id=189753965",
		BackWheel = "http://www.roblox.com/asset/?id=189753981",
	},
	Scale = Vector3.new(2, 2, 2)
}

Body = BasePart:Clone()
Body.Name = "FakeHandle"
Body.Size = Vector3.new(1, 5, 6)
Body.CanCollide = false
BodyMesh = Instance.new("SpecialMesh")
BodyMesh.MeshType = Enum.MeshType.FileMesh
BodyMesh.MeshId = MeshData.Meshes.Body
BodyMesh.TextureId = MeshData.TextureId
BodyMesh.Scale = MeshData.Scale
BodyMesh.Parent = Body

Wheel = BasePart:Clone()
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
FrontMotor.C0 = CFrame.Angles(0, (math.pi / 2), 0) + Vector3.new(0, -1.125, -2.1)
FrontMotor.C1 = CFrame.Angles(0, -(math.pi / 2), 0)
FrontMotor.Parent = FakeHandle
FrontWheelClone.Parent = FakeHandle
		
BackWheelClone = BackWheel:Clone()
BackMotor = Instance.new("Motor6D")
BackMotor.Name = "BackMotor"
BackMotor.Part0 = FakeHandle
BackMotor.Part1 = BackWheelClone
BackMotor.C0 = CFrame.Angles(0, (math.pi / 2), 0) + Vector3.new(0, -1.125, 2.125)
BackMotor.C1 = CFrame.Angles(0, -(math.pi / 2), 0)
BackMotor.Parent = FakeHandle
BackWheelClone.Parent = FakeHandle

return FakeHandle:Clone()