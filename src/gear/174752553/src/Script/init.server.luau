--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

CannonModel = InsertService:LoadAsset(174258074)
Cannon = CannonModel:GetChildren()[1]:Clone()
CannonModel:Destroy()

CurrentCannon = Tool:WaitForChild("CurrentCannon")

Remover = script:WaitForChild("Remover")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Equipped = false

ReloadTime = 15

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

Handle.Transparency = 0

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "Click" and Value and Tool.Enabled and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and (not CurrentCannon.Value  or not CurrentCannon.Value.Parent) then
		Tool.Enabled = false
		CannonVehicle = Cannon:Clone()
		CurrentCannon.Value = CannonVehicle
		local RemoverClone = Remover:Clone()
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = CannonVehicle
		RemoverClone.Disabled = false
		RemoverClone.Parent = CannonVehicle
		local CannonScript = CannonVehicle:FindFirstChild("Controller")
		CannonScript.Disabled = true
		CannonVehicle.Parent = game:GetService("Workspace")
		local CannonBody = CannonVehicle:FindFirstChild("Body")
		CannonBody.CFrame = (Torso.CFrame - Vector3.new(0, (Torso.Size.Y / 2), 0)) + Torso.CFrame.lookVector * (((CannonVehicle:GetModelSize().Z / 2) + (Torso.Size.Z / 2)) + 1)
		CannonScript.Disabled = false
		Handle.Transparency = 1
		wait(ReloadTime)
		Handle.Transparency = 0
		Tool.Enabled = true
	elseif Mode == "KeyPress" and Value.Key == "x" and Value.Down and CurrentCannon.Value then
		CurrentCannon.Value:Destroy()
	end
end)

Tool.Changed:connect(function(Property)
	if Property == "Parent" and not Tool.Parent:IsA("Backpack") and Tool.Parent ~= Character then
		CurrentCannon.Value:Destroy()
	end
end)

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end

function Unequipped()
	Equipped = false
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)