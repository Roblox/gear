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

Sounds = {
	Bells = script:WaitForChild("Bells"),
}

Reindeer = Create("Model"){
	Name = "Reindeer",
}

Body = BasePart:Clone()
Body.Name = "Body"
Body.Size = Vector3.new(0.2, 0.2, 0.2)
BodyMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "329864820"),
	TextureId = (BaseUrl .. "329865098"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Body,
}

LeftArm = Body:Clone()
LeftArm.Name = "LeftArm"
LeftArm.Size = Vector3.new(0.5, 2, 2)
LeftArm.Mesh.MeshId = (BaseUrl .. "329864881")

RightArm = Body:Clone()
RightArm.Name = "RightArm"
RightArm.Size = Vector3.new(0.5, 2, 2)
RightArm.Mesh.MeshId = (BaseUrl .. "329864927")


LeftLeg = Body:Clone()
LeftLeg.Name = "LeftLeg"
LeftLeg.Size = Vector3.new(0.75, 2, 2.5)
LeftLeg.Mesh.MeshId = (BaseUrl .. "329865045")

RightLeg = Body:Clone()
RightLeg.Name = "RightLeg"
RightLeg.Size = Vector3.new(0.75, 2, 2.5)
RightLeg.Mesh.MeshId = (BaseUrl .. "329892531")

Joints = {
	{Name = "Left Shoulder", Class = "Motor6D", Properties = {Part0 = Body, Part1 = LeftArm, MaxVelocity = 0.1, C0 = CFrame.new(0.719957352, -1.5801506, -0.669919133, -0.258818179, 4.83047188e-007, 0.965926051, 0.965925932, 3.79591029e-007, 0.258818239, -2.51960046e-007, 1, -5.64783477e-007), C1 = CFrame.new(1.2499733, 0.900003314, 0.450016439, -0.258817345, 6.07691618e-007, 0.965927064, 0.965925872, 7.76904017e-007, 0.258817494, -6.98761141e-007, 0.999999821, -5.86327587e-007)}},
	{Name = "Right Shoulder", Class = "Motor6D", Properties = {Part0 = Body, Part1 = RightArm, MaxVelocity = 0.1, C0 = CFrame.new(1.7801125, -2.57996368, -0.669932902, 0.49999997, 0, 0.866025448, 0.866025448, -4.37113883e-008, -0.49999997, 3.78549885e-008, 1, -2.18551577e-008), C1 = CFrame.new(1.24996114, -0.0999983251, 0.449982941, 0.499999732, -5.95864549e-008, 0.86602515, 0.86602515, -1.03314179e-007, -0.499999732, 6.07251422e-008, 0.999999464, 1.36926246e-007)}},
	{Name = "Left Hip", Class = "Motor6D", Properties = {Part0 = Body, Part1 = LeftLeg, MaxVelocity = 0.1, C0 = CFrame.new(0.554751158, -1.80840826, 2.28847075, -4.37113883e-008, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-008), C1 = CFrame.new(1.00009727, 0.650001526, -0.799991846, -1.3907993e-008, -3.87430191e-007, -1.00000203, 7.15255737e-007, 1.00000298, 1.49010347e-007, 1.00000632, 2.02655792e-006, 1.93830056e-006)}},
	{Name = "Right Hip", Class = "Motor6D", Properties = {Part0 = Body, Part1 = RightLeg, MaxVelocity = 0.1, C0 = CFrame.new(1.6174655, -1.80840826, 2.28847075, -4.37113883e-008, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-008), C1 = CFrame.new(1.20008922, 0.650001526, -0.799991846, -4.37113883e-008, 0, -1, 7.15253634e-007, 1, -3.12647281e-014, 1, -7.15253634e-007, -4.37113883e-008)}},
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

BellSound = Sounds.Bells:Clone()
BellSound.Parent = Body

for i, v in pairs({Body, LeftArm, RightArm, LeftLeg, RightLeg}) do
	v.Parent = Reindeer
end

AnimateCopy = Animate:Clone()
AnimateCopy.Disabled = false
AnimateCopy.Parent = Reindeer

return Reindeer