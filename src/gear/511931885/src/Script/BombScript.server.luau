--Made by Luckymaxer

Bomb = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Bomb:FindFirstChild("Creator")
Damage = Bomb:FindFirstChild("Damage")
Multiply = Bomb:FindFirstChild("Multiply")

Start = tick()

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Explode()
	local Explosion = Create("Explosion"){
		Name = "Explosion",
		ExplosionType = Enum.ExplosionType.NoCraters,
		DestroyJointRadiusPercent = 0,
		BlastRadius = 8,
		BlastPressure = 0,
		Position = Bomb.Position,
		Visible = true,
	}
	local CharactersHit = {}
	local CurrDmg = Damage.Value
	Explosion.Hit:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local Character = Hit.Parent
		if CheckTableForInstance(CharactersHit, Character) then
			return
		end
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not Humanoid or Humanoid.Health == 0 then
			return
		end
		local Player = Players:GetPlayerFromCharacter(Character)
		local CreatorPlayer = GetCreator()
		if Player and CreatorPlayer and (Player == CreatorPlayer or IsTeamMate(CreatorPlayer, Player)) then
			return
		end
		table.insert(CharactersHit, Character)
		UntagHumanoid(Humanoid)
		TagHumanoid(Humanoid, Players)
		Humanoid:TakeDamage((CurrDmg and CurrDmg) or 0)
	end)
	Explosion.Parent = game:GetService("Workspace")
end

function MultiplyBomb()
	if Multiply.Value > 0 then
		Multiply.Value = (Multiply.Value - 1)
		Damage.Value = (Damage.Value / 2)
		local NewBomb = Bomb:Clone()
		local SizeDec = 0.75
		NewBomb.Size = (NewBomb.Size * SizeDec)
		local Mesh = NewBomb:FindFirstChild("Mesh")
		if Mesh then
			Mesh.Scale = (Mesh.Scale * SizeDec)
		end
		for i, v in pairs({Creator, Damage, Multiply}) do
			local Value = v:Clone()
			Value.Parent = NewBomb
			local BombScript = script:Clone()
			BombScript.Disabled = false
			BombScript.Parent = NewBomb
		end
		local BombCount = math.ceil(Multiply.Value * 1.5)
		for i = 1, BombCount do
			local NewBombCopy = NewBomb:Clone()
			local DirHeight = Vector3.new(0, (math.random(500, 1500) * 0.01), 0)
			local OriginCF = (CFrame.new(Bomb.Position) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0))
			local DirAngle = (CFrame.new(Bomb.Position) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)) --(OriginCF * CFrame.Angles(0, ((math.pi * 2) / (BombCount - i)), 0))
			local RandomDir = (DirAngle + DirHeight).lookVector
			RandomDir = CFrame.new(Bomb.Position, (CFrame.new(Bomb.Position) + RandomDir * 2).p).lookVector
			NewBombCopy.CFrame = (Bomb.CFrame + RandomDir * ((Bomb.Size.Z / 2) + (NewBombCopy.Size.Z / 2)))
			NewBombCopy.Velocity = (RandomDir * math.random(15, 35))
			Debris:AddItem(NewBombCopy, 3)
			NewBombCopy.Parent = game:GetService("Workspace")
		end
	else
		return
	end
end

wait(2)

Explode()

MultiplyBomb()

Bomb.Name = "Effect"
Bomb.Transparency = 1
Bomb.Anchored = true
Bomb.CanCollide = false
Debris:AddItem(Bomb, 1)