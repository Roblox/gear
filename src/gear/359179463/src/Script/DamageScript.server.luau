--Made by Luckymaxer

Figure = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Damage = Figure:WaitForChild("Damage")

Creator = Figure:WaitForChild("Creator")
Animate = Figure:FindFirstChild("Animate")

HitDelay = false

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

function TakeDamage(humanoid, Damage)
	local CreatorPlayer = GetCreator()
	if not humanoid or not humanoid:IsA("Humanoid") or not Damage or not CreatorPlayer then
		return
	end
	local character = humanoid.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == CreatorPlayer or IsTeamMate(CreatorPlayer, player)) then
		return
	end
	if Animate then
		local Pose = Animate:FindFirstChild("Pose")
		if Pose then
			Pose.Value = "Attacking"
			Delay(1, (function()
				Pose.Value = "None"
			end))
		end
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage)
end

function MonkeyHit(Hit)
	if not Hit or not Hit.Parent or HitDelay then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	HitDelay = true
	TakeDamage(humanoid, Damage.Value)
	wait(0.2)
	HitDelay = false
end

for i, v in pairs(Figure:GetChildren()) do
	if v:IsA("BasePart") then
		v.Touched:connect(MonkeyHit)
	end
end