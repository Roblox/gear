-- // Created by StarWars
local InsertService = game:GetService("InsertService")
local GearService = require(1075123174)

local Tool = script.Parent
Tool.RequiresHandle = false

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()

if Tool:FindFirstChild("Handle") then
	Tool.Handle:Destroy()
end

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

local AIScript = script.AIScript

local Godzilla = InsertService:LoadAsset(3127241980)
Godzilla = Godzilla:GetChildren()[1]:Clone()
AIScript.Parent = Godzilla
AIScript.Disabled = false

local CurrentGodzilla = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentGodzilla = Godzilla:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentGodzilla
	
	CurrentGodzilla.Name = Character.Name .. "'s_Godzilla"
	CurrentGodzilla.Parent = workspace
	CurrentGodzilla:MakeJoints()
	CurrentGodzilla:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentGodzilla then 
		CurrentGodzilla:Destroy()
	end
	
	CurrentGodzilla = nil
	Character = nil
end


Gear.ServerControls.OnServerInvoke = function(player, mode, value)
	if mode == "FireClick" and CurrentGodzilla then
		CurrentGodzilla.Head.FireAttachment.Fire.Enabled = true
		
		wait(2)
		CurrentGodzilla.Head.FireAttachment.Fire.Enabled = false
	end
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)