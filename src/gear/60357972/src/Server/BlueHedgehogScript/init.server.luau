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

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Hedgehog = script.Parent

local Creator = script:WaitForChild("Creator")

local Fire = script:WaitForChild("Fire")

Fire.Parent = Hedgehog
Fire.Enabled = true

local Properties = {
	HedgehogAOE = 75,
	HedgehogSpeed = 120,
	BounceCount = 0,
}

local RNG = Random.new()

local RandomSound = script:WaitForChild("Sounds"):GetChildren()

if #RandomSound > 0 then
	RandomSound = RandomSound[RNG:NextInteger(1,#RandomSound)]
end


if RandomSound and RandomSound:IsA("Sound") then
	RandomSound.Parent = Hedgehog
	RandomSound:Play()
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
		local distance = (TorsoPopulationTable[i].CFrame.p-MarkedPosition).Magnitude
		if TorsoPopulationTable[i] and  distance < ClosestDistance then
			ClosestDistance = distance
			ClosestTorso = TorsoPopulationTable[i]
		end
	end
	--warn("The Closest Person is: "..ClosestTorso.Parent.Name)
	return ClosestTorso
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end
local RingList = {}
function onPlayerBlownUp(part, distance, position, explosionpressure)
	if not part or not part.Parent or part == Hedgehog or part.Parent:IsA("Accoutrement") or part:IsDescendantOf(Creator.Value.Character) or IsInTable(RingList,part) then return end
	local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local Character = humanoid.Parent
		if Character and Character ~= Creator.Value.Character and not Character:FindFirstChildOfClass("ForceField") and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Character)) then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Creator.Value)
			for _,joints in pairs(part:GetJoints()) do
				joints:Destroy()
			end
			part.Velocity = (part.CFrame.p-position).unit*(explosionpressure/1000)
		end
	else
		--part:BreakJoints()
		for _,joints in pairs(part:GetJoints()) do
			joints:Destroy()
		end
		if not part.Anchored then
			part.Velocity = (part.CFrame.p-position).unit*(explosionpressure/100)
		end
	end
end

Services.Debris:AddItem(Hedgehog,10)

local Exploded = false
local ExplodedHum = {}
Hedgehog.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
	Properties.BounceCount = Properties.BounceCount + 1
	
	if Hedgehog:FindFirstChildOfClass("BodyVelocity") then
		Hedgehog:FindFirstChildOfClass("BodyVelocity").Velocity = (Hedgehog:FindFirstChildOfClass("BodyVelocity").Velocity).Unit*(Properties.HedgehogSpeed + (Properties.BounceCount*4))
	end
	
	local Hum,FF,Torso = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField"),hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
	
	if not Hum or Hum.Health <= 0 or FF or not Torso then return end
	
	if IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or Creator.Value == Services.Players:GetPlayerFromCharacter(Hum.Parent) then return end
	
	UntagHumanoid(Hum)
	TagHumanoid(Hum,Creator.Value)
	if Properties.BounceCount > 5 and not Exploded and not IsInTable(ExplodedHum,Hum) then
		--Exploded = true
		ExplodedHum[#ExplodedHum+1] = Hum
		local e = Create("Explosion"){
			BlastRadius = 5,
			BlastPressure = 0,
			DestroyJointRadiusPercent = 0,
			ExplosionType = Enum.ExplosionType.NoCraters,
			Position = Hedgehog.Position,
			Parent = workspace,
		}
		e.Hit:Connect(function(part,distance)
			onPlayerBlownUp(part,distance,e.Position,600000)
		end)
	else
		Hum:TakeDamage(25)
	end
	if Hum.Health <= 0 then
		local Ring = Create("Part"){
			Locked = true,
			Anchored = false,
			Name = "Ring",
			CanCollide = true,
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Transparency = 0,
			Size = Vector3.new(1.7,1.7,.3)
		}
		Create("SpecialMesh"){
			MeshId = "rbxassetid://3270017",
			TextureId = "rbxassetid://3270066",
			Scale = Vector3.new(1,1,1)*1.5,
			VertexColor = Vector3.new(1,1,1)*2,
			Parent = Ring
		}
		for i=1,RNG:NextInteger(7,20),1 do
			local RingClone = Ring:Clone()
			RingList[#RingList+1] = RingClone
			RingClone.CFrame = Torso.CFrame
			RingClone.Velocity = Vector3.new(RNG:NextNumber(5,25),RNG:NextNumber(5,25),RNG:NextNumber(5,25))
			RingClone.RotVelocity = Vector3.new(RNG:NextNumber(20,40),RNG:NextNumber(20,40),RNG:NextNumber(20,40))
			RingClone.Parent = workspace
			RingClone:SetNetworkOwner(nil)
			Services.Debris:AddItem(RingClone,7)
		end
		--print("Dead")
	end
		
end)


Services.RunService.Heartbeat:Connect(function()
	local Neg,Pos = Hedgehog.Position - Vector3.new(1,1,1)* Properties.HedgehogAOE, Hedgehog.Position + Vector3.new(1,1,1)*Properties.HedgehogAOE
	local AOE = Region3.new(Neg,Pos)
	local Parts = workspace:FindPartsInRegion3WithIgnoreList(AOE,{Creator.Value.Character},math.huge)
	local PlayerTorsos,NPCTorsos = {},{}
	for i=1,#Parts,1 do
		if Parts[i] and Parts[i].Parent and (Parts[i].Position-Hedgehog.Position).Magnitude <= Properties.HedgehogAOE then
			local Hum, FF, Torso = Parts[i].Parent:FindFirstChildOfClass("Humanoid"), Parts[i].Parent:FindFirstChildOfClass("ForceField"),(Parts[i].Parent:FindFirstChild("Torso") or Parts[i].Parent:FindFirstChild("UpperTorso"))
			if Hum and Hum.Health ~= 0 and not FF and Torso and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
				if Services.Players:GetPlayerFromCharacter(Hum.Parent) then
					PlayerTorsos[#PlayerTorsos+1] = Torso
				else
					NPCTorsos[#NPCTorsos+1] = Torso
				end
			end
		end
	end
	
	local TargetTorso = GetNearestTorso(Hedgehog.Position,(#PlayerTorsos > 0 and PlayerTorsos) or (#NPCTorsos > 0 and NPCTorsos) or {})
	
	if TargetTorso then
		if Hedgehog:FindFirstChildOfClass("BodyVelocity") then
			Hedgehog:FindFirstChildOfClass("BodyVelocity").Velocity = (TargetTorso.Position-Hedgehog.Position).Unit*(Properties.HedgehogSpeed + (Properties.BounceCount*4))
		end
	end

end)



