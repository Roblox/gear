--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Player = Players:GetPlayerFromCharacter(Character)

Fire = script:WaitForChild("Fire")

Creator = script:FindFirstChild("Creator")

Removing = false
Flames = {}

function DestroyScript()
	if Removing then
		return
	end
	Removing = true
	if Humanoid then
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs(Flames) do
		v.Enabled = false
		Debris:AddItem(v, 2)
	end
	Debris:AddItem(script, 1)
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

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

CreatorPlayer = GetCreator()

if not Humanoid or Humanoid.Health == 0 or not CreatorPlayer then
	DestroyScript()
	return
end

Humanoid.WalkSpeed = 8

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		local Flame = Fire:Clone()
		Flame.Enabled = true
		table.insert(Flames, Flame)
		Flame.Parent = v
	end
end

for i = 1, 5 do
	wait(1.5)
	if not Player or (Player and not IsTeamMate(Player, CreatorPlayer)) then
		UntagHumanoid(Humanoid)
		TagHumanoid(Humanoid, Player)
		Humanoid:TakeDamage(5)
	end
end

DestroyScript()