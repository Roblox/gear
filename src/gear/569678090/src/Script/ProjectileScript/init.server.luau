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

Sounds = {
	Explode = script:WaitForChild("Explode"),
	Hit = script:WaitForChild("Hit"),
}

StunScript = script:WaitForChild("StunScript")

AlreadyHit = false
AlreadyUsed = false

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Parent) and Creator.Value) or nil)
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

Part.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or AlreadyUsed then
		return
	end
	local CreatorPlayer = GetCreator()
	if not CreatorPlayer then
		return
	end
	local Character = Hit.Parent
	if Character:IsA("Accoutrement") or Character:IsA("Tool") then
		Character = Character.Parent
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or Humanoid.Health == 0 or not RootPart then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player and (Player == CreatorPlayer or IsTeamMate(CreatorPlayer, Player)) then
		return
	end
		
	if Part.Velocity.Magnitude >= 2 and not AlreadyHit then
		
		AlreadyHit = true
		
		RootPart.Velocity = (CFrame.new(Part.Position, RootPart.Position).lookVector * PushForce.Value)
		
		for i, v in pairs(Part:GetChildren()) do
			if string.find(string.lower(v.ClassName), string.lower("Body")) then
				v:Destroy()
			end
		end
		
		local HitSound = Sounds.Hit:Clone()
		HitSound.Pitch = (math.random(500, 800) * 0.001)
		HitSound.Parent = Part
		HitSound:Play()
		
		local StunScriptCopy = StunScript:Clone()
		local Values = {
			{Name = "Direction", Class = "Vector3Value", Value = CFrame.new(Vector3.new(Part.Position.X, RootPart.Position.Y, Part.Position.Z), RootPart.Position).lookVector},
			{Name = "Force", Class = "NumberValue", Value = math.random(25, 50)},
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
	elseif Part.Velocity.Magnitude < 2 then
		AlreadyUsed = true
		local Explosion = Create("Explosion"){
			Name = "Explosion",
			ExplosionType = Enum.ExplosionType.NoCraters,
			DestroyJointRadiusPercent = 0,
			BlastPressure = 0,
			BlastRadius = 10,
			Visible = true,
			Position = Part.Position,
		}
		
		local PlayersHit = {}
		
		Explosion.Hit:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local CreatorPlayer = GetCreator()
			local Character = Hit.Parent
			local Humanoid = Character:FindFirstChild("Humanoid")
			local RootPart = Character:FindFirstChild("HumanoidRootPart")
			if CheckTableForInstance(PlayersHit, Character) or not Humanoid or Humanoid.Health == 0 or not RootPart then
				return
			end
			local Player = Players:GetPlayerFromCharacter(Character)
			if CreatorPlayer and Player and (Player == CreatorPlayer or IsTeamMate(CreatorPlayer, Player)) then
				return
			end
			table.insert(PlayersHit, Character)
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid, CreatorPlayer)
			local CurrDist = (Part.Position - RootPart.Position).Magnitude
			local MinDist = 0
			local MaxDist = 8
			local DistPercent = GetPercentage(MaxDist, MinDist, Clamp(CurrDist, MinDist, MaxDist))
			local MaxDamage = 66
			local Damage = (MaxDamage * (DistPercent * 0.01))
			Humanoid:TakeDamage(Damage)
			Humanoid.Sit = true
			RootPart.Velocity = ((CFrame.new(Part.Position, RootPart.Position) + Vector3.new(0, (math.random(50, 150) * 0.1), 0)).lookVector * math.random(40, 75))
		end)
		
		Explosion.Parent = game:GetService("Workspace")
		local ExplodeSound = Sounds.Explode:Clone()
		ExplodeSound.Parent = Part
		ExplodeSound:Play()
		
		Part.Anchored = true
		Part.CanCollide = false
		Part.Transparency = 1
		Part.Name = "Effect"
		Debris:AddItem(Part, 2)
	end
end)