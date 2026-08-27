--Rescripted by Luckymaxer

Functions = {}

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}

function Functions.IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function Functions.Round(Number, Decimal)
	Decimal = (Decimal or 0)
	local Multiplier = (10 ^ Decimal)
	return (math.floor(Number * Multiplier + 0.5) / Multiplier)
end

function Functions.SigNum(Number)
	if Number == 0 then
		return 1
	end
	return (math.abs(Number) / Number)
end

function Functions.TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function Functions.UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Functions.FindCharacterAncestor(Object)
	if Object and Object ~= game:GetService("Workspace") then
		if Object:FindFirstChild("Humanoid") then
			return Object
		else
			return Functions.FindCharacterAncestor(Object.Parent)
		end
	end
	return nil
end

function Functions.WeldBetween(Part1, Part2)
    local Weld = Instance.new("Weld")
    Weld.Part0 = Part1
    Weld.Part1 = Part2
    Weld.C0 = CFrame.new()
    Weld.C1 = Part2.CFrame:inverse() * Part1.CFrame
    Weld.Parent = Part1
    return Weld
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit.Transparency > 0.8 or CheckTableForString(ProjectileNames, Hit.Name) then
			return true
		end
	end
	return false
end

function Functions.CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = Functions.CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

return Functions