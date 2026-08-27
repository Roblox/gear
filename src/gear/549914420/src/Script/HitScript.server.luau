--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Part:WaitForChild("Creator")
Damage = Part:WaitForChild("Damage")

FlyingSound = Part:FindFirstChild("Flying")
if FlyingSound then
	FlyingSound:Play()
end

function GetCreator()
	return (((Creator and Creator.Parent and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

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

function Blow(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local CreatorPlayer = GetCreator()
	if not CreatorPlayer then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == CreatorPlayer or IsTeamMate(CreatorPlayer, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage.Value)
end

Part.Touched:connect(Blow)