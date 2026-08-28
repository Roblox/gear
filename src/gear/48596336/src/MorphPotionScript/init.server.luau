--Rescripted by TakeoHonorable
--No more Obtaining Forcefields with this one (^:
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

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Player,Character,Humanoid

local Properties = {
	Range = 20,
	RevertTime = 10,
	Swapped = true
}

local Sounds = {
	Morph = Handle:WaitForChild("MorphSound"),
}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

function FindClosestPlayer(Location,Range)
	local ClosestPlayer,ClosestPlayerTorso,ClosestPlayerHumanoid,ClosestPlayerDistance = nil,nil,nil,Range or math.huge
	local Players = Services.Players:GetPlayers()
	for player = 1,#Players,1 do
		if Players[player] and Players[player] ~= Player and Players[player].Character then
			local Hum = Players[player].Character:FindFirstChildOfClass("Humanoid")
			local Torso = Players[player].Character:FindFirstChild("Torso") or Players[player].Character:FindFirstChild("UpperTorso")
			if Hum and Hum.Health > 0 and Torso and (Torso.Position-Location).Magnitude < ClosestPlayerDistance then
				ClosestPlayerDistance = (Torso.Position-Location).Magnitude
				ClosestPlayer = Players[player]
				ClosestPlayerTorso = Torso
				ClosestPlayerHumanoid = Hum
			end
		end
	end
	return (ClosestPlayer and ClosestPlayer.Character) or nil
end


function Activated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 then return end
	Tool.Enabled = false
	Sounds.Morph:Play()
	local Target = FindClosestPlayer((Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")).Position,Properties.Range)
	if Target and not Character:FindFirstChild("TransformScript") then
		local TransformScript = script:WaitForChild("TransformScript"):Clone()
		Create("ObjectValue"){
			Name = "Target",
			Value = Target,
			Parent = TransformScript
		}
		TransformScript.Parent = Character
		TransformScript.Disabled = false
	end
	wait(1.5)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)