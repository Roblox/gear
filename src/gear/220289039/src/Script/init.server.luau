--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

EggScript = script:WaitForChild("EggScript"):Clone()

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	SlingRelease = Handle:WaitForChild("SlingRelease"),
}

MeshData = {
	GunWithSling = "223833506",
	Gun = "223833668",
	Sling = "223833582",
	Egg = "225334624",
	TextureId = "223833747",
}

Duration = 0.75
ReloadTime = 4

for i, v in pairs(MeshData) do
	MeshData[i] = (BaseUrl .. v)
end

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Egg = BasePart:Clone()
Egg.Name = "Egg"
Egg.BrickColor = BrickColor.new("Institutional white")
Egg.Size = Vector3.new(0.5, 0.6, 0.5)
EggMesh = Instance.new("SpecialMesh")
EggMesh.Name = "Mesh"
EggMesh.MeshType = Enum.MeshType.FileMesh
EggMesh.MeshId = MeshData.Egg
EggMesh.TextureId = ""
EggMesh.Scale = Vector3.new(0.55, 0.55, 0.55)
EggMesh.VertexColor = Vector3.new(1, 1, 1)
EggMesh.Offset = Vector3.new(0, 0, 0)
EggMesh.Parent = Egg

Sling = BasePart:Clone()
Sling.Name = "Sling"
Sling.Size = Vector3.new(0.5, 0.75, 2.75)
Sling.CanCollide = false
SlingMesh = Instance.new("SpecialMesh")
SlingMesh.Name = "Mesh"
SlingMesh.MeshType = Enum.MeshType.FileMesh
SlingMesh.MeshId = MeshData.Sling
SlingMesh.TextureId = MeshData.TextureId
SlingMesh.Scale = Vector3.new(0.65, 0.65, 0.65)
SlingMesh.VertexColor = Vector3.new(1, 1, 1)
SlingMesh.Offset = Vector3.new(0, 0, 0)
SlingMesh.Parent = Sling

Rate = (1 / 60)
Gravity = 196.20

EggReady = true
ToolEquipped = false

RemoteFunctions = Tool:WaitForChild("RemoteFunctions")

ServerControl = (RemoteFunctions:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = RemoteFunctions

ClientControl = (RemoteFunctions:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = RemoteFunctions

Mesh.MeshId = MeshData.GunWithSling
Handle.Transparency = 0
Tool.Enabled = true

function CreateEgg()
	if not ToolEquipped or not SlingClone or not SlingClone.Parent then
		return
	end
	if EggClone and EggClone.Parent then
		EggClone:Destroy()
	end
	EggClone = Egg:Clone()
	local EggWeld = Instance.new("Weld")
	EggWeld.Part0 = SlingClone
	EggWeld.Part1 = EggClone
	EggWeld.C0 = CFrame.new(0, 0.15, 0.8)
	EggWeld.Parent = EggClone
	EggClone.Parent = Tool
end

function ManageSling(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if Create then
		Mesh.MeshId = MeshData.Gun
		SlingClone = Sling:Clone()
		SlingMotor = Instance.new("Motor6D")
		SlingMotor.MaxVelocity = 0.25
		SlingMotor.Part0 = Handle
		SlingMotor.Part1 = SlingClone
		SlingMotor.C0 = CFrame.new(0.0785072446, 0.188826829, -1.54037094, -4.37113883e-008, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-008)
		SlingMotor.C1 = CFrame.new(0.078507781, -0.286166668, -1.31539106, -1.34110451e-007, -4.65661287e-010, -0.999999046, -1.39698386e-008, 0.999999404, -2.32830644e-010, 1.00000083, -1.95577741e-008, 7.4505806e-008)
		SlingMotor.Parent = SlingClone
		SlingClone.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped or not EggReady then
		return
	end
	if not SlingClone or not SlingClone.Parent or not SlingMotor or not SlingMotor.Parent then
		return
	end
	Tool.Enabled = false
	EggReady = false
	Sounds.SlingRelease.Pitch = (math.random(900, 1200) * 0.001)
	Sounds.SlingRelease:Play()
	SlingMotor.DesiredAngle = (math.random(500, 750) * 0.001)
	if EggClone and EggClone.Parent then
		Spawn(function()
			local MousePosition = InvokeClient("MousePosition").Position
			local EggCFrame = EggClone.CFrame
			local Direction = CFrame.new(EggCFrame.p, MousePosition)
			EggClone:Destroy()
			local LaunchedEgg = Egg:Clone()
			LaunchedEgg.CFrame = EggCFrame
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			BodyGyro.cframe = Direction
			BodyGyro.Parent = LaunchedEgg
			local EggScriptClone = EggScript:Clone()
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "Creator"
			Creator.Value = Player
			Creator.Parent = EggScriptClone
			EggScriptClone.Disabled = false
			EggScriptClone.Parent = LaunchedEgg
			
			local Velocity = (Direction.lookVector * 200)
			LaunchedEgg.Velocity = Velocity	
			
			Debris:AddItem(LaunchedEgg, 5)
			LaunchedEgg.Parent = game:GetService("Workspace")
		end)
	end
	Delay(Duration, (function()
		SlingMotor.DesiredAngle = 0
	end))
	wait(ReloadTime)
	CreateEgg()
	wait(Rate)
	EggReady = true
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = nil
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Humanoid") then
			Humanoid = v
			break
		end
	end
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		ManageSling(true)
		if EggReady then
			CreateEgg()
		end
	end)
end

function Unequipped()
	Mesh.MeshId = MeshData.GunWithSling
	ManageSling(false)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

--[[function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke]]

ManageSling(false)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)