-- // Updated for R15 avatars by StarWars

-- //Fixed Replication issue by TakeoHonorable

--remove us if all else fails

local Debris = (game:FindService("Debris") or game:GetService("Debris"))
local Players = (game:FindService("Players") or game:GetService("Players"))
Debris:AddItem(script.Parent, 30)

local Tick,Cframe,Angles,Vec3,Instant,random,Wait,sqrt,color3,Pairs,sin,inf,pi = tick,CFrame.new,CFrame.Angles,Vector3.new,Instance.new,math.random,wait,math.sqrt,Color3.new,pairs,math.sin,math.huge,math.pi

local Spawn = spawn
----------------------------------------

local DAMAGE_PER_SECOND = 10

local Grenade = script.Parent
local GrenadeScript = Grenade:WaitForChild("GrenadeScript")
local Creator = GrenadeScript:WaitForChild("creator")
local Character = Creator.Value.Character
local ExplodeSound = Grenade:WaitForChild("ExplodeSound")

---------------------------------------

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instant("ObjectValue")
		Creator_Tag.Name = "creator"
		Creator_Tag.Value = player
	
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in Pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

local Handling = false
Grenade.Touched:Connect(function(part)
	--ignore collisions with firer's stuff
	if Character and part:IsDescendantOf(Character) then return end
	if not part or not part.Parent or not part.CanCollide then return end
	if Handling then return end
	Handling = true

	--end grenade
	Grenade.Anchored = true
	Grenade.CanCollide = false
	Grenade.Transparency = 1

	--play sound
	ExplodeSound:Play()

	--
	local basePos = Grenade.Position
	local upsideDownCF = Angles(0,0,pi)

	--do explode
	local BlastPart = Instant('Part', workspace)
	BlastPart.FormFactor = 'Custom'
	BlastPart.Size = Vec3(1,1,1)
	BlastPart.Transparency = 0.3
	BlastPart.Anchored = true
	BlastPart.CanCollide = false
	BlastPart.Archivable = false
	BlastPart.CFrame = Cframe(Grenade.Position)*Angles(-pi/2,0,0)
	local BlastCFrame = Cframe(Grenade.Position)*Angles(-pi/2,0,0)
	local BlastMesh = Instant('SpecialMesh', BlastPart)
	BlastMesh.MeshId = 'http://www.roblox.com/asset/?id=1080954'
	BlastMesh.TextureId = 'http://www.roblox.com/asset/?id=70759279'
	Debris:AddItem(BlastPart, 10)

	Spawn(function()
		for i = 0, 1, 0.2 do
			Wait()
			BlastPart.CFrame = Cframe(0, sqrt(i)*10,0)*BlastCFrame
			BlastMesh.Scale = Vec3(4 + 4*i, 4 + 4*i, 4 + sqrt(i)*24)
		end
		for i = 0, 1, 0.1 do
			Wait()
			BlastPart.CFrame = Cframe(0,10 - i*i*4,0)*BlastCFrame
			BlastMesh.Scale = Vec3(8 + i*2, 8 + i*2, 28 - i*i*8)
			BlastPart.Transparency = 0.3 + 0.7*i*i
		end
		BlastPart:Destroy()
	end)

	Wait(0.2)

	--create clouds
	local cloudList = {}
	for i = 1, 10 do
		local cloud = {}
		cloud.A = random()*10
		cloud.B = random()*10
		cloud.C = random()*10
		cloud.Velocity = Vec3(random()-0.5, 0, random()-0.5)*6
		--
		local part = Instant('Part')
		part.Anchored = true
		part.CanCollide = false
		part.Archivable = false
		part.FormFactor = 'Custom'
		part.Shape = 'Ball'
		part.Size = Vec3(6,6,6)
		part.Transparency = 0.2
		part.CFrame = Cframe(basePos + Vec3(random(-3,3), 2, random(-3,3)))*upsideDownCF
		part.TopSurface = 'Smooth'
		part.BottomSurface = 'Smooth'
		part.Name = 'PoisonCloud'
		--
		local mesh = Instant('SpecialMesh', part)
		mesh.MeshId = 'http://www.roblox.com/asset/?id=1095708'
		mesh.TextureId = 'http://www.roblox.com/asset/?id=70759279'
		mesh.Scale = Vec3(5,8,7)
		mesh.Name = 'Mesh'
		--
		local smoke = Instant('Smoke', part)
		smoke.Color = color3(0,1,0)
		smoke.Opacity = 0.6
		smoke.RiseVelocity = 0
		smoke.Size = 0.6
		smoke.Name = 'Smoke'
		--
		cloud.Part = part
		--
		cloudList[#cloudList+1] = cloud
	end

	--track touching
	local LastTimeHumanoidDamagedMap = {}
	local TouchingPartsMap = {}
	local TouchingHumanoidMap = {}
	for _, cloud in Pairs(cloudList) do
		cloud.Part.Touched:Connect(function(part)
			if not part or not part.parent then return end
			local hum = part.Parent:FindFirstChildOfClass('Humanoid')
			if hum and hum.Parent and not IsTeamMate(Players:GetPlayerFromCharacter(hum.Parent),Creator.Value) and Players:GetPlayerFromCharacter(hum.Parent) ~= Creator.Value then
				TouchingHumanoidMap[hum] = true
				hum.WalkSpeed = 4

				--initial damage
				if not LastTimeHumanoidDamagedMap[hum] then
					UntagHumanoid(hum)
					TagHumanoid(hum,Creator.Value)
					hum:TakeDamage(10)
					LastTimeHumanoidDamagedMap[hum] = Tick()
				end
			end
		end)
	end

	--put the clouds into the workspace
	for _, cloud in Pairs(cloudList) do
		Debris:AddItem(cloud.Part, 15) --by 15 second we should have been done, 
		                                    --ensure that we don't leave behind anything if all else fails.
		cloud.Part.Parent = workspace
	end

	--do stuff
	local StartTime = Tick()
	local LastTime = StartTime
	while true do
		--timestep
		Wait()
		local Now = Tick()
		local dt = Now - LastTime
		local Elapsed = Now-StartTime
		LastTime = Now

		--progress
		local T = Elapsed/10

		--end
		if T > 1 then break end

		--do effects to clouds
		for _, cloud in Pairs(cloudList) do
			cloud.Part.CFrame = cloud.Part.CFrame * Cframe(cloud.Velocity*dt*(1-T))
			cloud.Part.Transparency = 0.2 + 0.8*T
			cloud.Part.Mesh.Scale = Vec3(5 + 2*sin((cloud.A/10+1)*Elapsed),
			                                    8,
			                                    7 + 2*sin((cloud.B/10+1)*Elapsed))
			cloud.Part.Smoke.Opacity = 0.6 - 0.6*T*T
			cloud.Part.Smoke.Size = 0.6 - 0.6*T
			cloud.Part.Smoke.Color = 
				color3(0   + 0.3*(0.5*sin((cloud.A/10+1)*Elapsed+cloud.C)+0.5),
				           0.5 + 0.5*(0.5*sin((cloud.C/10+1)*Elapsed+cloud.B)+0.5),
				           0   + 0.3*(0.5*sin((cloud.B/10+1)*Elapsed+cloud.A)+0.5))
		end

		--do damage to humanoids
		for hum in Pairs(TouchingHumanoidMap) do
			local lastT = (LastTimeHumanoidDamagedMap[hum] or Tick())
			if Now-lastT > 0.5 then
				local torso = (hum.Parent or game):FindFirstChild('HumanoidRootPart')
				if torso then
					--find a nearby cloud
					local nearestCloud, atDist = nil, inf
					for _, cloud in Pairs(cloudList) do
						local sep = (cloud.Part.Position - torso.Position).magnitude
						if sep < atDist then
							nearestCloud = cloud
							atDist = sep
						end
					end
					if atDist < 5 then
						local dmg = (Now-lastT)*DAMAGE_PER_SECOND
						UntagHumanoid(hum)
						TagHumanoid(hum,Creator.Value)
						hum:TakeDamage(dmg)
						LastTimeHumanoidDamagedMap[hum] = Now
					else
						TouchingHumanoidMap[hum] = nil
						LastTimeHumanoidDamagedMap[hum] = nil
						hum.WalkSpeed = 16
					end
				else
					TouchingHumanoidMap[hum] = nil
				end
			end
		end
	end


	Wait(2) --wait for the clouds to fade a bit
	--delete the clouds
	for _, cloud in Pairs(cloudList) do
		cloud.Part:Destroy()
	end
	--fix all of the humanoids
	for hum in Pairs(TouchingHumanoidMap) do
		hum.WalkSpeed = 16
	end

	--and finally get rid of us
	Grenade:Destroy()
end)

