function WaitFor(name)
	while not script:FindFirstChild(name) do script.ChildAdded:wait() end
	return script[name].Value
end

--get vars
local cframe = WaitFor('cframe')
local creator = WaitFor('creator')

--get my humanoid
local myHum = creator.Character:FindFirstChild('Humanoid')

--main effect code

--the snake bit code. We will be using a lot of 'snake bits'
function MakeSnakeBit()
	local part = Instance.new('Part')
	part.FormFactor = 'Custom'
	part.Size = Vector3.new(1,1,1)
	part.TopSurface = 'Weld'
	part.BottomSurface = 'Weld'
	part.RightSurface = 'Weld'
	part.LeftSurface = 'Weld'
	part.FrontSurface = 'Weld'
	part.BackSurface = 'Weld'
	--part.Material = 'Wood'
	part.CanCollide = false
	part.Anchored = true
	part.BrickColor = BrickColor.new(1021) --1021=`Camo`
	local mesh = Instance.new('SpecialMesh', part)
	mesh.MeshType = 'Sphere'
	return part
end

--slerp function that I need
local function Slerp(t, a, b)
	local om = math.acos(a:Dot(b))
	local sin_om = math.sin(om)
	return (math.sin((1-t)*om)/sin_om)*a + (math.sin(t*om)/sin_om)*b
end

--first, make one bit which will be the "shot" that flies through the air
local shot = MakeSnakeBit()
shot.Parent = game.Workspace
shot.CFrame = cframe --set the initial CFrame

local ShotSpeed = 50
local FlightDist = 0
local FlightMaxDist = 300
local HeatSeekingDistance = 20

--make the shot fly using raycasting. It's also heat-seeking for nearby players
local LastTime = tick()
local IT = 0
local HeatSeekingTarget = nil


--
function SnareHumanoid(hum, dir)
	--make sure they have a torso
	local torso = hum.Parent:FindFirstChild('Torso')
	if not torso then return end

	--set them to platformstanding
	hum.PlatformStand = true

	--tag them. We award KOs for shoving people off of odges
	-- trolollololol
	local tag = script.creator:Clone()
	tag.Parent = hum
	game.Debris:AddItem(tag, 4)

	--and shove them in the direction we were travelling
	local Shove = Instance.new('BodyVelocity')
	Shove.Name = 'Shove'
	Shove.velocity = dir*100
	Shove.maxForce = Vector3.new(5000,5000,5000)
	Shove.Parent = torso
	game.Debris:AddItem(Shove, 0.2)

	--also do same damage
	hum:TakeDamage(35)

	--create ensnare pieces
	local parts = {}
	for theta = 0, math.pi*4, math.pi/3 do 
		local dat = {}
		dat.Part = MakeSnakeBit()
		dat.Part.Parent = game.Workspace
		dat.Offset = CFrame.new(math.sin(theta)*2.5, theta/2, math.cos(theta)*2.5)
		parts[#parts+1] = dat
	end
	for i = 1, #parts-1 do
		local dat = parts[i]
		local datNext = parts[i+1]
		--
		dat.Part.Size = Vector3.new(0.6, 0.6, (dat.Offset.p-datNext.Offset.p).magnitude+0.4)
		dat.HOffset = -(dat.Offset.p-datNext.Offset.p).magnitude/2
	end

	--now draw ensnace pieces
	local startT = tick()
	for t = 1, 45 do
		local elapsed = tick()-startT
		local trans = math.min(elapsed/1.5, 1)
		local torsocf = torso.CFrame*CFrame.new(0, elapsed*2-4, 0)*CFrame.Angles(0, (tick()%10000)*6, 0)
		local thisPos = (torsocf*parts[1].Offset).p
		for i = 1, #parts-1 do
			local this = parts[i]
			local nextPos = (torsocf*parts[i+1].Offset).p
			this.Part.CFrame = CFrame.new(thisPos, nextPos)*
			                   CFrame.new(0, 0, this.HOffset)
			this.Part.Transparency = trans
			thisPos = nextPos
		end
		--
		wait(0.03)
	end

	--end anim
	for _, dat in pairs(parts) do
		dat.Part:Destroy()
	end

	--stop standing
	hum.PlatformStand = false
end


while true do
	wait()
	--update the iteration counter
	IT = IT+1

	--get the timestep
	local t = tick()
	local dt = (t-LastTime)
	LastTime = t

	--distance to travel
	local distToTravel = dt*ShotSpeed
	FlightDist = FlightDist + distToTravel

	--max flight distance
	if FlightDist > FlightMaxDist then
		shot:Destroy()
		script:Destroy()
		break
	end

	--first, cast a  ray to see if we will hit anything
	local ray = Ray.new(shot.Position, shot.CFrame.lookVector*(distToTravel+2))
	local part, at = game.Workspace:FindPartOnRay(ray)
	if part and (not part.CanCollide 
		or part.Parent == creator.Character
		or part.Parent.Parent == creator.Character) 
	then
		--"tunnel" through cancollide false parts
		local ignore = {}
		while part and (not part.CanCollide
			or part.Parent == creator.Character 
			or part.Parent.Parent == creator.Character)
		do
			ignore[#ignore+1] = part
			part, at = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
		end
	end

	--did we hit something?
	if part then
		local dir = shot.CFrame.lookVector
		shot:Destroy() --no need for the shot anymore
		--
		local hum = (part.Parent or game):FindFirstChild('Humanoid')
		if hum then
			--entangle the humanoid
			print("Hit, ", part.Name)
			SnareHumanoid(hum, dir)
			script:Destroy()
			break
		else
			--get rid of us, nothing to do
			script:Destroy()
			break
		end
	end

	--move the shot ahead
	local newCF = shot.CFrame*CFrame.new(0,0,-distToTravel)

	--resize the shot
	shot.Size = Vector3.new(1+0.5*math.sin(7*t), 1+0.5*math.cos(5*t), 4+math.cos(9*t))

	--clear heatseeking if the target went away
	if HeatSeekingTarget and not HeatSeekingTarget.Parent then
		HeatSeekingTarget = nil
	end

	--only update heat seeking every 5'th frame if we don't have a target, or
	--every second or so if we do
	if (not HeatSeekingTarget and IT%5 == 0) or IT%30 == 0 then 
		local dir = newCF.lookVector
		local at = newCF.p
		local function DistToPath(pos)
			local relPos = pos - at
			local proj = dir*(dir:Dot(relPos))
			return (relPos - proj).magnitude
		end
		local NearestTorso = nil
		local Distance = math.huge
		for _, p in pairs(game.Players:GetChildren()) do
			if p ~= creator then
				local torso = p.Character:FindFirstChild('Torso')
				if torso then
					local mag = (shot.Position-torso.Position).magnitude
					local dist = DistToPath(torso.Position)
					if dist < Distance and dist < HeatSeekingDistance and mag < 140 then
						NearestTorso = torso
						Distance = dist
					end
				end
			end
 		end
		--too expensive to search the workspace in a real game, just search players
		--[[
		for _, ob in pairs(game.Workspace:GetChildren()) do
			if ob:FindFirstChild('Humanoid') and 
				ob:FindFirstChild('Torso') and 
				not game.Players:GetPlayerFromCharacter(ob)
			then
				local torso = ob.Torso
				local mag = (shot.Position-torso.Position).magnitude
				local dist = DistToPath(torso.Position)
				if dist < Distance and dist < HeatSeekingDistance and mag < 140 then
					NearestTorso = torso
					Distance = dist
				end
			end
		end
		]]
		if NearestTorso then
			HeatSeekingTarget = NearestTorso
		end
	end

	--use heat-seeking
	if HeatSeekingTarget then
		--we need to bend towards the target at a fixed angular rate
		local dir = newCF.lookVector
		local dirToTarget = (HeatSeekingTarget.Position-newCF.p).unit
		--get the angle between them
		local theta = math.acos(dir:Dot(dirToTarget))
		if theta > 0.01 then
			local thetaToTurn = dt*1.0
			thetaToTurn = math.min(theta, thetaToTurn)
			--now do a slerp
			local newDir = Slerp(thetaToTurn/theta, dir, dirToTarget)
			--and edit the CFrame
			newCF = CFrame.new(newCF.p, newCF.p+newDir)
		end
	end

	--and apply the new CFrame
	shot.CFrame = newCF
end

script:Destroy()



