--Made by Luckymaxer

Part = script.Parent
Mesh = Part:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Creator = Part:WaitForChild("Creator")
Damage = Part:WaitForChild("Damage")

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Parent) and Creator.Value) or nil)
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

AlreadyHit = false

Part.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or Part.Velocity.Magnitude < 2 or AlreadyHit then
		return
	end
	local CreatorPlayer = GetCreator()
	if not CreatorPlayer then
		return
	end
	local Character = Hit.Parent
	if Character:IsA("Accoutrement") then
		Character = Character.Parent
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	local RootPart = (Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso"))
	if not Humanoid or Humanoid.Health == 0 or not RootPart then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player and (Player == CreatorPlayer or IsTeamMate(CreatorPlayer, Player)) then
		return
	end
	AlreadyHit = true
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid, CreatorPlayer)
	Humanoid:TakeDamage(Damage.Value)
	
end)