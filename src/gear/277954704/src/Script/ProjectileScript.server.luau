--Made by Luckymaxer

Projectile = script.Parent
Fire = Projectile:FindFirstChild("Fire")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Projectile:WaitForChild("Creator")
Origin = Projectile:WaitForChild("Origin").Value
TargetPosition = Projectile:WaitForChild("TargetPosition").Value
Direction = Projectile:WaitForChild("Direction").Value
Speed = Projectile:WaitForChild("Speed").Value
Damage = Projectile:WaitForChild("Damage").Value

Sounds = {
	Explode = Projectile:WaitForChild("Explode")
}

TotalDist = (TargetPosition - Origin).magnitude
FlightTime = (TotalDist / Speed)
Exploded = false

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

function Explode()
	if Exploded then
		return
	end
	Exploded = true
	Projectile.Transparency = 1
	Projectile.Anchored = true
	Projectile.CanCollide = false
	if Fire then
		Fire.Enabled = false
	end
	local Explosion = Create("Explosion"){
		ExplosionType = Enum.ExplosionType.NoCraters,
		BlastPressure = 0,
		BlastRadius = 4,
		Position = Projectile.Position,
	}
	local HitHumanoids = {}
	Explosion.Hit:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local NonLethalExplosion = false
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local CreatorPlayer = Creator.Value
		local CreatorCharacter = CreatorPlayer.Character
		if CreatorPlayer:IsA("Player") and CreatorPlayer.Character and CreatorPlayer.Character.Parent then
			CreatorCharacter = CreatorPlayer.Character
		end
		if character == CreatorCharacter then
			NonLethalExplosion = true
			return
		end
		local creator = character:FindFirstChild("Creator")
		if creator and creator.Value and creator.Value == Creator.Value then
			NonLethalExplosion = true
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 or HitHumanoids[humanoid] then
			NonLethalExplosion = true
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and IsTeamMate(Creator.Value, player) then
			NonLethalExplosion = true
			return
		end
		if not NonLethalExplosion then
			HitHumanoids[humanoid] = true
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Creator.Value)
			humanoid:TakeDamage(Damage)
		end
	end)
	Explosion.Parent = game:GetService("Workspace")
	Sounds.Explode:Play()
	Debris:AddItem(Explosion, 2)
	Debris:AddItem(Projectile, 2)
end

Projectile.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	Explode()
end)	

local AheadVector = (Direction.unit * TotalDist)
local FlightVector = (TargetPosition - Origin)

Spawn(function()
	while Projectile and Projectile.Parent and (Projectile.Position - TargetPosition).magnitude > 1 do
		wait()
	end
	Explode()
end)