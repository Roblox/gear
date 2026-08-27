--Rescripted by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Part:WaitForChild("Creator")

Sounds = {
	Hit = Part:WaitForChild("Hit"),
	PersonHit = Part:WaitForChild("PersonHit")
}

Damage = 10

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

function Touched(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	local HasForceField = false
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			HasForceField = true
		end
	end
	local HitSuccess = false
	local humanoid = character:FindFirstChild("Humanoid")
	if not HasForceField and humanoid and humanoid.Health > 0 then
		local CreatorPlayer = (((Creator and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
		local player = Players:GetPlayerFromCharacter(character)
		if CreatorPlayer and player and (CreatorPlayer == player or IsTeamMate(CreatorPlayer, player)) then
			return
		end
		HitSuccess = true
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, CreatorPlayer)
		humanoid:TakeDamage(Damage)
	end
	Sounds[((HitSuccess and "PersonHit") or "Hit")]:Play()
	Part:Destroy()
end

Part.Touched:connect(Touched)

Debris:AddItem(Part, 5)