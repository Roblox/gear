--Made by Luckymaxer

FireBall = script.Parent
Fire = FireBall:WaitForChild("Fire")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

ParticleScript = script:WaitForChild("ParticleScript")

Creator = script:WaitForChild("Creator")

Damage = 25

HitDebounce = false

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

function Blow(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (Creator.Value and Creator.Value:IsA("Player") and (player == Creator.Value or IsTeamMate(Creator.Value, player))) then
		return
	end
	HitDebounce = true
	local HealthAfter = (humanoid.Health - Damage)
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Creator.Value)
	humanoid:TakeDamage(Damage)
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and not v:FindFirstChild("Fire") then
			local FireParticle = Fire:Clone()
			FireParticle.Name = "Fire"
			FireParticle.Enabled = true
			local ParticleScriptCopy = ParticleScript:Clone()
			local Duration = Create("NumberValue"){
				Name = "Duration",
				Value = 3,
				Parent = ParticleScriptCopy,
			}
			ParticleScriptCopy.Disabled = false
			ParticleScriptCopy.Parent = FireParticle
			Debris:AddItem(FireParticle, 6)
			FireParticle.Parent = v
		end
	end
	if HealthAfter <= 0 then
	end
	FireBall.Anchored = true
	Fire.Enabled = false
	Debris:AddItem(FireBall, 2)
end

FireBall.Touched:connect(Blow)