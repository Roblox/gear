--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Goldify = script:WaitForChild("Goldify")

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

Orb = BasePart:Clone()
Orb.Name = "Earth"
Orb.Size = Vector3.new(1.5, 1.5, 1.5)
OrbMesh = Instance.new("SpecialMesh")
OrbMesh.MeshType = Enum.MeshType.FileMesh
OrbMesh.MeshId = (BaseUrl .. "230850974")
OrbMesh.TextureId = (BaseUrl .. "261464028")
OrbMesh.Scale = Vector3.new(0.75, 0.75, 0.75)
OrbMesh.VertexColor = Vector3.new(1, 1, 1)
OrbMesh.Parent = Orb

Sounds = {
	LightningSound = Handle:WaitForChild("LightningSound"),
}

ToolEquipped = false

Damage = 40
ReloadTime = 10

Gravity = 196.20
Rate = (1 / 60)

ProjectileNames = {"Lightning", "Lava", "Magma"}

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

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:IsA("Hat") or Hit.Parent:IsA("Tool") then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function LightningStrike(Source, Destination)
	local MaxSegLength = 15
	local MinSegLength = 3
	local MaxOffset = 4
	local LastDistance = 0
	local Points = {Source}
	local Direction = (Destination - Source).unit
	local Distance = (Source - Destination).magnitude
	
	while (Distance - LastDistance) > MaxSegLength do
		LastDistance = (LastDistance + ((math.random() * (MaxSegLength - MinSegLength)) + MinSegLength))
		local NewVector = (Source + (LastDistance * Direction) + Vector3.new(math.random(), math.random(), math.random()))
		table.insert(Points, NewVector)
		wait(Rate)
	end	
	table.insert(Points, Destination)
	
	local Parts = {}
	
	local LightningModel = Instance.new("Model")
	LightningModel.Name = "LightningModel"
	Debris:AddItem(LightningModel, 5)
	LightningModel.Parent = game:GetService("Workspace")	
	
	local ObjectHit
	for Index, i in pairs(Points) do
		local LastPart = BasePart:Clone()
		LastPart.BrickColor = BrickColor.new("Light grey metallic")
		LastPart.Material = Enum.Material.Plastic
		for i, v in pairs({"Top", "Bottom", "Left", "Right", "Front", "Back"}) do
			LastPart[v .. "Surface"] = Enum.SurfaceType.SmoothNoOutlines
		end
		LastPart.Reflectance = 0.25
		LastPart.Transparency = 0.3
		LastPart.Anchored = true
		LastPart.CanCollide = false
		local Mesh = Instance.new("CylinderMesh")
		Mesh.Scale = Vector3.new(1, 1, 1)
		Mesh.Parent = LastPart
		if Points[Index + 1] then		
			LastPart.Size = Vector3.new(0.5, (i - Points[Index + 1]).magnitude, 0.5)
			LastPart.CFrame = CFrame.new(((i + Points[Index + 1]) / 2), Points[Index + 1]) * CFrame.Angles((math.pi / 2), 0, 0)
			local RayHit, RayPos, RayNormal = CastRay(LastPart.Position, CFrame.new((LastPart.CFrame * CFrame.new(0, (LastPart.Size.Y / 2), 0)).p, (LastPart.CFrame * CFrame.new(0, 1, 0)).p).lookVector, LastPart.Size.Y, {Character, LightningModel}, false)
			Debris:AddItem(LastPart, 1)
			LastPart.Parent = LightningModel
			local FadeRate = 15
			Spawn(function()
				for i = 1, FadeRate do
					LastPart.Transparency = ((1 / FadeRate) * i)
					wait(Rate)
				end
			end)
			if RayHit then
				ObjectHit = RayHit
				break
			end
			wait(Rate)
		end
	end
	
	return ObjectHit
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

function CastMagma(character)
	if not OrbClone or not OrbClone.Parent then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	Spawn(function()
		local ObjectHit = LightningStrike(OrbClone.Position, torso.Position)
		if ObjectHit then
			local HitCharacter = ObjectHit.Parent
			if HitCharacter:IsA("Hat") then
				HitCharacter = HitCharacter.Parent
			end
			local HitHumanoid = HitCharacter:FindFirstChild("Humanoid")
			if not HitHumanoid or HitHumanoid.Health == 0 or HitHumanoid ~= humanoid then
				return
			end
			for i, v in pairs(HitCharacter:GetChildren()) do
				local Fire = Instance.new("Fire")
				Fire.Color = Color3.new((170 / 255), (170 / 255), (125 / 255))
				Fire.SecondaryColor = Fire.Color
				Delay(1.5, (function()
					Fire.Enabled = false
				end))
				Debris:AddItem(Fire, 2)
				Fire.Parent = v
			end
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("ForceField") then
					return
				end
			end
			local HealthAfter = (humanoid.Health - Damage)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			if HealthAfter <= 0 then
				local GoldifyScript = Goldify:Clone()
				GoldifyScript.Disabled = false
				GoldifyScript.Parent = character
				humanoid:TakeDamage(humanoid.Health)
			else
				humanoid:TakeDamage(Damage)
				--humanoid.Sit = true
			end
		end
	end)
end

function GetPlayersNearby(Radius)
	local NegativeRegion = (Torso.Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Torso.Position + Vector3.new(Radius, Radius, Radius))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local IgnoreList = {Character}
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
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if humanoid and humanoid.Health > 0 and torso and not CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end 

function OrbitPlayer()
	local Duration = 35
	local StartTick = tick()
	local LastStrike = 0
	local StrikeDelay = {Min = 1.25, Max = 2, Current = 0}
	local OrbitRadius = 7
	while OrbClone and OrbClone.Parent and ToolEquipped and CheckIfAlive() and (tick() - StartTick) <= Duration do
		local Frames = 45
		local FullAngle = (math.pi * 2)
		for i = 1, Frames do
			if not OrbClone or not OrbClone.Parent or not ToolEquipped or not CheckIfAlive() then
				return
			end
			local Angle = ((FullAngle / Frames) * i)
			OrbClone.CFrame = ((CFrame.new(Torso.Position) + (CFrame.new(Torso.Position) * CFrame.Angles(0, Angle, 0)) .lookVector * OrbitRadius) * CFrame.Angles(0, -Angle, -Angle))
			if (tick() - LastStrike) >= StrikeDelay.Current then
				StrikeDelay.Current = (math.random((StrikeDelay.Min * 1000), (StrikeDelay.Max * 1000)) * 0.001)
				local Humanoids = GetPlayersNearby(15)
				if #Humanoids > 0 then
					LastStrike = tick()
					Sounds.LightningSound:Play()
					for i, v in pairs(Humanoids) do
						if v and v.Health > 0 and v.Parent then
							local character = v.Parent
							CastMagma(character)
						end
					end
				end
			end
			wait()
		end
	end
	if OrbClone and OrbClone.Parent then
		OrbClone:Destroy()
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
	if not Tool.Enabled or not ToolEquipped and (not OrbClone or not OrbClone.Parent) then
		return
	end
	Tool.Enabled = false
	OrbClone = Orb:Clone()
	Handle.Transparency = 1
	OrbClone.Parent = Character
	OrbClone.Anchored = true
	OrbitPlayer()
	wait(ReloadTime)
	Handle.Transparency = 0
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
	if OrbClone and OrbClone.Parent then
		OrbClone:Destroy()
	end
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent)) and ((Tool.Enabled and 0) or 1)) or 0)
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)