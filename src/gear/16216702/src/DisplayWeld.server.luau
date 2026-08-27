--Fix implemented by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

function CreateEffectPart()
	local EffectPart = Tool:FindFirstChild("BoltDisplay")
	if EffectPart then
		EffectPart:Destroy()
	end
	EffectPart = BasePart:Clone()
	EffectPart.Name = "BoltDisplay"
	EffectPart.Transparency = 0
	EffectPart.Size = Vector3.new(1, 0.4, 2)
	EffectPart.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "http://www.roblox.com/asset/?id=15887356"
	Mesh.TextureId = "http://www.roblox.com/asset/?id=15886781"
	Mesh.Scale = Vector3.new(1, 1, 1)
	Mesh.VertexColor = Vector3.new(1, 1, 1)
	Mesh.Offset = Vector3.new(0, 0, 0)
	Mesh.Parent = EffectPart
	local Weld = Instance.new("Weld")
	Weld.Part0 = Handle
	Weld.Part1 = EffectPart
	Weld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.C1 = CFrame.new(0, -0.35, -1.6, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.Parent = EffectPart
	EffectPart.Parent = Tool
end

function Equipped()
	Spawn(CreateEffectPart)
end

function Unequipped()
	Spawn(CreateEffectPart)
end

Spawn(CreateEffectPart)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)