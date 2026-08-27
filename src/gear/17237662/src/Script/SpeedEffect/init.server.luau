--Rescripted by Luckymaxer
--Updated for R15 avatars by StarWars

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Head = Character:FindFirstChild("Head")
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

Sounds = {
	Explosion = script:WaitForChild("Explosion"),
}

function DestroyScript()
	Debris:AddItem(script, 0.5)
	script:Destroy()
end

if not Head or not Torso or not Humanoid or Humanoid.Health == 0 or not Player then
	DestroyScript()
	return
end

Duration = 30

Humanoid.WalkSpeed = (16 * 1.6)

Sparkles = Instance.new("Sparkles")
Sparkles.SparkleColor = Color3.new(0.8, 0, 0.8)
Sparkles.Enabled = true
Debris:AddItem(Sparkles, Duration)
Sparkles.Parent = Torso

Count = script:FindFirstChild("CoffeeCount")
if not Count then
	Count = Instance.new("IntValue")
	Count.Name = "CoffeeCount"
	Count.Value = 1
	Count.Parent = script
else
	if (Count.Value > 3) then
		if (math.random() > 0.5) then

			ExplosionSound = Sounds.Explosion:Clone()
			Debris:AddItem(ExplosionSound, 5)
			ExplosionSound.Parent = Head
			ExplosionSound:Play()

			local Explosion = Instance.new("Explosion")
			Explosion.ExplosionType = Enum.ExplosionType.NoCraters
			Explosion.BlastRadius = 2
			Explosion.BlastPressure = 1000000
			Explosion.Position = Torso.Position
			Explosion.Parent = game:GetService("Workspace")
			
		end
	end
	Count.Value = (Count.Value + 1)
end

wait(Duration)

Humanoid.WalkSpeed = 16

DestroyScript()