--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")
Debris = game:GetService("Debris")

AIScript = script:WaitForChild("AIScript")
Remover = script:WaitForChild("Remover")

CharacterModule = require(191816425)

BloxikinModel = InsertService:LoadAsset(248258445)
BloxikinItems = BloxikinModel:GetChildren()[1]:Clone()
Debris:AddItem(BloxikinModel, 1)

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	Pop = Handle:WaitForChild("Pop"),
	Magic = Handle:WaitForChild("Magic"),
	WizardLaugh = Handle:WaitForChild("WizardLaugh"),
	Jump = Handle:WaitForChild("Jump"),
	Died = Handle:WaitForChild("Died"),
}

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

BloxikinsSpawned = false
BloxikinsReady = false

CurrentBloxikins = {}

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

function MakeCircle(Data)
	local Parts, Radius, Size, Origin = Data.Parts, Data.Radius, Data.Size, Data.Origin
	local Model = Instance.new("Model")
	Model.Name = "Circle"
	local PartsCreated = {}
	for i = 1, Parts do
		local Part = BasePart:Clone()
		Part.Anchored = true
		Part.Size = Vector3.new((((Radius + Size.X) * math.pi) / Parts), Size.Y, Size.Z)
		Part.CFrame = (Origin * CFrame.Angles(0, (i * ((math.pi * 2) / Parts)), 0) + (Origin * CFrame.Angles(0, (i * ((math.pi * 2) / Parts)), 0)).lookVector * (0.5 * Radius))
		Part.Parent = Model
		table.insert(PartsCreated, Part)
	end
	return {Model = Model, Parts = PartsCreated}
end

function SetUpBloxikin(Figure)
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
	local Humanoid = Figure:FindFirstChild("Humanoid")
	local Torso = Figure:FindFirstChild("Torso")
	local BloxikinSounds = {}
	for i, v in pairs({Jump = Sounds.Jump, Died = ((Figure == BloxikinSummoner and Sounds.WizardLaugh) or Sounds.Died)}) do
		local Sound = v:Clone()
		Sound.Parent = Torso
		BloxikinSounds[i] = Sound
	end
	if Humanoid and Torso then
		Humanoid.Died:connect(function()
			if Figure ~= BloxikinSummoner then
				Sounds.Died.Pitch = (math.random(1900, 2500) * 0.001)
			end
			BloxikinSounds.Died:Play()
		end)
		Humanoid.Jumping:connect(function()
			BloxikinSounds.Jump:Play()
		end)
	end
	return
end

function SpawnBloxikins()
	BloxikinsReady = false
	
	CurrentBloxikins = {}
	
	local DisabledTags = {}
	
	local BloxikinModel = Instance.new("Model")
	BloxikinModel.Name = ToolName
	local AIScriptClone = AIScript:Clone()
	AIScriptClone.Disabled = false
	AIScriptClone.Parent = BloxikinModel
	local RemoverClone = Remover:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = BloxikinModel
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = BloxikinModel

	BloxikinModel.Changed:connect(function(Property)
		if Property == "Parent" and not BloxikinModel.Parent then
			for i, v in pairs(CurrentBloxikins) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			CurrentBloxikins = {}
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			Handle.Transparency = 0
			BloxikinsSpawned = false
		end
	end)	
	
	Debris:AddItem(BloxikinModel, Duration)
	BloxikinModel.Parent = game:GetService("Workspace")
	
	BloxikinSummoner = BloxikinItems.BloxikinSummoner:Clone()
	local SummonerHumanoid = BloxikinSummoner.Humanoid
	local SummonerTorso = BloxikinSummoner.Torso
	local MagicSound = Sounds.Magic:Clone()
	MagicSound.Parent = SummonerTorso
	SetUpBloxikin(BloxikinSummoner)
	local MovementDisabled = Instance.new("StringValue")
	MovementDisabled.Name = "Disabled"
	table.insert(DisabledTags, MovementDisabled)
	MovementDisabled.Parent = BloxikinSummoner
	local DisableValue = Instance.new("BoolValue")
	DisableValue.Name = "Disabled"
	DisableValue.Value = true
	DisableValue.Parent = BloxikinSummoner.Target
	BloxikinSummoner.Damage.Value = 20
	SummonerHumanoid.WalkSpeed = 18
	SummonerHumanoid.MaxHealth = 300
	SummonerHumanoid.Health = SummonerHumanoid.MaxHealth
	SummonerHumanoid.Died:connect(function()
		Debris:AddItem(BloxikinSummoner, 2)
		Debris:AddItem(BloxikinModel, 4)
		for i, v in pairs(CurrentBloxikins) do
			if v and v.Parent then
				v:BreakJoints()
			end
		end
	end)
	BloxikinSummoner.Changed:connect(function(Property)
		if Property == "Parent" and not BloxikinSummoner.Parent then
			Debris:AddItem(BloxikinModel, 2)
		end
	end)
	local OffsetValue = BloxikinSummoner.Offset
	OffsetValue.Value = Vector3.new(-9.5, 0, 0)
	SummonerTorso.CFrame = (Torso.CFrame * CFrame.new(OffsetValue.Value))
	BloxikinSummoner.Parent = BloxikinModel
	SummonerHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	table.insert(CurrentBloxikins, BloxikinSummoner)
	local function CreatePawns()
		local Data = CharacterModule.GetTable({Key = "Bloxikins", Player = Player})	
		if not Data then
			return
		end
		local BloxikinData = Data.GetData({Scale = 0.375})
		local Bloxikin = BloxikinData.MakeBloxikin()
		local NumberOfBloxikins = math.random(12, 16)
		for i = 1, NumberOfBloxikins do
			local BloxikinCopy = Bloxikin:Clone()
			BloxikinData.RandomizeDesign({Character = BloxikinCopy, Distribute = true})
			local BloxikinHumanoid = BloxikinCopy.Humanoid
			local BloxikinTorso = BloxikinCopy.Torso
			local PopSound = Sounds.Pop:Clone()
			PopSound.Parent = BloxikinTorso
			SetUpBloxikin(BloxikinCopy)
			BloxikinCopy.Follow.Value = BloxikinSummoner
			table.insert(CurrentBloxikins, BloxikinCopy)
			BloxikinCopy.Changed:connect(function(Property)
				if Property == "Parent" and not BloxikinCopy.Parent then
					for i, v in pairs(CurrentBloxikins) do
						if v == BloxikinCopy then
							table.remove(CurrentBloxikins, i)
							if #CurrentBloxikins == 0 then
								if BloxikinModel and BloxikinModel.Parent then
									Debris:AddItem(BloxikinModel, 1)
									BloxikinModel:Destroy()
								end
							end
						end
					end
				end
			end)
			BloxikinHumanoid.Died:connect(function()
				Debris:AddItem(BloxikinCopy, 2)
			end)
			local OffsetValue = BloxikinCopy.Offset
			OffsetValue.Value = (SummonerTorso.Position - (SummonerTorso.CFrame  + (SummonerTorso.CFrame * CFrame.Angles(0, (((math.pi * 2) / NumberOfBloxikins) * i), 0)).lookVector * 6).p)
			BloxikinHumanoid.WalkSpeed = 18
			BloxikinHumanoid.MaxHealth = 100
			BloxikinHumanoid.Health = BloxikinHumanoid.MaxHealth
			BloxikinTorso.CFrame = (SummonerTorso.CFrame * CFrame.new(OffsetValue.Value) - Vector3.new(0, 0.2, 0))
			BloxikinTorso.Anchored = true
			local MovementDisabled = Instance.new("StringValue")
			MovementDisabled.Name = "Disabled"
			table.insert(DisabledTags, MovementDisabled)
			MovementDisabled.Parent = BloxikinCopy
			BloxikinCopy.Parent = BloxikinModel
			BloxikinHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			PopSound:Play()
		end
	end
	
	wait(0.25)
	
	SummonerTorso.Anchored = true
	
	local CastSpell = SummonerHumanoid:LoadAnimation(BloxikinSummoner.ArmsUp)

	local Circle = MakeCircle({Parts = 10, Radius = 11.5, Size = Vector3.new(2, 0.2, 2), Origin = (SummonerTorso.CFrame - Vector3.new(0, (SummonerTorso.Size.Y + 0.4), 0))})
	local CircleModel = Circle.Model
	local CircleParts = Circle.Parts
	CircleModel.Name = "PurpleFog"
	
	CastSpell.KeyframeReached:connect(function(Frame)
		if Frame == "1" then
			local PurpleFogEffects = {}
			for i, v in pairs(BloxikinItems.Particles.PurpleFog:GetChildren()) do
				local Effect = v:Clone()
				pcall(function()
					Effect.Enabled = false
				end)
				table.insert(PurpleFogEffects, Effect)
			end
			for i, v in pairs(CircleParts) do
				if v:IsA("BasePart") then
					v.Transparency = 1
					for ii, vv in pairs(PurpleFogEffects) do
						local Effect = vv:Clone()
						pcall(function()
							Effect.Enabled = true
						end)
						Effect.Parent = v
						Delay(7.5, (function()
							Effect.Enabled = false
						end))
					end
					v.CanCollide = false
				end
			end
			Debris:AddItem(CircleModel, (60 * 1))
			CircleModel.Parent = BloxikinModel
		elseif Frame == "2" then
			CastSpell:AdjustSpeed(0)
			wait(0.75)
			MagicSound:Play()
			CastSpell:AdjustSpeed(0.25)
			wait(0.25)
			CreatePawns()
			Debris:AddItem(CircleModel, 5)
			wait(1.5)
			for i, v in pairs(DisabledTags) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			for i, v in pairs(CurrentBloxikins) do
				if v and v.Parent then
					local humanoid = v:FindFirstChild("Humanoid")
					local torso = v:FindFirstChild("Torso")
					if humanoid and torso then
						torso.Anchored = false
						humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
					end
				end
			end
			BloxikinsReady = true
		end
	end)
	CastSpell:Play(nil, 0.75, 0.25)
	
end

function SetTarget(Data)
	if not BloxikinsReady or not BloxikinsSpawned then
		return
	end
	local MousePosition = Data.MousePosition
	local Target = Data.Target
	for i, v in pairs(CurrentBloxikins) do
		Spawn(function()
			if v and v.Parent then
				local TargetValue = v:FindFirstChild("Target")
				local TargetPosValue = v:FindFirstChild("TargetPos")
				local ModeValue = v:FindFirstChild("Mode")
				local BloxikinTorso = v:FindFirstChild("Torso")
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
						if v ~= BloxikinSummoner then
							TargetValue.Value = nil
							ModeValue.Value = "Follow"
						else
							ModeValue.Value = "MoveTo"
						end
					end
				else
					ModeValue.Value = "Follow"
				end
			end
		end)
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	if not BloxikinsSpawned then
		local BloxikinModel = game:GetService("Workspace"):FindFirstChild(ToolName)
		if BloxikinModel then
			return
		end
		Handle.Transparency = 1
		BloxikinsSpawned = true
		SpawnBloxikins()
	elseif #CurrentBloxikins > 0 then
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
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolName = (Player.Name .. "'sBloxikins")
	ToolEquipped = true
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
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not BloxikinsSpawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)