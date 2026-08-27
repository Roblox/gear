--Made by Luckymaxer

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

MegabrandsTruck = Instance.new("Model")
MegabrandsTruck.Name = "MegabrandsTruck"

MegabrandsBody = BasePart:Clone()
MegabrandsBody.Name = "Body"
MegabrandsBody.Size = Vector3.new(1.75, 1.5, 2.5)

BodyMesh = Instance.new("SpecialMesh")
BodyMesh.MeshType = Enum.MeshType.FileMesh
BodyMesh.MeshId = "http://www.roblox.com/asset?id=183436331"
BodyMesh.TextureId = "http://www.roblox.com/asset?id=183436382"
BodyMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
BodyMesh.Parent = MegabrandsBody

MegabrandsWheel = BasePart:Clone()
MegabrandsWheel.Name = "Wheel"
MegabrandsWheel.Size = Vector3.new(0.2, 0.2, 0.2)
WheelMesh = Instance.new("SpecialMesh")
WheelMesh.MeshType = Enum.MeshType.FileMesh
WheelMesh.MeshId = "http://www.roblox.com/asset?id=183436357"
WheelMesh.TextureId = "http://www.roblox.com/asset?id=183436382"
WheelMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
WheelMesh.Parent = MegabrandsWheel

FrontLeftWheel = MegabrandsWheel:Clone()
FrontLeftWheel.Name = "FrontLeftWheel"
FrontLeftMotor = Instance.new("Motor6D")
FrontLeftMotor.Name = "FrontLeftMotor"
FrontLeftMotor.Part0 = FrontLeftWheel
FrontLeftMotor.Part1 = MegabrandsBody
FrontLeftMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
FrontLeftMotor.C1 = CFrame.new(-0.675, -0.3375, -0.9125) * CFrame.Angles(0, -(math.pi / 2), 0)
FrontLeftMotor.Parent = MegabrandsBody

FrontRightWheel = MegabrandsWheel:Clone()
FrontRightWheel.Name = "FrontRightWheel"
FrontRightMotor = Instance.new("Motor6D")
FrontRightMotor.Name = "FrontRightMotor"
FrontRightMotor.Part0 = FrontRightWheel
FrontRightMotor.Part1 = MegabrandsBody
FrontRightMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
FrontRightMotor.C1 = CFrame.new(0.675, -0.3375, -0.9125) * CFrame.Angles(0, -(math.pi / 2), 0)
FrontRightMotor.Parent = MegabrandsBody

BackLeftWheel = MegabrandsWheel:Clone()
BackLeftWheel.Name = "BackLeftWheel"
BackLeftMotor = Instance.new("Motor6D")
BackLeftMotor.Name = "BackLeftMotor"
BackLeftMotor.Part0 = BackLeftWheel
BackLeftMotor.Part1 = MegabrandsBody
BackLeftMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
BackLeftMotor.C1 = CFrame.new(-0.675, -0.3375, 0.9125) * CFrame.Angles(0, -(math.pi / 2), 0)
BackLeftMotor.Parent = MegabrandsBody

BackRightWheel = MegabrandsWheel:Clone()
BackRightWheel.Name = "BackRightWheel"
BackRightMotor = Instance.new("Motor6D")
BackRightMotor.Name = "BackRightMotor"
BackRightMotor.Part0 = BackRightWheel
BackRightMotor.Part1 = MegabrandsBody
BackRightMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
BackRightMotor.C1 = CFrame.new(0.675, -0.3375, 0.9125) * CFrame.Angles(0, -(math.pi / 2), 0)
BackRightMotor.Parent = MegabrandsBody

for i, v in pairs({MegabrandsBody, FrontLeftWheel, FrontRightWheel, BackLeftWheel, BackRightWheel}) do
	v.Parent = MegabrandsTruck
end

return MegabrandsTruck