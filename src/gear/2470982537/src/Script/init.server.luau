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

local ImaginaryFriend = InsertService:LoadAsset(2467538867)
ImaginaryFriend = ImaginaryFriend:GetChildren()[1]:Clone()
AIScript.Parent = ImaginaryFriend
AIScript.Disabled = false

local CurrentImaginaryFriend = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentImaginaryFriend = ImaginaryFriend:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentImaginaryFriend
	
	CurrentImaginaryFriend.Name = Character.Name .. "'s_ImaginaryFriend"
	CurrentImaginaryFriend.Parent = workspace
	CurrentImaginaryFriend:MakeJoints()
	CurrentImaginaryFriend:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentImaginaryFriend then 
		CurrentImaginaryFriend:Destroy()
	end
	
	CurrentImaginaryFriend = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)