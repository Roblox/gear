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

local OFFSET_POSITIONS = {
	Vector3.new(3, 0, 3),
	Vector3.new(-3, 0, 3),
	Vector3.new(0, 0, 5),
	Vector3.new(3, 0, 8),
	Vector3.new(-3, 0, 8)
}

local Rat = InsertService:LoadAsset(3374795585)
Rat = Rat:GetChildren()[1]:Clone()
AIScript.Parent = Rat
AIScript.Disabled = false

local CurrentRats = {}
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	for i = 1, 5 do
		local newRat = Rat:Clone()
		
		local Owner = Instance.new("ObjectValue")
		Owner.Name = "Owner"
		Owner.Value = Character
		Owner.Parent = newRat
		
		local Offset = Instance.new("Vector3Value")
		Offset.Name = "Offset"
		Offset.Value = OFFSET_POSITIONS[i]
		Offset.Parent = newRat
		
		newRat.Name = Character.Name .. "'s_Rat"
		newRat.Parent = workspace
		newRat:MakeJoints()
		newRat:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(OFFSET_POSITIONS[i])).p)	
		
		table.insert(CurrentRats, newRat)
	end
end

function OnUnequip()
	for _, v in pairs(CurrentRats) do
		v:Destroy()
	end
	
	CurrentRats = {}
	
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)