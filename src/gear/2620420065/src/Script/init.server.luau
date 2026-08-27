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

local Dog = InsertService:LoadAsset(2630453159)
Dog = Dog:GetChildren()[1]:Clone()
AIScript.Parent = Dog
AIScript.Disabled = false

local CurrentDog = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentDog = Dog:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentDog
	
	CurrentDog.Name = Character.Name .. "'s_Wolf"
	CurrentDog.Parent = workspace
	CurrentDog:MakeJoints()
	CurrentDog:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentDog then 
		CurrentDog:Destroy()
	end
	
	CurrentDog = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)