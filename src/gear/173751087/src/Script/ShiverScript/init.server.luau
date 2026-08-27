--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:WaitForChild("Humanoid")
Head = Character:WaitForChild("Head")
Face = Head:FindFirstChild("face")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")
Chat = game:GetService("Chat")

Player = Players:GetPlayerFromCharacter(Character)

AnimateScript = script:WaitForChild("AnimateScript")

Faces = {150182501, 117522793, 66330265, 45515121, 51241537, 34186804, 32723404, 28119051, 29296146, 26619096, 17138027, 18151826, 15395327, 15324577, 7317773}

BaseColor = BrickColor.new("Pastel Blue")
Color = BaseColor.Color

Duration = 10

Classes = {
	BasePart = {
		BrickColor = BaseColor,
		Material = Enum.Material.Plastic,
		Reflectance = 0.5,
	},
	FileMesh = {
		TextureId = "",
	},
	DataModelMesh = {
		VertexColor = Vector3.new(Color.r, Color.g, Color.b),
	},
	CharacterMesh = {
		BaseTextureId = 0,
		OverlayTextureId = 0,
	},
	ShirtGraphic = {
		Graphic = "",
	},
	Shirt = {
		ShirtTemplate = "",
	},
	Clothing = {
		CanRemove = true,
	},
	Pants = {
		PantsTemplate = "",
	},
	FaceInstance = {
		Texture = "",
	},
	Sparkles = {
		SparkleColor = Color,
	},
	Fire = {
		Color = Color,
		SecondaryColor = Color,
	},
	Smoke = {
		Color = Color,
	}
}

Objects = {}
RemovedObjects = {}
FakeParts = {}
Hats = {}

function GetPlayers()
	local PlayersTable = {}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player then
			table.insert(PlayersTable, v.Name)
		end
	end
	return PlayersTable
end

OtherPlayers = GetPlayers()

Messages = { --Messages above dedicated to moded for his brilliant ideas
	"OMG... SOOO COOOOOOLD!!!!!!",
	"IM FREEEZZINGGG!!!",
	"OH GOD, TOO COLD",
	"IT BURNS, IT BURNS, TOO HOT!",
	"Um, I felt nothing at all?",
	"I like turtles",
	"DID I COMPLETE THE CHALLENGE YET?!?!",
	"I NOMINATE YOU TO DO THE ICE BUCKET CHALLENGE",
	"Let's do it for the human race!",
	"I'm saving millions of lives! :D",
	"That was nothing, do it again!",
	"Curse you, Luckymaxer for making this gear!",
	"THIS BUCKET IS WHAT IM GONNA USE AS A FREE HAT",
	"OMG NO WAY.. A FREE HAT!!!",
	"I did it!",
	"This was easy.",
	"Challenge completed.",
	"That was it?",
	"Wasn't cold at all.",
	"YOU'RE NEXT! HAHAHA!!",
	"OMG I'M DYING!!!@$%@!#^&$!",
	"Builderman... WHY!!!!",
	"HOW DID I TURN THIS BUCKET UPSIDE DOWN?",
	"WHAT DID I JUST DO?",
	"IS THIS THE APOCALYPSE?",
	"THE WATER TEMPERATURE WAS LIKE 2*3+7-5+1/3+4",
	"I can finally reach the skies!!",
	((#OtherPlayers > 0 and (OtherPlayers[math.random(1, #OtherPlayers)] .. ", y")) or "Y") .. "ou're next!",
	"I'm MELTING!! SAVE ME!!",
	"Goodbye cruel world!!",
	"I'm going to do this again! :D",
	"ROBLOX.. WHY!!!",
	"Do I win?",
	"New level reached!",
	"SOOO H2O FRESH!!",
	"I guess you could say I'm cool now.",
}

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	Debris:AddItem(AssetModel, 0)
	return Asset
end

function Decorate(Object)
	local ObjectData = {
		Object = nil,
		Properties = {},
	}
	for i, v in pairs(Classes) do
		if Object:IsA(i) then
			if Object:IsA("CharacterMesh") then
				local Mesh = Instance.new("SpecialMesh")
				Mesh.MeshType = Enum.MeshType.FileMesh
				Mesh.MeshId = ("http://www.roblox.com/asset/?id=" .. Object.MeshId)
				for ii, vv in pairs(Character:GetChildren()) do
					if vv:IsA("BasePart") and Object.BodyPart.Name == string.gsub(vv.Name, " ", "") then
						Mesh.Parent = vv
						table.insert(RemovedObjects, {Object = Object, NewObject = Mesh, Parent = Object.Parent})
						Object.Parent = nil
					end
				end
			else
				ObjectData.Object = Object
				for ii, vv in pairs(v) do
					local PropertyValue = nil
					local PropertyValueSet = false
					pcall(function()
						PropertyValue = Object[ii]
						PropertyValueSet = true
						Object[ii] = vv
					end)
					if PropertyValueSet then
						ObjectData.Properties[ii] = PropertyValue
					end
				end
			end
			if v.CanRemove then
				table.insert(RemovedObjects, {Object = Object, Parent = Object.Parent})
				Object.Parent = nil
			end
		end
	end
	table.insert(Objects, ObjectData)
end

function Redesign(Parent)
	for i, v in pairs(Parent:GetChildren()) do
		if not v:IsA("Tool") then
			Decorate(v)
			Redesign(v)
		end
	end
end

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("Hat") then
		table.insert(Hats, v)
		local Handle = v:FindFirstChild("Handle")
		if Handle then
			local HandleClone = Handle:Clone()
			table.insert(FakeParts, HandleClone)
			local HeadWeld = Instance.new("Weld")
			HeadWeld.Name = "HeadWeld"
			HeadWeld.Part0 = Head
			HeadWeld.Part1 = HandleClone
			HeadWeld.C0 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			HeadWeld.C1 = v.AttachmentPoint
			HeadWeld.Parent = HandleClone
			HandleClone.Parent = Character
		end
	end
end

for i, v in pairs({Hats}) do
	for ii, vv in pairs(v) do
		vv.Parent = nil
	end
end

Humanoid.WalkSpeed = 0
Humanoid.AutoRotate = false

if Face then
	OriginalFace = Face.Texture
end

Redesign(Character)

if Face then
	Face.Texture = InsertAsset(Faces[math.random(1, #Faces)]).Texture
end

pcall(function()
	Chat:Chat(Head, Messages[math.random(1, #Messages)], Enum.ChatColor.Blue)
end)

AnimateScriptClone = AnimateScript:Clone()
AnimateScriptClone.Disabled = false
AnimateScriptClone.Parent = Character

wait(Duration)

for i, v in pairs(Objects) do
	for ii, vv in pairs(v.Properties) do
		v.Object[ii] = vv
	end
end
for i, v in pairs(RemovedObjects) do
	if v.NewObject and v.NewObject.Parent then
		v.NewObject:Destroy()
	end
	v.Object.Parent = v.Parent
end
for i, v in pairs(FakeParts) do
	if v and v.Parent then
		v:Destroy()
	end
end
for i, v in pairs(Hats) do
	v.Parent = Character
end

if Face then
	Face.Texture = OriginalFace
end

Humanoid.WalkSpeed = 16
Humanoid.AutoRotate = true

script:Destroy()