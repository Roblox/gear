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

local Hognob = InsertService:LoadAsset(1302750965)
Hognob = Hognob:GetChildren()[1]:Clone()

local CurrentHognob = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentHognob = Hognob:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentHognob
	
	CurrentHognob.Name = Character.Name .. "'s_Hognob"
	CurrentHognob.Parent = workspace
	CurrentHognob:MakeJoints()
	CurrentHognob:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentHognob then 
		CurrentHognob:Destroy()
	end
	
	CurrentHognob = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)