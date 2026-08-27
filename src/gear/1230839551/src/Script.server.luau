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

local Ferdinand = InsertService:LoadAsset(1230808157)
Ferdinand = Ferdinand:GetChildren()[1]:Clone()

local CurrentFerdinand= nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentFerdinand = Ferdinand:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentFerdinand
	
	CurrentFerdinand.Name = Character.Name .. "'s_Ferdinand"
	CurrentFerdinand.Parent = workspace
	CurrentFerdinand:MakeJoints()
	CurrentFerdinand:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentFerdinand then 
		CurrentFerdinand:Destroy()
	end
	
	CurrentFerdinand = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)