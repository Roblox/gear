--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

Sounds = {
	Strike = Part:WaitForChild("Strike"),
}

Creator = Part:FindFirstChild("Creator")
Damage = Part:WaitForChild("Damage")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

Rate = (1 / 60)

HitDelay = false

function GetCreator()
	return (((Creator and Creator.Parent and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function LightningStrike(Source, Destination)
	local SegLength = {Min = 0.5, Max = 3}
	local LastDistance = 0
	local Points = {Source}
	local Direction = (Destination - Source).Unit
	local Distance = (Source - Destination).Magnitude
	
	local CreatorPlayer = GetCreator()
	
	while (Distance - LastDistance) > SegLength.Max do
		LastDistance = (LastDistance + ((math.random() * (SegLength.Max - SegLength.Min)) + SegLength.Max))
		local NewVector = (Source + (LastDistance * Direction) + Vector3.new(math.random(), math.random(), math.random()))
		table.insert(Points, NewVector)
		--wait(Rate)
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
		LastPart.Name = "Effect"
		LastPart.BrickColor = Part.BrickColor
		LastPart.Material = Part.Material
		LastPart.Transparency = Part.Transparency
		LastPart.Anchored = true
		LastPart.CanCollide = false
		local Mesh = Instance.new("BlockMesh")
		Mesh.Scale = Vector3.new(0.75, 1, 0.75)
		Mesh.Parent = LastPart
		if Points[Index + 1] then
			local RayDistance = (i - Points[Index + 1]).Magnitude
			LastPart.Size = Vector3.new(0.5, RayDistance, 0.5)
			LastPart.CFrame = CFrame.new(((i + Points[Index + 1]) / 2), Points[Index + 1]) * CFrame.Angles((math.pi / 2), 0, 0)
			local RayHit, RayPos, RayNormal = Functions.CastRay(LastPart.Position, CFrame.new((LastPart.CFrame * CFrame.new(0, (LastPart.Size.Y / 2), 0)).p, (LastPart.CFrame * CFrame.new(0, 1, 0)).p).lookVector, RayDistance, {((CreatorPlayer and CreatorPlayer.Character) or nil), LightningModel}, false)
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

function CastLightning(character)
	local CreatorPlayer = GetCreator()
	if not CreatorPlayer then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	Spawn(function()
		local ObjectHit = LightningStrike(Part.Position, torso.Position)
		if ObjectHit then
			local HitCharacter = ObjectHit.Parent
			if HitCharacter:IsA("Hat") then
				HitCharacter = HitCharacter.Parent
			end
			local HitHumanoid = HitCharacter:FindFirstChild("Humanoid")
			if not HitHumanoid or HitHumanoid.Health == 0 or HitHumanoid ~= humanoid then
				return
			end
			Functions.UntagHumanoid(humanoid)
			Functions.TagHumanoid(humanoid, CreatorPlayer)
			humanoid:TakeDamage(Damage.Value)
			local TripChance = math.random(1, 6)
			if TripChance == 1 then
				humanoid.Sit = true
				torso.Velocity = (CFrame.new(Part.Position, torso.Position).lookVector * 50)
			end
		end
	end)
end

function GetPlayersNearby(Radius)
	local Humanoids = {}
	local CreatorPlayer = GetCreator()
	if CreatorPlayer then
		local NegativeRegion = (Part.Position - Vector3.new(Radius, Radius, Radius))
		local PositiveRegion = (Part.Position + Vector3.new(Radius, Radius, Radius))
		local Region = Region3.new(NegativeRegion, PositiveRegion)
		local IgnoreList = {((CreatorPlayer and CreatorPlayer.Character) or nil)}
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") and v ~= CreatorPlayer and v.Character and v.Character.Parent and Functions.IsTeamMate(CreatorPlayer, v) then
				table.insert(IgnoreList, v.Character)
			end
		end
		local Parts = Functions.GetParts(Region, 500, IgnoreList)
		for i, v in pairs(Parts) do
			local character = v.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if humanoid and humanoid.Health > 0 and torso and not Functions.CheckTableForInstance(Humanoids, humanoid) then
				table.insert(Humanoids, humanoid)
			end
		end
	end
	return Humanoids
end

function PartHit(Hit)
	local CreatorPlayer = GetCreator()
	if not Hit or not Hit.Parent or not CreatorPlayer or HitDelay or Part.Velocity.Magnitude < 8 then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (CreatorPlayer == player or Functions.IsTeamMate(CreatorPlayer, player)) then
		return
	end
	HitDelay = true
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage((Damage.Value * 2.5))
	wait(0.2)
	HitDelay = false
end

Duration = 35
StartTick = tick()
LastStrike = 0
StrikeDelay = 0.2
ShootRadius = 15

Spawn(function()
	while true do
		if (tick() - LastStrike) >= StrikeDelay then
			local Humanoids = GetPlayersNearby(ShootRadius)
			if #Humanoids > 0 then
				LastStrike = tick()
				Sounds.Strike:Play()
				for i, v in pairs(Humanoids) do
					if v and v.Health > 0 and v.Parent then
						local character = v.Parent
						local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
						if torso then
							local Facing = ((Part.Position - torso.Position).Unit + Part.Velocity.Unit).Magnitude
							if Facing <= 1.5 then
								CastLightning(character)
							end
						end
					end
				end
			end
		end
		wait(Rate)
	end
end)

Part.Touched:connect(PartHit)