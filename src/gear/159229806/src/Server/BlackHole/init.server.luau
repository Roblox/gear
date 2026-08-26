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

local Black_Hole = script.Parent

local Creator = script:WaitForChild("Creator",5)

local ParticleFolder = script:WaitForChild("Particles",5)

local CenterAttachment = Create("Attachment"){
	Position = Vector3.new(0,0,0),
	Parent = Black_Hole
}

local Radius = 50

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local function Wait(para) -- bypasses the latency
	local Initial = tick()
	repeat
		Services.RunService.Heartbeat:Wait()
	until tick()-Initial >= para
end

for _,particles in pairs(ParticleFolder:GetChildren()) do
	if particles:IsA("ParticleEmitter") then
		particles.Parent = CenterAttachment
		particles.Enabled = true
	end
end

local EffectSound = script:WaitForChild("Effect")
EffectSound.Parent = Black_Hole
EffectSound:Play()

local VeloForces = {}

local AffectedParts = {}

local Pulling = true

delay(5,function()
	Pulling = false
	for _,forces in pairs(VeloForces) do
		if forces then
			forces:Destroy()
		end
	end
	Black_Hole:Destroy()
end)

while Black_Hole and Black_Hole:IsDescendantOf(workspace) and Pulling do
	--spawn(function()
		local NegativeRegion = (Black_Hole.Position - Vector3.new(Radius,Radius,Radius))
		local PositiveRegion = (Black_Hole.Position + Vector3.new(Radius,Radius,Radius))
		local Region = Region3.new(NegativeRegion, PositiveRegion)
		local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Creator.Value.Character,Black_Hole},math.huge)
		for _,hit in pairs(Parts) do
			if hit and hit.Parent and not hit.Anchored and (hit.CFrame.p-Black_Hole.CFrame.p).Magnitude <= Radius and not IsInTable(AffectedParts,hit) and not hit:FindFirstAncestorWhichIsA("Tool") and not hit:FindFirstAncestorWhichIsA("Accoutrement") and not hit.Parent:FindFirstChildOfClass("ForceField") and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(hit.Parent)) then
				AffectedParts[#AffectedParts+1] = hit
				local Pull = Create("BodyVelocity"){
					MaxForce = Vector3.new(1,1,1)*math.huge,
					Velocity = ((Black_Hole.CFrame.p-hit.CFrame.p).Unit*25),
					Name = "Pull",
					Parent = hit
				}
				VeloForces[#VeloForces+1] = Pull
				delay(.5,function()
				
						for index,v in pairs(VeloForces) do
							if v == Pull then
								table.remove(AffectedParts,index)
								if Pull then
									Pull:Destroy()
								end
							end
						end
						for index,v in pairs(AffectedParts) do
							if v == hit then
								table.remove(AffectedParts,index)
							end
						end
					
				end)
				--Services.Debris:AddItem(Pull,.5)
			end
		end
	--end)
	Wait(1/30)
	--Services.RunService.Heartbeat:Wait()
end