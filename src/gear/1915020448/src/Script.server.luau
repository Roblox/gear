-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local Tool = script.Parent
Tool.RequiresHandle = false

if Tool:FindFirstChild("Handle") then
	Tool.Handle:Destroy()
end

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

local Wasp = InsertService:LoadAsset(1914909026)
Wasp = Wasp:GetChildren()[1]:Clone()

local CurrentWasp = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentWasp = Wasp:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentWasp
	
	CurrentWasp.Name = Character.Name .. "'s_Wasp"
	CurrentWasp.Parent = workspace
	CurrentWasp:MakeJoints()
	CurrentWasp:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentWasp then 
		CurrentWasp:Destroy()
	end
	
	CurrentWasp = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)