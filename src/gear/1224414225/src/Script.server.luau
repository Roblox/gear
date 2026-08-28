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

local Gingerbread = InsertService:LoadAsset(1224312993)
Gingerbread = Gingerbread:GetChildren()[1]:Clone()

local CurrentGingerbread = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentGingerbread = Gingerbread:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentGingerbread
	
	CurrentGingerbread.Name = Character.Name .. "'s_Gingerbread"
	CurrentGingerbread.Parent = workspace
	CurrentGingerbread:MakeJoints()
	CurrentGingerbread:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentGingerbread then 
		CurrentGingerbread:Destroy()
	end
	
	CurrentGingerbread = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)