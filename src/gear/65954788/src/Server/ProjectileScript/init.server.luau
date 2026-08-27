local Projectile = script.Parent

local Creator = script:WaitForChild("Creator",math.huge)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end


local HitHumanoids = {}

Projectile.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
	local Hum,FF  = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	
	if not Hum or Hum.Health <= 0 or FF or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or Creator.Value == Services.Players:GetPlayerFromCharacter(Hum.Parent) or IsInTable(HitHumanoids,Hum) then return end
	HitHumanoids[#HitHumanoids+1] = Hum --Can't hit this humanoid again
	
	UntagHumanoid(Hum)
	TagHumanoid(Hum,Creator.Value)
	
	Hum:TakeDamage((hit.Name == "Head" and 52) or 18)--Originally 30
	
	Hum.Sit = false
	local Seed = Random.new()
	local Velo = Create("BodyVelocity"){
		MaxForce = Vector3.new(1,1,1)*math.huge,
		Velocity = (Projectile.Velocity).Unit * 80,
		Parent = hit
	}
	local SpinFactor = 20
	local Angular = Create("BodyAngularVelocity"){
		MaxTorque = Vector3.new(1,1,1)*math.huge,
		AngularVelocity = Vector3.new(Seed:NextNumber(-SpinFactor,SpinFactor),Seed:NextNumber(-SpinFactor,SpinFactor),Seed:NextNumber(-SpinFactor,SpinFactor)),
		Parent = hit
	}
	Services.Debris:AddItem(Velo,.1)
	Services.Debris:AddItem(Angular,.1)
end)
