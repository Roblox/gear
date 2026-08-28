--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Remover = script:WaitForChild("Remover")

VehicleModel = InsertService:LoadAsset(248210662)
Vehicle = VehicleModel:GetChildren()[1]:Clone()
if VehicleModel and VehicleModel.Parent then
	VehicleModel:Destroy()
end

ReloadTime = 15

RemoteControl = Tool:WaitForChild("RemoteControl")

ServerControl = (RemoteControl:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = RemoteControl

ClientControl = (RemoteControl:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = RemoteControl

ToolEquipped = false

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function TransformModel(Objects, Center, NewCFrame, Recurse)
	local Objects = ((type(Objects) ~= "table" and {Objects}) or Objects)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			v.CFrame = NewCFrame:toWorldSpace(Center:toObjectSpace(v.CFrame))
		end
		if Recurse then
			TransformModel(v:GetChildren(), Center, NewCFrame, true)
		end
	end
end

function GetAllObjects(Parent, Classes)
	local Objects = {}
	local function GetObjects(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			for ii, vv in pairs(Classes) do
				if v:IsA(vv) then
					table.insert(Objects, v)
					break
				end
			end
			GetObjects(v)
		end
	end
	GetObjects(Parent)
	return Objects
end

function SpawnVehicle()
	
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		local CurrentlyDriving = PlayerGui:FindFirstChild("CurrentlyDriving")
		if CurrentlyDriving then
			return
		end
	end
	
	if CurrentVehicle and CurrentVehicle.Parent then
		CurrentVehicle:Destroy()
	end
	
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		Tool.Enabled = true
		return
	end
	MousePosition = MousePosition.Position
	
	local VehicleSize = Vehicle:GetModelSize()	
	
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	local VehicleCFrame = Direction + Direction.lookVector * (((Torso.Size.Z / 2) + (VehicleSize.Z / 2)) * 1.5)
	local VehicleAngle = CFrame.Angles(0, 0, 0)
	
	local PosX, PosY, PosZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = VehicleCFrame:components()	
	VehicleCFrame = CFrame.new(PosX, Torso.Position.Y, PosZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
	
	CurrentVehicle = Vehicle:Clone()
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = CurrentVehicle
	local Parts = GetAllObjects(CurrentVehicle, {"BasePart"})
	for i, v in pairs(Parts) do
		v.Anchored = true
	end
	local RemoverClone = Remover:Clone()
	local Data = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
		{Name = "Model", Class = "ObjectValue", Value = CurrentVehicle},
	}
	for i, v in pairs(Data) do
		local Object = Instance.new(v.Class)
		Object.Name = v.Name
		Object.Value = v.Value
		Object.Parent = RemoverClone
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = CurrentVehicle
	Debris:AddItem(Vehicle, (15 * 60))
	CurrentVehicle.Parent = game:GetService("Workspace")
	CurrentVehicle:MakeJoints()
	TransformModel(CurrentVehicle, CurrentVehicle:GetModelCFrame(), VehicleCFrame, true)
	for i, v in pairs(Parts) do
		v.Velocity = Vector3.new(0, 0, 0)
		v.RotVelocity = Vector3.new(0, 0, 0)
		v.Anchored = false
	end
	
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	SpawnVehicle()
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent then
		if not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) then
			if CurrentVehicle and CurrentVehicle.Parent then
				CurrentVehicle:Destroy()
			end
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)