--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

BaseUrl = "http://www.roblox.com/asset/?id="

MusicModule = require(191816425)

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

Handle.Transparency = 0
Tool.Enabled = true

function CreateDrum(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	for i, v in pairs({HumanoidRunning}) do
		if v then
			v:disconnect()
		end
	end
	Handle.Transparency = ((Create and 1) or 0)
	if not Create or not CheckIfAlive() then
		return
	end
	Drum = BasePart:Clone()
	Drum.Name = "Drum"
	Drum.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.Name = "Mesh"
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = (BaseUrl .. "667562408")
	Mesh.TextureId = (BaseUrl .. "667562852")
	Mesh.Scale = Vector3.new(1, 1, 1)
	Mesh.VertexColor = Vector3.new(1, 1, 1)
	Mesh.Offset = Vector3.new(0, 0, 0)
	Mesh.Parent = Drum
	local Mallets = {
		{
			C0 = CFrame.new(-1.3671819, -1.60984504, 0.7095505, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			C1 = CFrame.new(0.233925104, -0.174999237, -0.174552679, 0.743147671, -2.74938152e-008, 0.669133306, -6.20732692e-008, 1.00000095, -4.65220973e-010, -0.669133186, 1.94452561e-008, 0.743147969),
			MaxAngle = -2,
		},
		{
			C0 = CFrame.new(1.41083694, -1.63484883, 0.767505765, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			C1 = CFrame.new(-0.259847045, -0.200000763, 0.0732370019, 1.00000036, -1.07846052e-008, 0, -1.07241052e-008, 1.00000024, -4.65675609e-010, 0, 1.42108683e-014, 1.00000036),
			MaxAngle = 2,
		}
	}
	local MalletPieces = {}
	local MalletsHit = false
	local function HitDrum()
		if MalletsHit then
			return
		end
		MalletsHit = true
		for i, v in pairs(MalletPieces) do
			v.Motor.DesiredAngle = v.MaxAngle
		end
		wait(0.5)
		for i, v in pairs(MalletPieces) do
			v.Motor.DesiredAngle = 0
		end
		wait(0.5)
		MalletsHit = false
	end
	for i, v in pairs(Mallets) do
		local Mallet = BasePart:Clone()
		Mallet.Name = "Mallet"
		Mallet.CanCollide = false
		local Mesh = Instance.new("SpecialMesh")
		Mesh.Name = "Mesh"
		Mesh.MeshType = Enum.MeshType.FileMesh
		Mesh.MeshId = (BaseUrl .. "667562184")
		Mesh.TextureId = (BaseUrl .. "667562852")
		Mesh.Scale = Vector3.new(1, 1, 1)
		Mesh.VertexColor = Vector3.new(1, 1, 1)
		Mesh.Offset = Vector3.new(0, 0, 0)
		Mesh.Parent = Mallet
		local Motor = Instance.new("Motor6D")
		Motor.Name = "Motor"
		Motor.Part0 = Drum
		Motor.Part1 = Mallet
		Motor.C0 = v.C0
		Motor.C1 = v.C1
		Motor.MaxVelocity = 0.1
		Motor.DesiredAngle = 0
		Motor.CurrentAngle = 0
		Motor.Parent = Mallet
		table.insert(MalletPieces, {Part = Mallet, Motor = Motor, MaxAngle = v.MaxAngle})
		Mallet.Parent = Drum
	end
	local Weld = Instance.new("Weld")
	Weld.Name = "Weld"
	Weld.Part0 = Torso
	Weld.Part1 = Drum
	Weld.C0 = CFrame.new(0, 0.125, 1)
	Weld.C1 = CFrame.new(0, 0, 0)
	Weld.Parent = Drum
	Drum.Parent = Tool
	HumanoidRunning = RunService.Stepped:connect(function(Time, Step)
		if Tool.Enabled then
			return
		end
		local Speed = (Torso.Velocity * Vector3.new(1, 0, 1)).Magnitude
		if Speed >= 5 then
			Spawn(function()
				HitDrum()
			end)
		end
	end)
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() or not MusicData then
		return
	end
	Tool.Enabled = false
	local MusicFunctions = MusicData.GetData({Player = Player, Tool = Tool})
	Music = MusicFunctions.PlayMusic()
	if Drum and Drum.Parent then
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	MusicData = MusicModule.GetTable({Key = "OneManJazzBand", Player = Player, Tool = Tool})	
	Spawn(function()
		CreateDrum(true)
	end)
	Tool.Enabled = true
	Handle.Transparency = 1
	ToolEquipped = true
end

function Unequipped()
	if Music then
		Music:Stop()
	end
	Tool.Enabled = true
	CreateDrum(false)
	Handle.Transparency = 0
	ToolEquipped = false
end

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CreateDrum(false)
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)