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

local Dragon = InsertService:LoadAsset(1322985630)
Dragon = Dragon:GetChildren()[1]:Clone()

local CurrentDragon = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentDragon = Dragon:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentDragon
	
	CurrentDragon.Name = Character.Name .. "'s_Dragon"
	CurrentDragon.Parent = workspace
	CurrentDragon:MakeJoints()
	CurrentDragon:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentDragon then 
		CurrentDragon:Destroy()
	end
	
	CurrentDragon = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)