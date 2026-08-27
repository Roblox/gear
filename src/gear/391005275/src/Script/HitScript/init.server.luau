--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

TripScript = script:WaitForChild("StunScript")

Creator = Part:FindFirstChild("Creator")
Damage = Part:WaitForChild("Damage")

HitDelay = false

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
	
function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function GetCreator()
	return (((Creator and Creator.Parent and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function PartHit(Hit)
	local CreatorPlayer = GetCreator()
	if not Hit or not Hit.Parent or not CreatorPlayer or HitDelay or Part.Velocity.Magnitude < 8 then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (CreatorPlayer == player or IsTeamMate(CreatorPlayer, player)) then
		return
	end
	HitDelay = true
	local TripScriptCopy = character:FindFirstChild(TripScript.Name)
	local Duration
	if not TripScriptCopy then
		TripScriptCopy = TripScript:Clone()
		Duration = Create("NumberValue"){
			Name = "Duration",
			Value = 0,
			Parent = TripScriptCopy,
		}
		TripScriptCopy.Disabled = false
	end
	Duration = TripScriptCopy:FindFirstChild("Duration")
	if Duration then
		Duration.Value = 5
	end
	TripScriptCopy.Parent = character
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage.Value)
	wait(0.1)
	HitDelay = false
end

Part.Touched:connect(PartHit)