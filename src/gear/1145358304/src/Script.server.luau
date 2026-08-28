local InsertService = game:GetService("InsertService")

local Tool = script.Parent
Tool.RequiresHandle = false

if Tool:FindFirstChild("Handle") then
	Tool.Handle:Destroy()
end

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

local Turkey = InsertService:LoadAsset(1159622229)
Turkey = Turkey:GetChildren()[1]:Clone()

local CurrentTurkey = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentTurkey = Turkey:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character.PrimaryPart
	Owner.Parent = CurrentTurkey
	
	CurrentTurkey.Name = Character.Name .. "'s_Turkey"
	CurrentTurkey.Parent = workspace
	CurrentTurkey:MakeJoints()
	CurrentTurkey:MoveTo((Owner.Value.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentTurkey then 
		CurrentTurkey:Destroy()
	end
	
	CurrentTurkey = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)