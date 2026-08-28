-- // Made by StarWars
local Tool = script.Parent
local Shield = Tool:FindFirstChild("Shield")
if Shield then
	local Motor6D = Shield:FindFirstChildOfClass("Motor6D") 
	if Motor6D then
		Motor6D:Destroy()
	end
end

local BaseShield = Shield:Clone()
local LeftGripAttachment = Instance.new("Attachment")
LeftGripAttachment.Name = "LeftGripAttachment"
LeftGripAttachment.Parent = BaseShield
Shield:Destroy()

local GearService = require(1075123174)

local Gear = GearService:BindGear(Tool, "Sword")
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local ClientControls = Tool:WaitForChild("Remotes"):WaitForChild("ClientControls")

local CurrentShield = nil

local Animations = 
{
	ShieldHold = {Animation = Tool:WaitForChild("ShieldHold")};
	R15ShieldHold = {Animation = Tool:WaitForChild("R15ShieldHold")};	
}

local function CreateShield()
	CurrentShield = BaseShield:Clone()
	local LeftGripShield = CurrentShield:FindFirstChild("LeftGripAttachment")
	local LeftHand = Gear.Character:FindFirstChild("Left Arm") or Gear.Character:FindFirstChild("LeftHand")
	local LeftGripHand = LeftHand and LeftHand:FindFirstChild("LeftGripAttachment")
	
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		LeftGripShield.Orientation = LeftGripShield.Orientation + Vector3.new(90, 0, 0)
	end	
	
	if LeftGripShield and LeftGripHand then
		GearService:WeldToAttachment(LeftGripShield, LeftGripHand)
		CurrentShield.Parent = Gear.Character
	end
end

Gear:BindEquippedFunction("sword_shield_equipped", function()
	CreateShield()
	local Animation = Animations.ShieldHold
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15ShieldHold
	end
	pcall(function() ClientControls:InvokeClient(Gear.Player, "PlayAnimation", Animation) end)
end)

Gear:BindUnequippedFunction("sword_shield_unequipped", function()
	if CurrentShield then
		CurrentShield:Destroy()
	end
	CurrentShield = nil
end)