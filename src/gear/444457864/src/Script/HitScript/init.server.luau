--Made by Luckymaxer

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
Radius = Part:WaitForChild("Radius")

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
			local torso = character:FindFirstChild("Torso")
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
	for i, v in pairs(PlayersHit) do
		if v == character then
			return
		end
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (CreatorPlayer == player or Functions.IsTeamMate(CreatorPlayer, player)) then
		return
	end
	table.insert(PlayersHit, character)
	--HitDelay = true
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage.Value)
	wait(0.2)
	for i, v in pairs(PlayersHit) do
		if v == character then
			table.remove(PlayersHit, i)
		end
	end
	--HitDelay = false
end

StartTick = tick()
PlayersHit = {}
LastStrike = 0
StrikeDelay = 0.2

Spawn(function()
	while true do
		if (tick() - LastStrike) >= StrikeDelay then
			local Humanoids = GetPlayersNearby(Radius.Value)
			if #Humanoids > 0 then
				LastStrike = tick()
				Sounds.Strike:Play()
				for i, v in pairs(Humanoids) do
					if v and v.Health > 0 and v.Parent then
						local character = v.Parent
						local torso = character:FindFirstChild("HumanoidRootPart")
						if torso then
							local Facing = ((Part.Position - torso.Position).Unit + Part.Velocity.Unit).Magnitude
							if Facing <= 1.5 then
								PartHit(torso)
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