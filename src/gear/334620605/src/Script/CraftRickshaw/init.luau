--Made by Luckymaxer

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Controller = script:WaitForChild("Controller")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

function CraftRickshaw()
	local Model = Create("Model"){
		Name = "Rickshaw",
	}
	local Body = BasePart:Clone()
	Body.Name = "Body"
	Body.Size = Vector3.new(1, 1, 1)
	Body.CanCollide = false
	Create("SpecialMesh"){
		Name = "Mesh",
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "330128198"),
		TextureId = (BaseUrl .. "330128244"),
		Scale = Vector3.new(11, 11, 11),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Body,
	}
	Body.Parent = Model
	local Frame = {
		Base = {Size = Vector3.new(3.75, 0.2, 4.75), Offset = CFrame.new(0, 0.49, 1.125)},
		FrontSide = {Size = Vector3.new(3.75, 1.5, 0.5), Offset = CFrame.new(0, 1.3, -1)},
		LeftSide = {Size = Vector3.new(0.5, 1.5, 3.75), Offset = CFrame.new(-1.6, 1.3, 1.125)},
		RightSide = {Size = Vector3.new(0.5, 1.5, 3.75), Offset = CFrame.new(1.6, 1.3, 1.125)},
		LeftHandle = {Size = Vector3.new(0.5, 1, 2.25), Offset = CFrame.new(-1.6, 0.875, -2.375)},
		RightHandle = {Size = Vector3.new(0.5, 1, 2.25), Offset = CFrame.new(1.6, 0.875, -2.375)},
		LeftLeg = {Size = Vector3.new(0.5, 2.75, 0.5), Offset = CFrame.new(-1.65, -1.1, -0.95)},
		RightLeg = {Size = Vector3.new(0.5, 2.75, 0.5), Offset = CFrame.new(1.65, -1.1, -0.955)},
		WheelPlacement = {Size = Vector3.new(0.25, 2.75, 2.75), Offset = CFrame.new(0, -1.2, 2)},
	}
	for i, v in pairs(Frame) do
		local Part = BasePart:Clone()
		Part.Name = tostring(i)
		Part.Transparency = 1
		Part.Elasticity = 1
		Part.Friction = 0
		Part.Size = v.Size
		Part.CanCollide = true
		local Weld = Create("Weld"){
			Name = "Weld",
			Part0 = Body,
			Part1 = Part,
			C0 = v.Offset,
			C1 = CFrame.new(0, 0, 0),
			Parent = Part,
		}
		Part.Parent = Model
	end
	local WheelPlacement = Model:FindFirstChild("WheelPlacement")
	if WheelPlacement then
		local Wheel = Body:Clone()
		Wheel.Name = "Wheel"
		Wheel.Size = Vector3.new(0.2, 0.2, 0.2)
		Wheel.CanCollide = false
		local WheelMesh = Wheel.Mesh
		WheelMesh.MeshId = (BaseUrl .. "330128081")
		WheelMesh.TextureId = (BaseUrl .. "330128244")
		WheelMesh.Parent = Wheel
		local WheelMotor = Create("Motor6D"){
			Name = "Motor",
			Part0 = WheelPlacement,
			Part1 = Wheel,
			C0 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, -(math.pi / 2), 0)),
			C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)),
			MaxVelocity = 0.05,
			CurrentAngle = 0,
			DesiredAngle = 999999,
			Parent = Wheel,
		}
		Wheel.Parent = Model
	end
	local Base = Model:FindFirstChild("Base")
	if Base then
		Seat = Create("Seat"){
			Name = "Seat",
			Transparency = 1,
			Shape = Enum.PartType.Block,
			Material = Enum.Material.Plastic,
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FormFactor = Enum.FormFactor.Custom,
			Size = Vector3.new(2, 0.2, 2),
			Disabled = false,
			CanCollide = true,
			Locked = true,
			Anchored = false,
			Parent = Model,
		}
		Create("Weld"){
			Name = "Weld",
			Part0 = Base,
			Part1 = Seat,
			C0 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0)),
			C1 = CFrame.new(0, 0, 0),
			Parent = Seat,
		}
		Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, 0, math.huge),
			cframe = CFrame.new(0, 0, 0),
			D = 500,
			P = 3000,
			Parent = Base,
		}
	end
	local ControllerCopy = Controller:Clone()
	ControllerCopy.Disabled = false
	ControllerCopy.Parent = Model
	return Model
end

return CraftRickshaw