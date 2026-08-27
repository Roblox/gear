local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
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

local BaseUrl = "http://www.roblox.com/asset/?id="

local Star = script.Parent

local Creator = script:WaitForChild("Creator",10).Value

function Damage(hit,TotalDamage)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health <=0 or Hum == Creator.Character:FindFirstChildOfClass("Humanoid") or ForceField then return end
	
	if IsTeamMate(Creator,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	if not Hum.Parent:FindFirstChild("Stardust") then
		local StardustScript = script:WaitForChild("Stardust",10):Clone()
		StardustScript.Parent = Hum.Parent
		StardustScript.Disabled = false
	end
	spawn(function()
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Creator)
		Hum:TakeDamage(TotalDamage)

		--wait(.5)
	end)
end


local function Wait(para) -- bypasses the latency
	local Initial = tick()
	repeat
		Services.RunService.Heartbeat:Wait()
	until tick()-Initial >= para
end


local Seed = Random.new(tick())

local Sounds = {
	Twinkle = script:WaitForChild("Twinkle",10),
	Sparkle = script:WaitForChild("Sparkle",10),
}


local SpawnPos = Star.CFrame

local TwinkleSound = Sounds.Twinkle:Clone()
	TwinkleSound.Parent = Star
	TwinkleSound.TimePosition = 0.1
	TwinkleSound:Play()
	for i=1,60,1 do
		Star.Size = Vector3.new(1,1,1)*(i/60)*75
		Star.CFrame = SpawnPos:lerp(SpawnPos+Vector3.new(0,200,0),i/60)
		Star.Transparency = (1-(i/60))
		Services.RunService.Heartbeat:Wait()
	end
	local StarParticles = script:WaitForChild("StarParticles",10):GetChildren()
	for _,particle in pairs(StarParticles) do
		if particle:IsA("ParticleEmitter") then
			local Clone = particle:Clone()
			Clone.Parent = Star:WaitForChild("Attachment",10)
			
			local property = Clone.Size.Keypoints
			for step,value in pairs(property) do
				--print(property[step].Time,property[step].Value)
				property[step] = NumberSequenceKeypoint.new(property[step].Time,property[step].Value*Star.Size.X,property[step].Envelope)
				--print(times,value,property[times])
			end
			Clone.Size = NumberSequence.new(property)
			Clone.Enabled = true
		end
	end
	
	
	local Touch
	
	Touch = Star.Touched:Connect(function(hit)
		Damage(hit,math.huge)
	end)
	
	local StarFall = true
	local ShardContent = script:WaitForChild("ShardContent",10):GetChildren()
	
	spawn(function()
		local Shard = Create("Part"){
				Material = Enum.Material.Neon,
				Size = Vector3.new(1,1,1)*5,
				Anchored = false,
				CanCollide = false,
				Name = "StarShard",
				Locked = true,
				Transparency = 0,
				Shape = Enum.PartType.Ball,
				CFrame = Star.CFrame,
		}
		local TopAttachment = Create("Attachment"){
			Position = Vector3.new(0,Shard.Size.y/2,0),
			Name = "TopAttachment",
			Parent = Shard
		}
		local BottomAttachment = Create("Attachment"){
			Position = Vector3.new(0,-Shard.Size.y/2,0),
			Name = "BottomAttachment",
			Parent = Shard
		}
		for _,stuff in pairs(ShardContent) do
			if stuff:IsA("ParticleEmitter") then
				local particle = stuff:Clone()
				particle.Parent = Shard
			elseif stuff:IsA("Trail") then
				local trail = stuff:Clone()
				trail.Attachment0 = TopAttachment;
				trail.Attachment1 = BottomAttachment;
				trail.Parent = Shard
				trail.Enabled = true
			end
		end
		repeat
			--wait(Seed:NextNumber(.1,.5))
			local Proj = Shard:Clone()
			for _,v in pairs(Proj:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
			local SparkleClone = Sounds.Sparkle:Clone()
			SparkleClone.Parent = Proj
			SparkleClone:Play()
			local ShardScript = script:WaitForChild("StarShard",10):Clone()
			ShardScript:WaitForChild("Creator").Value = Creator
			ShardScript.Parent = Proj
			ShardScript.Disabled = false
			--Services.Debris:AddItem(Proj,7)
			Proj.CFrame = Star.CFrame
			Proj.Parent = workspace
			Proj:SetNetworkOwner(nil)
			Proj.Velocity = (Star.CFrame*CFrame.Angles(0,math.rad(Seed:NextInteger(0,360)),0)).lookVector*Seed:NextNumber(10,100)
			Wait(1/10)
			--Services.RunService.Heartbeat:Wait()
		until not Star or not Star.Parent or not StarFall
		--print("Supernova")
		
		local Attachment = Star:FindFirstChildOfClass("Attachment")
		for _,particles in pairs(Attachment:GetChildren()) do
			if particles:IsA("ParticleEmitter") then
				particles.Enabled = false
			end
		end
		
		wait(2)
		if Attachment then
			local Wave = Create("Part"){
				Name = "Wave",
				Size = Vector3.new(1,1,1)*0,
				Locked = true,
				Anchored = true,
				CanCollide = false,
				Material = Enum.Material.Neon,
				Transparency = 0.5,
				Color = Color3.fromRGB(255,255,255),
				CFrame = Star.CFrame*CFrame.Angles(math.rad(90),math.rad(0),math.rad(0)),
				Parent = Star
			}
			local WaveMesh = Create("SpecialMesh"){
				MeshType = Enum.MeshType.FileMesh,
				Offset = Vector3.new(0,0,0),
				Scale = Vector3.new(0,0,0),
				VertexColor = Vector3.new(1,1,1)*10^5,
				MeshId = BaseUrl.."3270017",
				TextureId = BaseUrl.."883311537",
				Parent = Wave
			}
			local SupernovaParticle = script:WaitForChild("Supernova",10)
			SupernovaParticle.Parent = Attachment

			SupernovaParticle:Emit(SupernovaParticle.Rate)
			script:WaitForChild("Explosion",10):Play()
			local OrigSize = Star.Size
			for i=1,60,1 do
				if Star and Wave then
					Star.Transparency = (i/60)
					Wave.Transparency = Star.Transparency
					Star.Size = OrigSize:Lerp(OrigSize*5.5,i/60)
					WaveMesh.Scale = Vector3.new(1,1,0):Lerp(Vector3.new(85,85,0)*8,i/60)
					Services.RunService.Heartbeat:Wait()	
				end
			end
			if Touch then Touch:Disconnect();Touch = nil end
			wait(script:WaitForChild("Explosion",10).TimeLength)
			Star:Destroy()
		end
		
	end)
	
	wait(10)
	StarFall = false
	