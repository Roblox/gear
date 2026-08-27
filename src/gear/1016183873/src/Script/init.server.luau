Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RemovalMonitor = script:WaitForChild("RemovalMonitor")

CarpetPieces = {
	{MeshId = 223079795, Angle = 160},
	{MeshId = 223079835, Angle = 100},
	{MeshId = 223079888, Angle = 100},
	{MeshId = 223079981, Angle = 160},
}

CarpetSize = Vector3.new(3, 0.5, 6.5)

BaseUrl = "http://www.roblox.com/asset/?id="

Rate = (1 / 10)

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

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
ColorMesh = Instance.new("SpecialMesh")
ColorMesh.Name = "Mesh"
ColorMesh.MeshType = Enum.MeshType.FileMesh
ColorMesh.MeshId = (BaseUrl .. "9856898")
ColorMesh.TextureId = (BaseUrl .. "1361097")
ColorMesh.Scale = (ColorPart.Size * 2) --Default mesh scale is 1/2 the size of a 1x1x1 brick.
ColorMesh.Offset = Vector3.new(0, 0, 0)
ColorMesh.VertexColor = Vector3.new(1, 1, 1)
ColorMesh.Parent = ColorPart
ColorLight = Instance.new("PointLight")
ColorLight.Name = "Light"
ColorLight.Brightness = 50
ColorLight.Range = 8
ColorLight.Shadows = false
ColorLight.Enabled = true
ColorLight.Parent = ColorPart

RainbowColors = {
	Vector3.new(1, 0, 0),
	Vector3.new(1, 0.5, 0),
	Vector3.new(1, 1, 0),
	Vector3.new(0, 1, 0),
	Vector3.new(0, 1, 1),
	Vector3.new(0, 0, 1),
	Vector3.new(0.5, 0, 1)
}

Animations = {
	Sit = {Animation = Tool:WaitForChild("Sit"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Sit = {Animation = Tool:WaitForChild("R15Sit"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Grips = {
	Normal = CFrame.new(-1.5, 0, 0, 0, 0, -1, -1, 8.90154915e-005, 0, 8.90154915e-005, 1, 0),
	Flying = CFrame.new(-1.5, 0.5, -0.75, -1, 0, -8.99756625e-009, -8.99756625e-009, 8.10000031e-008, 1, 7.28802977e-016, 0.99999994, -8.10000103e-008)
}

Flying = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Grip = Grips.Normal
Tool.Enabled = true

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
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

function Weld(Parent, PrimaryPart)
	local Parts = {}
	local Welds = {}
	local function WeldModel(Parent, PrimaryPart)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				if v ~= PrimaryPart then
					local Weld = Instance.new("Weld")
					Weld.Name = "Weld"
					Weld.Part0 = PrimaryPart
					Weld.Part1 = v
					Weld.C0 = PrimaryPart.CFrame:inverse()
					Weld.C1 = v.CFrame:inverse()
					Weld.Parent = PrimaryPart
					table.insert(Welds, Weld)
				end
				table.insert(Parts, v)
			end
			WeldModel(v, PrimaryPart)
		end
	end
	WeldModel(Parent, PrimaryPart)
	return Parts, Welds
end

function CleanUp()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
end

function CreateRainbow(Length)
	local RainbowModel = Instance.new("Model")
	RainbowModel.Name = "GoldParts"
	for i, v in pairs(RainbowColors) do
		local Part = ColorPart:Clone()
		Part.Name = "Part"
		Part.Size = Vector3.new(0.5, 0.5, Length)
		Part.CFrame = Part.CFrame * CFrame.new((Part.Size.X * (i - 1)), 0, 0)
		Part.BrickColor = BrickColor.new("Gold")
		Part.Mesh.Scale = (Part.Size * 2)
		Part.Mesh.VertexColor = Vector3.new(239/255, 184/255, 56/255)
		Part.Light.Color = Color3.new(v.X, v.Y, v.Z)
		Part.Parent = RainbowModel
	end
	local RainbowBoundingBox = BasePart:Clone()
	RainbowBoundingBox.Name = "BoundingBox"
	RainbowBoundingBox.Transparency = 1
	RainbowBoundingBox.Size = RainbowModel:GetModelSize()
	RainbowBoundingBox.Anchored = true
	RainbowBoundingBox.CanCollide = false
	RainbowBoundingBox.CFrame = RainbowModel:GetModelCFrame()
	RainbowBoundingBox.Parent = RainbowModel
	return RainbowModel
end

function GetRainbowModel()
	local ModelName = (Player.Name .. "'s Golden")
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

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Flying = not Flying
	if Flying then
		Handle.Transparency = 1
		CleanUp()
		local CarpetParts = {}
		for i, v in pairs(CarpetPieces) do
			local CarpetPart = BasePart:Clone()
			CarpetPart.Size = Vector3.new(CarpetSize.X, CarpetSize.Y, (CarpetSize.Z / #CarpetPieces))
			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = Enum.MeshType.FileMesh
			Mesh.MeshId = (BaseUrl .. v.MeshId)
			Mesh.TextureId = (BaseUrl .. "1014108463")
			Mesh.Scale = Vector3.new(1.125, 1.125, 1.125)
			Mesh.VertexColor = Vector3.new(1, 1, 1)
			Mesh.Offset = Vector3.new(0, 0, 0)
			Mesh.Parent = CarpetPart
			local Weld = Instance.new("Weld")
			Weld.Part0 = Handle
			Weld.Part1 = CarpetPart
			local XOffset = (((i == 1 or i == #CarpetPieces) and -0.005) or 0)
			local YOffset = ((-((Handle.Size.Z / 2) - (CarpetPart.Size.Z / 2))) + ((CarpetPart.Size.Z * (i - 1))) + ((i == 2 and 0.245) or (i == 3 and 0.04) or (i == #CarpetPieces and 0.28) or 0))
			Weld.C1 = CFrame.new(0, XOffset, YOffset)
			Weld.Parent = CarpetPart
			table.insert(CarpetParts, {Part = CarpetPart, Weld = Weld, InitialCFrame = Weld.C0, Angle = v.Angle})
			CarpetPart.Parent = Tool
		end	
		
		local Animation = Animations.Sit
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Sit
		end	
		
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
			Tool.Grip = Grips.Flying
		end)
		
		FlightSpin = Instance.new("BodyGyro")
		FlightSpin.Name = "FlightSpin"
		FlightSpin.P = 1000000
		FlightSpin.maxTorque = Vector3.new(FlightSpin.P, FlightSpin.P, FlightSpin.P)
		FlightSpin.cframe = Torso.CFrame
		
		FlightPower = Instance.new("BodyVelocity")
		FlightPower.Name = "FlightPower"
		FlightPower.velocity = Vector3.new(0, 0, 0)
		FlightPower.P = 1000000
		FlightPower.maxForce = Vector3.new(FlightPower.P, FlightPower.P, FlightPower.P)
		FlightPower.P = 10000
		
		FlightHold = Instance.new("BodyPosition")
		FlightHold.Name = "FlightHold"
		FlightHold.P = 100000
		FlightHold.maxForce = Vector3.new(0, 0, 0)
		FlightHold.position = Torso.Position
		
		FlightSpin.Parent = Torso
		FlightPower.Parent = Torso
		FlightHold.Parent = Torso
		
		Spawn(function()
			local LastPlace = nil
			while Flying and ToolEquipped and CheckIfAlive() do
				
				local CurrentPlace = Handle.Position
				local Velocity = Torso.Velocity
				Velocity = Vector3.new(Velocity.X, 0, Velocity.Z).magnitude
				
				if LastPlace and Velocity > 10 then
					
					Spawn(function()
						local Model = GetRainbowModel()
						local Distance = (LastPlace - CurrentPlace).magnitude
						local Length = Distance + 3.5
						
						local RainbowModel = CreateRainbow(Length)
						
						--Thanks so much to ArceusInator for helping solve this part!
						local RainbowCFrame = CFrame.new((LastPlace + (CurrentPlace - LastPlace).unit * (Distance / 2)), CurrentPlace)
						
						TransformModel(RainbowModel, RainbowModel:GetModelCFrame(), RainbowCFrame, true)
						Debris:AddItem(RainbowModel, 1)
						RainbowModel.Parent = Model
						
						if Model and not Model.Parent then
							Model.Parent = game:GetService("Workspace")
						end
						
						LastPlace = CurrentPlace
					end)
				elseif not LastPlace then
					LastPlace = CurrentPlace
				end
				
				wait(Rate)
			end
		end)
	elseif not Flying then
		Torso.Velocity = Vector3.new(0, 0, 0)
		Torso.RotVelocity = Vector3.new(0, 0, 0)
		
		for i, v in pairs({FlightSpin, FlightPower, FlightHold}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		Spawn(function()
			Tool.Grip = Grips.Normal
			local Animation = Animations.Sit
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				Animation = Animations.R15Sit
			end
			InvokeClient("StopAnimation", Animation)
		end)
	end
	
	wait(2)
	
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Normal
	ToolEquipped = true
end

function Unequipped()
	Flying = false
	for i, v in pairs({FlightSpin, FlightPower, FlightHold}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	CleanUp()
	Handle.Transparency = 0
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

CleanUp()

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)