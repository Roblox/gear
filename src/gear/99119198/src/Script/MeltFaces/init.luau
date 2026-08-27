--Rescripted by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

MeltFaceScript = script:WaitForChild("MeltFaceScript")

Rate = (1 / 60)

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetPlayersNearby(Player, Position, Radius)
	local NegativeRegion = (Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Position + Vector3.new(Radius, Radius, Radius))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local IgnoreList = {((Player and Player.Character) or nil)}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	local Parts = GetParts(Region, 500, IgnoreList)
	local Humanoids = {}
	for i, v in pairs(Parts) do
		local character = v.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if humanoid and humanoid.Health > 0 and torso and not CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end

function InitializeMelting(Table)
	if not Table then
		return
	end
	
	local Melting = false
	local MashMeter = 0
	
	local Tool = Table.Tool
	local MaxDistance = Table.MaxDistance
	if not MaxDistance or not Tool then
		return
	end
	local Handle = Tool:FindFirstChild("Handle")
	if not Handle then
		return
	end
	
	local Player = nil
	
	local function MeltFace(Figure)
		local humanoid = Figure:FindFirstChild("Humanoid")
		local head = Figure:FindFirstChild("Head")
		if not humanoid or humanoid.Health == 0 or not head then
			return
		end
		local Face
		for i, v in pairs(head:GetChildren()) do
			if v:IsA("Decal") and (string.lower(v.Name) == string.lower("Face") or v.Face == Enum.NormalId.Front) then
				Face = v
				break
			end
		end
		if not Face then
			return
		end
		local MeltFaceScriptCopy = Figure:FindFirstChild(MeltFaceScript.Name)
		if MeltFaceScriptCopy then
			return
		end
		MeltFaceScriptCopy = MeltFaceScript:Clone()
		MeltFaceScriptCopy.Disabled = false
		MeltFaceScriptCopy.Parent = Figure
	end
	
	local function MeltNearbyFaces()
		local PlayersNearby = GetPlayersNearby(Player, Handle.Position, MaxDistance)
		for i, v in pairs(PlayersNearby) do
			local humanoid = v
			local character = v.Parent
			if humanoid and humanoid.Health > 0 and character then
				MeltFace(character)
			end
		end
	end
	
	local function BeginMelting()
		if Melting or not Player then
			return
		end
		Melting = true
		Spawn(function()
			while Melting and Player do
				if MashMeter > 0 then
					MashMeter = (MashMeter - Rate)
				end
				if MashMeter > 9 then
					MeltNearbyFaces()
					wait(5)
					MashMeter = 0
				end
				wait(Rate)
			end
		end)
	end
	
	local function StopMelting()
		Melting = false
	end
	
	local function IncreaseMashMeter()
		MashMeter = (MashMeter + 1)
	end
	
	local function SetPlayer(player)
		Player = player
		if Player then
			BeginMelting()
		else
			StopMelting()
		end
	end
	
	return {
		MeltNearbyFaces = MeltNearbyFaces,
		BeginMelting = BeginMelting,
		StopMelting = StopMelting,
		IncreaseMashMeter = IncreaseMashMeter,
		SetPlayer = SetPlayer,
	}

end

return {
	InitializeMelting = InitializeMelting,
}