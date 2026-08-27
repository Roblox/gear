local Shard = script.Parent

delay(7,function()
	Shard:Destroy()
end)

local Creator = script:WaitForChild("Creator",10)

local Blind = script:WaitForChild("Blind",10)

local CreatorHumanoid = Creator.Value.Character:FindFirstChildOfClass("Humanoid")

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Properties = {
	CurrentRadius = 75
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

local function GetNearestTorso(MarkedPosition,TorsoPopulationTable)
	local ClosestDistance = math.huge
	local ClosestTorso
	for i=1,#TorsoPopulationTable do
		local distance = (TorsoPopulationTable[i].CFrame.p-MarkedPosition).magnitude
		if TorsoPopulationTable[i] and  distance < ClosestDistance then
			ClosestDistance = distance
			ClosestTorso = TorsoPopulationTable[i]
		end
	end
	--warn("The Closest Person is: "..ClosestTorso.Parent.Name)
	return ClosestTorso
end

local function TrackCharacters(Center,Range)
	local Characters = {}
	local Players = {}
	local NegativeRegion = (Center.Position - Vector3.new(Range, Range, Range))
	local PositiveRegion = (Center.Position + Vector3.new(Range, Range, Range))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local Parts = workspace:FindPartsInRegion3(Region,Creator.Value.Character,math.huge)
	local TaggedHumanoids = {}
		for _,hit in pairs(Parts) do
			if string.find(string.lower(hit.Name),"torso") then
				local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
				local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
				if Hum and Hum.Parent and Hum.Health > 0 and Creator.Value.Character and Hum ~= Creator.Value.Character:FindFirstChildOfClass("Humanoid") and not IsInTable(TaggedHumanoids,Hum) and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not ForceField then
					TaggedHumanoids[#TaggedHumanoids+1] = Hum
					if Services.Players:GetPlayerFromCharacter(Hum.Parent) then
						--print("Is a Player")
						Players[#Players+1] = hit
					else
						--print("Is an NPC")
						Characters[#Characters+1] = hit
					end
				end
			end
		end
	return Characters,Players
end

local Rocket = Instance.new("RocketPropulsion")
Rocket.CartoonFactor = 0.05
Rocket.TargetRadius = 4
Rocket.TargetOffset = Vector3.new(0,0,0)
Rocket.MaxThrust = 10^4.5
Rocket.ThrustP = 10^2
Rocket.TurnP = 10
Rocket.MaxSpeed = 200
Rocket.Parent = Shard

local Touch
function Damage(hit,TotalDamage)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health <=0 or Hum:IsDescendantOf(Creator.Value.Character) then return end
	
	if IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	local Player = Services.Players:GetPlayerFromCharacter(Hum.Parent)
	
	spawn(function()
		if Player and not ForceField then
			Blind.Parent = Player:WaitForChild("PlayerGui",10)
			Services.Debris:AddItem(Blind,3)
		end
	end)

	
	spawn(function()
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Creator.Value)
		Hum:TakeDamage(TotalDamage)
		--Hum:UnequipTools()
		Touch:Disconnect()
		Shard:Destroy()
		--wait(.5)
	end)
end

Touch = Shard.Touched:Connect(function(hit)
	Damage(hit,27)
end)
repeat
	local NPCs,Players = TrackCharacters(Shard,Properties.CurrentRadius)
	
	local PriorityTable = ((#Players > 0 and Players) or NPCs)-- Players before NPCs
	local PriorityTorso = GetNearestTorso(Shard.CFrame.p,PriorityTable)
	
	if PriorityTorso and Rocket.Target ~= PriorityTorso then
		--Track Target
		Rocket:Abort()
		Rocket.Target = PriorityTorso
		Rocket:Fire()
	end
	wait(1/10)
	--Services.RunService.Heartbeat:Wait()
until not Shard or not Shard.Parent