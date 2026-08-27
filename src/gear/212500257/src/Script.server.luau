--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Fire = Handle:WaitForChild("Fire")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

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

TsunamiModel = InsertService:LoadAsset(212226090)
TsunamiWave = TsunamiModel:GetChildren()[1]:Clone()
if TsunamiModel and TsunamiModel.Parent then
	TsunamiModel:Destroy()
end

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 15, Max = 20}},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 15, Max = 20}},
	Slash1 = {Animation = Tool:WaitForChild("Slash1"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 20, Max = 25}},
	Slash2 = {Animation = Tool:WaitForChild("Slash2"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 20, Max = 30}},
	Slash3 = {Animation = Tool:WaitForChild("Slash3"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 25, Max = 35}},
	Charge = {Animation = Tool:WaitForChild("Charge"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Bite = Handle:WaitForChild("Bite")
}

TouchDamage = {Min = 10, Max = 10}

Shark = BasePart:Clone()
Shark.Name = "Shark"
Shark.Size = Vector3.new(1, 2.2, 7)
SharkMesh = Instance.new("SpecialMesh")
SharkMesh.MeshType = Enum.MeshType.FileMesh
SharkMesh.MeshId = (BaseUrl .. "82821384")
SharkMesh.TextureId = (BaseUrl .. "82844051")
SharkMesh.Scale = Vector3.new(5, 5, 5)
SharkMesh.Parent = Shark

ToolEquipped = false
MouseDown = false
FullyCharged = false
SpecialActive = false
SpecialReloadTime = 20

Clicks = 0
FirstClick = false

Gravity = 196.20
Rate = (1 / 60)

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Fire.Enabled = false
Tool.Enabled = true

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	
	local character = Hit.Parent
	
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
		return
	end
	
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	
	humanoid:TakeDamage(DamageAmount)
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			PossibleSounds[math.random(1, #PossibleSounds)]:Play()
		end 
		CurrentAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		InvokeClient("PlayAnimation", CurrentAnimation)
		if CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
			wait(CurrentAnimation.Duration)
			CurrentAnimation = nil
		end
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		local AttackAnims = {}
		local AttackSounds = {}
		if MouseDown and Clicks == 1 and not SpecialActive then
			AttackAnims = {Animations.Charge}
			Spawn(function()
				if not SpecialActive then
					local ChargeTick = tick()
					while MouseDown and ToolEquipped and CheckIfAlive() and not FullyCharged do
						if (tick() - ChargeTick) >= 3 then
							FullyCharged = true
							Fire.Enabled = true
						end
						wait()
					end
				end
			end)
		else
			AttackSounds = {Sounds.Slash}
			AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.Slash1, Animations.Slash2, Animations.Slash3}
		end
		Attack(AttackAnims, AttackSounds)
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
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
	local CurrentlyEquipped = true
	EquippedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if EquippedToolUnequipped then
		EquippedToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	FullyCharged = true
	Fire.Enabled = false
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
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
	if player == Player and ToolEquipped and CheckIfAlive() then
		if Mode == "MouseClick" then
			local Down = Value.Down
			if Down and not MouseDown then
				MouseDown = true
				Activated()
			elseif not Down and MouseDown then
				MouseDown = false
				InvokeClient("StopAnimation", Animations.Charge)
				if FullyCharged and not SpecialActive then
					if CurrentAnimation == Animations.Charge and FullyCharged then
						SpecialActive = true
						FullyCharged = false
						Fire.Enabled = false
						local RayHit, RayPos, RayNormal = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
						if not RayHit then
							return
						end
						local Duration = 5
						Humanoid.WalkSpeed = 0
						InvokeClient("DisableJump", true)
						Character.Archivable = true
						local CharacterClone = Character:Clone()
						Character.Archivable = false
						for i, v in pairs(CharacterClone:GetChildren()) do
							if v:IsA("Tool") then
								v:Destroy()
							end
						end
						local AttackSounds = {}
						InvokeClient("StopAnimation", Animations.Charge)
						local AttackAnims = {}
						Attack(AttackAnims, AttackSounds)
						wait(0.125)
						if not ToolEquipped then
							return
						end
						local TsunamiWaveClone = TsunamiWave:Clone()
						TsunamiWaveClone.Touched:connect(function(Hit)
							if not Hit or not Hit.Parent then
								return
							end
							local character = Hit.Parent
							if character:IsA("Hat") then
								character = Hit.Parent
							end
							if character == Character then
								return
							end
							local player = Players:GetPlayerFromCharacter(character)
							if player and IsTeamMate(Player, player) then
								return
							end
							local humanoid = character:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 then
								UntagHumanoid(humanoid)
								TagHumanoid(humanoid, Player)
								humanoid:TakeDamage(30)
							end
						end)
						local Offset = (Torso.CFrame - Vector3.new(0, ((CharacterClone:GetModelSize().Y / 2) + (TsunamiWaveClone.Size.Y / 2) - 0), 0)) + Vector3.new(0, 1, 0)
						Offset = CFrame.new(Offset.p, (Torso.CFrame + Torso.CFrame.lookVector * 2).p) * CFrame.Angles((math.pi / 2), -(math.pi / 2), 0)
						local PX, PY, PZ, XX, XY, XZ, YX, YY, YZ, ZX, ZY, ZZ = Offset:components()
						Offset = CFrame.new(PX, PY, PZ, XX, XY, XZ, 0, YY, YZ, ZX, ZY, ZZ) * CFrame.Angles(math.pi, math.pi, 0)
						TsunamiWaveClone.CFrame = Offset
						local Weld = Instance.new("Weld")
						Weld.Part0 = Torso
						Weld.Part1 = TsunamiWaveClone
						Weld.C0 = CFrame.new(0, -((TsunamiWaveClone.Size.Y / 2) + (CharacterClone:GetModelSize().Y / 2) - 0), 6) * CFrame.Angles(0, -(math.pi / 2), 0)
						Weld.Parent = TsunamiWaveClone
						Debris:AddItem(TsunamiWaveClone, Duration)
						local BodyPosition = Instance.new("BodyPosition")
						BodyPosition.maxForce = Vector3.new(math.huge, math.huge, 0)
						BodyPosition.position = Offset.p
						BodyPosition.Parent = TsunamiWaveClone
						local BodyGyro = Instance.new("BodyGyro")
						BodyGyro.maxTorque = Vector3.new(0, math.huge, 0)
						BodyGyro.cframe = Offset * CFrame.Angles(0, 0, 0)
						local PlayerGyro = Instance.new("BodyGyro")
						PlayerGyro.maxTorque = Vector3.new(math.huge, 0, math.huge)
						Debris:AddItem(PlayerGyro, Duration)
						PlayerGyro.Parent = Torso
						BodyGyro.Parent = TsunamiWaveClone
						TsunamiWaveClone.CFrame = Offset
						TsunamiWaveClone.Anchored = false
						TsunamiWaveClone.Parent = game:GetService("Workspace")
						local SharksAvailable = 5
						local SharkRadius = {
							Min = Vector3.new((TsunamiWave.Size.X + 10), (TsunamiWave.Size.Y + 10), (TsunamiWave.Size.Z + 10)),
							Max = Vector3.new((TsunamiWave.Size.X + 10), (TsunamiWave.Size.Y / 2), (TsunamiWave.Size.Z + 10))
						}
						local Humanoids = {}
						local IgnoreObjects = {Character, TsunamiWaveClone}
						while TsunamiWaveClone and TsunamiWaveClone.Parent and ToolEquipped do
							if math.abs(TsunamiWaveClone.Position.Y - Offset.p.Y + 1.5) < TsunamiWaveClone.Size.Y then
								TsunamiWaveClone.CFrame = TsunamiWaveClone.CFrame + Vector3.new(0, (0.01 / 5 / Rate), 0)
								BodyPosition.position = TsunamiWaveClone.Position
							end
							if SharksAvailable > 0 then
								local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new((TsunamiWaveClone.Position - SharkRadius.Min), (TsunamiWaveClone.Position + SharkRadius.Max)), IgnoreObjects, 100)
								local CurrentHumanoids = {}
								for i, v in pairs(Parts) do
									if v and v.Parent then
										local character = v.Parent
										if character:IsA("Hat") then
											character = character.Parent
										end
										local player = Players:GetPlayerFromCharacter(character)
										if not player or (player and not IsTeamMate(Player, player)) then
											local humanoid = character:FindFirstChild("Humanoid")
											if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
												table.insert(CurrentHumanoids, humanoid)
												table.insert(Humanoids, humanoid)
											end
										end
									end
								end
								if #CurrentHumanoids > 0 then
									for i = 1, #CurrentHumanoids do
										if SharksAvailable <= 0 then
											break
										end
										local Index = math.random(1, #CurrentHumanoids)
										local humanoid = CurrentHumanoids[Index]
										if humanoid and humanoid.Parent and humanoid.Health > 0 then
											local character = humanoid.Parent
											local head = character:FindFirstChild("Head")
											if head then
												SharksAvailable = (SharksAvailable - 1)
											end
											table.remove(CurrentHumanoids, Index)
											table.insert(IgnoreObjects, character)
											local SharkClone = Shark:Clone()
											SharkClone.CanCollide = false
											local Bite = Sounds.Bite:Clone()
											Bite.Parent = SharkClone
											SharkClone.CFrame = TsunamiWaveClone.CFrame
											local Direction = CFrame.new(SharkClone.Position, head.Position)
											SharkClone.CFrame = Direction
											local Velocity = Direction.lookVector * 100
											local Mass = (Shark:GetMass() * Gravity)
											local BodyGyro = Instance.new("BodyGyro")
											BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
											BodyGyro.cframe = Direction
											BodyGyro.Parent = SharkClone
											local BodyVelocity = Instance.new("BodyVelocity")
											BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
											BodyVelocity.velocity = Velocity
											BodyVelocity.Parent = SharkClone
											SharkClone.Velocity = Velocity
											local Bitten = false
											SharkClone.Touched:connect(function(Hit)
												if not Hit or not Hit.Parent or Bitten then
													return
												end
												local character = Hit.Parent
												if character:IsA("Hat") then
													character = Hit.Parent
												end
												if character == Character then
													return
												end
												local player = Players:GetPlayerFromCharacter(character)
												if player and IsTeamMate(Player, player) then
													return
												end
												local humanoid = character:FindFirstChild("Humanoid")
												if humanoid and humanoid.Health > 0 then
													Bitten = true
													UntagHumanoid(humanoid)
													TagHumanoid(humanoid, Player)
													humanoid:TakeDamage(50)
													if BodyVelocity and BodyVelocity.Parent then
														BodyVelocity:Destroy()
													end
													Bite:Play()
												end
											end)
											Debris:AddItem(SharkClone, 5)
											SharkClone.Parent = game:GetService("Workspace")
										end
									end
								end
							end
							local NewPosition = (TsunamiWaveClone.CFrame + (TsunamiWaveClone.CFrame * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * 2)
							TsunamiWaveClone.CFrame = NewPosition
							BodyPosition.position = TsunamiWaveClone.Position
							wait(Rate)
						end
						if TsunamiWaveClone and TsunamiWaveClone.Parent then
							TsunamiWaveClone:Destroy()
						end
						Humanoid.WalkSpeed = 16
						InvokeClient("DisableJump", false)
						wait(SpecialReloadTime)
						SpecialActive = false
					end
				end
			end
		end
	end
end)

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)