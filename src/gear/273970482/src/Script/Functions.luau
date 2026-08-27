--Made by Luckymaxer

Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Functions = {
	
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
		if Hit and Hit.Parent then
			local Character = Hit.Parent
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid or Character:IsA("Hat") or Character:IsA("Tool") then
				return false
			end
			if (Hit.Transparency >= 1 and not Hit.CanCollide) or Functions.CheckTableForString(ProjectileNames, Hit.Name) then
				return true
			end
		end
		return false
	end),
	
	CastRay = (function(StartPos, Vec, Length, Ignore, DelayIfHit)
		local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
		if RayHit and Functions.CheckIntangible(RayHit) then
			if DelayIfHit then
				wait()
			end
			RayHit, RayPos, RayNormal = Functions.CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).Magnitude)), Ignore, DelayIfHit)
		end
		return RayHit, RayPos, RayNormal
	end),

	TagHumanoid = (function(humanoid, player)
		local Creator_Tag = Create("ObjectValue"){
			Name = "creator",
			Value = player,
		}
		local NoTransform = Create("BoolValue"){
			Name = "NoTransform",
			Value = true,
			Parent = Creator_Tag,
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