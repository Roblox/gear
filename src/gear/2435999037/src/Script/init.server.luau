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

local Niffler = InsertService:LoadAsset(2463541382)
Niffler = Niffler:GetChildren()[1]:Clone()
AIScript.Parent = Niffler
AIScript.Disabled = false

local CurrentNiffler = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentNiffler = Niffler:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentNiffler
	
	CurrentNiffler.Name = Character.Name .. "'s_Niffler"
	CurrentNiffler.Parent = workspace
	CurrentNiffler:MakeJoints()
	CurrentNiffler:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentNiffler then 
		CurrentNiffler:Destroy()
	end
	
	CurrentNiffler = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)