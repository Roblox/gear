--Rescripted by Luckymaxer
--Updated for R15 avatars by StarWars

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Head = Character:FindFirstChild("Head")
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

Count = script:FindFirstChild("GrapeTroubleCountdown")

Sounds = {
	Hyper = script:WaitForChild("Hyper"),
	Explosion = script:WaitForChild("Explosion"),
}

function DestroyScript()
	Debris:AddItem(script, 0.5)
	script:Destroy()
end

if not Head or not Humanoid or Humanoid.Health == 0 or not Player or not Count or Count.Value <= 0 then
	DestroyScript()
	return
end

function GrapeMe()
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Clothing") then
			v:Destroy()
		elseif v:IsA("BasePart") then
			v.Material = Enum.Material.Ice
			v.BrickColor = BrickColor.new("Magenta")
		end
	end
end



function UpdateUI(timeleft)
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	local GrapeGui = PlayerGui:FindFirstChild("GrapeGUI")
	GrapeGui.Frame.Frame.Time.Text = (timeleft .. " seconds")
	if (timeleft < 10) then
		GrapeGui.Frame.Frame.Warning.TextColor = BrickColor.new("Really red")
		if (timeleft % 2 == 1) then
			GrapeGui.Frame.Frame.Warning.Text = "WARNING"
		else
			GrapeGui.Frame.Frame.Warning.Text = "MindGrapes on FIRE!!!"
		end
	else
		GrapeGui.Frame.Frame.Warning.TextColor = BrickColor.new("Hot pink")
		GrapeGui.Frame.Frame.Warning.Text = "MindGrapes Ok..."
	end
end

Humanoid.WalkSpeed = (16 * 2)
Humanoid.MaxHealth = (100 * 0.25)


HyperSound = Sounds.Hyper:Clone()
HyperSound.Parent = Head
HyperSound:Play()

GrapeMe()

Played = false

while true do
	Count.Value = (Count.Value - 1)
	if Count.Value < 0 then
		ExplosionSound = Sounds.Explosion:Clone()
		ExplosionSound.Parent = Head
		ExplosionSound:Play()
			
		local Explosion = Instance.new("Explosion")
		Explosion.ExplosionType = Enum.ExplosionType.NoCraters
		Explosion.BlastRadius = 2
		Explosion.BlastPressure = 1000000
		Explosion.Position = Torso.Position
		Explosion.Parent = game:GetService("Workspace")
	else
		if (not HyperSound.IsPlaying and not Played) then
			HyperSound:Play()
			Played = true
		end
		UpdateUI(Count.Value)
	end

	wait(1)
end