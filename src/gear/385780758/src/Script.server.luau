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

Sounds = {
	Hop = Handle:WaitForChild("Hop"),
}

Handle.Transparency = 0
Tool.Enabled = true

function CreateBunnyFeet(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if HumanoidJumped then
		HumanoidJumped:disconnect()
	end
	if Create and CheckIfAlive() then
		HumanoidJumped = Humanoid.Jumping:connect(function()
			Sounds.Hop.Pitch = (math.random(2250, 2500) * 0.001)
			Sounds.Hop:Play()
		end)
		local BunnyTail = BasePart:Clone()
		BunnyTail.Name = "Tail"
		BunnyTail.Size = Vector3.new(1, 1, 0.75)
		BunnyTail.CanCollide = false
		local BunnyTailMesh = Instance.new("SpecialMesh")
		BunnyTailMesh.Name = "Mesh"
		BunnyTailMesh.MeshType = Enum.MeshType.FileMesh
		BunnyTailMesh.MeshId = (BaseUrl .. "232544957")
		BunnyTailMesh.TextureId = (BaseUrl .. "385765630")
		BunnyTailMesh.Scale = Vector3.new(1.125, 1.25, 0.875)
		BunnyTailMesh.VertexColor = Vector3.new(1, 1, 1)
		BunnyTailMesh.Offset = Vector3.new(0, 0, 0)
		BunnyTailMesh.Parent = BunnyTail
		local BunnyFoot = BasePart:Clone()
		BunnyFoot.Size = Vector3.new(1.5, 0.75, 2.75)
		BunnyFoot.CanCollide = false
		local BunnyFootMesh = Instance.new("SpecialMesh")
		BunnyFootMesh.Name = "Mesh"
		BunnyFootMesh.MeshType = Enum.MeshType.FileMesh
		BunnyFootMesh.MeshId = ""
		BunnyFootMesh.TextureId = (BaseUrl .. "385765630")
		BunnyFootMesh.Scale = Vector3.new(1.25, 1, 1)
		BunnyFootMesh.VertexColor = Vector3.new(1, 1, 1)
		BunnyFootMesh.Offset = Vector3.new(0, 0, 0)
		BunnyFootMesh.Parent = BunnyFoot
		LeftFoot = BunnyFoot:Clone()
		LeftFoot.Name = "LeftFoot"
		LeftFoot.Mesh.MeshId = (BaseUrl .. "232545016")
		RightFoot = BunnyFoot:Clone()
		RightFoot.Name = "RightFoot"
		RightFoot.Mesh.MeshId = (BaseUrl .. "232544931")
		local TorsoWeld = Instance.new("Motor6D")
		TorsoWeld.Part0 = Torso
		TorsoWeld.Part1 = BunnyTail
		TorsoWeld.C0 = CFrame.new(1.5, 0.5, -1.5, 1, 0, -0, 0, 0, 1, 0, -1, -0) * CFrame.Angles((math.pi / 2), 0, 0)
		TorsoWeld.C1 = Tool.Grip
		TorsoWeld.Parent = BunnyTail
		BunnyTail.Parent = Tool
		local LeftLeg = Character:FindFirstChild("Left Leg") or Character:FindFirstChild("LeftFoot")
		local RightLeg = Character:FindFirstChild("Right Leg") or Character:FindFirstChild("RightFoot")
		for i, v in pairs({LeftLeg, RightLeg}) do
			if v then
				local Foot = ((v == LeftLeg and LeftFoot) or RightFoot)
				local Weld = Instance.new("Weld")
				Weld.Part0 = v
				Weld.Part1 = Foot
				Weld.C0 = CFrame.new((0.2 * ((v == RightLeg and 1) or -1)), (Humanoid.RigType == Enum.HumanoidRigType.R6 and -0.78) or 0, -0.6)
				Weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				Weld.Parent = Foot
				Foot.Parent = Tool
			end
		end
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateBunnyFeet(true)
		Humanoid.WalkSpeed = (16 * 1.75)
		Humanoid.JumpPower = 85
	end)
	Handle.Transparency = 1
	ToolEquipped = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50
	end
	CreateBunnyFeet(false)
	Handle.Transparency = 0
	ToolEquipped = false
end

CreateBunnyFeet(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)