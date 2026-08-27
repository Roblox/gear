--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = script:WaitForChild("Creator").Value
Duration = script:WaitForChild("Duration").Value
Damage = script:WaitForChild("Damage").Value

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

wait(Duration)

if Humanoid and Humanoid.Health > 0 then
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid, Creator)
	local CurrentHealth = Humanoid.Health
	Humanoid:TakeDamage(Damage)
	if (CurrentHealth - Damage) <= 0 then
		Humanoid:TakeDamage(math.huge)
		local Explosion = Instance.new("Explosion")
		Explosion.ExplosionType = Enum.ExplosionType.NoCraters
		Explosion.BlastRadius = 15
		Explosion.BlastPressure = 0
		Explosion.Position = Character:GetModelCFrame().p
		Explosion.Parent = game:GetService("Workspace")
	end
	Debris:AddItem(script, 1)
end