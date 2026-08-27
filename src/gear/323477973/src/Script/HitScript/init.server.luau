--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Part:WaitForChild("Creator")
Damage = Part:WaitForChild("Damage")
PushStrength = Part:WaitForChild("PushStrength")
FadeDelay = Part:WaitForChild("FadeDelay")

Functions = require(script:WaitForChild("Functions"))

Sounds = {
	Hit = Part:WaitForChild("Hit")
}

function GetCreator()
	return (((Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function Blow(Object)
	local HitDebounce = false
	local TouchedConnection = Object.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Object.Transparency >= 1 then
			return
		end
		local CreatorPlayer = GetCreator()
		local character = Hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and CreatorPlayer and (CreatorPlayer == player or Functions.IsTeamMate(CreatorPlayer, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		if not HitDebounce then
			HitDebounce = true
			local Sound = Sounds.Hit
			Sound.Pitch = (math.random(500, 1500) * 0.001)
			Sound:Play()
			Functions.UntagHumanoid(humanoid)
			if CreatorPlayer then
				Functions.TagHumanoid(humanoid, CreatorPlayer)
			end
			humanoid:TakeDamage(Damage.Value)
			Delay(1, (function()
				HitDebounce = false
			end))
		end
		if PushStrength.Value > 0 then
			local torso = character:FindFirstChild("Torso")
			if torso then
				local PushDirection = CFrame.new(Object.Position, torso.Position).lookVector
				torso.Velocity = (PushDirection * PushStrength.Value)
			end
			local SitChance = math.random()
			if SitChance >= 0.5 then
				humanoid.Sit = true
			end
		end
	end)
	return TouchedConnection
end

Delay(FadeDelay.Value, (function()
	local TimeToFade = 0.75
	local FadeRate = 0.05
	local OrigTransparency = Part.Transparency
	for i = 1, (TimeToFade / FadeRate) do
		wait(FadeRate)
		Part.Transparency = (OrigTransparency + (i / (TimeToFade / FadeRate)))
	end
	Part.Name = "Effect"
	Part.Anchored = true
	Part.Transparency = 1
	Part.CanCollide = false
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
	Debris:AddItem(Part, 1.5)
end))

Blow(Part)