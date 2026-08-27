--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Ray", "Bullet", "ParticlePart"}

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
		if Hit and Hit.Parent then
			if (Hit.Transparency >= 1 and not Hit.CanCollide) or Functions.CheckTableForString(ProjectileNames, Hit.Name) then
				return true
			end
			local ObjectParent = Hit.Parent
			local Character = ObjectParent.Parent
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid and Humanoid.Health > 0 and ObjectParent:IsA("Hat") then
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
			RayHit, RayPos, RayNormal = Functions.CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
		end
		return RayHit, RayPos, RayNormal
	end),

	IsTeamMate = (function(Player1, Player2)
		return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
	end),

	TagHumanoid = (function(humanoid, player)
		local Creator_Tag = Instance.new("ObjectValue")
		Creator_Tag.Name = "creator"
		Creator_Tag.Value = player
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
	
	GetTotalParts = (function(MaxParts, PossibleParts, Parts)
		if MaxParts < PossibleParts then
			return MaxParts
		elseif Parts >= MaxParts then
			return 0
		elseif MaxParts >= PossibleParts then
			local PartCount = (MaxParts - PossibleParts)
			if Parts <= MaxParts then
				PartCount = (MaxParts - Parts)
				if PartCount > PossibleParts then
					return PossibleParts
				else
					return PartCount
				end
			elseif PartCount >= PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		end
	end),

	GetParts = (function(Region, MaxParts, Ignore)
		local Parts = {}
		local RerunFailed = false
		while #Parts < MaxParts and not RerunFailed do
			local Region = Region
			local PossibleParts = Functions.GetTotalParts(MaxParts, 100, #Parts)
			local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
			if #PartsNearby == 0 then
				RerunFailed = true
			else
				for i, v in pairs(PartsNearby) do
					table.insert(Parts, v)
					table.insert(Ignore, v)
				end
			end
		end
		return Parts
	end),
	
}

return Functions