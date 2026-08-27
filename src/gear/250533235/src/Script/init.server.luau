--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Remover = script:WaitForChild("Remover")

VehicleModel = InsertService:LoadAsset(248223518)
Vehicle = VehicleModel:GetChildren()[1]:Clone()
if VehicleModel and VehicleModel.Parent then
	VehicleModel:Destroy()
end

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

ToolEquipped = false

Tool.Enabled = true

function SpawnVehicle()
	CurrentVehicle = Vehicle:Clone()
	local VehicleTorso = CurrentVehicle:FindFirstChild("Torso")
	if not VehicleTorso then
		return
	end
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = CurrentVehicle
	local RemoverClone = Remover:Clone()
	local Data = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
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
	VehicleTorso.CFrame = ((Torso.CFrame * CFrame.new(0, 0, -((Torso.Size.Z / 2) + (Vehicle:GetModelSize().Z / 2) + 2))) + Vector3.new(0, 1.5, 0))
	CurrentVehicle.Parent = game:GetService("Workspace")
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
	Debris:AddItem(Tool, 0)
	if Tool and Tool.Parent then
		Tool:Destroy()
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 1
	ToolEquipped = true
	Activated()
end

function Unequipped()
	Handle.Transparency = 0
	ToolEquipped = false
end

--Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)