--Plant the Ice Stalagmite and let em' have it!

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Players = (game:FindService("Players") or game:GetService("Players")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Regions = require(script:WaitForChild("RegionModule"))


local Region,Vec = Region3.new,Vector3.new

local Position,Creator = script:FindFirstChild("Pos"),script:FindFirstChild("Creator")

if not Position or not Creator then script:Destroy() end

Position = Position.Value

Creator = Creator.Value

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

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

function CastScripts(Duration,ScriptEntries) -- Could be used for ServerScripts, but we'll use LocalScripts in this case
	local LoggedScripts = {} -- Keeps track of the current scripts
	local Players = Services.Players:GetPlayers()
	for p=1,#Players do
		if Players[p] then
			for i=1,#ScriptEntries do
				if ScriptEntries[i] and ScriptEntries[i]:IsA("LocalScript") and Players[p]:FindFirstChild("PlayerGui")then
					local Clone = ScriptEntries[i]:Clone()
					Clone.Parent = Players[p]:FindFirstChild("PlayerGui") -- The best spot to place it at
					Clone.Disabled = false
					LoggedScripts[#LoggedScripts+1] = Clone
				end
			end
		end
	end
	
	local function Clean()
		--print("CLEANING")
		for s=1,#LoggedScripts do
			
			if LoggedScripts[s] then
				--LoggedScripts[s]:Destroy()
				Services.Debris:AddItem(LoggedScripts[s],(Duration or 1)+1)
			end
		end
		LoggedScripts = {} -- Clear the Memory
	end
	
	Clean()
	
end

wait(.1)--Small time to make an escape


local StatlagmiteClient = script:WaitForChild("StalagmiteClient")
local Pos = Instance.new("Vector3Value")
Pos.Value = Position
Pos.Name = "Pos"
Pos.Parent = StatlagmiteClient
CastScripts(4,{StatlagmiteClient})

local Parts = Regions.new(CFrame.new(Position) * CFrame.new(0,50,0),Vec(14,100,14)):Cast({Creator})
local TaggedHum = {}

for i=1,#Parts,1 do
	if Parts[i] and Parts[i].Parent then
		local Hum,FF = Parts[i].Parent:FindFirstChildOfClass("Humanoid"),Parts[i].Parent:FindFirstChildOfClass("ForceField")
		
		if Hum and not FF and not IsTeamMate(Services.Players:GetPlayerFromCharacter(Creator),Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not IsInTable(TaggedHum,Hum) then 
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Services.Players:GetPlayerFromCharacter(Creator))
			Hum:TakeDamage(Hum.MaxHealth*(1/3))
			TaggedHum[#TaggedHum+1] = Hum
			local Chance = Random.new():NextInteger(1,2)
			--print(Chance)
			if Hum and Hum.Health ~= 0 and Hum.Parent and Chance == 2 then
				--warn("Freezing")
				local Freeze = script:WaitForChild("Freeze"):Clone()
				Create("ObjectValue"){
					Name = "Target",
					Value = Hum.Parent,
					Parent = Freeze
				}
				Freeze.Parent = Services.ServerScriptService
				Freeze.Disabled = false
			end
		end
		
	end
end

script:Destroy()
