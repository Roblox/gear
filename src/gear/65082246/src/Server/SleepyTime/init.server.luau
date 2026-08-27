local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

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

local function FindInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then 
			return true
		end
	end
	return false
end

local Smog = script.Parent

local Creator = script:WaitForChild("Creator").Value

local Radius = 25

local Particle = script:WaitForChild("Smog")
Particle.Parent = Smog

local property = Particle.Size.Keypoints

for step,value in pairs(property) do
	property[step] = NumberSequenceKeypoint.new(property[step].Time,property[step].Value*Radius,property[step].Envelope)
end
Particle.Size = NumberSequence.new(property)

Particle.Enabled = true

local Pos = Smog.CFrame.p + Vector3.new(1,1,1)*Radius
local Neg = Smog.CFrame.p - Vector3.new(1,1,1)*Radius

local Region = Region3.new(Neg,Pos)

wait(1)

local Capture = workspace:FindPartsInRegion3WithIgnoreList(Region,{Creator},math.huge)

local CapturedHumanoids = {}

for _,parts in pairs(Capture) do
	if parts and parts.Parent then
		local Hum = parts.Parent:FindFirstChildOfClass("Humanoid")
		if Hum and Hum.Health ~= 0 and not FindInTable(CapturedHumanoids,Hum) and Hum.Parent ~= Creator.Character and not IsTeamMate(Creator,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
			local FF = Hum.Parent:FindFirstChildOfClass("ForceField")
			if not FF then
				CapturedHumanoids[#CapturedHumanoids+1] = Hum
				print("Putting " .. Hum.Parent.Name.." to sleep")
				local Sleep = script:WaitForChild("Sleep"):Clone()
				Sleep:WaitForChild("Target").Value = Hum.Parent
				Sleep.Parent = Services.ServerScriptService
				Sleep.Disabled = false
			end
		end
	end
end

Smog:Destroy()
