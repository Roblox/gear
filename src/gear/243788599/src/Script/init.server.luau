--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")
Debris = game:GetService("Debris")

HedgehogModel = InsertService:LoadAsset(228289069)
Hedgehog = HedgehogModel:GetChildren()[1]:Clone()
Debris:AddItem(HedgehogModel, 1)

Remover = script:WaitForChild("Remover")

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

ReloadTime = 45

NumberOfHedgehogs = 6
Spawned = false

CurrentHedgehogs = {}

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

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function GetOffset()
	local SpawnRadius = {
		X = {
			Min = {
				Begin = 2,
				End = 3,
			},
			Max = {
				Begin = 4,
				End = 15,
			},
		},
		Y = {
			Min = {
				Begin = 0,
				End = 0,
			},
			Max = {
				Begin = 2,
				End = 2,
			},
		},
		Z = {
			Min = {
				Begin = -6,
				End = 0,
			},
			Max = {
				Begin = 0,
				End = 10,
			},
		},
	}
	for i, v in pairs(SpawnRadius) do
		for ii, vv in pairs(v) do
			for iii, vvv in pairs(vv) do
				SpawnRadius[i][ii][iii] = (vvv * 100)
			end
		end
	end
	local DesiredSpawnLocation = Vector3.new(
		math.random(math.random(SpawnRadius.X.Min.Begin, SpawnRadius.X.Min.End), math.random(SpawnRadius.X.Max.Begin, SpawnRadius.X.Max.End)),
		math.random(math.random(SpawnRadius.Y.Min.Begin, SpawnRadius.Y.Min.End), math.random(SpawnRadius.Y.Max.Begin, SpawnRadius.Y.Max.End)),
		math.random(math.random(SpawnRadius.Z.Min.Begin, SpawnRadius.Z.Min.End), math.random(SpawnRadius.Z.Max.Begin, SpawnRadius.Z.Max.End))
	)
	DesiredSpawnLocation = (DesiredSpawnLocation * 0.01)
	return DesiredSpawnLocation
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	if not Spawned then
		Handle.Transparency = 1
		Spawned = true
		CurrentHedgehogs = {}
		for i = 1, NumberOfHedgehogs do
			local HedgehogCopy = Hedgehog:Clone()
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "Creator"
			Creator.Value = Player
			Creator.Parent = HedgehogCopy
			local RemoverClone = Remover:Clone()
			RemoverClone.Disabled = false
			RemoverClone.Parent = HedgehogCopy
			local humanoid = HedgehogCopy:FindFirstChild("Humanoid")
			humanoid.Health = humanoid.MaxHealth
			table.insert(CurrentHedgehogs, HedgehogCopy)
			HedgehogCopy.Changed:connect(function(Property)
				if Property == "Parent" and not HedgehogCopy.Parent then
					for i, v in pairs(CurrentHedgehogs) do
						if v == HedgehogCopy then
							table.remove(CurrentHedgehogs, i)
							if #CurrentHedgehogs == 0 then
								Tool.Enabled = false
								wait(ReloadTime)
								Tool.Enabled = true
								Handle.Transparency = 0
								Spawned = false
							end
						end
					end
				end
			end)
			humanoid.Died:connect(function()
				Debris:AddItem(HedgehogCopy, 2)
			end)
			local Offset = GetOffset()
			HedgehogCopy.Torso.CFrame = (Torso.CFrame * CFrame.new(Offset))
			local OffsetValue = HedgehogCopy:FindFirstChild("Offset")
			if OffsetValue then
				OffsetValue.Value = Offset
			end
			Debris:AddItem(HedgehogCopy, (60 * 2))
			HedgehogCopy.Parent = game:GetService("Workspace")
		end
	elseif #CurrentHedgehogs > 0 then
		local MouseData = InvokeClient("MousePosition")
		local MousePosition = MouseData.Position
		local Target = MouseData.Target
		for i, v in pairs(CurrentHedgehogs) do
			Spawn(function()
				if v and v.Parent then
					local TargetValue = v:FindFirstChild("Target")
					local TargetPosValue = v:FindFirstChild("TargetPos")
					local ModeValue = v:FindFirstChild("Mode")
					if not TargetValue or not TargetPosValue or not ModeValue then
						return
					end
					if Target and Target.Parent then
						TargetPosValue.Value = MousePosition
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
						if humanoid and humanoid.Health > 0 and (not creator or (creator and creator.Value ~= Player and not IsTeamMate(Player, creator.Value))) then
							if TargetValue then
								TargetValue.Value = character
								ModeValue.Value = "Attack"
								return
							end
						end
						local OffsetValue = v:FindFirstChild("Offset")
						if OffsetValue then
							OffsetValue.Value = GetOffset()
						end
						ModeValue.Value = "MoveTo"
					else
						local OffsetValue = v:FindFirstChild("Offset")
						if OffsetValue then
							OffsetValue.Value = GetOffset()
						end
						ModeValue.Value = "Follow"
					end
				end
			end)
		end
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
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
	if Property == "Parent" then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not Spawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)