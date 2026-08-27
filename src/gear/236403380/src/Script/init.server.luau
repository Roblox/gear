--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

CameraShake = script:WaitForChild("CameraShake")
TripScript = script:WaitForChild("TripScript")

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

ShockWave = BasePart:Clone()
ShockWave.Name = "ShockWave"
ShockWave.Transparency = 1
ShockWave.Size = Vector3.new(0.2, 4, 0.2)
ShockWave.Anchored = true
ShockWave.CanCollide = false
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Brick
Mesh.Scale = Vector3.new(1, 0, 1)
Mesh.Parent = ShockWave
for i = 1, 2 do
	local Decal = Instance.new("Decal")
	Decal.Texture = "http://www.roblox.com/asset?id=183210124"
	Decal.Transparency = 0.125
	Decal.Face = ((i == 1 and Enum.NormalId.Top) or Enum.NormalId.Bottom)
	Decal.Parent = ShockWave
end

Animations = {
	Blow = {Animation = Tool:WaitForChild("Blow"), FadeTime = 0.75, Weight = nil, Speed = 0.5, Duration = 1},
	R15Blow = {Animation = Tool:WaitForChild("R15Blow"), FadeTime = 0.75, Weight = nil, Speed = 0.5, Duration = 1},
}

Sounds = {
	Horn = Handle:WaitForChild("Horn"),
	Earthquake = Handle:WaitForChild("Earthquake"),
	RockFall = Handle:WaitForChild("RockFall"),
}

ToolEquipped = false
ReloadTime = 12

Gravity = 196.20
Rate = (1 / 60)

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

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
		local PossibleParts = GetTotalParts(MaxParts, 3000, #Parts)
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

function Shake()
	local UserPlayer = Player
	local UserCharacter = Character
	local IgnoreObjects = {UserCharacter, Tool}
	local Radius = 45
	local ShakeForce = {Min = 5, Max = 10}
	local Objects = {}
	local Humanoids = {}
	local PlayersNearby = {}
	local NegativeRadius = (Torso.Position - Vector3.new(Radius, (Torso.Size.Y * 1.25), Radius))
	local PositiveRadius = (Torso.Position + Vector3.new(Radius, (Radius / 6), Radius))
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= UserPlayer then
			local character = v.Character
			if character and character.Parent then
				table.insert(IgnoreObjects, v)
				if not IsTeamMate(v, UserPlayer) then
					local humanoid = character:FindFirstChild("Humanoid")
					local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
					if humanoid and humanoid.Health > 0 and (Torso.Position - torso.Position).magnitude <= Radius then
						table.insert(Humanoids, humanoid)
					end
				end
			end
		end
	end
	local Parts = GetParts(Region3.new(NegativeRadius, PositiveRadius), 500, IgnoreObjects)
	for i, v in pairs(Parts) do
		if v and v.Parent and not CheckTableForInstance(Objects, v) then
			local character = v.Parent
			if character:IsA("Hat") or character:IsA("Tool") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local player = Players:GetPlayerFromCharacter(character)
			if not CheckTableForInstance(Humanoids, humanoid) and not CheckTableForInstance(PlayersNearby, character) then
				if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
					table.insert(Humanoids, humanoid)
					if player and not CheckTableForInstance(PlayersNearby, player) then
						table.insert(PlayersNearby, player)
					end
				elseif (Torso.Position - v.Position).magnitude <= Radius then
					table.insert(Objects, v)
				end
			end
		end
	end
	for i, v in pairs(Objects) do
		if v and v.Parent then
			if not v:IsGrounded() then
				if v:GetMass() <= 80 then
					local ConnectedParts = #v:GetConnectedParts()
					if v.Velocity.magnitude < 20 and ConnectedParts == 1 then
						local Velocity = Vector3.new(math.random(-math.random(ShakeForce.Min, ShakeForce.Max), math.random(ShakeForce.Min, ShakeForce.Max)), v.Velocity.Y, math.random(-math.random(ShakeForce.Min, ShakeForce.Max), math.random(ShakeForce.Min, ShakeForce.Max)))
						Velocity = Vector3.new(Velocity.X, v.Velocity.Y, Velocity.Z)
						v.Velocity = Velocity
					end
					if ConnectedParts > 0 then
						local ChanceToBreak = math.random(1, 1000)
						if ChanceToBreak == 1 then
							v:BreakJoints()
						end
					end
				end
			end
		end
	end
	for i, v in pairs(Humanoids) do
		local character = v.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			local PlayerGui = player:FindFirstChild("PlayerGui")
			if PlayerGui then
				local CameraShakeClone = PlayerGui:FindFirstChild(CameraShake.Name)
				if not CameraShakeClone then
					CameraShakeClone = CameraShake:Clone()
					CameraShakeClone.Disabled = false
					Debris:AddItem(CameraShakeClone, 3)
					CameraShakeClone.Parent = PlayerGui
				end
			end
		end
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if torso then
			if (Torso.Position - torso.Position).magnitude <= 25 then
				if player then
					local TripScriptClone = character:FindFirstChild(TripScript.Name)
					if not TripScriptClone then
						TripScriptClone = TripScript:Clone()
						TripScriptClone.Disabled = false
						Debris:AddItem(TripScriptClone, 0.5)
						TripScriptClone.Parent = character
						v.Sit = true
					end
				elseif not v.Sit then
					v.Sit = true
				end
				Spawn(function()
					UntagHumanoid(v)
					TagHumanoid(v, UserPlayer)
					v:TakeDamage(0.7)
				end)
			end
		end
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
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
	local SoundLength = 8
	local Duration = (SoundLength + 7)
	local Animation = Animations.Blow
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Blow
	end
	Spawn(function()
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(SoundLength)
		Spawn(function()
			if Humanoid then
				if Humanoid.RigType == Enum.HumanoidRigType.R6 then
					InvokeClient("StopAnimation", {Animation = Animations.Blow.Animation, FadeTime = 0.5})
				elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
					InvokeClient("StopAnimation", {Animation = Animations.R15Blow.Animation, FadeTime = 0.5})
				end
			end
		end)
	end)
	wait(Animation.Duration)
	Sounds.Horn:Play()
	Sounds.Earthquake:Play()
	Spawn(function()
		local PushBack = 50
		local ShockWaves = {0, 3, 3}
		local DesiredRadius = 50
		for i, v in pairs(ShockWaves) do
			wait(v)
			if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			local ShockWaveClone = ShockWave:Clone()
			local OriginalCFrame = CFrame.new(Torso.Position)
			ShockWaveClone.CFrame = OriginalCFrame
			ShockWaveClone.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				local character = Hit.Parent
				if character:IsA("Hat") then
					character = character.Parent
				end
				local player = Players:GetPlayerFromCharacter(character)
				if player and (player == Player or IsTeamMate(Player, player)) then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or humanoid.Health == 0 then
					return
				end
				local torso = character:FindFirstChild("Torso") or character:FindFIrstChild("UpperTorso")
				if torso then
					torso.Velocity = CFrame.new(torso.Position, Torso.Position).lookVector * -PushBack
				end
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(3)
				humanoid.Sit = true
			end)
			Debris:AddItem(ShockWaveClone, 5)
			ShockWaveClone.Parent = game:GetService("Workspace")
			Spawn(function()
				local ResizeRate = 25
				for i = 1, ResizeRate do
					local ShockWaveSize = ((DesiredRadius / 25) * i)
					for ii, vv in pairs(ShockWaveClone:GetChildren()) do
						if vv:IsA("Decal") then
							vv.Transparency = ((1 * i) / ResizeRate)
						end
					end
					ShockWaveClone.Size = Vector3.new(ShockWaveSize, ShockWave.Size.Y, ShockWaveSize)
					ShockWaveClone.CFrame = OriginalCFrame
					Sounds.RockFall:Play()
					wait(Rate)
				end
				if ShockWaveClone and ShockWaveClone.Parent then
					ShockWaveClone:Destroy()
				end
			end)
		end
	end)
	local StartTick = tick()
	while (tick() - StartTick) <= Duration and ToolEquipped and CurrentlyEquipped and CheckIfAlive() do
		Spawn(Shake)
		wait(Rate)
	end
	Sounds.Earthquake:Stop()
	wait(ReloadTime)
	Tool.Enabled = true
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
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
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

--[[ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end)]]

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)