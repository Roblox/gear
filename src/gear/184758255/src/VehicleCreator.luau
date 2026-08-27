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

HotWheelsStreetHawk = Instance.new("Model")
HotWheelsStreetHawk.Name = "HotWheelsStreetHawk"

HotWheelsStreetHawkBody = BasePart:Clone()
HotWheelsStreetHawkBody.Name = "Body"
HotWheelsStreetHawkBody.Size = Vector3.new(3.25, 1.5, 3)

BodyMesh = Instance.new("SpecialMesh")
BodyMesh.MeshType = Enum.MeshType.FileMesh
BodyMesh.MeshId = "http://www.roblox.com/asset?id=183664928"
BodyMesh.TextureId = "http://www.roblox.com/asset?id=183665022"
BodyMesh.Scale = Vector3.new(1, 1, 1)
BodyMesh.Parent = HotWheelsStreetHawkBody

HotWheelsStreetHawkWheel = BasePart:Clone()
HotWheelsStreetHawkWheel.Name = "Wheel"
HotWheelsStreetHawkWheel.Size = Vector3.new(0.2, 0.2, 0.2)
WheelMesh = Instance.new("SpecialMesh")
WheelMesh.MeshType = Enum.MeshType.FileMesh
WheelMesh.MeshId = "http://www.roblox.com/asset?id=183665009"
WheelMesh.TextureId = "http://www.roblox.com/asset?id=183665022"
WheelMesh.Scale = Vector3.new(1, 1, 1)
WheelMesh.Parent = HotWheelsStreetHawkWheel

FrontLeftWheel = HotWheelsStreetHawkWheel:Clone()
FrontLeftWheel.Name = "FrontLeftWheel"
FrontLeftMotor = Instance.new("Motor6D")
FrontLeftMotor.Name = "FrontLeftMotor"
FrontLeftMotor.Part0 = FrontLeftWheel
FrontLeftMotor.Part1 = HotWheelsStreetHawkBody
FrontLeftMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, -(math.pi / 2), 0)
FrontLeftMotor.C1 = CFrame.new(-0.9, -0.45, -0.885) * CFrame.Angles(0, -(math.pi / 2), 0)
FrontLeftMotor.Parent = HotWheelsStreetHawkBody

FrontRightWheel = HotWheelsStreetHawkWheel:Clone()
FrontRightWheel.Name = "FrontRightWheel"
FrontRightMotor = Instance.new("Motor6D")
FrontRightMotor.Name = "FrontRightMotor"
FrontRightMotor.Part0 = FrontRightWheel
FrontRightMotor.Part1 = HotWheelsStreetHawkBody
FrontRightMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
FrontRightMotor.C1 = CFrame.new(0.9, -0.45, -0.885) * CFrame.Angles(0, -(math.pi / 2), 0)
FrontRightMotor.Parent = HotWheelsStreetHawkBody

BackLeftWheel = HotWheelsStreetHawkWheel:Clone()
BackLeftWheel.Name = "BackLeftWheel"
BackLeftMotor = Instance.new("Motor6D")
BackLeftMotor.Name = "BackLeftMotor"
BackLeftMotor.Part0 = BackLeftWheel
BackLeftMotor.Part1 = HotWheelsStreetHawkBody
BackLeftMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, -(math.pi / 2), 0)
BackLeftMotor.C1 = CFrame.new(-0.9, -0.45, 1.14) * CFrame.Angles(math.pi, -(math.pi / 2), 0)
BackLeftMotor.Parent = HotWheelsStreetHawkBody

BackRightWheel = HotWheelsStreetHawkWheel:Clone()
BackRightWheel.Name = "BackRightWheel"
BackRightMotor = Instance.new("Motor6D")
BackRightMotor.Name = "BackRightMotor"
BackRightMotor.Part0 = BackRightWheel
BackRightMotor.Part1 = HotWheelsStreetHawkBody
BackRightMotor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)
BackRightMotor.C1 = CFrame.new(0.9, -0.45, 1.14) * CFrame.Angles(0, -(math.pi / 2), 0)
BackRightMotor.Parent = HotWheelsStreetHawkBody

for i, v in pairs({HotWheelsStreetHawkBody, FrontLeftWheel, FrontRightWheel, BackLeftWheel, BackRightWheel}) do
	v.Parent = HotWheelsStreetHawk
end

return HotWheelsStreetHawk