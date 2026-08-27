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
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}



local Comet = script.Parent

local Properties = {
	CurrentRadius = 700--Comet.Size.Y*5
}

local CometRefScript = script:WaitForChild("AmethystComet",10)
local CometRef = CometRefScript:WaitForChild("CometRef",10)
local Creator = script:WaitForChild("Creator",10).Value

CometRefScript:WaitForChild("Creator",5).Value = Creator

CometRef.Value = Comet
CometRefScript.Parent = Services.ServerScriptService
CometRefScript.Disabled = false

local CometParticles = script:WaitForChild("CometParticles",10):GetChildren()
local CometSounds = script:WaitForChild("CometSounds",10):GetChildren()



local Center,Top,Bottom = Create("Attachment"){Parent = Comet}

Top = Center:Clone();Top.Position = Vector3.new(0,Comet.Size.Y/2,0);Top.Parent = Comet
Bottom = Center:Clone();Bottom.Position = Vector3.new(0,-Comet.Size.Y/2,0);Bottom.Parent = Comet

local Velo = Create("BodyVelocity"){
	MaxForce = Vector3.new(1,1,1)*math.huge,
	Velocity = Comet.CFrame.lookVector * 100,
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
				Clone.Lifetime = NumberRange.new(Clone.Lifetime.Min*Comet.Size.Y/25,Clone.Lifetime.Max*Comet.size.Y/25)
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
		--sounds.Parent = Comet
		sounds:Play()
	end
end




spawn(function() -- "Disable" Floating forces
	repeat
		local NegativeRegion = (Comet.CFrame.p - Vector3.new(Properties.CurrentRadius, Properties.CurrentRadius, Properties.CurrentRadius))
		local PositiveRegion = (Comet.CFrame.p + Vector3.new(Properties.CurrentRadius, Properties.CurrentRadius, Properties.CurrentRadius))
		local Region = Region3.new(NegativeRegion, PositiveRegion)
		local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Creator.Character,Comet},850)
		--local TaggedHumanoids = {}
		for _,hit in pairs(Parts) do
			for _,forces in pairs(hit:GetChildren()) do
				if forces:IsA("BodyMover") then
					forces:Destroy()
				end
				--[[if forces:IsA("BodyVelocity") then
					forces.MaxForce = Vector3.new(0,0,0)
					--print("Disabling Velocity")
				elseif forces:IsA("BodyForce") then
					forces.Force = Vector3.new(0,0,0)
					--print("Disabling Force")
				end]]
			end
		end
		wait(1/10)
		--Services.RunService.Heartbeat:Wait()
	until not Comet or not Comet.Parent
end)

wait(15)
Comet:Destroy()