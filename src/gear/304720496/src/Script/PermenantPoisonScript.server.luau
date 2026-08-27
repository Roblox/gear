--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

ZombieScript = script:FindFirstChild("ZombieScript")
if ZombieScript then
	ZombieModule = require(ZombieScript)
end

Values = {}

Destroyed = false

Player = Players:GetPlayerFromCharacter(Character)

for i, v in pairs(script:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Value")) then
		Values[v.Name] = v
	end
end

function DestroyScript()
	if Destroyed then
		return
	end
	Destroyed = true
	Debris:AddItem(script, 1)
end

function GetCreator()
	local CreatorValue = Values.Creator.Value
	return (((CreatorValue and CreatorValue.Parent and CreatorValue:IsA("Player")) and CreatorValue) or nil)
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

if not Values.Creator or not Values.Damage or not Values.Delay then
	DestroyScript()
	return
end

if Humanoid.MaxHealth > 0 then
	Humanoid.MaxHealth = (Humanoid.MaxHealth * 0.75)
end

DesiredSpeed = 10
DesiredHealth = 75
Zombified = false

while Humanoid and Humanoid.Health > 0 do
	local Creator = GetCreator()
	if Humanoid.WalkSpeed > DesiredSpeed then
		Humanoid.WalkSpeed = DesiredSpeed
	end
	if Humanoid.MaxHealth > DesiredHealth then
		Humanoid.MaxHealth = DesiredHealth
	end
	if not Player or (not Creator or (Creator and Player and not IsTeamMate(Creator, Player))) then
		UntagHumanoid(Humanoid)
		TagHumanoid(Humanoid, Creator)
		--Humanoid:TakeDamage(Values.Damage.Value)
		if ZombieModule and Humanoid.Health <= 0 then
			Zombified = true
			ZombieModule.Zombify(Creator, Character, true)
			break
		end
	end
	wait(Values.Delay.Value)
end
if Humanoid.Health == 0 then
	if not Zombified then
		local Creator = GetCreator()
		ZombieModule.Zombify(Creator, Character)
	end
end

DestroyScript()