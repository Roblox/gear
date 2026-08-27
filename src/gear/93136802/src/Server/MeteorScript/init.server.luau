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
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
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

local Comet = script.Parent

local MaxDamage = 90

local CometParticles = script:WaitForChild("CometParticles",10):GetChildren()
local CometSounds = script:WaitForChild("CometSounds",10):GetChildren()

local Creator = script:WaitForChild("Creator",10)

local CreatorHumanoid = Creator.Value.Character:FindFirstChildOfClass("Humanoid")

local Center,Top,Bottom = Create("Attachment"){Parent = Comet}

Top = Center:Clone();Top.Position = Vector3.new(0,Comet.Size.Y/2,0);Top.Parent = Comet
Bottom = Center:Clone();Bottom.Position = Vector3.new(0,-Comet.Size.Y/2,0);Bottom.Parent = Comet

local Velo = Create("BodyVelocity"){
	MaxForce = Vector3.new(1,1,1)*math.huge,
	Velocity = Comet.CFrame.lookVector * ((Comet.Size.X/20)*200),
	Parent = Comet
}

for _,particle in pairs(CometParticles) do
		if particle:IsA("ParticleEmitter") then
			local Clone = particle:Clone()
			Clone.Parent = Center
			
			local property = Clone.Size.Keypoints
			for step,value in pairs(property) do
				--print(property[step].Time,property[step].Value)
				property[step] = NumberSequenceKeypoint.new(property[step].Time,property[step].Value*Comet.Size.X/10,property[step].Envelope)
				--print(times,value,property[times])
			end
			Clone.Size = NumberSequence.new(property)
			Clone.Speed = NumberRange.new(Clone.Speed.Min*Comet.Size.Y/10,Clone.Speed.Max*Comet.Size.Y/10)
			if not Clone.LockedToPart then
				Clone.Lifetime = NumberRange.new(Clone.Lifetime.Min*Comet.Size.Y/10,Clone.Lifetime.Max*Comet.size.Y/10)
			end
			Clone.Enabled = true
		elseif particle:IsA("Trail") then
			particle.Parent = Comet
			particle.Attachment0 = Top
			particle.Attachment1 = Bottom
			particle.Enabled = true
		end
	end
	
		
for _,sounds in pairs(CometSounds) do
	if sounds:IsA("Sound") then
		sounds.Parent = Comet
		sounds:Play()
	end
end

local Touch
local ImpactSound = script:WaitForChild("Impact",10)
ImpactSound.Parent = Comet

Touch = Comet.Touched:Connect(function(hit)
	if not hit or not hit.Parent or not hit.CanCollide then return end
	Touch:Disconnect()
	Comet.Anchored = true
		if hit and hit.Parent then 
			local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
			if Hum and Hum.Health > 0 and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and Hum ~= CreatorHumanoid then 
				UntagHumanoid(Hum)
				TagHumanoid(Hum,Creator.Value)
				Hum:TakeDamage(MaxDamage * 2)
			end
		end
	for _,v in pairs(Comet:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Enabled = false
		end
	end
	--local Rays = Ray.new(Comet.CFrame.p,((Comet.CFrame.p-Vector3.new(0,1,0)-Comet.CFrame.p)).unit*999.999)
	local Rays = Ray.new(Comet.CFrame.p,Comet.CFrame.p+Comet.Velocity*999.999)
	local part,pos = workspace:FindPartOnRay(Rays,Comet)
	
	
		if part then
			Comet.CFrame = CFrame.new(pos) * (Comet.CFrame-Comet.CFrame.p)
		end
	
		local Shockwave = Create("Part"){
		Name = "Shockwave",
		Size = Vector3.new(1,1,1)*0,
		Locked = true,
		Color = Color3.fromRGB(170, 0, 255),
		Shape = Enum.PartType.Ball,
		Material = Enum.Material.Neon,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		Anchored = true,
		CanCollide = false,
		CFrame = CFrame.new(((part and pos)or Comet.CFrame.p))*(Comet.CFrame-Comet.CFrame.p),
		Parent = workspace
		}
		
		local TaggedHumanoids = {}

			spawn(function()
				repeat
					--spawn(function()
						local NegativeRegion = (Shockwave.CFrame.p - Vector3.new(Shockwave.Size.X, Shockwave.Size.Y, Shockwave.Size.Z))
						local PositiveRegion = (Shockwave.CFrame.p + Vector3.new(Shockwave.Size.X, Shockwave.Size.Y, Shockwave.Size.Z))
						local Region = Region3.new(NegativeRegion, PositiveRegion)
						local Parts = workspace:FindPartsInRegion3(Region,Creator.Value.Character,math.huge)
						for _,hit in pairs(Parts) do
							--spawn(function()
								if hit and hit.Parent and (hit.CFrame.p-Shockwave.CFrame.p).Magnitude <= Shockwave.Size.X then 
									--[[if not hit.Anchored  then
										hit.Color = Color3.fromRGB(170,0,255)
									end]]
									local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
									if Hum and Hum.Health ~= 0 and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not IsInTable(TaggedHumanoids,Hum) and Hum ~= CreatorHumanoid then  
										TaggedHumanoids[#TaggedHumanoids+1]=Hum
										UntagHumanoid(Hum)
										TagHumanoid(Hum,Creator.Value)
										Hum:TakeDamage(((Comet.Size.X/20)*MaxDamage))
									end
								end
							--end)
						end
					--end)
					Services.RunService.Heartbeat:Wait()
				until not Comet or not Comet.Parent or not Shockwave or not Shockwave.Parent
			end)
		
		Services.Debris:AddItem(Shockwave,5)
		
		ImpactSound:Play()
		delay(ImpactSound.TimeLength*.75,function()
			Shockwave:Destroy()
			Comet:Destroy()
		end)
		
		for i=0,30,1 do
			Shockwave.Size = Vector3.new(0,0,0):Lerp(Vector3.new(1,1,1)*(Comet.Size.X*5),i/30)
			Shockwave.Transparency = i/30
			Shockwave.CFrame = CFrame.new(((part and pos)or Comet.CFrame.p))*(Comet.CFrame-Comet.CFrame.p)
			Services.RunService.Heartbeat:Wait()
		end

	Shockwave:Destroy()
	--Comet:Destroy()
end)

delay(10,function()
	Comet:Destroy()
end)