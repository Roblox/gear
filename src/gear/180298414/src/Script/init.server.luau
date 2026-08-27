--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

TrainedBatTheifModel = InsertService:LoadAsset(180247488)
TrainedBatTheif = TrainedBatTheifModel:GetChildren()[1]:Clone()
if TrainedBatTheifModel and TrainedBatTheifModel.Parent then
	TrainedBatTheifModel:Destroy()
end

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

BatManagement = script:WaitForChild("BatManagement")

MaxEnemyDistance = 100

Gravity = 196.20

ReloadTime = 5

Active = false
BatTarget = nil
ToolTaken = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and CheckIfAlive() then
		if Mode == "MouseClick" and Value.Down then
			if not BatTheif or not BatTheif.Parent and Tool.Enabled then
				Handle.Transparency = 1
				SpawnBatTheif()
			elseif Value.Target and Value.Target.Parent then
				local character = Value.Target.Parent
				if character:IsA("Hat") or character:IsA("Tool") then
					character = character.Parent
				end
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
					if humanoid and humanoid.Health > 0 and torso and (torso.Position - Torso.Position).magnitude <= MaxEnemyDistance then
						local ToolsFound = {} --Supports multiple tools equipped theft
						for i, v in pairs(character:GetChildren()) do
							if v:IsA("Tool") and v:FindFirstChild("Handle") then
								table.insert(ToolsFound, v)
							end
						end
						if #ToolsFound > 0 then
							local ToolSelected = ToolsFound[math.random(1, #ToolsFound)]
							BatTarget = ToolSelected
						end
					end
				end
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function Reload(Destroy)
	if not Active then
		return
	end
	BatTarget = nil
	ToolTaken = false
	if Destroy then
		Active = false
		if BatTheif and BatTheif.Parent then
			BatTheif:Destroy()
		end
		for i, v in pairs({BatDied, BatDestroyed}) do
			if v then
				v:disconnect()
			end
		end
		Handle.Transparency = 0
	end
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	wait(ReloadTime)
	Tool.Enabled = true
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function CreateBatTheif()
	local BatTheif = TrainedBatTheif:Clone()
	local BatManagementClone = BatManagement:Clone()
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = BatManagementClone
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = BatManagementClone
	BatManagementClone.Disabled = false
	BatManagementClone.Parent = BatTheif
	local BatHumanoid = BatTheif:FindFirstChild("Humanoid")
	local BatTorso = BatTheif:FindFirstChild("Torso")
	if not BatHumanoid or BatHumanoid.Health == 0 or not BatTorso then
		return
	end
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.Parent = BatTorso
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.Parent = BatTorso
	return BatTheif
end

function SpawnBatTheif()
	BatTheif = CreateBatTheif()
	local BatHumanoid = BatTheif:FindFirstChild("Humanoid")
	local BatTorso = BatTheif:FindFirstChild("Torso")
	if not BatHumanoid or BatHumanoid.Health == 0 or not BatTorso then
		return
	end
	local BodyPosition = BatTorso:FindFirstChild("BodyPosition")
	local BodyGyro = BatTorso:FindFirstChild("BodyGyro")
	if not BodyPosition or not BodyGyro then
		return
	end
	Active = true
	BatDied = BatHumanoid.Died:connect(function()
		Debris:AddItem(BatTheif, 2)
	end)
	BatDestroyed = BatTheif.Changed:connect(function(Property)
		if Property == "Parent" and not BatTheif.Parent then
			Reload(true)
		end
	end)
	for i, v in pairs(BatTheif:GetChildren()) do
		if v:IsA("BasePart") then
			v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				local character = Hit.Parent
				if character:IsA("Hat") or character:IsA("Tool") then
					character = character.Parent
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and BatTarget and BatTarget.Parent == character then
					BatTarget.Parent = nil
					ToolTaken = true
				end
			end)
		end
	end
	Spawn(function()
		while CheckIfAlive() and BatTheif.Parent and BatHumanoid.Parent and BatHumanoid.Health > 0 and BatTorso.Parent and BodyPosition.Parent and BodyGyro.Parent do
			if not BatTarget or not BatTarget.Parent then
				if (BatTorso.Position - Torso.Position).magnitude <= 8 and BatTarget and ToolTaken then
					local Backpack = Player:FindFirstChild("Backpack")
					if Backpack then
						BatTarget.Parent = Backpack
					end
					Spawn(function()
						Reload(false)
					end)
				end
				BodyGyro.cframe = ((ToolTaken and CFrame.new(BatTorso.Position, Torso.Position)) or Torso.CFrame)
				local Mass = ((GetTotalMass(BatTheif) * Gravity) * 100)
				if (BatTarget and BatTarget.Parent) or ToolTaken then
					Mass = ((GetTotalMass(BatTheif) * Gravity) * 1.05)
				end
				BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
				local Position = (Torso.CFrame + Torso.CFrame.lookVector * -(Torso.Size.Z * 1.5))
				Position = (Position + (Position * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (BatTorso.Size.X * 0.5)).p
				Position = (Position + Vector3.new(0, 5, 0))
				if BatTarget and ToolTaken then
					local Direction = CFrame.new(BatTorso.Position, Position)
					BodyPosition.position = (BatTorso.CFrame + Direction.lookVector * 5).p
				else
					BodyPosition.position = Position
				end
			else
				local ModelCheck = Instance.new("Model")
				local TargetClone = BatTarget:Clone()
				TargetClone.Parent = ModelCheck
				local TargetSize = ModelCheck:GetModelSize()
				local TargetCFrame = ModelCheck:GetModelCFrame()
				local Position = TargetCFrame + Vector3.new(0, ((TargetSize.Y / 2) + (BatTheif:GetModelSize().Y / 2)), 0)
				local Direction = CFrame.new(BatTorso.Position, Position.p)
				BodyGyro.cframe = Direction
				BodyPosition.position = (BatTorso.CFrame + Direction.lookVector * 5).p
			end
			wait(0.1)
		end
	end)
	BatTheif.Parent = game:GetService("Workspace")
	BatTorso.CFrame = Torso.CFrame + Torso.CFrame.lookVector * (Torso.Size.Z * 2) + Vector3.new(0, 6, 0)
end

function CheckIfAlive()
	return (Character and Character.Parent and Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 0
end

function Unequipped()
	Player = nil
	Reload(true)
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)