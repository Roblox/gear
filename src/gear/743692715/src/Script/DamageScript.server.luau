Weight = script.Parent
Pole = Weight:WaitForChild("Pole")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = script:WaitForChild("Creator")
Damage = script:WaitForChild("Damage")

Sounds = {
	HitGround = Pole:WaitForChild("HitGround")
}

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

function GetCreator()
	local Player = (((Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
	local Character = (((Player and Player.Character and Player.Character.Parent) and Player.Character) or nil)
	return Player, Character
end

function Blow(Hit)
	if not Hit or not Hit.Parent or Pole.Velocity.magnitude < 5 then
		return
	end
	local character = Hit.Parent
	if character:IsA("Accessory") then
		character = character.Parent
	end
	local CreatorPlayer, CreatorCharacter = GetCreator()
	if character == CreatorCharacter then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		Sounds.HitGround:Play()
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (CreatorPlayer and IsTeamMate(CreatorPlayer, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage.Value)
end

for i, v in pairs(Weight:GetChildren()) do
	if v:IsA("BasePart") then
		Delay(0.125, function()
			v.CanCollide = true
		end)
		v.Touched:connect(Blow)
	end
end