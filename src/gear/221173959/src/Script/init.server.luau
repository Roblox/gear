--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Remover = script:WaitForChild("Remover")

PetModel = InsertService:LoadAsset(220799053)
Pet = PetModel:GetChildren()[1]:Clone()
Pet.FrontRightLeg.Mesh.MeshId = 'rbxassetid://243248017'
Pet.BackRightLeg.Mesh.MeshId = 'rbxassetid://243248259'
Debris:AddItem(PetModel, 0)

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function MakePet()
	if PlayerPet and PlayerPet.Parent then
		PlayerPet:Destroy()
	end
	PlayerPet = Pet:Clone()
	local PetHumanoid = PlayerPet:FindFirstChild("Humanoid")
	local PetTorso = PlayerPet:FindFirstChild("Torso")
	if not PetHumanoid or not PetTorso then
		return
	end
	local CreatorValue = (PlayerPet:FindFirstChild("Creator") or Instance.new("ObjectValue"))
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = PlayerPet
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = PlayerPet
	local RemoverClone = Remover:Clone()
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerPet
	PlayerPet.Parent = game:GetService("Workspace")
	local PetOffset = Vector3.new(-2, -Torso.Size.Y, -3)
	local OffsetValue = PlayerPet:FindFirstChild("Offset")
	if OffsetValue then
		OffsetValue.Value = PetOffset
	end
	PetTorso.CFrame = Torso.CFrame * CFrame.new(PetOffset)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 0
	Spawn(function()
		Handle.Transparency = 1
		MakePet()
	end)
	ToolEquipped = true
end

function Unequipped()
	if PlayerPet and PlayerPet.Parent then
		PlayerPet:Destroy()
	end
	Handle.Transparency = 0
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Mode == "MouseClick" and PlayerPet and PlayerPet.Parent then
		local Down = Value.Down
		local Target = Value.Target
		local MousePosition = Value.Position
		
		local TargetValue = PlayerPet:FindFirstChild("Target")
		local TargetPosValue = PlayerPet:FindFirstChild("TargetPos")
		local ModeValue = PlayerPet:FindFirstChild("Mode")
		
		if not Target then
			return
		end
		
		if Down then
			
			if TargetPosValue then
				TargetPosValue.Value = MousePosition
			end
			
			local character = Target.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				if TargetValue then
					TargetValue.Value = character
					ModeValue.Value = "Attack"
					return
				end
			end
			ModeValue.Value = "MoveTo"
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)