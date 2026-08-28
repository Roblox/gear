--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

LightningFunctions = require(script:WaitForChild("LightningFunctions"))

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Gravity = 196.20
Rate = (1 / 60)

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

ManaBar = script:WaitForChild("ManaBar")

Animations = {
	Blast = {Animation = Tool:WaitForChild("Blast"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1.5, PauseAt = "Complete"},
	ArmsUp = {Animation = Tool:WaitForChild("ArmsUp"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
}

Sounds = {
	Lightning = Handle:WaitForChild("Lightning"),
	Lightning2 = Handle:WaitForChild("Lightning2"),
	Strike = Handle:WaitForChild("Strike"),
	Zap = Handle:WaitForChild("Zap"),
	
}

CurrentMana = Create("DoubleConstrainedValue"){
	MinValue = 0,
	MaxValue = 100,
}
CurrentMana.Value = (CurrentMana.MaxValue * 0.75)
ManaCharging = Create("BoolValue"){
	Value = false,
}

InUse = Create("BoolValue"){
	Value = false,
}
MouseDown = Create("BoolValue"){
	Value = false,
}
ToolEquipped = Create("BoolValue"){
	Value = false,
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function TakeDamage(humanoid, Damage)
	if not humanoid or not humanoid:IsA("Humanoid") or not Damage or not Player then
		return
	end
	local character = humanoid.Parent
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			return
		end
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		if IsTeamMate(Player, player) then
			return
		end
		CurrentMana.Value = (CurrentMana.Value + (CurrentMana.MaxValue * 0.02))
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function MakeCircle(Origin, Radius, Parts)
	local Circle = Create("Model"){
		Name = "Circle",
	}
	for i = 1, Parts do
		local Part = BasePart:Clone()
		Part.Name = "Effect"
		Part.Transparency = 1
		Part.Size = Vector3.new(6, 0.2, (Radius * 2))
		Part.Anchored = true
		Part.CanCollide = false
		Part.CFrame = (Origin * CFrame.Angles(0, ((math.pi * 2) / (Parts / i)), 0))
		Part.CFrame = (Part.CFrame + Part.CFrame.lookVector * (Radius / 2))
		Part.Parent = Circle
	end
	return Circle
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end
	
function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end
	
function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end
	
function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region
		local PossibleParts = GetTotalParts(MaxParts, 100, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
end

function GetNearbyObjects(Region)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return GetParts(Region, 500, IgnoreList)
end

function ManageMana(Gui)
	local Mana = {}
	if not Gui then
		return
	end
	local Frame = Gui:FindFirstChild("Frame")
	if not Frame then
		return
	end
	local Bar = Frame:FindFirstChild("Bar")
	if not Bar then
		return
	end
	local function AdjustBar()
		local ChargePercent = (GetPercentage(0, 100, CurrentMana.Value) * 0.01)
		local NewMana = Clamp((Frame.AbsoluteSize.X * ChargePercent), 0, Frame.AbsoluteSize.X)
		Bar.Size = (UDim2.new(Bar.Size.X.Scale, 0, Bar.Size.Y.Scale, Bar.Size.Y.Offset) + UDim2.new(0, NewMana, 0, 0))
	end
	for i, v in pairs({ToolUnequipped, ManaAltered}) do
		if v then
			v:disconnect()
		end
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	ManaAltered = CurrentMana.Changed:connect(function()
		AdjustBar()
	end)
	function Mana:UseMana(Amount)
		CurrentMana.Value = (CurrentMana.Value - Amount)
		if CurrentMana.Value < CurrentMana.MaxValue and not ManaCharging.Value then
			ManaCharging.Value = true
		end
	end
	AdjustBar()
	return Mana
end

function ChargeMana()
	--[[if not ManaCharging.Value then
		return
	end]]
	Spawn(function()
		local ChargeTimeRate = 0.15
		local ChargeRate = 1
		local ChargePercent = 0.005
		while --[[ManaCharging.Value and CurrentMana.Value < CurrentMana.MaxValue]]true do
			wait(ChargeTimeRate)
			--if not InUse.Value then
				CurrentMana.Value = (CurrentMana.Value + ((CurrentMana.MaxValue * ChargePercent) * ChargeRate))
			--end
		end
		--ManaCharging.Value = false
	end)
end

function CreateStaff(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	Handle.Transparency = ((CreateNew and 1) or 0)
	if not CreateNew then
		return
	end
	Staff = BasePart:Clone()
	Staff.Name = "Staff"
	Staff.Size = Vector3.new(0.5, 6, 0.5)
	Staff.CanCollide = false
	local Mesh = Create("SpecialMesh"){
		Name = "Mesh",
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "276091843"),
		TextureId = (BaseUrl .. "276091966"),
		Scale = Vector3.new(1, 1, 1),
		Parent = Staff,
	}
	GripPiece = Staff:Clone()
	GripPiece.Name = "GripPiece"
	GripPiece.Size = Vector3.new(0.5, 1.5, 0.5)
	GripPiece.Mesh.MeshId = (BaseUrl .. "276091878")
	Orb = Staff:Clone()
	Orb.Name = "Orb"
	Orb.Size = Vector3.new(0.2, 0.2, 0.2)
	Orb.Mesh.MeshId = (BaseUrl .. "276091920")
	local Joints = {
		{Class = "Weld", Parent = Staff, Properties = {Part0 = Handle, Part1 = Staff, C0 = CFrame.new(0, 0, 0), C1 = CFrame.new(0, 0, 0)}},
		{Class = "Weld", Parent = Staff, Properties = {Part0 = Staff, Part1 = GripPiece, C0 = CFrame.new(-0.05, 1.925, -0.0375), C1 = CFrame.new(0, 0, 0)}},
		{Class = "Motor6D", Parent = Staff, Properties = {Part0 = GripPiece, Part1 = Orb, MaxVelocity = 0.05, DesiredAngle = 99999999, C0 = CFrame.new(-0.0225, 0.3, 0.0275), C1 = CFrame.new(0, 0, 0)}},
	}
	for i, v in pairs(Joints) do
		local Joint = Create(v.Class){}
		for ii, vv in pairs(v.Properties) do
			Joint[ii] = vv
		end
		Joint.Parent = v.Parent
	end
	for i, v in pairs({Staff, GripPiece, Orb}) do
		v.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped.Value or MouseDown.Value or not CheckIfAlive() or InUse.Value then
		return
	end
	Tool.Enabled = false
	MouseDown.Value = true
	local CurrentlyEquipped = true
	local CurrentlyDown = true
	local ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local MouseButtonUp = MouseDown.Changed:connect(function()
		if not MouseDown.Value then
			CurrentlyDown = false
		end
	end)
	InUse.Value = true
	Sounds.Lightning:Play()
	Delay(0.25, (function()
		for i, v in pairs({ToolUnequipped, MouseButtonUp}) do
			if v then
				v:disconnect()
			end
		end
		if CurrentlyEquipped and CurrentlyDown and CheckIfAlive() then
			Sounds.Strike:Play()
		end
	end))
	local ManaCost = 2.5
	local MaxDuration = 5
	local StartTime = tick()
	local StrikeCount = 0
	local LightningDamage = 10
	local FireRate = 0.1
	local LightningReloadTime = 2
	while CheckIfAlive() and ToolEquipped.Value and MouseDown.Value and Orb.Parent --[[and (tick() - StartTime) <= MaxDuration]] and CurrentMana.Value >= ManaCost do
		StrikeCount = (StrikeCount + 1)
		if StrikeCount > 1 then
			ManaUsage:UseMana(ManaCost)
		end
		Sounds.Strike.Volume = (((math.sin(tick() * 3) + 1) * 0.25) + 0.25)
		local MousePosition = InvokeClient("MousePosition")
		if MousePosition then
			MousePosition = MousePosition.Position
			LightningFunctions.RemoveLightning()
			local RayData = LightningFunctions.Zap({StartPosition = Orb.Position, TargetPosition = MousePosition, Character = Character, Color = "Cyan", Individual = false})
			if RayData then
				local RayHit = RayData.RayHit
				if RayHit then
					local character = RayHit.Parent
					if character == Character then
						return
					end
					if character:IsA("Hat") then
						character = character.Parent
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid and humanoid.Health > 0 then
						local player = Players:GetPlayerFromCharacter(character)
						if not player or (player and not IsTeamMate(Player, player)) then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(LightningDamage)
						end
					end
				end
				Spawn(function()
					InvokeClient("SetMouse", {Property = "TargetFilter", Value = RayData.LightningModel})
				end)
			end
		end
		wait(FireRate)
	end
	InUse.Value = false
	Sounds.Strike:Stop()
	if StrikeCount > 1 then
		wait(LightningReloadTime)
	else
		wait(LightningReloadTime / 4)
	end
	Tool.Enabled = true
end

function ResetStuff()
	for i, v in pairs({ManaBarCopy, ManaAltered, ToolUnequipped}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v.Parent then
				v:Destroy()
			end
		end
	end
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	for i, v in pairs({InUse, MouseDown}) do
		v.Value = false
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		EquipTick = tick()
		ResetStuff()
		--[[if CurrentMana.Value >= (CurrentMana.MaxValue * 0.8) then
			CurrentMana.Value = (CurrentMana.MaxValue * 0.8)
		end]]
		CreateStaff(true)
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			ManaBarCopy = ManaBar:Clone()
			ManaUsage = ManageMana(ManaBarCopy)
			ManaBarCopy.Parent = PlayerGui
		end
	end)
	ToolEquipped.Value = true
end

function Unequipped()
	ResetStuff()
	CreateStaff(false)
	ToolEquipped.Value = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped.Value or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
		if not Down and MouseDown.Value then
			MouseDown.Value = false
		end
	elseif mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Down and Tool.Enabled and not InUse.Value then
			if Key == "z" then
				local ManaCost = 100
				if CurrentMana.Value < ManaCost or (tick() - EquipTick) < 5 then
					return
				end
				ManaUsage:UseMana(ManaCost)
				Tool.Enabled = false
				InUse.Value = true
				local PlayersNearby = {}
				for i, v in pairs(Players:GetChildren()) do
					if v:IsA("Player") and v ~= Player and not IsTeamMate(Player, v) and v.Character then
						local character = v.Character
						local ForceField = nil
						for i, v in pairs(character:GetChildren()) do
							if v:IsA("ForceField") then
								ForceField = v
								break
							end
						end
						if not ForceField then
							local torso = character:FindFirstChild("Torso")
							table.insert(PlayersNearby, v)
						end
					end
				end
				local ClosestPlayer = {Player = nil, Distance = 40}
				for i, v in pairs(PlayersNearby) do
					local character = v.Character
					local torso = character:FindFirstChild("Torso")
					if torso then
						local DistanceApart = (Torso.Position - torso.Position).Magnitude
						if DistanceApart < ClosestPlayer.Distance then
							ClosestPlayer.Player = character
							ClosestPlayer.Distance = DistanceApart
						end
					end
				end
				if not ClosestPlayer.Player then
					local HumanoidsHit = {}
					local NPCsNearby = {}
					local LightningRadius = ClosestPlayer.Distance
					local LightningRegion = Region3.new((Torso.Position - Vector3.new(LightningRadius, LightningRadius, LightningRadius)), (Torso.Position + Vector3.new(LightningRadius, LightningRadius, LightningRadius)))
					for i, v in pairs(GetNearbyObjects(LightningRegion)) do
						if v and v.Parent then
							local character = v.Parent
							if character ~= Character then
								local humanoid = character:FindFirstChild("Humanoid")
								if humanoid and humanoid.Health > 0 then
									local player = Players:GetPlayerFromCharacter(character)
									if not player then
										if not CheckTableForInstance(HumanoidsHit, humanoid) then
											local ForceField = nil
											for ii, vv in pairs(character:GetChildren()) do
												if vv:IsA("ForceField") then
													ForceField = vv
													break
												end
											end
											if not ForceField then
												table.insert(NPCsNearby, character)
											end
										end
									end
								end
							end
						end
					end
					for i, v in pairs(NPCsNearby) do
						local torso = v:FindFirstChild("Torso")
						if torso then
							local DistanceApart = (Torso.Position - torso.Position).Magnitude
							if DistanceApart < ClosestPlayer.Distance then
								ClosestPlayer.Player = v
								ClosestPlayer.Distance = DistanceApart
							end
						end
					end
				end
				if ClosestPlayer.Player then
					local character = ClosestPlayer.Player
					local humanoid = character:FindFirstChild("Humanoid")
					local torso = character:FindFirstChild("Torso")
					if humanoid and humanoid.Health > 0 and torso then
						local StartPosition = (CFrame.new(torso.Position) * CFrame.new(0, 50, 0))
						local TargetPosition = (StartPosition + Vector3.new(0, -1, 0) * 75)
						local RayData = LightningFunctions.Zap({StartPosition = StartPosition.p, TargetPosition = TargetPosition.p, Character = Character, Color = "Cyan", Individual = true, Duration = 2, TimeToFade = 1, MaxRange = 150, SegmentLength = 5, Ignore = {character}})
						for i = 1, 4 do
							Spawn(function()
								LightningFunctions.Zap({StartPosition = StartPosition.p, TargetPosition = TargetPosition.p, Character = Character, Color = "Cyan", Individual = true, Duration = 2, TimeToFade = 1, MaxRange = 150, SegmentLength = 5, Ignore = {character}})
							end)
						end
						if RayData then
							local RayPos = RayData.RayPos
							local SoundPart = BasePart:Clone()
							SoundPart.Name = "Effect"
							SoundPart.Transparency = 1
							SoundPart.CanCollide = false
							local Sound = Sounds.Lightning2:Clone()
							Sound.Parent = SoundPart
							Debris:AddItem(SoundPart, 2)
							SoundPart.Parent = game:GetService("Workspace")
							SoundPart.CFrame = CFrame.new(RayPos)
							Sound:Play()
							wait(0.1)
							for i = 1, math.random(10, 15) do
								local StartPosition = (CFrame.new(RayData.RayPos) * CFrame.new(0, 0, 0))
								local TargetPosition = (StartPosition + Vector3.new((math.random(-360, 360) * 0.01), 1, (math.random(-360, 360) * 0.01)) * 2)
								local Spark = LightningFunctions.Zap({StartPosition = StartPosition.p, TargetPosition = TargetPosition.p, Character = Character, Color = "Cyan", Individual = true, Duration = 1.9, TimeToFade = 0.9, MaxRange = (math.random(800, 1500) * 0.01), SegmentLength = (math.random(200, 1000) * 0.001), Ignore = {character}})
							end
						end
						TakeDamage(humanoid, 100)
					end
				end
				InUse.Value = false
				Tool.Enabled = true
			end
			if Key == "x" then
				local ManaCost = 25
				if CurrentMana.Value < ManaCost then
					return
				end
				ManaUsage:UseMana(ManaCost)
				Tool.Enabled = false
				InUse.Value = true
				Sounds.Zap:Play()
				local Animation = Animations.Spin
				Spawn(function()
					InvokeClient("StopAnimation", Animation)
					InvokeClient("PlayAnimation", Animation)
				end)
				Spawn(function()
					local Animation = Animations.ArmsUp
					InvokeClient("StopAnimation", Animation)
					InvokeClient("PlayAnimation", {Animation = Animation.Animation, FadeTime = Animation.FadeTime, Weight = Animation.Weight, Speed = 1.5})
				end)
				Spawn(function()
					local WaitTime = (Animation.Duration / 10)
					for i = 1, 10 do
						if not ToolEquipped or not CheckIfAlive() then
							return
						end
						local StartPosition = (Orb.CFrame * CFrame.new(0, 0, 0))
						local TargetPosition = (StartPosition * CFrame.new((math.random(-100, 100) * 0.01), 0, (math.random(-500, 500) * 0.01)))
						local RayData = LightningFunctions.Zap({StartPosition = StartPosition.p, TargetPosition = TargetPosition.p, Character = Character, Color = "Cyan", Individual = true, Duration = 2.5, MaxRange = 2, SegmentLength = 0.5})
						wait(WaitTime)
					end
				end)
				local HumanoidsHit = {}
				local LightningRadius = 6
				local LightningRegion = Region3.new((Torso.Position - Vector3.new(LightningRadius, LightningRadius, LightningRadius)), (Torso.Position + Vector3.new(LightningRadius, LightningRadius, LightningRadius)))
				for i, v in pairs(GetNearbyObjects(LightningRegion)) do
					if v and v.Parent then
						local character = v.Parent
						if character ~= Character then
							local humanoid = character:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 then
								local player = Players:GetPlayerFromCharacter(character)
								if not player or (player and not IsTeamMate(Player, player)) then
									if not CheckTableForInstance(HumanoidsHit, humanoid) then
										local ForceField = nil
										for ii, vv in pairs(character:GetChildren()) do
											if vv:IsA("ForceField") then
												ForceField = vv
												break
											end
										end
										if not ForceField then
											table.insert(HumanoidsHit, humanoid)
											TakeDamage(humanoid, 10)
											local torso = character:FindFirstChild("Torso")
											if torso then
												humanoid.Sit = true
												torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * 50)
											end
										end
									end
								end
							end
						end
					end
				end
				InUse.Value = false
				Tool.Enabled = true
			elseif Key == "q" then
				local ManaCost = 50
				if CurrentMana.Value < ManaCost then
					return
				end
				Spawn(function()
					InvokeClient("DisableMobility", {Disabled = true})
				end)
				local SpellDuration = 1
				ManaUsage:UseMana(ManaCost)
				Tool.Enabled = false
				InUse.Value = true
				local Animation = Animations.Blast
				Spawn(function()
					InvokeClient("StopAnimation", Animation)
					InvokeClient("PlayAnimation", Animation)
				end)
				wait(Animation.Duration)
				local TorsoCFrame = Torso.CFrame
				local StartPoint = (TorsoCFrame + TorsoCFrame.lookVector * -10)
				local DesiredPoint = (StartPoint + StartPoint.lookVector * 3)
				local Direction = CFrame.new(StartPoint.p, Vector3.new(DesiredPoint.X, StartPoint.Y, DesiredPoint.Z)).lookVector
				Spawn(function()
					local HumanoidsHit = {}
					local LightningRadius = 6
					for i = 1, 10 do
						if not ToolEquipped or not CheckIfAlive() then
							return
						end
						Spawn(function()
							local StartPosition = ((StartPoint * CFrame.new(0, 75, 0)) + Direction * i * 5)
							local TargetPosition = (StartPosition + Vector3.new(0, -1, 0) * 2)
							local RayData = LightningFunctions.Zap({StartPosition = StartPosition.p, TargetPosition = TargetPosition.p, Character = Character, Color = "Cyan", Individual = true, Duration = 2.5, TimeToFade = 1.5, MaxRange = 150, SegmentLength = 5})
							if RayData then
								local RayPos = RayData.RayPos
								local SoundPart = BasePart:Clone()
								SoundPart.Name = "Effect"
								SoundPart.Transparency = 1
								SoundPart.CanCollide = false
								local Sound = Sounds.Lightning:Clone()
								Sound.Parent = SoundPart
								Debris:AddItem(SoundPart, 2)
								SoundPart.Parent = game:GetService("Workspace")
								SoundPart.CFrame = CFrame.new(RayPos)
								Sound:Play()
								local LightningRegion = Region3.new((RayPos - Vector3.new(LightningRadius, LightningRadius, LightningRadius)), (RayPos + Vector3.new(LightningRadius, LightningRadius, LightningRadius)))
								for i, v in pairs(GetNearbyObjects(LightningRegion)) do
									if v and v.Parent then
										local character = v.Parent
										if character ~= Character then
											local humanoid = character:FindFirstChild("Humanoid")
											if humanoid and humanoid.Health > 0 then
												local player = Players:GetPlayerFromCharacter(character)
												if not player or (player and not IsTeamMate(Player, player)) then
													if not CheckTableForInstance(HumanoidsHit, humanoid) then
														local ForceField = nil
														for ii, vv in pairs(character:GetChildren()) do
															if vv:IsA("ForceField") then
																ForceField = vv
																break
															end
														end
														if not ForceField then
															table.insert(HumanoidsHit, humanoid)
															TakeDamage(humanoid, 40)
															local torso = character:FindFirstChild("Torso")
															if torso then
																humanoid.Sit = true
																torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * 10)
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end)
						wait(0.05)
					end
				end)
				wait(SpellDuration)
				Spawn(function()
					InvokeClient("StopAnimation", Animation)
				end)
				Spawn(function()
					InvokeClient("DisableMobility", {Disabled = false})
				end)
				InUse.Value = false
				Tool.Enabled = true
			elseif Key == "e" then
				local ManaCost = 75
				if CurrentMana.Value < ManaCost then
					return
				end
				Tool.Enabled = false
				InUse.Value = true
				ManaUsage:UseMana(ManaCost)
				local Animation = Animations.ArmsUp
				Spawn(function()
					InvokeClient("StopAnimation", Animation)
					InvokeClient("PlayAnimation", Animation)
				end)
				local LightningStrikeDamage = 40
				local MaxLightningStrikeDamage = 70
				local Strikes = {
					{NumberOfStrikes = 16, Radius = 14},
					{NumberOfStrikes = 8, Radius = 8},
					{NumberOfStrikes = 5, Radius = 5},
				}
				local HumanoidsHit = {}
				local LightningRadius = Strikes[1].Radius
				local LightningRegion = Region3.new((Torso.Position - Vector3.new(LightningRadius, LightningRadius, LightningRadius)), (Torso.Position + Vector3.new(LightningRadius, LightningRadius, LightningRadius)))
				local function DamageHumanoid(character)
					local HumanoidFound = false
					local DeterminedDamage = 0
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					for i, v in pairs(character:GetChildren()) do
						if v:IsA("ForceField") then
							return
						end
					end
					for i, v in pairs(HumanoidsHit) do
						if v and v.Humanoid == humanoid then
							HumanoidFound = true
							if v.DamageDealt < MaxLightningStrikeDamage then
								DeterminedDamage = (((v.DamageDealt + LightningStrikeDamage) <= MaxLightningStrikeDamage and LightningStrikeDamage) or (MaxLightningStrikeDamage - v.DamageDealt))
								v.DamageDealt = (v.DamageDealt + DeterminedDamage)
							end
							break
						end
					end
					if not HumanoidFound then
						table.insert(HumanoidsHit, {Humanoid = humanoid, DamageDealt = DeterminedDamage})
					end
					TakeDamage(humanoid, DeterminedDamage)
					humanoid.Sit = true
				end
				for i, v in pairs(GetNearbyObjects(LightningRegion)) do
					if v and v.Parent then
						local character = v.Parent
						if character ~= Character then
							local humanoid = character:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 then
								local player = Players:GetPlayerFromCharacter(character)
								if not player or (player and not IsTeamMate(Player, player)) then
									DamageHumanoid(character)
								end
							end
						end
					end
				end
				for i, v in pairs(Strikes) do
					local LightningPoints = MakeCircle((CFrame.new(Torso.Position) * CFrame.Angles(0, 0, 0)), v.Radius, v.NumberOfStrikes)
					for ii, vv in pairs(LightningPoints:GetChildren()) do
						if vv:IsA("BasePart") then
							Spawn(function()
								local StartPosition = (CFrame.new(vv.Position) * CFrame.new(0, 50, 0))
								local TargetPosition = (StartPosition + Vector3.new(0, -1, 0) * 75)
								local RayData = LightningFunctions.Zap({StartPosition = StartPosition.p, TargetPosition = TargetPosition.p, Character = Character, Color = "Cyan", Individual = true, Duration = 2.5, MaxRange = 150, SegmentLength = 5})
								if RayData then
									local RayPos = RayData.RayPos
									local SoundPart = BasePart:Clone()
									SoundPart.Name = "Effect"
									SoundPart.Transparency = 1
									SoundPart.CanCollide = false
									local Sound = Sounds.Lightning:Clone()
									Sound.Parent = SoundPart
									Debris:AddItem(SoundPart, 2)
									SoundPart.Parent = game:GetService("Workspace")
									SoundPart.CFrame = CFrame.new(RayPos)
									Sound:Play()
									local RayHit = RayData.RayHit
									if RayHit then
										local character = RayHit.Parent
										if character ~= Character then
											if character:IsA("Hat") then
												character = character.Parent
											end
											local humanoid = character:FindFirstChild("Humanoid")
											if humanoid and humanoid.Health > 0 then
												local player = Players:GetPlayerFromCharacter(character)
												if not player or (player and not IsTeamMate(Player, player)) then
													DamageHumanoid(character)
												end
											end
										end
									end
								end
							end)
						end
					end
					InUse.Value = false
					Tool.Enabled = true
				end
			end
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

--[[ManaCharging.Changed:connect(function()
	ChargeMana()
end)
ManaCharging.Value = true]]
ChargeMana()

CreateStaff(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)