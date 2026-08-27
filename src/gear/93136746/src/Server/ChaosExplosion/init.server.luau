local Center = script.Parent

local Creator = script:WaitForChild("Creator")

local BaseUrl = "http://www.roblox.com/asset/?id="

local Radius = 150

local StunRadius = 60

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
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




local Shockwave = Create("Part"){
	Material = Enum.Material.Neon,
	Transparency = 0,
	CFrame = Center.CFrame + Vector3.new(0,.35*.5,0),
	Size = Vector3.new(1.6,.35,1.6),
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Anchored = true,
	CanCollide = false,
	Locked = true
}

local Surfaces = {"Top","Bottom","Left","Right","Front","Back"}
local Lights = {}
for _,surface in pairs(Surfaces) do
	Lights[#Lights+1] = Create("SurfaceLight"){
		Brightness = 2,
		Angle = 180,
		Range = 1,
		Color = Color3.fromRGB(255,85,0),
		Enabled = true,
		Parent = Shockwave,
		Face = surface
	}
end

local ShockwaveMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = BaseUrl .. "173770780",
	TextureId = BaseUrl .. "173770840",
	Scale = Vector3.new(1,1,1),
	VertexColor = Vector3.new(1,1,1),
	Parent = Shockwave
}

Shockwave.Parent = Center

for _,v in pairs(script:WaitForChild("Particles"):GetChildren()) do
	if v:IsA("ParticleEmitter") then
		local Particle = v:Clone()
		Particle.Parent = Center
		Particle.Size = NumberSequence.new(1,((Particle.Name == "Fire" and 60) or 70))
		Particle:Emit(Particle.Rate)
	end
end

local ExplosionSound = script:WaitForChild("Explosion")
ExplosionSound.Parent = Center
ExplosionSound:Play()

local Neg,Pos = Center.CFrame.p - Vector3.new(1,1,1) * StunRadius,Center.CFrame.p + Vector3.new(1,1,1) * StunRadius
local Region = Region3.new(Neg,Pos)
local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Creator.Value.Character},math.huge)

local CapHumanoids = {}
for _,parts in pairs(Parts) do
	if parts and parts.Parent and (parts.CFrame.p-Center.CFrame.p).Magnitude <= StunRadius then
		local Hum,FF = parts.Parent:FindFirstChildOfClass("Humanoid"),parts.Parent:FindFirstChildOfClass("ForceField")
		if not FF and Hum and Hum.Health ~= 0 and not IsInTable(CapHumanoids,Hum) and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
			CapHumanoids[#CapHumanoids+1] = Hum
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Creator.Value)
			Hum:TakeDamage(60)
			
			local ThornScript = script:WaitForChild("TelaThornScript")
			if not Hum.Parent:FindFirstChild(ThornScript.Name) then
				ThornScript = ThornScript:Clone()
				ThornScript:WaitForChild("Creator").Value = Creator.Value
				ThornScript.Parent = Hum.Parent
				ThornScript.Disabled = false 
			end
			
			local player = Services.Players:GetPlayerFromCharacter(Hum.Parent)
			if player then
				if player:FindFirstChild("PlayerGui") and not player:FindFirstChild("PlayerGui"):FindFirstChild("CameraShake") then
					local QuakeScript = script:WaitForChild("CameraShake"):Clone()
					QuakeScript.Parent = player:FindFirstChild("PlayerGui")
					QuakeScript.Disabled = false
					Services.Debris:AddItem(QuakeScript, 3)
				end
			end
		end
	end
end

for i=0,Radius,2 do
	Shockwave.Size = Vector3.new(1.6,.35,1.6)*i
	Shockwave.CFrame = CFrame.new(Center.CFrame.p+Vector3.new(0,Shockwave.Size*1.5,0))*((Shockwave.CFrame-Shockwave.CFrame.p)*CFrame.Angles(0,math.rad(3),0))
	ShockwaveMesh.Scale = Vector3.new(1,1,1)*i 
	Shockwave.Transparency = (i/Radius)
	for _,v in pairs(Lights) do
		v.Brightness = (1-(i/Radius))*2
		v.Range = i
	end
	local Neg,Pos = Center.CFrame.p - Vector3.new(1,1,1) * i,Center.CFrame.p + Vector3.new(1,1,1) * i
	local Region = Region3.new(Neg,Pos)
	local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Creator.Value.Character},math.huge)

	for _,parts in pairs(Parts) do
	if parts and parts.Parent and (parts.CFrame.p-Center.CFrame.p).Magnitude <= i then
		local Hum,FF = parts.Parent:FindFirstChildOfClass("Humanoid"),parts.Parent:FindFirstChildOfClass("ForceField")
			if not FF and Hum and Hum.Health ~= 0 and not IsInTable(CapHumanoids,Hum) and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
				CapHumanoids[#CapHumanoids+1] = Hum
				UntagHumanoid(Hum)
				TagHumanoid(Hum,Creator.Value)
				Hum:TakeDamage(20)
				local player = Services.Players:GetPlayerFromCharacter(Hum.Parent)
					if player then
						if not Hum.Parent:FindFirstChild("TripScript") then
							local TripScript = script:WaitForChild("TripScript"):Clone()
							TripScript.Parent = Hum.Parent
							TripScript.Disabled = false
							Services.Debris:AddItem(TripScript, 7)
						end
					end
				local Velo = Create("BodyVelocity"){
					MaxForce =  Vector3.new(1,1,1)*math.huge,
					Velocity = ((parts.CFrame.p-Center.CFrame.p).Unit * 100) + Vector3.new(0,75,0),
					Parent = parts
				}
				Services.Debris:AddItem(Velo,.1)
			end
		end
	end
	
	Services.RunService.Heartbeat:Wait()
end
Center:Destroy()

