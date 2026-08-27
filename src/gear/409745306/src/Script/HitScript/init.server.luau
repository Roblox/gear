--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

FirePoison = script:WaitForChild("FirePoison")

Creator = script:WaitForChild("Creator")

AlreadyHit = false

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

function PartHit(Hit)
	local CreatorPlayer = GetCreator()
	if not Hit or not Hit.Parent or not CreatorPlayer or AlreadyHit then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == CreatorPlayer or IsTeamMate(CreatorPlayer, player)) then
		return
	end
	AlreadyHit = true
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(5)
	--humanoid.Sit = true
	--torso.Velocity = (CFrame.new(Vector3.new(Part.Position.X, torso.Position.Y, Part.Position.Z), torso.Position).lookVector * 75)
	local FirePoisonCopy = character:FindFirstChild(FirePoison.Name)
	if not FirePoisonCopy then
		FirePoisonCopy = FirePoison:Clone()
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = CreatorPlayer},
		}
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = FirePoisonCopy,
			}
		end
		FirePoisonCopy.Disabled = false
		FirePoisonCopy.Parent = character
	end
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Light") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
	Part.Anchored = true
	Debris:AddItem(Part, 3)
end

Part.Touched:connect(PartHit)