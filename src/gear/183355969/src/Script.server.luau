--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	LeftPunch = {Animation = Tool:WaitForChild("LeftPunch"), FadeTime = nil, Weight = nil, Speed = 6, Duration = 0.25},
	RightPunch = {Animation = Tool:WaitForChild("RightPunch"), FadeTime = nil, Weight = nil, Speed = 6, Duration = 0.25},
	ClapPunch = {Animation = Tool:WaitForChild("ClapPunch"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = nil},
	FistPunch = {Animation = Tool:WaitForChild("FistPunch"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.5},
	GroundPunch = {Animation = Tool:WaitForChild("GroundPunch"), FadeTime = nil, Weight = nil, Speed = 4, Duration = nil},
}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Smash = Handle:WaitForChild("Smash"),
	Hit = Handle:WaitForChild("Hit"),
	ShockWave = Handle:WaitForChild("ShockWave")
}

SpecialAttacks = {
	Enabled = true,
	Active = false,
	ReloadTime = 5,
	GroundSmash = {
		Radius = 20,
		Damage = 40,
		ReloadTime = 45,
		Enabled = true,
		Active = false
	},
	ShockWave = {
		Radius = 30,
		Damage = 1,
		ReloadTime = 10,
		Enabled = true,
		Active = false
	}
}

Damage = {
	Hit = 5,
	Punch = 15,
	Crush = 50
}

Equipped = false

Clicks = 0
FirstClick = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" and ((LeftFist and LeftFist.Parent) and (RightFist and RightFist.Parent)) and SpecialAttacks.Enabled and not SpecialAttacks.Active then
			local Key = Value.Key
			local Down = Value.Down
			local SpecialAttack = nil
			if Key == "q" and Down then
				SpecialAttack = SpecialAttacks.GroundSmash
				if SpecialAttack.Enabled and not SpecialAttack.Active then
					
					SpecialAttacks.Enabled = false
					SpecialAttacks.Active = true
					
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
					
					local Animation = Animations.GroundPunch
					InvokeClient("PlayAnimation", Animation)
					
					local CurrentlyEquipped = true
					ToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
					end)
					
					wait(0.5)
					
					local RayHit, RayPos
					if CurrentlyEquipped then
						Sounds.Smash:Play()
						RayHit, RayPos = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
						if RayHit then
							local Parts = {}
							local Parts1 = MakeCircle(10, 30, Vector3.new(6, 6, 6), RayPos)
							local Parts2 = MakeCircle(8, 30, Vector3.new(2, 2, 2), RayPos)
							local Parts3 = MakeCircle(6, 30, Vector3.new(4, 4, 4), RayPos)
							local BoulderModel = Instance.new("Model")
							BoulderModel.Name = "BoulderModel"
							for i, v in pairs({Parts1, Parts2, Parts3}) do
								for ii, vv in pairs(v) do
									table.insert(Parts, vv)
								end
							end
							local BoulderConnections = {}
							for i, v in pairs(Parts) do
								local RayHit1, RayPos1 = RayCast(Vector3.new(v.Position.X, Torso.Position.Y, v.Position.Z), Vector3.new(0, -1, 0), (v.Size.Y * 2), {Character, BoulderModel})
								if RayHit1 then
									v.BrickColor = BrickColor.new("Bright orange")
									v.Material = Enum.Material.Granite
									v.Anchored = true
									v.Parent = BoulderModel
									v.CFrame = v.CFrame * CFrame.Angles(math.random(), math.random(),math.random())
									local BoulderTouched = v.Touched:connect(function(Hit)
										if not Hit or not Hit.Parent then
											return
										end
										local character = Hit.Parent
										if character:IsA("Hat") or character:IsA("Tool") then
											character = character.Parent
										end
										if character == Character then
											return
										end
										local humanoid = character:FindFirstChild("Humanoid")
										local torso = character:FindFirstChild("Torso")
										if not humanoid or humanoid.Health == 0 or not torso then
											return
										end
										UntagHumanoid(humanoid)
										TagHumanoid(humanoid, Player)
										humanoid:TakeDamage(SpecialAttack.Damage)
										humanoid.Sit = true
										torso.Velocity = CFrame.new(torso.Position, v.Position).lookVector * math.random(75, 150)
									end)
									table.insert(BoulderConnections, BoulderTouched)
								end
								Delay(0.5, function()
									for i, v in pairs(BoulderConnections) do
										if v then
											v:disconnect()
										end
									end
								end)
							end
							if #BoulderModel:GetChildren() > 0 then
								Debris:AddItem(BoulderModel, 15)
								BoulderModel.Parent = game:GetService("Workspace")
							end
						end
					end
					if ToolUnequipped then
						ToolUnequipped:disconnect()
					end
					SpecialAttack.Active = false
					SpecialAttacks.Active = false
					
					Delay(((RayHit and SpecialAttack.ReloadTime) or 0), function()
						SpecialAttack.Enabled = true
					end)
					
				end
			elseif Key == "e" and Down then
				SpecialAttack = SpecialAttacks.ShockWave
				if SpecialAttack.Enabled and not SpecialAttack.Active then
					SpecialAttacks.Enabled = false
					SpecialAttacks.Active = true
					
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
					
					local Animation = Animations.ClapPunch
					InvokeClient("PlayAnimation", Animation)
					
					local CurrentlyEquipped = true
					ToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
					end)
					
					wait(0.6)
					
					if CurrentlyEquipped then
						
						local ShockWave = BasePart:Clone()
						ShockWave.Name = "ShockWave"
						ShockWave.Transparency = 1
						ShockWave.Size = Vector3.new(0.2, 4, 0.2)
						ShockWave.Anchored = true
						ShockWave.CanCollide = false
						local Mesh = Instance.new("SpecialMesh")
						Mesh.MeshType = Enum.MeshType.Brick
						Mesh.Scale = Vector3.new(1, 0, 1)
						Mesh.Parent = ShockWave
						local ShockWaveTransparency = 0.125
						for i = 1, 2 do
							local Decal = Instance.new("Decal")
							Decal.Texture = "http://www.roblox.com/asset?id=183210124"
							Decal.Transparency = ShockWaveTransparency
							Decal.Face = ((i == 1 and Enum.NormalId.Top) or Enum.NormalId.Bottom)
							Decal.Parent = ShockWave
						end
						
						local ShockWaveCFrame = CFrame.new(Handle.Position) * CFrame.Angles(math.pi, 0, 0)
						
						Debris:AddItem(ShockWave, 5)
						
						Sounds.ShockWave:Play()
						
						ShockWave.Parent = game:GetService("Workspace")
						ShockWave.CFrame = CFrame.new(Handle.Position)
						
						ShockWave.Touched:connect(function(Hit)		
							if not Hit or not Hit.Parent then
								return
							end
							local character = Hit.Parent
							if character:IsA("Hat") or character:IsA("Tool") then
								character = character.Parent
							end
							if character == Character then
								return
							end
							local humanoid = character:FindFirstChild("Humanoid")
							local torso = character:FindFirstChild("Torso")
							if not humanoid or humanoid.Health == 0 or not torso then
								return
							end
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(SpecialAttack.Damage)
							humanoid.Sit = true
							local PushBack = CFrame.new(torso.Position, ShockWave.Position).lookVector * -50
							PushBack = Vector3.new(PushBack.X, -math.random(10, 50), PushBack.Z)
							torso.Velocity = PushBack
						end)				
						
						local Transparency = (1 - ShockWaveTransparency)
						for i = 1, 25 do
							if ShockWave and ShockWave.Parent then
								local RadiusSize = ((SpecialAttack.Radius / 25) * i)
								for ii, vv in pairs(ShockWave:GetChildren()) do
									if vv:IsA("Decal") then
										vv.Transparency = ((Transparency / 25) * i)
									end
								end
								ShockWave.Size = Vector3.new(RadiusSize, ShockWave.Size.Y, RadiusSize)
								ShockWave.CFrame = ShockWaveCFrame
							end
							wait(0.025)
						end
						if ShockWave and ShockWave.Parent then
							ShockWave:Destroy()
						end
					end
					if ToolUnequipped then
						ToolUnequipped:disconnect()
					end
					
					SpecialAttack.Active = false
					SpecialAttacks.Active = false
					
					Delay(SpecialAttack.ReloadTime, function()
						SpecialAttack.Enabled = true
					end)
					
				end
			end
			if SpecialAttack then
				wait(SpecialAttacks.ReloadTime)
				SpecialAttacks.Enabled = true
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function MakeCircle(Diameter, Consistency, Size, Position)
	local Parts = {}
	for i = 1, 360, Consistency do
		local Part = BasePart:Clone()
		Part.Size = Size
		Part.CFrame = CFrame.new(Position) * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, Diameter)
		table.insert(Parts, Part)
	end
	return Parts
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

function Activated()
	if not Tool.Enabled or not Equipped or SpecialAttacks.Active then
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
		if (not (LeftFist and LeftFist.Parent) and not (RightFist and RightFist.Parent)) then
			return
		end
		Tool.Enabled = false
		local SingleClickAnims = {}
		local DoubleClickAnims = {}
		local PunchSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
		for i, v in pairs({LeftFist, RightFist}) do
			if v and v.Parent then
				if v == LeftFist then
					table.insert(SingleClickAnims, Animations.LeftPunch)
				elseif v == RightFist then
					table.insert(SingleClickAnims, Animations.RightPunch)
				end
			end
		end
		if ((LeftFist and LeftFist.Parent) and (RightFist and RightFist.Parent)) then
			table.insert(DoubleClickAnims, Animations.FistPunch)
		end
		PunchSounds[math.random(1, #PunchSounds)]:Play()
		AnimationChosen = (((Clicks < 2 or #DoubleClickAnims == 0) and SingleClickAnims[math.random(1, #SingleClickAnims)]) or DoubleClickAnims[math.random(1, #DoubleClickAnims)])
		local FistConnections = {}
		local CharactersHit = {}
		for i, v in pairs({LeftFist, RightFist}) do
			if v and v.Parent then
				local FistTouched = v.Touched:connect(function(Hit)		
					if not Hit or not Hit.Parent then
						return
					end
					local character = Hit.Parent
					if character:IsA("Hat") or character:IsA("Tool") then
						character = character.Parent
					end
					if character == Character or CheckTableForInstance(CharactersHit, character) then
						return
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					local DamageAmount = 0
					if AnimationChosen == Animations.FistPunch then
						local LeftFistHit, LeftFistPos = RayCast(LeftFist.Position, (LeftFist.CFrame * CFrame.Angles(0, (math.pi / 2), 0)).lookVector, (LeftFist.Size.X * 2), {Character})
						local RightFistHit, RightFistPos = RayCast(RightFist.Position, (RightFist.CFrame * CFrame.Angles(0, -(math.pi / 2), 0)).lookVector, (RightFist.Size.X * 2), {Character})
						if ((LeftFistHit and LeftFistHit.Parent) and (RightFistHit and RightFistHit.Parent)) then
							local LeftHit = LeftFistHit.Parent
							local RightHit = RightFistHit.Parent
							LeftHit = (((LeftHit:IsA("Hat") or LeftHit:IsA("Tool")) and LeftHit.Parent) or LeftHit)
							RightHit = (((RightHit:IsA("Hat") or RightHit:IsA("Tool")) and RightHit.Parent) or RightHit)
							if LeftHit == character and RightHit == character then
								if LeftHit.Parent and LeftHit == character and RightHit.Parent and RightHit == character then
									DamageAmount = Damage.Crush
								end
							end
						end
					elseif ((AnimationChosen == Animations.LeftPunch and v == LeftFist) or (AnimationChosen == Animations.RightPunch and v == RightFist)) then
						DamageAmount = Damage.Punch
					end
					Sounds.Hit:Play()
					table.insert(CharactersHit, character)
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(DamageAmount)
				end)	
				table.insert(FistConnections, FistTouched)	
			end
		end
		Delay(1, function()
			for i, v in pairs(FistConnections) do
				if v then
					v:disconnect()
				end
			end
		end)
		InvokeClient("PlayAnimation", AnimationChosen)
		wait(AnimationChosen.Duration)
		AnimationChosen = nil
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function EquipFists()
	local Fist = BasePart:Clone()
	Fist.Name = "Fist"
	Fist.Transparency = 0
	Fist.Size = Vector3.new(1.5, 1.6, 1.5)
	Fist.CanCollide = true
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshId = "http://www.roblox.com/asset?id=181205091"
	Mesh.TextureId = "http://www.roblox.com/asset?id=181205268"
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.Scale = Vector3.new(1, 1, 1)
	Mesh.Parent = Fist
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	if LeftArm then
		LeftFist = Fist:Clone()
		LeftFist.Name = "LeftFist"
		local Weld = Instance.new("Weld")
		Weld.Part0 = LeftArm
		Weld.Part1 = LeftFist
		Weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Weld.C1 = CFrame.new(-0.150000006, 0.5, 0, -1, 0, 0, 0, 7.20990921e-013, 1, 0, 1, -7.20990921e-013)
		Weld.Parent = LeftFist
		LeftFist.Parent = Tool
	end
	if RightArm then
		RightFist = Fist:Clone()
		RightFist.Name = "RightFist"
		local Weld = Instance.new("Weld")
		Weld.Part0 = RightArm
		Weld.Part1 = RightFist
		Weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Weld.C1 = CFrame.new(-0.150000006, 0.5, 0, -1, 0, 0, 0, 7.20990921e-013, 1, 0, 1, -7.20990921e-013)
		Weld.Parent = RightFist
		RightFist.Parent = Tool
	end
	for i, v in pairs({LeftFist, RightFist}) do
		if v and v.Parent then
			v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				local character = Hit.Parent
				if character:IsA("Hat") or character:IsA("Tool") then
					character = character.Parent
				end
				if character == Character then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or humanoid.Health == 0 then
					return
				end
				if not AnimationChosen or ((AnimationChosen == Animations.LeftPunch and v ~= LeftFist) or (AnimationChosen == Animations.RightPunch and v ~= RightFist)) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage.Hit)
				end
			end)
		end
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
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
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	InvokeClient("PlayAnimation", Animations.Equip)
	Handle.Transparency = 1
	Spawn(function()
		EquipFists()
	end)
	Equipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({LeftFist, RightFist}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Handle.Transparency = 0
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	Equipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)