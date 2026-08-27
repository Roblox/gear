--failsafe
Delay(30, function() 
	script:Destroy()
end)

function WaitFor(name)
	while not script:FindFirstChild(name) do script.ChildAdded:wait() end
	return script[name].Value
end

--get vars
local position = WaitFor('position')
local creator = WaitFor('creator')

--main effect code
function MakeSnakeBit()
	local part = Instance.new('Part')
	part.FormFactor = 'Custom'
	part.Size = Vector3.new(1,1,1)
	--part.TopSurface = 'Weld'
	--part.BottomSurface = 'Weld'
	--part.RightSurface = 'Weld'
	--part.LeftSurface = 'Weld'
	--part.FrontSurface = 'Weld'
	--part.BackSurface = 'Weld'
	--part.Material = 'Wood'
	part.CanCollide = false
	part.Anchored = true
	part.BrickColor = BrickColor.new(1021) --1021=`Camo`
	local mesh = Instance.new('SpecialMesh', part)
	mesh.MeshType = 'Sphere'
	return part
end

--first, get the torso of the creator to use
local torso = creator.Character:FindFirstChild('Torso')
if not torso then
	script:Destroy()
	return
end

function RunSnake()
	--
	Spawn(function()
	--
	local startT = tick()
	local LastT = startT
	--
	local baseR = 7+math.random()*4
	local baseT = math.random()
	--
	local modT = LastT+baseT
	--
	local thetaDir = math.random(0,1)*2-1
	local currentTheta = -1 - math.random()*2
	local currentSnakeH = 3 + 3*math.sin(4*modT)
	local currentRadius = baseR + 2.5*math.cos(5*modT)
	--
	local function getCurrentPoint()
		return Vector3.new(math.sin(currentTheta)*currentRadius, 
		                   currentSnakeH,
		                   math.cos(currentTheta)*currentRadius)
	end

	--now, we need to `drag arroud` the player in a circle creating a
	--trail, and also making the trail dissappear after a certair duration
	local currentTail = {}
	local bit1 = MakeSnakeBit()
	bit1.Parent = game.Workspace
	bit1.Anchored = false
	local bit1Weld = Instance.new('Weld', newBit)
	bit1Weld.Part0 = centerPart
	bit1Weld.Part1 = bit1
	currentTail[1] = { 
		Part = bit1;
		At = getCurrentPoint(); 
		Timestamp = LastT;
		Weld = bit1Weld;
	}

	--centerPart
	local centerPart = Instance.new('Part', game.Workspace)
	centerPart.CanCollide = false
	centerPart.CFrame = CFrame.new(torso.Position)
	centerPart.Size = Vector3.new(2,2,2)
	centerPart.Transparency = 1
	local hold = Instance.new('BodyPosition', centerPart)
	hold.Name = 'Hold'
	hold.maxForce = Vector3.new(1000000,1000000,10000000)
	hold.position = torso.Position
	hold.P = 1000000
	hold.D = 1000
	game.Debris:AddItem(centerPart, 2)

	--now loop
	while tick()-startT < 1 do
		local t = tick()
		local dt = t-LastT
		LastT = t
		local modT = LastT+baseT
		--------------------------
		--rotate at 6 radians per second
		currentTheta = currentTheta + 7*dt*thetaDir
		currentSnakeH = 3 + 3*math.sin(4*modT)
		currentRadius = baseR + 2.5*math.cos(5*modT)

		--update the currently expanding function
		local pos = getCurrentPoint()
		local lastSeg = currentTail[#currentTail]
		local distFromLast = (lastSeg.At-pos).magnitude
		lastSeg.Weld.Part1 = nil
		lastSeg.Part.Size = Vector3.new(0.6,0.6,distFromLast)
		lastSeg.Weld.Part1 = lastSeg.Part
		lastSeg.Weld.C0 = CFrame.new(lastSeg.At, pos)*CFrame.new(0,0,-distFromLast/2)

		--make a new seg
		if distFromLast > 1.5 then
			local newBit = MakeSnakeBit()
			newBit.Parent = game.Workspace
			newBit.Size = Vector3.new(0.6,0.6,0.6)
			newBit.Anchored = false
			--
			local newBitWeld = Instance.new('Weld', newBit)
			newBitWeld.Part0 = centerPart
			newBitWeld.Part1 = newBit
			newBitWeld.C0 = CFrame.new(pos)
			--
			game.Debris:AddItem(newBit, 2)
			--
			currentTail[#currentTail+1] = {
				Part = newBit;
				At = pos;
				Timestamp = LastT;
				Weld = newBitWeld;
			}
		end

		--now fade the other segments
		for _, seg in pairs(currentTail) do
			local segTime = math.min(1, (t-seg.Timestamp)/0.5)
			seg.Part.Transparency = segTime
		end

		--update centerpart
		centerPart.Hold.position = torso.Position

		---------------------------
		wait()
	end
	--
	for _, seg in pairs(currentTail) do
		seg.Part:Destroy()
	end
	centerPart:Destroy()
	--
	end)
end


--the main script. Create 3 snakes
RunSnake()
wait(0.1)
RunSnake()
wait(0.1)
RunSnake()
wait(0.1)
RunSnake()

--now damage all the people around me
for _, p in pairs(game.Players:GetChildren()) do
	local torso = p.Character:FindFirstChild('Torso')
	if torso and (torso.Position-position).magnitude < 12 then
		if p ~= creator then
			local dir = (torso.Position-position).unit
		------------ stolen from dagger of time to push the character
			local force = Instance.new("BodyVelocity")
			force.velocity = Vector3.new(0,1,0)
			force.Parent = torso
			torso.Velocity = dir*250
			game.Debris:AddItem(force, 0.5)
		------------
			local hum = torso.Parent:FindFirstChild('Humanoid')
			local tag = script.creator:Clone()
			tag.Parent = hum
			game.Debris:AddItem(tag, 2)
			if hum then
				hum:TakeDamage(100)
			end
		end
	end
end

--and kill the script
wait(2)
script:Destroy()
