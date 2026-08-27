--Made by Luckymaxer

Tool = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.SmoothNoOutlines,
	BottomSurface = Enum.SurfaceType.SmoothNoOutlines,
	FrontSurface = Enum.SurfaceType.SmoothNoOutlines,
	BackSurface = Enum.SurfaceType.SmoothNoOutlines,
	LeftSurface = Enum.SurfaceType.SmoothNoOutlines,
	RightSurface = Enum.SurfaceType.SmoothNoOutlines,
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

LightningRadius = 60

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

function GetLightning()

	local function LightningStrike(Source, Destination)
		local MaxSegLength = 7
		local MinSegLength = 3
		local MaxOffset = 4
		local Direction = (Destination - Source).unit
		local Distance = (Source - Destination).magnitude
		
		local Points = {}	
		Points[1] = Source
		local LastDist = 0
		
		while (Distance - LastDist) > MaxSegLength do
			LastDist = (LastDist + ((math.random() * (MaxSegLength - MinSegLength)) + MinSegLength))
			local NewVector = (Source + (LastDist * Direction) + Vector3.new(math.random(), math.random(), math.random()))
			table.insert(Points, NewVector)
			wait(Rate)
		end	
		table.insert(Points, Destination)
		
		local Parts = {}
		
		local LightningModel = Create("Model"){
			Name = "LightningModel",
		}
		Debris:AddItem(LightningModel, 3)
		LightningModel.Parent = game:GetService("Workspace")	
		
		for i, v in pairs(Points) do
			local LastPart = BasePart:Clone()
			LastPart.BrickColor = BrickColor.new("Hot pink")
			LastPart.Transparency = 0.3
			LastPart.Anchored = true
			LastPart.CanCollide = false
			for i, v in pairs({"Front", "Back", "Left", "Right", "Top", "Bottom"}) do
				local Light = Instance.new("SurfaceLight")
				Light.Face = Enum.NormalId[v]
				Light.Range = 4
				Light.Brightness = 100
				Light.Color = LastPart.BrickColor.Color
				Light.Enabled = true
				Light.Parent = LastPart
			end
			local Mesh = Create("CylinderMesh"){
				Scale = Vector3.new(0.5, 1, 0.5),
				Parent = LastPart,
			}
			if Points[i + 1] then		
				LastPart.Size = Vector3.new(0.5, (v - Points[i + 1]).magnitude, 0.5)
				LastPart.CFrame = CFrame.new(((v + Points[i + 1]) / 2), Points[i + 1]) * CFrame.Angles((math.pi / 2), 0, 0)
				Debris:AddItem(LastPart, 1)
				LastPart.Parent = LightningModel
				wait(Rate)
			end
		end
	end
	
	local function DoLightning(Position, HitPlayers, Player)
		local humanoids = GetPlayersNearby(Player, Position, LightningRadius)
		for i, v in pairs(humanoids) do
			local character = v.Parent
			local torso = character:FindFirstChild("Torso")
			if v and v.Health > 0 and torso then
				Spawn(function()
					LightningStrike(Position, torso.Position)
				end)
				HitPlayers[character] = true
				v:TakeDamage(100)
				DoLightning(Position, HitPlayers, Player)
				return true
			end
		end
		return false
	end
	
	local function Strike(Table)
		if not Table then
			return
		end
		local Position = Table.Position
		local Player = Table.Player
		if not Position or not Player then
			return
		end
		local HitPlayers = {}
		--if not DoLightning(Position, HitPlayers, Player) then
			for i = 1, math.random(8, 25), 1 do	
				Spawn(function()
					LightningStrike(Position, (Position + (Vector3.new(((math.random() - 0.5) * 2), ((math.random() - 0.5) * 2),((math.random() - 0.5) * 2)) * 45)))
				end)
			end
		--end
	end
	
	return {
		LightningStrike = LightningStrike,
		DoLightning = DoLightning,
		Strike = Strike,
	}

end

return GetLightning