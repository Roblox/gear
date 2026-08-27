--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Remover = script:WaitForChild("Remover")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Grips = {
	Thumbnail = CFrame.new(1.5, 4.75, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(-2.5, 1.25, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

PolarBearModel = InsertService:LoadAsset(419528946)
PolarBear = PolarBearModel:GetChildren()[1]:Clone()
Debris:AddItem(PolarBearModel, 1)

ToolEquipped = false

Handle.Transparency = 0
Tool.Grip = Grips.Equipped
Tool.Enabled = true

function SpawnVehicle()
	CurrentVehicle = PolarBear:Clone()
	local VehicleTorso = CurrentVehicle:FindFirstChild("Body")
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
	local TorsoCF = (((Torso.CFrame * CFrame.new(0, (-(Torso.Size.Y / 2) + (CurrentVehicle:GetModelSize().Y / 2)), -((Torso.Size.Z / 2) + (CurrentVehicle:GetModelSize().Z / 2) + 4))) + Vector3.new(0, 0, 0)) * CFrame.Angles(-(math.pi / 2), 0, 0))
	VehicleTorso.CFrame = TorsoCF
	CurrentVehicle.Parent = game:GetService("Workspace")
	VehicleTorso.CFrame = TorsoCF
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
	Torso = Character:FindFirstChild("Torso")
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