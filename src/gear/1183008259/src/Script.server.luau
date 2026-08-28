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

local R2D2Robot = InsertService:LoadAsset(1207909309)
R2D2Robot = R2D2Robot:GetChildren()[1]:Clone()

local CurrentRobot = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentRobot = R2D2Robot:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentRobot
	
	CurrentRobot.Name = Character.Name .. "'s_Robot"
	CurrentRobot.Parent = workspace
	CurrentRobot:MakeJoints()
	CurrentRobot:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentRobot then 
		CurrentRobot:Destroy()
	end
	
	CurrentRobot = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)