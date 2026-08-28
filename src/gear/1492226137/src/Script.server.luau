-- // Created by StarWars
local CollectionService = game:GetService("CollectionService")

local GearService = require(1075123174)
local Tool = script.Parent

local BASE_URL = "rbxassetid://"

local Gear = GearService:BindGear(Tool, "Sword")
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")
Gear.Class:DisableLunge()

local BasePart = Instance.new("Part")
BasePart.Anchored = false
BasePart.CanCollide = false
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)

local BaseMesh = Instance.new("SpecialMesh")

local BaseShield = BasePart:Clone()
BaseShield.Name = "Shield"
BaseShield.Size = Vector3.new(2.341, 2.934, 0.657)
CollectionService:AddTag(BaseShield, GearService.ShieldTag)

local BaseShieldMesh = BaseMesh:Clone()
BaseShieldMesh.MeshId = BASE_URL .. 1450698100
BaseShieldMesh.TextureId = BASE_URL .. 1450698643
BaseShieldMesh.Parent = BaseShield

local ShieldAttachment = Instance.new("Attachment")
ShieldAttachment.Name = "LeftGripAttachment"
ShieldAttachment.Orientation = Vector3.new(0, -90, -90)
ShieldAttachment.Position = Vector3.new(0.317, 0.177, 0.763)
ShieldAttachment.Axis = Vector3.new(0, -1, 0)
ShieldAttachment.SecondaryAxis = Vector3.new(0, 0, 1)
ShieldAttachment.Parent = BaseShield

local Shield = Tool:FindFirstChild("Shield")
if Shield then
	Shield:Destroy()
end

local Animations = {}

local CurrentShield = nil

function InvokeClient(Mode, Value)
	local Result = nil
	pcall(function()
		Result = Gear.ClientControls:InvokeClient(Gear.Player, Mode, Value)
	end)
	
	return Result
end

function EquipShield()
	if Gear:IsPlayerAlive() then
		CurrentShield = BaseShield:Clone()
		local NewMotor = Instance.new("Motor6D")
		NewMotor.Name = "ShieldJoint"
		NewMotor.Part0 = CurrentShield
		NewMotor.C0 = CurrentShield.LeftGripAttachment.CFrame
		
		local LeftGripAttachment = Gear.Character:FindFirstChild("LeftGripAttachment", true)
		if LeftGripAttachment then
			NewMotor.Part1 = LeftGripAttachment.Parent
			NewMotor.C1 = LeftGripAttachment.CFrame
		end
		
		CurrentShield.Parent = Gear.Character
		NewMotor.Parent = CurrentShield
	end
end

Gear:BindEquippedFunction("roman_sword_equipped", EquipShield)

Gear:BindUnequippedFunction("roman_sword_unequipped", function()
	if CurrentShield then
		CurrentShield:Destroy()
	end
	
	CurrentShield = nil
end)

Gear:BindActivateFunction("roman_sword_activate", function()

end)