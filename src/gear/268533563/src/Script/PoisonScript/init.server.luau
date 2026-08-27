--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Creator = script:FindFirstChild("Creator")
Damage = script:FindFirstChild("Damage")
Duration = script:FindFirstChild("Duration")

Particles = script:FindFirstChild("Particles")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Player = Players:GetPlayerFromCharacter(Character)

ParticlesUsed = {}

function DestroyScript()
	Debris:AddItem(script, 0.5)
	script:Destroy()
end

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

if not Humanoid or Humanoid.Health == 0 or not Creator or not Creator.Value or not Creator.Value.Parent or not Creator.Value:IsA("Player") or not Damage or not Duration then
	DestroyScript()
	return
end

if Particles then
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			local Particle = Particles:Clone()
			Particle.Enabled = true
			table.insert(ParticlesUsed, Particle)
			Particle.Parent = v
		end
	end
end

DamageRate = (Damage.Value / Duration.Value)
DamageValue = (Damage.Value / DamageRate)
DelayRate = (Duration.Value / Damage.Value)
for i = 1, math.ceil(DamageRate) do
	if (Creator.Value and Creator.Value:IsA("Player") and Player and IsTeamMate(Creator.Value, Player)) or Humanoid.Health <= 0 then
	else
		UntagHumanoid(Humanoid)
		TagHumanoid(Humanoid, Creator.Value)
		Humanoid:TakeDamage(DamageValue)
	end
	wait(DelayRate)
end

Delay((Duration.Value - 2), (function()
	for i, v in pairs(ParticlesUsed) do
		if v and v.Parent then
			v.Enabled = false
		end
	end
end))

wait(Duration.Value)

DestroyScript()