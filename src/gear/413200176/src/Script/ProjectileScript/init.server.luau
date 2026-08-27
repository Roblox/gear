--Made by Luckymaxer

Part = script.Parent
Mesh = Part:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

OrigSize = Part.Size
OrigScale = Mesh.Scale

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Creator = Part:WaitForChild("Creator")
PushForce = Part:WaitForChild("PushForce")
Damage = Part:WaitForChild("Damage")
Unlucky = Part:WaitForChild("Unlucky")

HitSound = Part:FindFirstChild("HitSound")

StunScript = script:WaitForChild("StunScript")

AlreadyHit = false

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

Part.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or Part.Velocity.Magnitude < 2 or AlreadyHit then
		return
	end
	local CreatorPlayer = GetCreator()
	if not CreatorPlayer then
		return
	end
	local Character = Hit.Parent
	if Character:IsA("Hat") or Character:IsA("Tool") then
		Character = Character.Parent
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Torso = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player and (Player == CreatorPlayer or IsTeamMate(CreatorPlayer, Player)) then
		return
	end
	
	AlreadyHit = true
	
	Torso.Velocity = (CFrame.new(Part.Position, Torso.Position).lookVector * PushForce.Value)
	
	for i, v in pairs(Part:GetChildren()) do
		if string.find(string.lower(v.ClassName), string.lower("Body")) then
			v:Destroy()
		end
	end
	
	if HitSound then
		HitSound:Play()
	end
	
	local StunScriptCopy = StunScript:Clone()
	local Values = {
		{Name = "Direction", Class = "Vector3Value", Value = CFrame.new(Vector3.new(Part.Position.X, Torso.Position.Y, Part.Position.Z), Torso.Position).lookVector},
		{Name = "Force", Class = "NumberValue", Value = math.random(25, 50)},
		{Name = Unlucky.Name, Class = Unlucky.ClassName, Value = Unlucky.Value},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = StunScriptCopy,
		}
	end
	StunScriptCopy.Disabled = false
	StunScriptCopy.Parent = Character
	
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid, CreatorPlayer)
	Humanoid:TakeDamage(Damage.Value)
end)