--Made by Luckymaxer

Briefcase = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "rbxassetid://"

Random = math.random
V3 = Vector3.new
CF = CFrame.new
An = CFrame.Angles

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = V3(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Lid = Briefcase:WaitForChild("Lid")
Bottom = Briefcase:WaitForChild("Bottom")
Hinge = Bottom:WaitForChild("Hinge")

Creator = Briefcase:WaitForChild("Creator")

BaseDocument = BasePart:Clone()
BaseDocument.Name = "Document"
BaseDocument.BrickColor = BrickColor.new("Institutional white")
BaseDocument.Material = Enum.Material.SmoothPlastic
BaseDocument.Transparency = 1
BaseDocument.Size = V3(1.25, 0.2, 1.25)
BaseDocument.CanCollide = false
Create("BlockMesh"){
	Name = "Mesh",
	Scale = V3(1, 0, 1.5),
	VertexColor = V3(1, 1, 1),
	Offset = V3(0, 0, 0),
	Parent = BaseDocument,
}
Create("Decal"){
	Name = "Front",
	Face = Enum.NormalId.Top,
	Texture = "",
	Transparency = 0,
	Parent = BaseDocument,
}
Create("Decal"){
	Name = "Back",
	Face = Enum.NormalId.Bottom,
	Texture = (BaseUrl .. "252883294"),
	Transparency = 0,
	Parent = BaseDocument,
}

Documents = {1317926679, 1317927082, 1317927346, 1317927608}

OpenDelay = {Delay = 0.5, Now = tick(), Auto = 2}
Opened = false

function GetCreator()
	local Player = (((Creator and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
	local Character = (((Player and Player.Character) and Player.Character) or nil)
	return Player, Character
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function DocumentTouched(Document, DocumentImage)
	local DocumentImage = (DocumentImage or "")
	local HitAlready = {}
	Document.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		local CreatorPlayer, CreatorCharacter = GetCreator()
		if not player or (player and CreatorPlayer and player == CreatorPlayer) and not CheckTableForInstance(HitAlready, player) then
			return
		end
		table.insert(HitAlready, player)
		local PlayerGui = player:FindFirstChild("PlayerGui")
		if not PlayerGui then
			return
		end
		local DocumentGui = Create("ScreenGui"){
			Name = "DocumentGui",
			Create("ImageLabel"){
				Name = "Document",
				Image = DocumentImage,
				BackgroundColor3 = Color3.new((255 / 255), (255 / 255), (255 / 255)),
				Size = UDim2.new(0, 350, 0, 400),
				Position = UDim2.new((Random(125, 750) * 0.001), 0, (Random(-250, 250) * 0.001), 0),
				Rotation = Random(0, 360),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				ImageTransparency = 0.1,
				ZIndex = 1,
			}
		}
		Debris:AddItem(DocumentGui, (Random((5 * 1000), (15 * 1000)) * 0.001))
		DocumentGui.Parent = PlayerGui
	end)
end

function OpenBriefcase(Hit)
	if Opened then
		return
	end
	Opened = true
	for i = 1, 4 do
		local Document = (BaseUrl .. Documents[Random(1, #Documents)])
		local DocumentPart = BaseDocument:Clone()
		DocumentPart.Front.Texture = Document
		local Weld = Create("Motor6D"){
			Part0 = Bottom,
			Part1 = DocumentPart,
			C0 = (CF((0.05 * (i - 1)), 0, -0.225) * An(((math.pi / 2) + (Random(-(0.05 * 100), (0.05 * 100)) * 0.01)), 0, -(math.pi / 2))),
			C1 = CF(0, 0, 0),
			Parent = DocumentPart
		}
		DocumentPart.Parent = Briefcase
	end
	Hinge.DesiredAngle = (Random(1000, 1750) * 0.001)
	wait(0.25)
	local Direction = V3(0, 1, 0)
	local DocumentCopy = BaseDocument:Clone()
	DocumentCopy.Size = (DocumentCopy.Size * 2)
	DocumentCopy.Mesh.Scale = (DocumentCopy.Mesh.Scale / 2)
	for i = 1, Random(75, 75) do
		local Document = (BaseUrl .. Documents[Random(1, #Documents)])
		local DocumentPart = DocumentCopy:Clone()
		DocumentPart.Front.Texture = Document
		DocumentPart.CFrame = (Bottom.CFrame + Direction * 2)
		local Force = Random(50, 100)
		local Velocity = (Direction * Force)
		Velocity = (Velocity + V3(Random(-25, 25), 0, Random(-25, 25)))
		DocumentPart.Velocity = Velocity
		DocumentPart.RotVelocity = V3((Random(-360, 360) * 0.01), (Random(-360, 360) * 0.01), (Random(-360, 360) * 0.01))
		DocumentPart.CFrame = (DocumentPart.CFrame * CFrame.new((Random(-500, 500) * 0.001), (Random(0, 500) * 0.001), (Random(-500, 500) * 0.001)) * An((Random(-360, 360) * 0.01), (Random(-360, 360) * 0.01), (Random(-360, 360) * 0.01)))
		DocumentTouched(DocumentPart, Document)
		Debris:AddItem(DocumentPart, 3)
		DocumentPart.Parent = game:GetService("Workspace")
	end
end

for i, v in pairs(Briefcase:GetChildren()) do
	if v:IsA("BasePart") then
		if v.Name == "Document" then
			v:Destroy()
		else
			v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent or (tick() - OpenDelay.Now) < OpenDelay.Delay then
					return
				end
				local character = Hit.Parent
				local CreatorPlayer, CreatorCharacter = GetCreator()
				if CreatorCharacter and character == CreatorCharacter then
					return
				end
				OpenBriefcase()
			end)
		end
	end
end

Spawn(function()
	while Bottom.Velocity.Magnitude > 5 do
		wait()
	end
	OpenBriefcase()
end)

wait(OpenDelay.Auto)
OpenBriefcase()