--Made by Luckymaxer

BaseUrl = "http://www.roblox.com/asset?id="

Assets = {
	Meshes = {
		Body = 220616158,
		Wheel = 220616226,
	},
	Texture = 220616251,
}

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

HotWheelsTwinductionCar = Instance.new("Model")
HotWheelsTwinductionCar.Name = "HotWheelsTwinductionCar"

HotWheelsTwinductionBody = BasePart:Clone()
HotWheelsTwinductionBody.Name = "Body"
HotWheelsTwinductionBody.Size = Vector3.new(1, 0.65, 2)

BodyMesh = Instance.new("SpecialMesh")
BodyMesh.MeshType = Enum.MeshType.FileMesh
BodyMesh.MeshId = (BaseUrl .. Assets.Meshes.Body)
BodyMesh.TextureId = (BaseUrl .. Assets.Texture)
BodyMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
BodyMesh.Parent = HotWheelsTwinductionBody

HotWheelsTwinductionWheel = BasePart:Clone()
HotWheelsTwinductionWheel.Name = "Wheel"
HotWheelsTwinductionWheel.Size = Vector3.new(0.2, 0.2, 0.2)
HotWheelsTwinductionWheel.CanCollide = false
WheelMesh = Instance.new("SpecialMesh")
WheelMesh.MeshType = Enum.MeshType.FileMesh
WheelMesh.MeshId = (BaseUrl .. Assets.Meshes.Wheel)
WheelMesh.TextureId = (BaseUrl .. Assets.Texture)
WheelMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
WheelMesh.Parent = HotWheelsTwinductionWheel

FrontLeftWheel = HotWheelsTwinductionWheel:Clone()
FrontLeftWheel.Name = "FrontLeftWheel"
FrontLeftMotor = Instance.new("Motor6D")
FrontLeftMotor.Name = "FrontLeftMotor"
FrontLeftMotor.Part0 = FrontLeftWheel
FrontLeftMotor.Part1 = HotWheelsTwinductionBody
FrontLeftMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
FrontLeftMotor.C1 = CFrame.new(-0.4, -0.15, -0.685) * CFrame.Angles(0, -(math.pi / 2), 0)
FrontLeftMotor.Parent = HotWheelsTwinductionBody

FrontRightWheel = HotWheelsTwinductionWheel:Clone()
FrontRightWheel.Name = "FrontRightWheel"
FrontRightMotor = Instance.new("Motor6D")
FrontRightMotor.Name = "FrontRightMotor"
FrontRightMotor.Part0 = FrontRightWheel
FrontRightMotor.Part1 = HotWheelsTwinductionBody
FrontRightMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
FrontRightMotor.C1 = CFrame.new(0.4, -0.15, -0.685) * CFrame.Angles(0, -(math.pi / 2), 0)
FrontRightMotor.Parent = HotWheelsTwinductionBody

BackLeftWheel = HotWheelsTwinductionWheel:Clone()
BackLeftWheel.Name = "BackLeftWheel"
BackLeftMotor = Instance.new("Motor6D")
BackLeftMotor.Name = "BackLeftMotor"
BackLeftMotor.Part0 = BackLeftWheel
BackLeftMotor.Part1 = HotWheelsTwinductionBody
BackLeftMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
BackLeftMotor.C1 = CFrame.new(-0.42, -0.15, 0.6275) * CFrame.Angles(0, -(math.pi / 2), 0)
BackLeftMotor.Parent = HotWheelsTwinductionBody

BackRightWheel = HotWheelsTwinductionWheel:Clone()
BackRightWheel.Name = "BackRightWheel"
BackRightMotor = Instance.new("Motor6D")
BackRightMotor.Name = "BackRightMotor"
BackRightMotor.Part0 = BackRightWheel
BackRightMotor.Part1 = HotWheelsTwinductionBody
BackRightMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
BackRightMotor.C1 = CFrame.new(0.42, -0.15, 0.6275) * CFrame.Angles(0, -(math.pi / 2), 0)
BackRightMotor.Parent = HotWheelsTwinductionBody

for i, v in pairs({HotWheelsTwinductionBody, FrontLeftWheel, FrontRightWheel, BackLeftWheel, BackRightWheel}) do
	v.Parent = HotWheelsTwinductionCar
end

return HotWheelsTwinductionCar