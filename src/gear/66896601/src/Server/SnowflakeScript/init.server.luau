local Snowflake = script.Parent

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}



function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
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

delay(7,function()
	Snowflake:Destroy()
end)

local Puff = script:WaitForChild("Puff")
Puff.Parent = Snowflake
Puff.Enabled = true

local Creator = script:WaitForChild("Creator")

local Touch

Touch = Snowflake.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	local FF = hit.Parent:FindFirstChildOfClass("ForceField")
	if FF or not Hum or Hum.Health <= 0 or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or Creator.Value == Services.Players:GetPlayerFromCharacter(Hum.Parent) then return end
	Touch:Disconnect();Touch = nil
	UntagHumanoid(Hum)
	TagHumanoid(Hum)
	Hum:TakeDamage(17)
	local function Frozen(Character) -- Quick check to see if they're not frozen
		for _,v in pairs(Services.ServerScriptService:GetChildren()) do
			if v:IsA("Script") and v.Name == "Freeze" and v:FindFirstChild("Target") and v:FindFirstChild("Target").Value == Hum.Parent then
				return true
			end
		end
		return false
	end
	if not Frozen(Hum.Parent) then
		local FreezeScript = script:WaitForChild("Freeze"):Clone()
		FreezeScript:WaitForChild("Creator").Value = Creator.Value
		FreezeScript:WaitForChild("Target").Value = Hum.Parent
		FreezeScript.Parent = Services.ServerScriptService
		FreezeScript.Disabled = false
	end
	Snowflake:Destroy()
end)
