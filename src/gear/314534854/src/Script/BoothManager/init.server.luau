--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Part = script.Parent
Mesh = Part:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

Creator = Part:FindFirstChild("Creator")

BaseChair = Instance.new("Seat")
BaseChair.Material = Enum.Material.Plastic
BaseChair.Shape = Enum.PartType.Block
BaseChair.TopSurface = Enum.SurfaceType.Smooth
BaseChair.BottomSurface = Enum.SurfaceType.Smooth
BaseChair.FormFactor = Enum.FormFactor.Custom
BaseChair.Size = Vector3.new(2, 1.65, 2)
BaseChair.Locked = true
BaseChair.CanCollide = true
BaseChair.Anchored = false
BaseChair.Disabled = false
ChairMesh = Instance.new("SpecialMesh")
ChairMesh.Name = "Mesh"
ChairMesh.MeshType = Enum.MeshType.FileMesh
ChairMesh.MeshId = (BaseUrl .. "112335925")
ChairMesh.TextureId = (BaseUrl .. "112335881")
ChairMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
ChairMesh.VertexColor = Vector3.new(1, 1, 1)
ChairMesh.Offset = Vector3.new(0, 0, 0)
ChairMesh.Parent = BaseChair

BaseSize = Part.Size
BaseScale = Mesh.Scale

MaxSize = Vector3.new(6, 3.25, 3)
MaxScale = Vector3.new(5.5, 5.5, 5.5)

Rate = (1 / 60)

Removing = false

for i, v in pairs(Part:GetChildren()) do
	if v:IsA("BasePart") then
		v:Destroy()
	end
end

function DestroyModel()
	if Removing then
		return
	end
	Removing = true
	Debris:AddItem(Part, 0.5)
end

function GetMass(Vector)
	return (Vector.X * Vector.Y * Vector.Z)
end

function Grow()
	local Frames = 10
	local SizeIncrease = (MaxSize / Frames)
	local ScaleIncrease = (MaxScale / Frames)
	for i = 1, Frames do
		local OriginalCFrame = Part.CFrame
		local DesiredSize = (SizeIncrease * i)
		local DesiredScale = (ScaleIncrease * i)
		if GetMass(DesiredSize) > GetMass(BaseSize) then
			Part.Size = DesiredSize
			Mesh.Scale = DesiredScale
		end
		Part.CFrame = (OriginalCFrame + Vector3.new(0, (SizeIncrease.Y / 2), 0))
		wait(Rate)
	end
	local Chairs = {}
	for i = 1, 2 do
		local Chair = BaseChair:Clone()
		local ChairOffset = CFrame.new(((((Part.Size.X / 2) + (Chair.Size.X / 2)) / 3) * ((i == 1 and 1) or -1)), (-(Part.Size.Y / 2) + (Chair.Size.Y / 2)), ((Part.Size.Z / 2) + (Chair.Size.Z / 2)))
		Chair.CFrame = (Part.CFrame * ChairOffset)
		local Weld = Instance.new("Weld")
		Weld.Name = "Weld"
		Weld.Part0 = Part
		Weld.Part1 = Chair
		Weld.C0 = ChairOffset
		Weld.C1 = CFrame.new(0, 0, 0)
		Weld.Parent = Chair
		table.insert(Chairs, Chair)
		Chair.Parent = Part
	end
	if Character and Character.Parent then
		local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
		if Torso then
			local Seat = Chairs[2]
			local SeatWeld = Instance.new("Weld")
			SeatWeld.Name = "SeatWeld"
			SeatWeld.Part0 = Seat
			SeatWeld.Part1 = Torso
			SeatWeld.C0 = CFrame.new(0, (Seat.Size.Y / 2), 0)
			SeatWeld.C1 = CFrame.new(0, -1.5, 0)
			SeatWeld.Parent = Seat
		end
	end
end

if not Creator or not Creator.Value or not Creator.Value.Parent or not Creator.Value:IsA("Player") or not Creator.Value.Character or not Creator.Value.Character.Parent then
	DestroyModel()
	return
end

Player = Creator.Value
Character = Player.Character

Player.Changed:connect(function(Property)
	if not Player.Parent or not Player.Character or not Player.Character.Parent then
		DestroyModel()
	end
end)

Grow()