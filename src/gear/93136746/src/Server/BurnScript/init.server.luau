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

local Character = script.Parent

local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

local Humanoid = Character:FindFirstChildOfClass("Humanoid")


if not Torso or not Humanoid then script:Destroy() end

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

local Tool = script:WaitForChild("ToolHandle")

local Creator = script:WaitForChild("Creator")

local FireParticle = script:WaitForChild("FireParticle")

FireParticle.Parent = Torso
FireParticle.Enabled = true

local DmgPerFrame = (1/60)*10

repeat
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid,Creator.Value)
	Humanoid:TakeDamage(DmgPerFrame)
	Services.RunService.Heartbeat:Wait()
until not FireParticle or not FireParticle.Parent or not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 or not Tool.Value or (Torso.CFrame.p-Tool.Value.CFrame.p).Magnitude > 30 or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Character)) or not Tool.Value:IsDescendantOf(Creator.Value.Character)


FireParticle:Destroy()
script:Destroy()
