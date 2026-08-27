Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Remover = script:WaitForChild("Remover")

Module = require(191816425)

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function SpawnVehicle()
	if not Mount then
		return
	end
	CurrentVehicle = Mount:Clone()
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
	CurrentVehicle.Parent = game:GetService("Workspace")
	VehicleTorso.CFrame = ((Torso.CFrame * CFrame.new(0, 0, -((Torso.Size.Z / 2) + (CurrentVehicle:GetModelSize().Z / 2) + 2))) + Vector3.new(0, 1.5, 0))
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
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	ModuleData = Module.GetTable({Key = "GiantBird", Player = Player})
	if not ModuleData then
		return
	end
	ModuleFunctions = ModuleData.GetData({Player = Player, Tool = Tool, Character = Character})
	if not ModuleFunctions then
		return
	end
	Mount = ModuleFunctions.CraftMount()
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