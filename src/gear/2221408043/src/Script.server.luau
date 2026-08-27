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

local QBot6 = InsertService:LoadAsset(2222824787)
QBot6 = QBot6:GetChildren()[1]:Clone()

local CurrentQBot6 = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentQBot6 = QBot6:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentQBot6
	
	CurrentQBot6.Name = Character.Name .. "'s_QBot6"
	CurrentQBot6.Parent = workspace
	CurrentQBot6:MakeJoints()
	CurrentQBot6:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentQBot6 then 
		CurrentQBot6:Destroy()
	end
	
	CurrentQBot6 = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)