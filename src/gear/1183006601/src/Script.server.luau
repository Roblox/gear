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

local Porg = InsertService:LoadAsset(1207908937)
Porg = Porg:GetChildren()[1]:Clone()

local CurrentPorg= nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentPorg = Porg:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentPorg
	
	CurrentPorg.Name = Character.Name .. "'s_Porg"
	CurrentPorg.Parent = workspace
	CurrentPorg:MakeJoints()
	CurrentPorg:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentPorg then 
		CurrentPorg:Destroy()
	end
	
	CurrentPorg = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)