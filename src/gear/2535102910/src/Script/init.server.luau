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

local AIScript = script.AIScript

local Penguin = InsertService:LoadAsset(2514061928)
Penguin = Penguin:GetChildren()[1]:Clone()
AIScript.Parent = Penguin
AIScript.Disabled = false

local CurrentPenguin = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentPenguin = Penguin:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentPenguin
	
	CurrentPenguin.Name = Character.Name .. "'s_Penguin"
	CurrentPenguin.Parent = workspace
	CurrentPenguin:MakeJoints()
	CurrentPenguin:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentPenguin then 
		CurrentPenguin:Destroy()
	end
	
	CurrentPenguin = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)