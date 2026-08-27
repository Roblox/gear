--Made by Luckymaxer

Projectile = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Projectile:WaitForChild("Creator")
Damage = Projectile:WaitForChild("Damage")
RemovalTime = Projectile:FindFirstChild("RemovalTime")

DeathEffect = script:WaitForChild("DeathEffect")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

Rate = (1 / 60)

IgnoreHit = false

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

function ApplyDeathEffect(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local DeathEffectCopy = character:FindFirstChild(DeathEffect.Name)
	if DeathEffectCopy then
		return
	end
	DeathEffectCopy = DeathEffect:Clone()
	DeathEffectCopy.Disabled = false
	DeathEffectCopy.Parent = character
end

function Disappear()
	IgnoreHit = true
	Projectile.Name = "Effect"
	Projectile.Transparency = 1
	Projectile.Anchored = true
	Projectile.CanCollide = false
	for i, v in pairs(Projectile:GetChildren()) do
		if v:IsA("Light") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
end

function Touched(Hit)
	if not Hit or not Hit.Parent or Hit.Name == Projectile.Name or Hit.Name == "Effect" or IgnoreHit then
		return
	end
	local Player = Creator.Value
	if not Player or not Player:IsA("Player") then
		return
	end
	local Character = Player.Character
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player == Player then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		if not IsTeamMate(Player, player) and humanoid.Health > 0 then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage.Value)
			if humanoid.Health <= 0 then
				ApplyDeathEffect(character)
			end
		end
	end
	IgnoreHit = true
	if Projectile and Projectile.Parent then
		Disappear()
	end
end

if RemovalTime then
	Delay(RemovalTime.Value, (function()
		Disappear()
	end))
end

Projectile.Touched:connect(Touched)