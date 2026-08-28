local Self = script

local Projectile = Self.Parent

local Creator = Self:WaitForChild("Creator")

local Instant,Pairs,Type,Tick,wrap,Delay,Wait,Pcall = Instance.new,pairs,type,tick,coroutine.wrap,delay,wait,pcall

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Players = (game:FindService("Players") or game:GetService("Players"))
}

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in Pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

--[[function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end]]

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instant("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in Pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


Projectile.Touched:Connect(function(hit)
	
	if not hit or not hit.Parent then return end
	
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	
	if not Hum or Hum.Health <= 0 or --[[IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or]] Creator.Value == Services.Players:GetPlayerFromCharacter(Hum.Parent) then return end
	
	local Directory = Hum.Parent
	
	local Confused = Directory:FindFirstChild("Confuse")
	
	if Confused then return end
	
	--print("Made it here")
	
	local Confusion = Self:WaitForChild("Confuse"):Clone()
	
	Create("NumberValue"){
		Name = "Duration",
		Value = 3,
		Parent = Confusion
	}
	
	Confusion.Parent = Directory
	Confusion.Disabled = false
	
	
end)