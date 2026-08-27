--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Part:WaitForChild("Creator")
Damage = Part:WaitForChild("Damage")

Sounds = {
	Hit = Part:WaitForChild("Hit"),
}

AlreadyHit = false

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = player
	Debris:AddItem(CreatorTag, 2)
	CreatorTag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

Part.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or AlreadyHit or Part.Velocity.Magnitude < 5 then
		return
	end
	local CreatorPlayer = GetCreator()
	local Character = Hit.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid or Humanoid.Health == 0 then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player and (Player == CreatorPlayer or IsTeamMate(CreatorPlayer, Player)) then
		return
	end
	AlreadyHit = true
	UntagHumanoid(Humanoid)
	if CreatorPlayer then
		TagHumanoid(Humanoid, CreatorPlayer)
	end
	Humanoid:TakeDamage(Damage.Value)
	Sounds.Hit:Play()
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
	Part.Velocity = (Part.Velocity * 0.15)
end)