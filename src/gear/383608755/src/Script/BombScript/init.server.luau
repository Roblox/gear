--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Part = script.Parent
Mesh = Part:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

OrigSize = Part.Size
OrigScale = Mesh.Scale

local Instant = Instance.new
function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

BaseUrl = "http://www.roblox.com/asset/?id="

Creator = Part:WaitForChild("Creator")
PushForce = Part:WaitForChild("PushForce")
Damage = Part:WaitForChild("Damage")

StunScript = script:WaitForChild("StunScript")

function TweenVector(Start, Goal, Time)
	return (Vector3.new((Goal.X - Start.X), (Goal.Y - Start.Y), (Goal.Z - Start.Z)) / Time)
end

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

ScaleFrames = 20
Duration = 3
Scale = 8
for i = 1, ScaleFrames do
	local OrigCF = Part.CFrame
	local NewSize = (OrigSize + TweenVector(OrigSize, (OrigSize * Scale), ((Duration * ScaleFrames) / i)))
	Part.Size = NewSize
	Mesh.Scale = ((NewSize / OrigSize) * OrigScale)
	Part.CFrame = (OrigCF + Vector3.new(0, (NewSize / 2), 0))
	wait()
end

wait(2)

Part.Transparency = 1
Part.Anchored = true
Part.CanCollide = false

Explosion = Create("Explosion"){
	Name = "Explosion",
	ExplosionType = Enum.ExplosionType.NoCraters,
	BlastPressure = 0,
	BlastRadius = 20,
	DestroyJointRadiusPercent = 0,
	Position = Part.Position,
}



HitHumanoids = {}

Explosion.Hit:Connect(function(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local CreatorPlayer = GetCreator()
	if not CreatorPlayer then
		return
	end
	local Character = Hit.Parent
	if Character:IsA("Accessory") or Character:IsA("Tool") then
		Character = Character.Parent
	end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Humanoid or Humanoid.Health == 0 or not Torso or CheckTableForInstance(HitHumanoids, Humanoid) then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player and (Player == CreatorPlayer or IsTeamMate(CreatorPlayer, Player)) then
		return
	end
	table.insert(HitHumanoids, Humanoid)
	Torso.Velocity = (CFrame.new(Explosion.Position, Torso.Position).lookVector * PushForce.Value)
	
	local StunScriptCopy = StunScript:Clone()
	StunScriptCopy.Disabled = false
	StunScriptCopy.Parent = Character
	
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid, CreatorPlayer)
	Humanoid:TakeDamage(Damage.Value)
end)

Explosion.Parent = workspace

wait(3)

Part:Destroy()