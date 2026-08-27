--Made by Luckymaxer.  Fixed by ArceusInator.
local GLib = require(206209239) -- Function library

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Anchored = true
BasePart.CanCollide = false
BasePart.Locked = true

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5}
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash")
}

Damage = {
	Touch = 10,
	Slash = 15
}

SpecialAttacks = {
	Enabled = true,
	Active = false,
	ReloadTime = 1,
	VineGrab = {
		MaxDistance = 15,
		Duration = 10,
		ReloadTime = 5,
		Enabled = true,
		Active = false
	},
	VineShot = {
		Damage = 12,
		Duration = 10,
		ReloadTime = 7.5,
		Enabled = true,
		Active = false
	},
	VineShield = {
		Damage = 20,
		Duration = 10,
		ReloadTime = 10,
		Enabled = true,
		Active = false
	}
}

Equipped = false
Active = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and Equipped and Humanoid.Health > 0 then
		local SpecialSuccessful = false
		if Mode == "KeyPress" and SpecialAttacks.Enabled and not SpecialAttacks.Active then
			local Key = Value.Key
			local Down = Value.Down
			SpecialAttacks.Enabled = false
			SpecialAttacks.Active = true
			if Key == "q" and Down then
				local SpecialAttack = SpecialAttacks.VineGrab
				if SpecialAttack.Enabled and not SpecialAttack.Active then
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
					local PlayersTrapped = {}
					local CharactersInRange = {}
					local PartsInRegion = workspace:FindPartsInRegion3(
						Region3.new(
							Torso.Position - Vector3.new(1,1,1)*SpecialAttack.MaxDistance/2,
							Torso.Position + Vector3.new(1,1,1)*SpecialAttack.MaxDistance/2
						),
						Torso.Parent
					)
					for i, p in next, PartsInRegion do
						if (p.Position - Torso.Position).magnitude <= SpecialAttack.MaxDistance then
							local char = GLib.GetCharacterFromPart(p)
							if char then
								CharactersInRange[char] = true
							end
						end
					end
					for character in next, CharactersInRange do
						if character ~= Player.Character then
							local humanoid = GLib.GetHumanoid(character)
							local torso = character:FindFirstChild'HumanoidRootPart'
							local canHurt = GLib.IsTeammate(Player, GLib.GetPlayerFromPart(character))~=true
							if humanoid and humanoid.Health > 0 and torso and (Torso.Position - torso.Position).magnitude <= SpecialAttack.MaxDistance and canHurt then
								local RayHit, RayPos = RayCast(torso.Position, Vector3.new(0, -1, 0), (torso.Size.Y * 2), {character, Character})
								if RayHit then
									table.insert(PlayersTrapped, RayHit)
									local Vine = CreateVine(3)
									Debris:AddItem(Vine, SpecialAttack.Duration)
									local VineSize = Vine:GetModelSize()
									local VineCFrame = (torso.CFrame + Vector3.new(0, ((VineSize.Y / 2) - (character:GetModelSize().Y / 2) - 1), 0))
									VineCFrame = (VineCFrame + VineCFrame.lookVector * 0.5) * CFrame.Angles(0, math.random(-360, 360), 0)
									local VineOrigin = VineCFrame - Vector3.new(0, VineSize.Y, 0)
									local TorsoCFrame = Torso.CFrame
									local TempPart = BasePart:Clone()
									TempPart.Transparency = 1
									local BP = Instance.new'BodyPosition'
									BP.position = torso.Position
									BP.maxForce = Vector3.new(1,1,1)*1000000000
									BP.Parent = torso
									Debris:AddItem(BP, SpecialAttack.Duration)
									Debris:AddItem(TempPart, (SpecialAttack.Duration + 3))
									TempPart.Parent = character
									TempPart.CFrame = TorsoCFrame
									for i, v in pairs(Vine:GetChildren()) do
										if v:IsA("BasePart") then
											v.Transparency = 1
										end
									end
									Vine.Parent = game:GetService("Workspace")
									Spawn(function()
										for i = 1, 25 do
											if Vine and Vine.Parent then
												TransformModel(Vine, Vine:GetModelCFrame(), (VineOrigin + Vector3.new(0, ((VineSize.Y / 25) * i), 0)), true)
												if i == 1 then
													for ii, vv in pairs(Vine:GetChildren()) do
														if vv:IsA("BasePart") then
															vv.Transparency = 0
														end
													end
												end
												wait(0.01)
											end
										end
										if character and character.Parent then
											for i, v in pairs(Vine:GetChildren()) do
												if v:IsA("BasePart") then
													for ii, vv in pairs(character:GetChildren()) do
														if vv:IsA("BasePart") and vv.Name=='HumanoidRootPart' then
															local Weld = WeldTo(v, vv)
														end
													end
												end
											end
										end
										if TempPart and TempPart.Parent then
											TempPart:Destroy()
										end
										TransformModel(Vine, Vine:GetModelCFrame(), VineCFrame, true)
									end)
								end
							end
						end
					end
					
					if #PlayersTrapped > 0 then
						SpecialSuccessful = true
						wait(SpecialAttack.Duration)
					end
					SpecialAttack.Active = false
					Spawn(function()
						if #PlayersTrapped > 0 then
							wait(SpecialAttack.ReloadTime)
						end
						SpecialAttack.Enabled = true
					end)
				end
			elseif Key == "e" and Down then
				local SpecialAttack = SpecialAttacks.VineShot
				if SpecialAttack.Enabled and not SpecialAttack.Active then
					SpecialSuccessful = true
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
					local Vines = {}
					local VineModel = Instance.new("Model")
					VineModel.Name = "VineModel"
					Debris:AddItem(VineModel, SpecialAttack.Duration)
					VineModel.Parent = game:GetService("Workspace")
					local CharacterSize = Character:GetModelSize()
					local TorsoCFrame = Torso.CFrame
					for i = 1, 10 do
						if VineModel and VineModel.Parent then
							local Vine = CreateVine(3)
							for i, v in pairs(Vine:GetChildren()) do
								if v:IsA("BasePart") then
									v.Touched:connect(function(Hit)
										if not Hit or not Hit.Parent then
											return
										end
										local character = Hit.Parent
										local humanoid = character:FindFirstChild("Humanoid")
										local canHurt = GLib.IsTeammate(Player, GLib.GetPlayerFromPart(character))~=true
										if character ~= Character and humanoid and humanoid.Health > 0 and canHurt then
											UntagHumanoid(humanoid)
											TagHumanoid(humanoid, Player)
											humanoid:TakeDamage(SpecialAttack.Damage)
										end
									end)
								end
							end
							Debris:AddItem(Vine, (SpecialAttack.Duration + 3))
							for i, v in pairs(Vine:GetChildren()) do
								if v:IsA("BasePart") then
									v.Transparency = 1
								end
							end
							Vine.Parent = VineModel
							local VineSize = Vine:GetModelSize()
							local VineCFrame = (TorsoCFrame + Vector3.new(0, ((VineSize.Y / 2) - (CharacterSize.Y / 2) - 1), 0))
							VineCFrame = (VineCFrame + VineCFrame.lookVector * 0.5) * CFrame.Angles(0, math.random(-360, 360), 0)
							local VineOrigin = VineCFrame - Vector3.new(0, VineSize.Y, 0)
							TransformModel(Vine, Vine:GetModelCFrame(), VineOrigin, true)
							local LookVector = CFrame.new(TorsoCFrame.p, Vector3.new(VineOrigin.p.X, TorsoCFrame.p.Y, VineOrigin.p.Z)).lookVector
							Spawn(function()
								for ii = 1, 25 do
									if VineModel and VineModel.Parent then
										TransformModel(Vine, Vine:GetModelCFrame(), (VineOrigin + Vector3.new(0, ((VineSize.Y / 25) * ii), 0)) + LookVector * ((20 / VineSize.Z) * i), true)
										if ii == 1 then
											for iii, vvv in pairs(VineModel:GetChildren()) do
												if vvv:IsA("Model") then
													for iiii, vvvv in pairs(vvv:GetChildren()) do
														if vvvv:IsA("BasePart") then
															vvvv.Transparency = 0
														end
													end
												end
											end
										end
										wait(0.01)
									end
								end
							end)
							wait(0.25)
						end
					end
					wait(SpecialAttack.Duration)
					SpecialAttack.Active = false
					Spawn(function()
						wait(SpecialAttack.ReloadTime)
						SpecialAttack.Enabled = true
					end)
				end
			elseif Key == "x" and Down then
				local SpecialAttack = SpecialAttacks.VineShield
				if SpecialAttack.Enabled and not SpecialAttack.Active then
					
					local RayHit, RayPos = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 4), {Character})
					
					if RayHit then
						
						SpecialSuccessful = true
						SpecialAttack.Enabled = false
						SpecialAttack.Active = true
						
						local VineModel = Instance.new("Model")
						VineModel.Name = "VineShield"
						Debris:AddItem(VineModel, SpecialAttack.Duration)
						
						local Center = RayPos
						
						local NumberOfVines = 16
						local Increment = ((math.pi * 2) / NumberOfVines)
						local LookVector = CFrame.new(Center).lookVector
						local PosX = (12.5 * LookVector.x)
						local PosZ = (12.5 * LookVector.z)
						local Pos = Vector3.new((Center.x + PosX), Center.y, (Center.z + PosZ))
						local Vines = {}
						
						for i = 1, NumberOfVines do
							local Vine = CreateVine(9)
							for i, v in pairs(Vine:GetChildren()) do
								if v:IsA("BasePart") then
									v.Transparency = 1
								end
							end
							for ii, v in pairs(Vine:GetChildren()) do
								if v:IsA("BasePart") then
									v.CanCollide = true
									v.Touched:connect(function(Hit)
										if not Hit or not Hit.Parent then
											return
										end
										local character = Hit.Parent
										local humanoid = character:FindFirstChild("Humanoid")
										local canHurt = GLib.IsTeammate(Player, GLib.GetPlayerFromPart(character))~=true
										if character ~= Character and humanoid and humanoid.Health > 0 and canHurt then
											UntagHumanoid(humanoid)
											TagHumanoid(humanoid, Player)
											humanoid:TakeDamage(SpecialAttack.Damage)
										end
									end)
								end
							end
							local VineClone = Vine:Clone()
							Pos = CFrame.new(CFrame.new(Pos).p, Center) * CFrame.Angles(0, (math.pi / 2), 0)
							Pos = Pos + Vector3.new(0, ((VineClone:GetModelSize().Y / 2) - (Torso.Size.Y * 1.5)), 0)
							local Angle = (Increment * i)
							table.insert(Vines, {Vine = Vine, Position = Pos})
							Pos = Vector3.new(((Pos.x - Center.x) * math.cos(Angle)) - ((Pos.z - Center.z) * math.sin(Angle)) + Center.x, Center.y, ((Pos.x - Center.x) * math.sin(Angle)) + ((Pos.z - Center.z) * math.cos(Angle)) + Center.z)
						end
						
						for i, v in pairs(Vines) do
							if v.Vine then
								v.Vine.Parent = VineModel
								TransformModel(v.Vine, v.Vine:GetModelCFrame(), v.Position, true)
							end
						end
						
						local VineModelCFrame = VineModel:GetModelCFrame()
						TransformModel(VineModel, VineModelCFrame, (VineModelCFrame - Vector3.new(0, VineModel:GetModelSize().Y, 0)), true)
						VineModel.Parent = game:GetService("Workspace")

						for i = 1, 50 do
							local VineCFrame = VineModel:GetModelCFrame()
							TransformModel(VineModel, VineCFrame, (VineCFrame + Vector3.new(0, (VineModel:GetModelSize().Y / 50), 0)), true)
							if i == 1 then
								for ii, vv in pairs(VineModel:GetChildren()) do
									if vv:IsA("Model") then
										for iii, vvv in pairs(vv:GetChildren()) do
											if vvv:IsA("BasePart") then
												vvv.Transparency = 0
											end
										end
									end
								end
							end
							wait(0.01)
						end
						
						wait(SpecialAttack.Duration)
						SpecialAttack.Active = false
						Spawn(function()
							wait(SpecialAttack.ReloadTime)
							SpecialAttack.Enabled = true
						end)
					end
				end
			end
			if SpecialSuccessful then
				wait(SpecialAttacks.ReloadTime)
			end
			SpecialAttacks.Active = false
			SpecialAttacks.Enabled = true
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

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
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

function Blow(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not Equipped or not Character or not Character.Parent then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		local canHurt = GLib.IsTeammate(Player, GLib.GetPlayerFromPart(character)) ~= true
		if character ~= Character and humanoid and humanoid.Health > 0 and canHurt then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage((Active and Damage.Slash) or Damage.Touch)
		end
	end)
end

function TransformModel(Objects, Center, NewCFrame, Recurse)
	Objects = ((type(Objects) ~= "table" and {Objects}) or Objects)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			v.CFrame = NewCFrame:toWorldSpace(Center:toObjectSpace(v.CFrame))
		end
		if Recurse then
			TransformModel(v:GetChildren(), Center, NewCFrame, true)
		end
	end
end

function WeldTo(PrimaryPart, SecondaryPart)
	if not PrimaryPart or not SecondaryPart then
		return
	end
	local Weld = Instance.new("Weld")
	Weld.Name = "Weld"
	Weld.Part0 = PrimaryPart
	Weld.Part1 = SecondaryPart
	Weld.C0 = PrimaryPart.CFrame:inverse()
	Weld.C1 = SecondaryPart.CFrame:inverse()
	Weld.Parent = PrimaryPart
	return Weld
end

function CreateVine(Length)
	local VineModel = Instance.new("Model")
	VineModel.Name = "Vines"
	local Vine = BasePart:Clone()
	Vine.Name = "Vine"
	Vine.Size = Vector3.new(3, 2.4, 3)
	local VineMesh = Instance.new("SpecialMesh")
	VineMesh.MeshType = Enum.MeshType.FileMesh
	VineMesh.MeshId = "http://www.roblox.com/asset/?id=178186804"
	VineMesh.TextureId = "http://www.roblox.com/asset/?id=17585271"
	VineMesh.Scale = Vector3.new(2, 2, 2)
	VineMesh.VertexColor = Vector3.new(1, (math.random() / 2), 0)
	VineMesh.Parent = Vine
	for i = 1, Length do
		local VinePart = Vine:Clone()
		VinePart.Parent = VineModel
		VinePart.CFrame = VinePart.CFrame + Vector3.new(0, (VinePart.Size.Y * i), 0)
	end
	return VineModel
end

function Activated()
	if not Tool.Enabled or not Equipped then
		return
	end
	Tool.Enabled = false
	Active = true
	local SlashAnims = {Animations.LeftSlash, Animations.RightSlash}
	local SlashAnim = SlashAnims[math.random(1, #SlashAnims)]
	InvokeClient("PlayAnimation", SlashAnim)
	InvokeClient("PlaySound", Sounds.Slash)
	wait(SlashAnim.Duration)
	InvokeClient("StopAnimation", SlashAnim)
	Active = false
	Tool.Enabled = true
end

function Equipped(Mouse)
	Equipped = false
	Active = false
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	InvokeClient("PlaySound", Sounds.Unsheath)
	local EquipAnim = Animations.Equip
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	InvokeClient("PlayAnimation", EquipAnim)
	wait(EquipAnim.Duration)
	if CurrentlyEquipped then
		InvokeClient("StopAnimation", EquipAnim)
		Equipped = true
	end
end

function Unequipped()
	Equipped = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Animations) do
		if v and v.Parent then
			InvokeClient("StopAnimation", v)
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			InvokeClient("StopSound", v)
		end
	end
end

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)