--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

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

Grips = {
	Equipped = CFrame.new(0, 0, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Unequipped = CFrame.new(1.5, 3, -1.45, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Sparks = Handle:WaitForChild("Sparks")
Light = Handle:WaitForChild("Light")

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function CreateBoots(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	for i, v in pairs({HumanoidRunning, HumanoidJumped}) do
		if v then
			v:disconnect()
		end
	end
	if Create and CheckIfAlive() then
		HumanoidRunning = Humanoid.Running:connect(function(Speed)
			local Speed = (Torso.Velocity * Vector3.new(1, 0, 1)).Magnitude
			if Speed > 0 then
				wait(0.1)
				for i, v in pairs(BootSparks) do
					v:Emit(math.random(1, 3))
				end
			end
		end)
		HumanoidJumped = Humanoid.FreeFalling:connect(function()
			for i, v in pairs(BootLights) do
				if v.Enabled then --Lights already enabled, prevent overlap
					return
				end
				v.Enabled = true
			end
			wait(0.5)
			for i, v in pairs(BootLights) do
				v.Enabled = false
			end
		end)
		local Boot = BasePart:Clone()
		Boot.Size = Vector3.new(1.5, 0.75, 2.75)
		Boot.CanCollide = false
		local BootMesh = Instance.new("SpecialMesh")
		BootMesh.Name = "Mesh"
		BootMesh.MeshType = Enum.MeshType.FileMesh
		BootMesh.MeshId = ""
		BootMesh.TextureId = Mesh.TextureId
		BootMesh.Scale = Vector3.new(1.05, 1.05, 1.05)
		BootMesh.VertexColor = Vector3.new(1, 1, 1)
		BootMesh.Offset = Vector3.new(0, 0, 0)
		BootMesh.Parent = Boot
		LeftBoot = Boot:Clone()
		LeftBoot.Name = "LeftBoot"
		LeftBoot.Mesh.MeshId = (BaseUrl .. "563018591")
		RightBoot = Boot:Clone()
		RightBoot.Name = "RightBoot"
		RightBoot.Mesh.MeshId = (BaseUrl .. "563018700")
		local LeftLeg = Character:FindFirstChild("Left Leg")
		local RightLeg = Character:FindFirstChild("Right Leg")
		BootSparks = {}
		BootLights = {}
		for i, v in pairs({LeftLeg, RightLeg}) do
			if v then
				local Boot = ((v == LeftLeg and LeftBoot) or RightBoot)
				local NewSpark = Sparks:Clone()
				NewSpark.Parent = Boot
				local NewLight = Light:Clone()
				NewLight.Parent = Boot
				table.insert(BootSparks, NewSpark)
				table.insert(BootLights, NewLight)
				local Weld = Instance.new("Weld")
				Weld.Part0 = v
				Weld.Part1 = Boot
				Weld.C0 = CFrame.new((-0.18 * ((v == RightLeg and 1) or -1)), -0.6, 0)
				Weld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				Weld.Parent = Boot
				Boot.Parent = Tool
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
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	Spawn(function()
		CreateBoots(true)
		Humanoid.WalkSpeed = (16 * 1.375)
		Humanoid.JumpPower = 100
	end)
	Handle.Transparency = 1
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50
	end
	CreateBoots(false)
	Handle.Transparency = 0
	ToolEquipped = false
end

CreateBoots(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)