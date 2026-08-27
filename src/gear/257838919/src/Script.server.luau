--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	if not Tool.Enabled then
		return
	end
end

function EquipShoes(Create)
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not Create then
		return
	end
	local Shoe = BasePart:Clone()
	Shoe.CanCollide = false
	Shoe.Size = Vector3.new(1, 1.75, 1)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.Scale = Vector3.new(1.075, 0.75, 1)
	Mesh.TextureId = (BaseUrl .. "255503085")
	Mesh.Parent = Shoe
	LeftLeg = Character:FindFirstChild("Left Leg")
	RightLeg = Character:FindFirstChild("Right Leg")
	if LeftLeg then
		LeftShoe = Shoe:Clone()
		LeftShoe.Name = "LeftShoe"
		LeftShoe.Mesh.MeshId = (BaseUrl .. "255503237")
		local LeftWeld = Instance.new("Weld")
		LeftWeld.Part0 = LeftLeg
		LeftWeld.Part1 = LeftShoe
		LeftWeld.C0 = CFrame.new(0, -0.13, -0.125)
		LeftWeld.Parent = LeftShoe
		LeftShoe.Parent = Tool
	end
	if RightLeg then
		RightShoe = Shoe:Clone()
		RightShoe.Name = "RightShoe"
		RightShoe.Mesh.MeshId = (BaseUrl .. "255503198")
		local RightWeld = Instance.new("Weld")
		RightWeld.Part0 = RightLeg
		RightWeld.Part1 = RightShoe
		RightWeld.C0 = CFrame.new(0, -0.13, -0.125)
		RightWeld.Parent = RightShoe
		RightShoe.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Humanoid.WalkSpeed = 24
	Handle.Transparency = 1
	Spawn(function()
		EquipShoes(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
	Handle.Transparency = 0
	Spawn(function()
		EquipShoes(false)
	end)
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
end

EquipShoes(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)