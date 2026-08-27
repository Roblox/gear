local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Module = require(191816425)

local Tool = script.Parent
local Handle = Tool.Handle

local Remover = script:WaitForChild("Remover")

local Player = nil
local Character = nil
local Torso = nil
local Humanoid = nil

local Mount = nil
local CurrentMount = nil

local ModuleData = nil
local ModuleFunctions = nil

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function SpawnWolf()
	if not Mount then return end
	
	CurrentMount = Mount:Clone()
	local MountTorso = CurrentMount:FindFirstChild("Torso")
	if not MountTorso then return end
	
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	local RemoverClone = Remover:Clone()
	local Data = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Model", Class = "ObjectValue", Value = CurrentMount}
	}
	
	for i, v in pairs(Data) do
		local Object = Instance.new(v.Class)
		Object.Name = v.Name
		Object.Value = v.Value
		Object.Parent = RemoverClone
	end
	
	RemoverClone.Disabled = false
	RemoverClone.Parent = CurrentMount
	CurrentMount.Parent = workspace
	MountTorso.CFrame = ((Torso.CFrame * CFrame.new(0, 0, -((Torso.Size.Z * 0.5) + (CurrentMount:GetModelSize().Z * 0.5) + 2))) + Vector3.new(0, 1.5, 0))
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then return end
	Tool.Enabled = false	
	
	SpawnWolf()
	Debris:AddItem(Tool, 0)
	if Tool and Tool.Parent then
		Tool:Destroy()
	end
end

function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	
	ModuleData = Module.GetTable({Key = "WolfMount", Player = Player})	
	if not ModuleData then return end
	
	ModuleFunctions = ModuleData.GetData({Player = Player, Tool = Tool, Character = Character})
	if not ModuleFunctions then return end
	
	Mount = ModuleFunctions.CraftMount()
	
	Handle.Transparency = 1
	Activated()
end

function OnUnequipped()
	Handle.Transparency = 0
	Tool.Enabled = true
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)