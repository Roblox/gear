--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Unicorn = require(script:WaitForChild("Unicorn"))

RemovalMonitor = script:WaitForChild("RemovalMonitor")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

ColorPart = BasePart:Clone()
ColorPart.Name = "ColorPart"
ColorPart.Reflectance = 0.25
ColorPart.Transparency = 0.1
ColorPart.Material = Enum.Material.SmoothPlastic
ColorPart.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.BackSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.TopSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.RightSurface = Enum.SurfaceType.SmoothNoOutlines
ColorPart.Size = Vector3.new(1, 1, 1)
ColorPart.Anchored = true
ColorPart.CanCollide = false
ColorMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "9856898"),
	TextureId = (BaseUrl .. "1361097"),
	Scale = (ColorPart.Size * 2), --Default mesh scale is 1/2 the size of a 1x1x1 brick.
	Offset = Vector3.new(0, 0, 0),
	VertexColor = Vector3.new(1, 1, 1),
	Parent = ColorPart,
}
ColorLight = Create("PointLight"){
	Name = "Light",
	Brightness = 50,
	Range = 8,
	Shadows = false,
	Enabled = true,
	Parent = ColorPart,
}
Colors = {
	Vector3.new(1, 0, 0),
	Vector3.new(1, 0.5, 0),
	Vector3.new(1, 1, 0),
	Vector3.new(0, 1, 0),
	Vector3.new(0, 1, 1),
	Vector3.new(0, 0, 1),
	Vector3.new(0.5, 0, 1),
}

Rate = (1 / 60)

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

function TransformModel(Objects, Center, NewCFrame, Recurse)
	local Objects = ((type(Objects) ~= "table" and {Objects}) or Objects)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			v.CFrame = NewCFrame:toWorldSpace(Center:toObjectSpace(v.CFrame))
		end
		if Recurse then
			TransformModel(v:GetChildren(), Center, NewCFrame, true)
		end
	end
end

function CreateStripes(Length)
	local StripesModel = Instance.new("Model")
	StripesModel.Name = "StripesPart"
	for i, v in pairs(Colors) do
		local Part = ColorPart:Clone()
		Part.Name = "Part"
		Part.Size = Vector3.new(1, 0.2, Length)
		Part.CFrame = Part.CFrame * CFrame.new((Part.Size.X * (i - 1)), 0, 0)
		Part.Mesh.Scale = (Part.Size * 2)
		Part.Mesh.VertexColor = v
		Part.Light.Color = Color3.new(v.X, v.Y, v.Z)
		Part.Parent = StripesModel
	end
	return StripesModel
end

function GetStripesModel()
	local ModelName = ("RainbowUnicornStripes")
	local Model = game:GetService("Workspace"):FindFirstChild(ModelName)
	if not Model then
		Model = Instance.new("Model")
		Model.Name = ModelName
		local RemovalMonitorClone = RemovalMonitor:Clone()
		RemovalMonitorClone.Disabled = false
		RemovalMonitorClone.Parent = Model
	end
	return Model
end

function MakeRainbowTrail(Origin, Offset)
	local LastPlace = nil
	while ToolEquipped and CheckIfAlive() do
		local SpawnPos = (Origin.CFrame * Offset)
		local CurrentPlace = (SpawnPos * CFrame.new(0, 0, 0.25)).p
		local Velocity = Torso.Velocity
		Velocity = Vector3.new(Velocity.X, 0, Velocity.Z).magnitude
		if LastPlace and Velocity > 5 then
			Spawn(function()
				local Model = GetStripesModel()
				local Distance = (LastPlace - CurrentPlace).magnitude
				if Distance > 8 then
					LastPlace = nil
					return
				end
				local Length = (Distance + 0)
				local StripesModel = CreateStripes(Length)
				local StripesCFrame = CFrame.new((LastPlace + (CurrentPlace - LastPlace).Unit * (Distance / 2)), CurrentPlace) * CFrame.Angles(0, 0, -(math.pi / 2))					
				TransformModel(StripesModel, StripesModel:GetModelCFrame(), StripesCFrame, true)
				Debris:AddItem(StripesModel, 1.25)
				StripesModel.Parent = Model
				if Model and not Model.Parent then
					Model.Parent = game:GetService("Workspace")
				end					
				LastPlace = CurrentPlace
			end)
		elseif not LastPlace then
			LastPlace = CurrentPlace
		end
		wait(0.15)
	end
end

function SpawnUnicorn(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("Model") or v:IsA("BasePart")) and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	local UnicornCopy = Unicorn:Clone()
	local Body = UnicornCopy.Body
	local TorsoWeld = Create("Weld"){
		Part0 = Torso,
		Part1 = Body,
		C0 = CFrame.new(-0.25, -0.85, -1.75),
		C1 = CFrame.new(0, 0, 0),
		Parent = Body
	}
	UnicornCopy.Parent = Tool
	Spawn(function()
		MakeRainbowTrail(Body, CFrame.new(0.3, -2, 0))
	end)
	local RayHit, RayPos, RayNormal = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
	if RayHit then
		Torso.CFrame = Torso.CFrame + Vector3.new(0, ((Character:GetModelSize().Y / 2) + 2.5), 0)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		SpawnUnicorn(true)
	end)
	Handle.Transparency = 1
end

function Unequipped()
	SpawnUnicorn(false)
	ToolEquipped = false
	Handle.Transparency = 0
end

SpawnUnicorn(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)