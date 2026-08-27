--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")
Debris = game:GetService("Debris")

AIScript = script:WaitForChild("AIScript")
Remover = script:WaitForChild("Remover")

MeerkatModel = InsertService:LoadAsset(267059049)
Meerkat = MeerkatModel:GetChildren()[1]:Clone()
Debris:AddItem(MeerkatModel, 1)

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

ReloadTime = 20
Duration = (60 * 2)

MeerkatsSpawned = false
MeerkatsReady = false

CurrentMeerkats = {}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end
function SetUpMeerkat(Figure)
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Mode", Class = "StringValue", Value = "Follow"},
		{Name = "MaxDistance", Class = "NumberValue", Value = 150},
		{Name = "Follow", Class = "ObjectValue", Value = Player},
		{Name = "Offset", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
		{Name = "Target", Class = "ObjectValue", Value = nil},
		{Name = "TargetPos", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
		{Name = "Damage", Class = "NumberValue", Value = 5},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = Figure
	end
	return
end

function MakeMeerkats()
	MeerkatsReady = false
	CurrentMeerkats = {}
	
	local DisabledTags = {}
	
	local MeerkatModel = Instance.new("Model")
	MeerkatModel.Name = ToolName
	local AIScriptClone = AIScript:Clone()
	AIScriptClone.Disabled = false
	AIScriptClone.Parent = MeerkatModel
	local RemoverClone = Remover:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = MeerkatModel
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = MeerkatModel

	MeerkatModel.Changed:connect(function(Property)
		if Property == "Parent" and not MeerkatModel.Parent then
			for i, v in pairs(CurrentMeerkats) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			CurrentMeerkats = {}
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			Handle.Transparency = 0
			MeerkatsSpawned = false
		end
	end)	
	
	Debris:AddItem(MeerkatModel, Duration)
	MeerkatModel.Parent = game:GetService("Workspace")
	
	local function CreatePawns()
		local NumberOfMeerkats = 6
		for i = 1, NumberOfMeerkats do
			local MeerkatCopy = Meerkat:Clone()
			local MeerkatHumanoid = MeerkatCopy.Humanoid
			local MeerkatTorso = MeerkatCopy.Torso
			SetUpMeerkat(MeerkatCopy)
			MeerkatCopy.Follow.Value = Player
			table.insert(CurrentMeerkats, MeerkatCopy)
			MeerkatCopy.Changed:connect(function(Property)
				if Property == "Parent" and not MeerkatCopy.Parent then
					for i, v in pairs(CurrentMeerkats) do
						if v == MeerkatCopy then
							table.remove(CurrentMeerkats, i)
							if #CurrentMeerkats == 0 then
								if MeerkatModel and MeerkatModel.Parent then
									Debris:AddItem(MeerkatModel, 1)
									MeerkatModel:Destroy()
								end
							end
						end
					end
				end
			end)
			MeerkatHumanoid.Died:connect(function()
				Debris:AddItem(MeerkatCopy, 2)
			end)
			local OffsetValue = MeerkatCopy.Offset
			OffsetValue.Value = (Torso.Position - (Torso.CFrame  + (Torso.CFrame * CFrame.Angles(0, (((math.pi * 2) / NumberOfMeerkats) * i), 0)).lookVector * 6).p)
			MeerkatHumanoid.WalkSpeed = 16
			MeerkatHumanoid.MaxHealth = 100
			MeerkatHumanoid.Health = MeerkatHumanoid.MaxHealth
			MeerkatTorso.CFrame = (Torso.CFrame * CFrame.new(OffsetValue.Value) - Vector3.new(0, 0.2, 0))
			MeerkatTorso.Anchored = true
			local MovementDisabled = Instance.new("StringValue")
			MovementDisabled.Name = "Disabled"
			table.insert(DisabledTags, MovementDisabled)
			MovementDisabled.Parent = MeerkatCopy
			MeerkatCopy.Parent = MeerkatModel
			MeerkatHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
	end
	CreatePawns()
	for i, v in pairs(DisabledTags) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(CurrentMeerkats) do
		if v and v.Parent then
			local humanoid = v:FindFirstChild("Humanoid")
			local torso = v:FindFirstChild("Torso")
			if humanoid and torso then
				torso.Anchored = false
				humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		end
	end
	MeerkatsReady = true
end

function SetTarget(Data)
	if not MeerkatsReady or not MeerkatsSpawned then
		return
	end
	local MousePosition = Data.MousePosition
	local Target = Data.Target
	for i, v in pairs(CurrentMeerkats) do
		Spawn(function()
			if v and v.Parent then
				local TargetValue = v:FindFirstChild("Target")
				local TargetPosValue = v:FindFirstChild("TargetPos")
				local ModeValue = v:FindFirstChild("Mode")
				local MeerkatTorso = v:FindFirstChild("Torso")
				local OffsetValue = v:FindFirstChild("Offset")
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
						ModeValue.Value = "MoveTo"
					end
				else
					ModeValue.Value = "Follow"
				end
			end
		end)
	end
end

function SpawnMeerkats()
	if not MeerkatsSpawned then
		local MeerkatModel = game:GetService("Workspace"):FindFirstChild(ToolName)
		if MeerkatModel then
			return
		end
		Handle.Transparency = 1
		MeerkatsSpawned = true
		MakeMeerkats()
	elseif #CurrentMeerkats > 0 then
		local MouseData = InvokeClient("MousePosition")
		if not MouseData then
			return
		end
		local MousePosition = MouseData.Position
		local Target = MouseData.Target
		SetTarget({MousePosition = MousePosition, Target = Target})
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	SpawnMeerkats()
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolName = (Player.Name .. "'sMeerkats")
	ToolEquipped = true
	Spawn(SpawnMeerkats)
end

function Unequipped()
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
	if Property == "Parent" and Tool.Parent then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not MeerkatsSpawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)