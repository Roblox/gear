--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Functions = require(script:WaitForChild("Functions"))

Creator = Part:WaitForChild("Creator")
Damage = Part:WaitForChild("Damage")

Sounds = {
	Hit = Part:WaitForChild("Hit"),
	HitGround = Part:WaitForChild("HitGround"),
}

AlreadyHit = false

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

Part.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or AlreadyHit or Hit.Name == Part.Name then
		return
	end
	local CreatorPlayer = GetCreator()
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local player = Players:GetPlayerFromCharacter(character)
		if player and player == CreatorPlayer then
			return
		end
		if player and CreatorPlayer and Functions.IsTeamMate(CreatorPlayer, player) then
		else
			Functions.UntagHumanoid(humanoid)
			if CreatorPlayer then
				Functions.TagHumanoid(humanoid, CreatorPlayer)
			end
			humanoid:TakeDamage(Damage.Value)
		end
		Sounds.Hit:Play()
	else
		Sounds.HitGround:Play()
	end
	AlreadyHit = true
end)