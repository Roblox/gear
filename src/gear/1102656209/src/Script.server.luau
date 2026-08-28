local InsertService = game:GetService("InsertService")

local Tool = script.Parent
Tool.RequiresHandle = false

if Tool:FindFirstChild("Handle") then
	Tool.Handle:Destroy()
end

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

local BubbleTroubleRobot = InsertService:LoadAsset(1102850213)
BubbleTroubleRobot = BubbleTroubleRobot:GetChildren()[1]:Clone()

local CurrentRobot = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentRobot = BubbleTroubleRobot:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character.PrimaryPart
	Owner.Parent = CurrentRobot
	
	CurrentRobot.Name = Character.Name .. "'s_Robot"
	CurrentRobot.Parent = workspace
	CurrentRobot:MakeJoints()
	CurrentRobot:MoveTo((Owner.Value.CFrame * CFrame.new(4, 0, 3)).p)
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