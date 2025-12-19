--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

AIScript = script:WaitForChild("AIScript")
Remover = script:WaitForChild("Remover")

NPCModel = InsertService:LoadAsset(257489726)
NPC = NPCModel:GetChildren()[1]:Clone()
if NPCModel and NPCModel.Parent then
	NPCModel:Destroy()
end

ReloadTime = 5

NPCSpawned = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function MakeNPC()
	if PlayerNPC and PlayerNPC.Parent then
		PlayerNPC:Destroy()
	end
	PlayerNPC = NPC:Clone()
	NPCHumanoid = PlayerNPC:FindFirstChild("Humanoid")
	NPCTorso = PlayerNPC:FindFirstChild("Torso")
	if not NPCHumanoid or not NPCTorso then
		return
	end
	NPCHumanoid.WalkSpeed = 18
	NPCHumanoid.MaxHealth = 200
	NPCHumanoid.Health = NPCHumanoid.MaxHealth
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
		{Name = "Mode", Class = "StringValue", Value = "Follow"},
		{Name = "MaxDistance", Class = "NumberValue", Value = 50},
		{Name = "Follow", Class = "ObjectValue", Value = Player},
		{Name = "Offset", Class = "Vector3Value", Value = Vector3.new(-3, 0, -0.5)},
		{Name = "Target", Class = "ObjectValue", Value = nil},
		{Name = "TargetPos", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
		{Name = "Damage", Class = "NumberValue", Value = 0},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = PlayerNPC
	end
	for i, v in pairs({AIScript, Remover}) do
		local ScriptClone = v:Clone()
		ScriptClone.Disabled = false
		ScriptClone.Parent = PlayerNPC
	end
	NPCHumanoid.Died:connect(function()
		Debris:AddItem(PlayerNPC, 3)
	end)
	PlayerNPC.Changed:connect(function(Property)
		if Property == "Parent" and not PlayerNPC.Parent and NPCSpawned then
			Tool.Enabled = false
			NPCSpawned = false
			wait(ReloadTime)
			Tool.Enabled = true
		end
	end)
	NPCTorso.CFrame = (Torso.CFrame * CFrame.new(PlayerNPC.Offset.Value))
	PlayerNPC.Parent = game:GetService("Workspace")
	NPCHumanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	NPCSpawned = true
end

function SetTarget(Data)
	if not PlayerNPC or not PlayerNPC.Parent then
		return
	end
	local MousePosition = Data.MousePosition
	local Target = Data.Target
	local TargetValue = PlayerNPC:FindFirstChild("Target")
	local TargetPosValue = PlayerNPC:FindFirstChild("TargetPos")
	local ModeValue = PlayerNPC:FindFirstChild("Mode")
	local OffsetValue = PlayerNPC:FindFirstChild("Offset")
	if not TargetValue or not TargetPosValue or not ModeValue then
		return
	end
	if Target and Target.Parent then
		local character = Target.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and IsTeamMate(player, Player) then
			return
		end
		local creator = character:FindFirstChild("Creator")
		local humanoid = character:FindFirstChild("Humanoid")
		if creator and (creator.Value == Player or IsTeamMate(Player, creator.Value)) then
			return
		end
		if humanoid and humanoid.Health > 0 then
			if TargetValue then
				TargetValue.Value = character
				ModeValue.Value = "Attack"
				return
			end
		else
			TargetPosValue.Value = MousePosition
			TargetValue.Value = nil
			ModeValue.Value = "MoveTo"
		end
	else
		ModeValue.Value = "Follow"
	end
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Tool.Enabled and (not PlayerNPC or not PlayerNPC.Parent) then
		Handle.Transparency = 1
		--MakeNPC()
	else
		local MouseData = InvokeClient("MousePosition")
		if not MouseData then
			return
		end
		local MousePosition = MouseData.Position
		local Target = MouseData.Target
		SetTarget({MousePosition = MousePosition, Target = Target})
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Handle.Transparency = 1
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	--[[NPCSpawned = false
	if PlayerNPC then
		for i, v in pairs({PlayerNPC}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		PlayerNPC = nil
	end]]
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Changed:connect(function(Property)
	if not Tool.Parent then
		return
	end
	if Tool.Enabled and not NPCSpawned and ToolEquipped and CheckIfAlive() then
		MakeNPC()
	end
	Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and (((not NPCSpawned and Tool.Enabled) and 0) or 1)) or 0))
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)