--Made by Luckymaxer

Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Functions = {
	
	CheckTableForInstance = (function(Table, Instance)
		for i, v in pairs(Table) do
			if v == Instance then
				return true
			end
		end
		return false
	end),
	
	CheckTableForString = (function(Table, String)
		for i, v in pairs(Table) do
			if string.lower(v) == string.lower(String) then
				return true
			end
		end
		return false
	end),
	
	CheckIntangible = (function(Hit)
		local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Ray", "Bullet", "ParticlePart"}
		if not Hit or not Hit.Parent then
			return true
		end
		local character = Hit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		local humanoid = nil
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("Humanoid") then
				humanoid = v
				break
			end
		end
		if ((not humanoid and Hit.Transparency >= 1 and not Hit.CanCollide) or Functions.CheckTableForString(ProjectileNames, Hit.Name)) then
			return true
		end
		return false
	end),
	
	CastRay = (function(StartPos, Vec, Length, Ignore, DelayIfHit, HitObjects)
		local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
		if RayHit and Functions.CheckIntangible(RayHit) then
			if DelayIfHit then
				wait()
			end
			RayHit, RayPos, RayNormal = Functions.CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).Magnitude)), Ignore, DelayIfHit, HitObjects)
		end
		return RayHit, RayPos, RayNormal
	end),

	TagHumanoid = (function(humanoid, player)
		local Creator_Tag = Create("ObjectValue"){
			Name = "creator",
			Value = player,
		}
		Debris:AddItem(Creator_Tag, 2)
		Creator_Tag.Parent = humanoid
	end),
	
	UntagHumanoid = (function(humanoid)
		for i, v in pairs(humanoid:GetChildren()) do
			if v:IsA("ObjectValue") and v.Name == "creator" then
				v:Destroy()
			end
		end
	end),
	
	IsTeamMate = (function(Player1, Player2)
		return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
	end),
	
}

return Functions