--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

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

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

function GetAllObjectsByClassName(Parent, Classes)
	local Objects = {}
	function GetObjectsByClassName(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			for ii, vv in pairs(Classes) do
				if v:IsA(vv) then
					table.insert(Objects, v)
					break
				end
			end
			GetObjectsByClassName(v, Classes)
		end
	end
	GetObjectsByClassName(Parent)
	return Objects
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function Transform8Bitize(Part)
	
	local EightBit = BasePart:Clone()
	EightBit.Name = "Effect"
	EightBit.Transparency = Part.Transparency
	EightBit.Reflectance = Part.Reflectance
	EightBit.Friction = 0.3
	EightBit.Elasticity = 0.5
	EightBit.Size = Vector3.new(0.5, 0.5, 0.5)
	
	local TotalX = Clamp(math.floor(Part.Size.X / EightBit.Size.X), 0, 5)
	local TotalY = Clamp(math.floor(Part.Size.Y / EightBit.Size.Y), 0, 5)
	local TotalZ = Clamp(math.floor(Part.Size.Z / EightBit.Size.Z), 0, 5)
	
	local Left = (-(Part.Size.X / 2) + (EightBit.Size.X / 2))
	local Top = ((Part.Size.Y / 2) - (EightBit.Size.Y / 2))
	local Back = (-(Part.Size.Z / 2) + (EightBit.Size.Z / 2))
	
	local EightBitModel = Create("Model"){
		Name = "EightBitModel",
	}
	
	for X = 1, TotalX do
		for Y = 1, TotalY do
			for Z = 1, TotalZ do
				local XPos = (((Part.Size.X - (EightBit.Size.X * TotalX)) / 2) + (Left + (EightBit.Size.X * (X - 1))))
				local YPos = (((Part.Size.Y - (EightBit.Size.Y * TotalY)) / 2) - (Top - (EightBit.Size.Y * (Y - 1))))
				local ZPos = (((Part.Size.Z - (EightBit.Size.Z * TotalZ)) / 2) + (Back + (EightBit.Size.Z * (Z - 1))))
				local Piece = EightBit:Clone()
				Piece.BrickColor = Part.BrickColor
				Piece.CFrame = (Part.CFrame * CFrame.new(XPos, YPos, ZPos))
	
				Create("SpecialMesh"){
					Name = "Mesh",
					MeshType = Enum.MeshType.Brick,
					Offset = Vector3.new(0, 0, 0),
					VertexColor = Vector3.new(1, 1, 1),
					Parent = Piece
				}
				local Surfaces = {
					{Surface = "Top", Shading = 20},
					{Surface = "Bottom", Shading = 40},
					{Surface = "Left", Shading = 60},
					{Surface = "Right", Shading = 80},
					{Surface = "Front", Shading = 100},
					{Surface = "Back", Shading = 120},
				}
				local Color = Piece.BrickColor.Color
				local r = Color.r
				local g = Color.g
				local b = Color.b
				for i, v in pairs(Surfaces) do
					local Shading = (v.Shading / 255)
					local FrameColor = Color3.new((r + Shading), (g + Shading), (b + Shading))
					local SurfaceImage = Create("SurfaceGui"){
						Adornee = Piece,
						CanvasSize = Vector2.new(800, 600),
						Face = Enum.NormalId[v.Surface],
						Active = false,
						Enabled = true,
						Create("Frame"){
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 1, 0),
							BorderSizePixel = 2,
							BackgroundColor3 = FrameColor,
							BorderColor3 = FrameColor,
							ZIndex = 1,
						},
					}
					SurfaceImage.Parent = Piece
				end
				Piece.Parent = EightBitModel
			end
		end
	end
	Debris:AddItem(EightBitModel, 10)
	EightBitModel.Parent = game:GetService("Workspace")
end

if not Humanoid then
	DestroyScript()
	return
end

Limbs = {}

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		if v.Transparency < 1 then
			table.insert(Limbs, v:Clone())
		end
	end
	if v:IsA("BasePart") or v:IsA("Hat") or v:IsA("Tool") then
		v:Destroy()
	end
end

for i, v in pairs(Limbs) do
	Transform8Bitize(v)
end