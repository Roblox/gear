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

local BabyElephant = InsertService:LoadAsset(1427578407)
BabyElephant = BabyElephant:GetChildren()[1]:Clone()

local CurrentBabyElephant = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentBabyElephant = BabyElephant:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentBabyElephant
	
	CurrentBabyElephant.Name = Character.Name .. "'s_BabyElephant"
	CurrentBabyElephant.Parent = workspace
	CurrentBabyElephant:MakeJoints()
	CurrentBabyElephant:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentBabyElephant then 
		CurrentBabyElephant:Destroy()
	end
	
	CurrentBabyElephant = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)