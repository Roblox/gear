--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset?id="

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

BasePart = Instance.new("Part")
BasePart.Name = "Part"
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true

BaseShoe = BasePart:Clone()
BaseShoe.Name = "Shoe"
BaseShoe.CanCollide = false
ShoeMesh = Instance.new("SpecialMesh")
ShoeMesh.Name = "Mesh"
ShoeMesh.MeshType = Enum.MeshType.FileMesh
ShoeMesh.TextureId = (BaseUrl .. "717278234")
ShoeMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
ShoeMesh.VertexColor = Vector3.new(1, 1, 1)
ShoeMesh.Offset = Vector3.new(0, 0, 0)
ShoeMesh.Parent = BaseShoe

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function CreateShoes(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	Handle.Transparency = ((Create and 1) or 0)
	if not Create then
		return
	end
	local LeftLeg = Character:FindFirstChild("Left Leg")
	local RightLeg = Character:FindFirstChild("Right Leg")
	if LeftLeg then
		LeftShoe = BaseShoe:Clone()
		LeftShoe.Name = "LeftShoe"
		LeftShoe.Mesh.MeshId = (BaseUrl .. "717277734")
		LeftShoeWeld = Instance.new("Weld")
		LeftShoeWeld.Part0 = LeftLeg
		LeftShoeWeld.Part1 = LeftShoe
		LeftShoeWeld.C1 = CFrame.new(0, 0.55, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		LeftShoeWeld.Parent = LeftShoe
		LeftShoe.Parent = Tool
	end
	if RightLeg then
		RightShoe = BaseShoe:Clone()
		RightShoe.Name = "RightShoe"
		RightShoe.Mesh.MeshId = (BaseUrl .. "717277863")
		RightShoeWeld = Instance.new("Weld")
		RightShoeWeld.Part0 = RightLeg
		RightShoeWeld.Part1 = RightShoe
		RightShoeWeld.C1 = CFrame.new(0, 0.55, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		RightShoeWeld.Parent = RightShoe
		RightShoe.Parent = Tool
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		CreateShoes(true)
	end)
	Humanoid.WalkSpeed = (16 * 2)
end

function Unequipped()
	ToolEquipped = false
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	Spawn(function()
		CreateShoes(false)
	end)
end

Delay(0, (function()
	if not ToolEquipped then
		CreateShoes(false)
	end
end))

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)