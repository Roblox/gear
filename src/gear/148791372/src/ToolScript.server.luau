--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
}

PieScript = Tool:WaitForChild("PieScript")

Pies = {
	{MeshId = 18417911, TextureId = 18417918, Name = "ApplePie", Scale = Vector3.new(0.35, 0.35, 0.35), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles((math.pi / 2.5), 0, 0), Offset = Vector3.new(0, 0.825, 0), FiringAngle = CFrame.Angles(0, 0, 0), RotateFace = false, Damage = 5, Percentage = 90},
	{MeshId = 40312463, TextureId = 40311968, Name = "CherryPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(-(math.pi / 1.5), 0, 0), Offset = Vector3.new(0, 0.8, 0), FiringAngle = CFrame.Angles(0, 0, 0), RotateFace = true, Damage = 6, Percentage = 75},
	{MeshId = 40312463, TextureId = 40311869, Name = "BlueberryPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(-(math.pi / 1.5), 0, 0), Offset = Vector3.new(0, 0.8, 0), FiringAngle = CFrame.Angles(0, 0, 0), RotateFace = true, Damage = 6, Percentage = 75},
	{MeshId = 143518445, TextureId = 143499030, Name = "CherryPie", Scale = Vector3.new(0.5, 0.35, 0.5), Size = Vector3.new(1, 0.25, 1), Angle = CFrame.Angles(-(math.pi / 8), (math.pi / 2), 0), Offset = Vector3.new(-0.05, 0.85, 0), FiringAngle = CFrame.Angles((math.pi / 2), 0, (math.pi / 1)), RotateFace = false, Damage = 7, Percentage = 65},
	{MeshId = 65950268, TextureId = 65950352, Name = "PumpkinPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(-(math.pi / 1.6), 0, 0), Offset = Vector3.new(-0.05, 0.8, 0), FiringAngle = CFrame.Angles(0, 0, 0), RotateFace = true, Damage = 8, Percentage = 50},
	{MeshId = 18453224, TextureId = 18453205, Name = "PumpkinPi", Scale = Vector3.new(0.35, 0.35, 0.35), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles((math.pi / 2.5), 0, 0), Offset = Vector3.new(0, 0.8, 0), FiringAngle = CFrame.Angles(0, 0, 0), RotateFace = false, Damage = 10, Percentage = 35},
	{MeshId = 148484293, TextureId = 148484299, Name = "PiSymbol", Scale = Vector3.new(1, 1, 1), Size = Vector3.new(0.25, 0.65, 0.75), Angle = CFrame.Angles(0, (math.pi / 2), 0), Offset = Vector3.new(0, 1, 0), FiringAngle = CFrame.Angles(0, (math.pi / 2), 0), RotateFace = false, Damage = 35, Percentage = 15},
	{MeshId = 125732887, TextureId = 125728597, Name = "PizzaPie", Scale = Vector3.new(0.6, 0.6, 0.6), Size = Vector3.new(1, 0.25, 1), Angle = CFrame.Angles(-(math.pi / 20), 0, 0), Offset = Vector3.new(-0.05, 0.75, -0.05), FiringAngle = CFrame.new(0, 0, 0), RotateFace = false, Damage = 6, Percentage = 25}
}

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Anchored = false
BasePart.CanCollide = true
BasePart.Locked = true

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function RandomByPercent(Table)
	local Max = 0
	for i, v in pairs(Table) do
		Max = (Max + v.Percentage)
	end
	local Chosen = (math.random() * Max)
	local Last
	local Total = 0
	for i, v in pairs(Table) do
		Total = (Total + v.Percentage)
		Last = v
		if Total >= Chosen then
			break
		end
	end
	return Last, Chosen
end

function CreatePie()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	ChosenPie = RandomByPercent(Pies)
	Pie = BasePart:Clone()
	Pie.Name = ChosenPie.Name
	Pie.Size = ChosenPie.Size
	local PieMesh = Instance.new("SpecialMesh")
	PieMesh.MeshType = Enum.MeshType.FileMesh
	PieMesh.MeshId = BaseUrl .. ChosenPie.MeshId
	PieMesh.TextureId = BaseUrl .. ChosenPie.TextureId
	PieMesh.Scale = ChosenPie.Scale
	PieMesh.Parent = Pie
	Pie.Parent = Tool
	Pie.CFrame = Handle.CFrame 
	Pie.CFrame = CFrame.new(Handle.Position, Handle.CFrame.lookVector)
	PieWeld = Instance.new("Motor6D")
	PieWeld.Part0 = Handle
	PieWeld.Part1 = Pie
	PieWeld.C0 = (PieWeld.C0 * ChosenPie.Angle + ChosenPie.Offset)
	PieWeld.Parent = Pie
end

function Fire(v)
	if not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	if not Pie or not Pie.Parent or not PieWeld or not PieWeld.Parent then
		CreatePie()
	else
		
		local LocalPie = Pie
		local LocalChosenPie = ChosenPie
		Pie = nil		
		Sounds.Fire:Play()
		
		local Force = Instance.new("BodyForce")
		Force.force = Vector3.new(0, 24 ,0)
		Force.Parent = LocalPie
			
		local Gyro = Instance.new("BodyGyro")
		Gyro.D = 500
		Gyro.maxTorque = Vector3.new(0, 0, 0)
		Gyro.P = 3000
		Gyro.Parent = LocalPie
		
		local HitSound = Sounds.Hit:Clone()
		HitSound.Parent = LocalPie
		
		local Creator = Instance.new("ObjectValue")
		Creator.Value = Player
		Creator.Name = "creator"
		Creator.Parent = LocalPie
		
		local Damage_Tag = Instance.new("NumberValue")
		Damage_Tag.Value = (LocalChosenPie.Damage * 2)
		Damage_Tag.Name = "Damage"
		Damage_Tag.Parent = LocalPie
		
		local PieScriptClone = PieScript:Clone()
		PieScriptClone.Disabled = false
		PieScriptClone.Parent = LocalPie
		
		if PieWeld and PieWeld.Parent then
			PieWeld:Destroy()
		end
		
		local Launch = (Handle.Position + 5 * v)
		LocalPie.CFrame = CFrame.new(Launch + ((LocalChosenPie.RotateFace and v) or Vector3.new(0, 0, 0)), Launch + ((not LocalChosenPie.RotateFace and v) or Vector3.new(0, 0, 0)))
		LocalPie.CFrame = LocalPie.CFrame * LocalChosenPie.FiringAngle
		LocalPie.Velocity = v * 100
		Debris:AddItem(LocalPie, 10)
		LocalPie.Parent = game:GetService("Workspace")
		
	end
	wait(0.25)
	Tool.Enabled = true
end

function Activated()
	if not CheckIfAlive() or not Tool.Enabled then
		return
	end
	local MousePosition = InvokeClient("MousePosition").Position
	local TargetPos = MousePosition
	local LookAt = (TargetPos - Handle.Position).unit
	Fire(LookAt)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

CreatePie()

Tool.Equipped:connect(Equipped)
Tool.Activated:connect(Activated)
Tool.Unequipped:connect(Unequipped)