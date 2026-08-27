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

local GhostDog = InsertService:LoadAsset(1239320650)
GhostDog = GhostDog:GetChildren()[1]:Clone()

local CurrentGhostDog = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentGhostDog = GhostDog:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentGhostDog
	
	CurrentGhostDog.Name = Character.Name .. "'s_GhostDog"
	CurrentGhostDog.Parent = workspace
	CurrentGhostDog:MakeJoints()
	CurrentGhostDog:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentGhostDog then 
		CurrentGhostDog:Destroy()
	end
	
	CurrentGhostDog = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)