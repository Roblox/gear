--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

TripScript = script:WaitForChild("TripScript")

Functions = require(script:WaitForChild("Functions"))

LastMove = 0

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

Figures = {}

function IncludeFigure(Child)
	if not Child or not Child.Parent then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Child)
	if Player then
		return
	end
	for i, v in pairs(Figures) do
		if v.Figure == Child then
			return
		end
	end
	local Figure = {Figure = Child, TouchDebounce = false, Connections = {}}
	local Humanoid = Child:FindFirstChild("Humanoid")
	local Head = Child:FindFirstChild("Head")
	local Torso = Child:FindFirstChild("Torso")
	if not Humanoid or not Humanoid:IsA("Humanoid") or Humanoid.Health == 0 or not Head or not Torso then
		return
	end
	local Neck = Torso:FindFirstChild("Neck")
	if not Neck then
		return
	end
	for i, v in pairs({Humanoid, Head, Torso, Neck}) do
		Figure[v.Name] = v
	end
	local Values = {"Creator", "Mode", "Follow", "Target", "TargetPos", "Offset", "Damage", "MaxDistance"}
	for i, v in pairs(Values) do
		local Value = Child:FindFirstChild(v)
		if not Value then
			return
		end
		Figure[v] = Value
	end
	local HumanoidChanged = Humanoid.Changed:connect(function(Property)
		if Property == "Sit" and Humanoid.Sit then
			Humanoid.Sit = false
			Humanoid.Jump = true
		end
	end)
	local HumanoidDied = Humanoid.Died:connect(function()
		Debris:AddItem(Child, 2)
	end)
	local FigureRemoved = Child.Changed:connect(function(Property)
		if Property == "Parent" and not Child.Parent then
			for i, v in pairs(Figures) do
				if v == Figure then
					for ii, vv in pairs(v.Connections) do
						if vv then
							vv:disconnect()
						end
					end
					table.remove(Figures, i)
					if #Figures == 0 then
						Debris:AddItem(Model, 2)
					end
				end
			end
		end
	end)
	for i ,v in pairs({HumanoidChanged, HumanoidDied, FigureRemoved}) do
		table.insert(Figure.Connections, v)
	end
	for i, v in pairs(Child:GetChildren()) do
		if v:IsA("BasePart") then
			local TouchedConnection
			TouchedConnection = v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent or Figure.TouchDebounce then
					return
				end
				local Connected = false
				local ConnectedParts = v:GetConnectedParts()
				if #ConnectedParts <= 1 then
					return
				end
				for i, v in pairs(ConnectedParts) do
					if v == Torso then
						Connected = true
					end
				end
				if not Connected then
					return
				end
				local character = Hit.Parent
				if character:IsA("Hat") then
					character = character.Parent
				end
				--[[if character ~= Figure.Target.Value then
					return
				end]]
				local player = Players:GetPlayerFromCharacter(character)
				local CreatorValue = Figure.Creator.Value
				if not CreatorValue then
					return
				end
				local CreatorPlayer = ((CreatorValue:IsA("Player") and CreatorValue) or Players:GetPlayerFromCharacter(CreatorValue))
				if player then
					if player == CreatorPlayer then
						return
					end
					if player and CreatorPlayer and Functions.IsTeamMate(CreatorPlayer, player) then
						return
					end
				end
				local creator = character:FindFirstChild("Creator")
				if creator and creator:IsA("ObjectValue") and creator.Value == CreatorValue then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or not humanoid:IsA("Humanoid") or humanoid.Health == 0 then
					return
				end
				if player then
					local TripScriptClone = TripScript:Clone()
					local Duration = Instance.new("NumberValue")
					Duration.Name = "Duration"
					Duration.Value = 2
					Duration.Parent = TripScriptClone
					TripScriptClone.Disabled = false
					Debris:AddItem(TripScriptClone, 4)
					TripScriptClone.Parent = character
				end
				Figure.TouchDebounce = true
				Functions.UntagHumanoid(humanoid)
				Functions.TagHumanoid(humanoid, CreatorPlayer)
				humanoid:TakeDamage(Figure.Damage.Value)
				wait(0.125)
				Figure.TouchDebounce = false
			end)
			table.insert(Figure.Connections, TouchedConnection)
		end
	end
	table.insert(Figures, Figure)
end

function SecureJump(Table)
	local Humanoid = Table.Humanoid
	local Torso = Table.Torso
	if not Humanoid or Humanoid.Jump or not Torso then
		return
	end
	local TargetPoint = Torso.Velocity.Unit
	local Blockage, BlockagePos = Functions.CastRay((Torso.CFrame + CFrame.new(Torso.Position, Vector3.new(TargetPoint.X, Torso.Position.Y, TargetPoint.Z)).lookVector * (Torso.Size.Z / 2)).p, Torso.CFrame.lookVector, (Torso.Size.Z * 2.5), {Figure, (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character) and Creator.Value.Character) or nil)}, false)
	local Jumpable = false
	if Blockage then
		Jumpable = true
		if Blockage:IsA("Terrain") then
			local CellPos = Blockage:WorldToCellPreferSolid((BlockagePos - Vector3.new(0, 2, 0)))
			local CellMaterial, CellShape, CellOrientation = Blockage:GetCell(CellPos.X, CellPos.Y, CellPos.Z)
			if CellMaterial == Enum.CellMaterial.Water then
				Jumpable = false
			end
		elseif Blockage.Parent:FindFirstChild("Humanoid") then
			Jumpable = false
		end
	end
	if Jumpable then
		Humanoid.Jump = true
	end
end

RunService.Stepped:connect(function()
	_, Time = wait(0.05)
	for i, v in pairs(Figures) do
		Spawn(function()
			pcall(function()
				if v and v.Figure and v.Figure.Parent then
					Spawn(function()
						SecureJump(v)
					end)
					local Disabled = v.Figure:FindFirstChild("Disabled")
					if not Disabled then
						local CreatorValue = v.Creator.Value
						if CreatorValue then
							local CreatorPlayer = ((CreatorValue:IsA("Player") and CreatorValue) or Players:GetPlayerFromCharacter(v.Creator.Value))
							if CreatorPlayer then
								local CreatorCharacter = CreatorPlayer.Character
								if CreatorCharacter and CreatorCharacter.Parent then
									local CreatorTorso = CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso")
									if CreatorTorso then
										local DistanceApart = (CreatorTorso.Position - v.Torso.Position).magnitude
										if DistanceApart > v.MaxDistance.Value then
											v.Figure:Destroy()
											--v.Mode.Value = "Follow"
										end
									end
								end
							end
						end
						if v.Mode.Value == "Follow" then
							local FollowValue = v.Follow.Value
							if FollowValue then
								if FollowValue:IsA("Player") and FollowValue.Character and FollowValue.Character.Parent then
									FollowValue = FollowValue.Character
								end
								local FollowHumanoid = FollowValue:FindFirstChild("Humanoid")
								local FollowTorso = FollowValue:FindFirstChild("Torso") or FollowValue:FindFirstChild("UpperTorso")
								if FollowHumanoid and FollowHumanoid.Health > 0 and FollowTorso then
									--if (v.Torso.Position - FollowTorso.Position).magnitude > 5 then
										v.Humanoid:MoveTo((FollowTorso.CFrame * CFrame.new(v.Offset.Value)).p)
									--end
								end
							end
						elseif v.Mode.Value == "MoveTo" then
							v.Humanoid:MoveTo(v.TargetPos.Value)
							LastMove = Time
							--v.Mode.Value = "Nothing"
						elseif v.Mode.Value == "Attack" then
							local TargetCharacter = v.Target.Value
							local TargetDisabled = v.Target:FindFirstChild("Disabled")
							local NotFound = false
							if not TargetDisabled or not TargetDisabled.Value then
								if TargetCharacter and TargetCharacter.Parent then
									local TargetHumanoid = TargetCharacter:FindFirstChild("Humanoid")
									local TargetTorso = TargetCharacter:FindFirstChild("Torso") or TargetCharacter:FindFirstChild("UpperTorso")
									local creator = TargetCharacter:FindFirstChild("Creator")
									if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso and (not creator or (creator and v.Creator.Value ~= creator.Value and not Functions.IsTeamMate(v.Creator.Value, creator.Value))) then
										local ChaseOffset = Vector3.new(((math.random() - 0.5) * 5), ((math.random() - 0.5) * 5), ((math.random() - 0.5) * 5))
										v.Humanoid:MoveTo((TargetTorso.CFrame * CFrame.new(ChaseOffset)).p)
									else
										NotFound = true
									end
								else
									NotFound = true
								end
							end
							if NotFound then
								v.Target.Value = nil
								v.Mode.Value = "Follow"
							end
						elseif v.Mode.Value == "Nothing" then
							if (Time - LastMove) >= 30 then
								v.Mode.Value = "Follow"
							end
						end
					end
				end
			end)
		end)
	end
end)

for i, v in pairs(Model:GetChildren()) do
	IncludeFigure(v)
end

Model.ChildAdded:connect(function(Child)
	IncludeFigure(Child)
end)