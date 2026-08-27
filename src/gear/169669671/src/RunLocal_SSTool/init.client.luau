local Players = Game:GetService('Players')
local RunService = Game:GetService('RunService')

local Character = script.Parent
local Player = Players:GetPlayerFromCharacter(Character)
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera

local PartList = {
	{
		-- 15 degrees
		Sweep = 20;
		Mesh = 'rbxassetid://168892318';
		CFrame = CFrame.new(-2.028, 0.003, 0.063, 0.482962936, -0.258818984, -0.836516321, 0.129409432, 0.965925813, -0.224143848, 0.866025388, 6.70552254e-008, 0.5);
	},
	{
		-- 180 degrees
		Sweep = 180;
		Mesh = 'rbxassetid://168892343';
		CFrame = CFrame.new(-0.500, -0.169, -0.275, -0.546336055, 0.136979967, 0.826288223, -0.0343417339, 0.982042372, -0.185506523, -0.836861134, -0.129725233, -0.531821132);
	},
	{
		-- 30 degrees
		Sweep = 40;
		Mesh = 'rbxassetid://168892363';
		CFrame = CFrame.new(-1.738, -0.056, -0.034, 0.913205206, -0.157400429, -0.375873566, 0.0347544663, 0.949112594, -0.313011229, 0.406014502, 0.272780538, 0.872205615);
	},
	{
		-- 250 degrees
		Sweep = 250;
		Mesh = 'rbxassetid://168892387';
		CFrame = CFrame.new(0.033, -0.053, -0.015, -0.947963715, 0.129520699, 0.290842265, 0.0606384911, 0.970239401, -0.23443158, -0.312550366, -0.20459649, -0.927605391);
	},
	{
		-- 200 degrees
		Sweep = 200;
		Mesh = 'rbxassetid://168892408';
		CFrame = CFrame.new(-0.293, -0.027, -0.226, -0.517871141, -0.154164821, -0.841452301, 0.081988588, 0.970154822, -0.228204504, 0.85152036, -0.187170446, -0.489775389);
	},
}

local MainBodyPartList = {
	'Head', 'Torso', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg';
}

local function DuplicateCharacterInto(character, parent)
	local partSet = {}
	--
	for _, ch in pairs(character:GetChildren()) do
		if ch:IsA('Clothing') then
			ch:Clone().Parent = parent
		end
	end
	for _, partName in pairs(MainBodyPartList) do
		local ch = Character:FindFirstChild(partName)
		if ch and ch:IsA('BasePart') then
			local c = ch:Clone()
			c.Parent = parent
			c.Anchored = true
			c.CanCollide = false
			c.TopSurface = 'Smooth'
			c.BottomSurface = 'Smooth'
			c.RightSurface = 'Smooth'
			c.LeftSurface = 'Smooth'
			c.FrontSurface = 'Smooth'
			c.BackSurface = 'Smooth'
			c:BreakJoints()
			partSet[c.Name] = c
		end
	end
	--
	return partSet
end

local function CreateEffectModel(character)
	local model;
	if Workspace.FilteringEnabled then
		model = Instance.new('Configuration', character)
	else
		model = Instance.new('Configuration', Workspace.CurrentCamera)
	end
	model.Name = Player.Name.."_EffectModel"
	return model
end

local function CreatePartPool()
	local this = {}
	
	local mPartPoolPtr = 0
	local mPartPool = {}
	
	function this:Allocate()
		mPartPoolPtr = mPartPoolPtr + 1
		local part = mPartPool[mPartPoolPtr]
		if not part then
			part = Instance.new('Part')
			part.Anchored = true
			part.CanCollide = false
			part.FormFactor = 'Custom'
			part.TopSurface = 'Smooth'
			part.BottomSurface = 'Smooth'
			part.BrickColor = BrickColor.new(23)
			local box = Instance.new('SelectionBox', part)
			box.Adornee = part
			box.Transparency = 0.3
			box.Color = BrickColor.new(1010)
			--
			mPartPool[mPartPoolPtr] = part
		end
		return part
	end
	
	function this:ResetPointer()
		mPartPoolPtr = 0
	end
	
	function this:HideRest()
		for i = mPartPoolPtr+1, #mPartPool do
			mPartPool[i].Parent = nil
		end
	end
	
	function this:HideAll()
		for _, part in pairs(mPartPool) do
			part.Parent = nil
		end
	end
	
	function this:Destroy()
		for _, part in pairs(mPartPool) do
			part:Destroy()
		end
	end
	
	return this
end

local function CreateBlurEffect(parent, partSet)
	local this = {}
	local mTransparency = 0.5
	local mVelocity = Vector3.new(0, 0, 0)
	local mRiseDir = Vector3.new(0, 1, 0)
	--
	local mPartList = {}
	local mTweenSet = {}
	--
	local tm = tick()
	for part, _ in pairs(partSet) do
		local dat = {}
		dat.Part = part
		dat.NextEmit = tm + math.random()*0.5
		table.insert(mPartList, dat)
	end
	
	function this:SetTransparency(trans)
		mTransparency = trans
	end
	function this:SetVelocity(velo)
		mVelocity = velo
	end
	
	local function emit(part)
		local dir = (CFrame.new(Vector3.new(), mRiseDir) * CFrame.Angles(0, 0, math.pi*2*math.random()) * CFrame.Angles(2*math.random(), 0, 0)).lookVector
		local dat = {}
		dat.CFrame = part.CFrame
		dat.Direction = dir
		dat.Emitted = tick()
		dat.Lifetime = 0.4 + math.random()*0.3
		dat.SpeedFactor = 1 + (math.random()*2-1)*0.5
		dat.BaseSize = part.Size
		dat.Velocity = mVelocity
		local newPart = part:Clone()
		dat.Part = newPart
		newPart.Anchored = true
		newPart.CanCollide = false
		newPart.FormFactor = 'Custom'
		newPart.Transparency = mTransparency
		newPart.BrickColor = BrickColor.new(23)
		newPart.TopSurface = 'Smooth'
		newPart.BottomSurface = 'Smooth'
		newPart.RightSurface = 'Smooth'
		newPart.LeftSurface = 'Smooth'
		newPart:BreakJoints()
		mTweenSet[dat] = true
	end
	
	function this:Update(dt)
		-- Update rise dir	
		local desiredRise = (Vector3.new(0, 2, 0) - mVelocity).unit
		if (desiredRise - mRiseDir).magnitude <= 2*dt then
			mRiseDir = desiredRise
		else
			mRiseDir = (mRiseDir + (desiredRise - mRiseDir).unit * (2*dt)).unit
		end	
		
		-- Update part list
		for _, dat in pairs(mPartList) do
			if tick() > dat.NextEmit then
				emit(dat.Part)
				dat.NextEmit = tick() + (0.1 + math.random()*0.2)
			end
		end
		
		-- Update the tween parts
		for dat, _ in pairs(mTweenSet) do
			local frac = (tick() - dat.Emitted) / dat.Lifetime
			if frac > 1 then
				mTweenSet[dat] = nil
				dat.Part:Destroy()
			else
				dat.Part.Parent = parent
				dat.Part:BreakJoints()
				dat.Part.Size = dat.BaseSize * (1 - 0.3*frac)
				dat.CFrame = dat.CFrame + (frac^1.5*dt*20*dat.SpeedFactor)*dat.Direction + dat.Velocity*dt
				dat.Part.CFrame = dat.CFrame
				dat.Part.Transparency = mTransparency + (1 - mTransparency)*(frac^1.5)
			end
		end
	end
	
	function this:Destroy()
		for dat, _ in pairs(mTweenSet) do
			dat.Part:Destroy()
		end
	end
	
	return this
end

local function CreateSpinEffect(parent)
	local this = {}
	
	local mTransparency = 0.5
	local mCFrame = CFrame.new()
	
	local mRingSet = {}
	local mRingCount = 0
	local mNextRingAt = tick() + 0.5
	local mDesiredRingCount = 8
	
	function this:SetTransparency(trans)
		mTransparency = trans
	end
	
	function this:SetCFrame(cf)
		mCFrame = CFrame.new(cf.p)
	end
	
	function this:AddRing()
		local ring = PartList[math.random(1, #PartList)] 
		mRingCount = mRingCount + 1
		--
		local dat = {}
		dat.Started = tick()
		dat.Created = dat.Started
		dat.Mode = 'In'
		dat.PartRotOffset = (ring.CFrame - ring.CFrame.p)
		dat.PartMoveOffset = ring.CFrame.p
		--
		local part = Instance.new('Part')
		part.FormFactor = 'Custom'
		part.Size = Vector3.new(1, 1, 1)
		part.TopSurface = 'Smooth'
		part.BottomSurface = 'Smooth'
		part.Anchored = true
		part.CanCollide = false
		local mesh = Instance.new('SpecialMesh', part)
		mesh.TextureId = 'rbxassetid://168892465'
		mesh.MeshId = ring.Mesh
		mesh.VertexColor = Vector3.new(0, 0.5, 1)
		--
		dat.Part = part
		dat.Mesh = mesh
		dat.VerticalOffset = 4*(math.random()*2-1)
		dat.Radius = 2 + 5*math.sqrt(1 - math.abs(dat.VerticalOffset/4))
		dat.Theta = (math.random()*math.pi*2)
		dat.TurnDirection = (math.random(0,1)*2-1)
		dat.TurnSpeed = 3 + (math.random()*2-1)*2
		mRingSet[dat] = true
	end
	
	function this:ShedRing()
		for ring, _ in pairs(mRingSet) do
			if ring.Mode == 'Norm' then
				ring.Mode = 'Out'
				ring.Started = tick()
				mRingCount = mRingCount - 1
			end
		end
	end
	
	function this:Update(dt)
		local now = tick()
		
		if now > mNextRingAt then			
			if mRingCount > mDesiredRingCount then
				this:ShedRing()
			else
				this:AddRing()
			end
			mNextRingAt = now + (0.1 + math.random()*(0.3 * (mRingCount / mDesiredRingCount)))
		end
		
		for ring, _ in pairs(mRingSet) do
			local frac = (now - ring.Started) / 2
			local radius = nil
			local trans = nil
			if ring.Mode == 'In' then
				if frac > 1 then
					ring.Mode = 'Norm'
				else
					local turnFactor = 0.2 + 0.8*(0.5+0.5*math.cos(frac*math.pi))^2
					local turnSpeed = ring.TurnSpeed + turnFactor*10
					ring.Theta = ring.Theta + dt*(ring.TurnDirection*turnSpeed)
					radius = ring.Radius + turnFactor*5
					trans = frac
				end
			elseif ring.Mode == 'Out' then
				if frac > 1 then
					mRingSet[ring] = nil
					ring.Part:Destroy()
				else
					radius = ring.Radius + 5*(frac^2)
					ring.Theta = ring.Theta + dt*(ring.TurnDirection*ring.TurnSpeed)
					trans = frac^2
				end
			end
			if ring.Mode == 'Norm' then
				radius = ring.Radius
				trans = 1
				ring.Theta = ring.Theta + dt*(ring.TurnDirection*ring.TurnSpeed)			
			end
			--
			if mRingSet[ring] then
				local sz = radius / 4
				ring.Mesh.Scale = Vector3.new(sz, 1, sz)
				ring.Part.Parent = parent
				ring.Part.CFrame = (mCFrame * CFrame.new(0, ring.VerticalOffset, 0) * CFrame.Angles(0, ring.Theta, 0) * CFrame.new(ring.PartMoveOffset*sz)) * ring.PartRotOffset
				ring.Part.Transparency = 1 - (1-mTransparency)*(1-trans)
			end
		end
	end
	
	return this
end

local function CreateLightningEffect(parent)
	local this = {}
	
	local mPartPool = CreatePartPool()
	local mActive = false
	local mActivatedAt = 0
	local mFrom = Vector3.new()
	local mTo = Vector3.new()
	local mLightningPath = {{P = mFrom; T = tick(); Expiry = 0}}
	local mLightningPart = Instance.new('Part')
	mLightningPart.Anchored = true
	mLightningPart.CanCollide = false
	mLightningPart.FormFactor = 'Custom'
	mLightningPart.Size = Vector3.new()
	mLightningPart.Transparency = 1
	local fire = Instance.new('Fire', mLightningPart)
	fire.Heat = 20
	fire.Color = Color3.new(10/255, 149/255, 255/255)
	fire.SecondaryColor = Color3.new(0, 0, 0)
	fire.Size = 5
	fire:Clone().Parent = mLightningPart
	local light = Instance.new('PointLight', mLightningPart)
	light.Brightness = 2
	light.Range = 4
	light.Color = Color3.new(0/255, 153/255, 255/255)
	
	local function tickPath(dt)
		local cachedPoints = {}
		mLightningPath[1].P = mFrom
		local i = 1
		local now = tick()	
		while true do	
			-- Fudge the current point		
			local currentPoint = mLightningPath[i]
			currentPoint.P = currentPoint.P + Vector3.new(math.random()*2-1, math.random()*2-1, math.random()*2-1)*(5*dt)
						
			-- Are we at the goal?	
			-- If we are then clear out the other points
			if (currentPoint.P - mTo).magnitude < 0.5 then
				for j = i+1, #mLightningPath do
					mLightningPath[j] = nil
				end
				break
			end
			
			-- Not at the goal, do we have a next point?
			local useNext;
			local nextPoint = mLightningPath[i+1]
			if nextPoint then
				local toNext = nextPoint.P - currentPoint.P
				local toGoal = mTo - currentPoint.P
				
				-- Is the next point near the goal?				
				if toGoal.magnitude < 4.6 then
					-- Just snap it to the goal
					nextPoint.P = mTo
					useNext = true
				else
					-- 
					if math.acos(toNext.unit:Dot(toGoal.unit)) > math.pi/2 then
						-- The next point is too far out of direction
						useNext = false
					else
						useNext = true
					end	
				end
			else
				useNext = false
			end		
			
			if useNext and (now - currentPoint.T) > currentPoint.Expiry then
				local fracThere = (currentPoint.P - mFrom).magnitude / (mFrom - mTo).magnitude	
				currentPoint.Expiry = math.random()*0.1 + 0.6*fracThere
				currentPoint.T = now
				useNext = false
			end
			
			-- If we can't use the next then we need to do some work
			if not useNext then
				-- Move all the points ahead to the cached list
				for j = i+1, #mLightningPath do
					table.insert(cachedPoints, mLightningPath[j])
					mLightningPath[j] = nil
				end
				
				-- Create the next point
				local toGoal = mTo - currentPoint.P
				if toGoal.magnitude < 4.5 then
					-- If we're close enough to the goal, just snap there
					table.insert(mLightningPath, {P = mTo; T = now; Expiry = math.random()*0.4})
				else
					-- Otherwise, perturb the direction
					local upwards = math.min(1, (now - mActivatedAt) / 0.8)
					if upwards == 1 then
						mActivatedAt = now
					end
					local dir = CFrame.new(Vector3.new(), toGoal) * CFrame.Angles(0.2 + upwards*0.5, 0, 0) * CFrame.Angles(0, 0, math.random()*math.pi*2) * CFrame.Angles(math.random()*math.pi/3, 0, 0)
					dir = dir.lookVector * (2 + math.random()*1)
					local fracThere = (currentPoint.P + dir - mFrom).magnitude / (mFrom - mTo).magnitude
					table.insert(mLightningPath, {
						P = currentPoint.P + dir;
						T = now;
						Expiry = math.random()*0.1 + 0.6*fracThere;
					})
				end
			end
			
			-- Done
			i = i + 1
			if i > 40 then
				break
			end
		end
	end
	
	local function drawPath()
		mPartPool:ResetPointer()
		for i = 1, #mLightningPath - 1 do
			local a = mLightningPath[i].P
			local b = mLightningPath[i+1].P
			--
			local frac = i / (#mLightningPath-1)
			local w = 0.2 + 0.2*(1 - 2*math.abs(frac - 0.5))
			--
			local part = mPartPool:Allocate()
			part.Size = Vector3.new(w, w, (a-b).magnitude)
			part.CFrame = CFrame.new(0.5*(a+b), b)
			part.Parent = parent
			part.Transparency = 1
		end
		mPartPool:HideRest()
		mLightningPart.CFrame = CFrame.new(mTo)
		mLightningPart.Parent = parent
	end
	
	function this:Set(from, to)
		mFrom = from
		mTo = to
	end
	
	function this:SetActive(state)
		if mActive == state then return end
		mActive = state
		if mActive then
			mActivatedAt = tick()
			mLightningPath[1].P = mFrom
			for i = 2, #mLightningPath do
				mLightningPath[i] = nil
			end
		else
			mPartPool:HideAll()
			mLightningPart.Parent = nil
		end
	end
	
	function this:Update(dt)
		if mActive then
			tickPath(dt)
			drawPath()
		end
	end
	
	function this:Destroy()
		mPartPool:Destroy()
	end
	
	return this
end

local BREAKOFF_TIME = 1
local FLOAT_FINISH_TIME = 3
local FLOAT_HEIGHT = 10
--
local RISE_VELOCITY = FLOAT_FINISH_TIME / FLOAT_HEIGHT

local function TransformationSequence(character)
	local torso = character:WaitForChild('HumanoidRootPart')
	local humanoid = character:WaitForChild('Humanoid')
	local dir = torso.CFrame.lookVector
	local transformBase = CFrame.new(torso.Position, torso.Position + Vector3.new(dir.X, 0, dir.Z))
	
	-- Remove the tools
	Delay(0.2, function()
		for _, tool in pairs(Player:WaitForChild('Backpack'):GetChildren()) do
			if tool:IsA('Tool') or tool:IsA('Hopperbin') then
				tool.Parent = nil
			end
		end
		for _, tool in pairs(Character:GetChildren()) do
			if tool:IsA('Tool') then
				tool.Parent = nil
			end
		end
	end)
	
	-- If not filtering, we can clone the viewLocal into the other clients
	local addViewCn;
	if not Workspace.FilteringEnabled then
		local viewLocal = script:WaitForChild('ViewLocal')
		for _, player in pairs(Players:GetChildren()) do
			if player ~= Player then
				Spawn(function()
					local cl = viewLocal:Clone()
					cl:WaitForChild('TargetCharacter').Value = character
					cl.Disabled = false
					while not player.Character do player.Changed:wait() end
					cl.Parent = player.Character
				end)
			end
		end
		-- .PlayerAdded does not work for other players on the client
		addViewCn = Players.ChildAdded:connect(function(player)
			if not player:IsA('Player') then return end
			Spawn(function()
				local cl = viewLocal:Clone()
				cl:WaitForChild('TargetCharacter').Value = character
				cl.Disabled = false
				while not player.Character do player.Changed:wait() end
				cl.Parent = player.Character
			end)			
		end)
	end
	
	-- Gather the parts to do the tween on
	local partsToTween = {}
	local function gatherParts(object)
		for _, ch in pairs(object:GetChildren()) do
			if ch:IsA('BasePart') then
				local tweenPart = {
					Part = ch;
				}
				table.insert(partsToTween, tweenPart)
			else
				gatherParts(ch)
			end
		end
	end
	gatherParts(character)
	
	-- The effect model
	local effectModel = CreateEffectModel(character)
	
	-- Duplicate the parts we want normally, but want to make fly away
	local flyAwayParts = DuplicateCharacterInto(character, effectModel)
	
	-- Put the body parts into a set
	local flyAwayPartSet = {}

	-- Decide what to do with each of the parts
	for _, dat in pairs(partsToTween) do
		if flyAwayParts[dat.Part.Name] then
			flyAwayPartSet[dat.Part] = true
			dat.Mode = 'BreakAway'
			dat.BreakAwayPart = flyAwayParts[dat.Part.Name]
		else
			dat.Mode = 'Fade'
		end
	end
	
	-- Anchor and ready the character
	torso.Anchored = true
	humanoid:ChangeState('Physics')
	
	-- Go into the transformation sequence
	local transformStart = tick()
	local transformLast = transformStart
	local transformBase = character.Torso.CFrame * CFrame.new(0, -3, 0)
	transformBase = CFrame.new(transformBase.p, transformBase.p + Vector3.new(transformBase.lookVector.X, 0, transformBase.lookVector.z))
	
	-- Generate some of the effects
	local effectSet = {}

	-- Takeoff ground waves
	do
		local waves = {}
		for i = 1, 4 do
			local wave = {}
			wave.Delay = ((i-1)/4)*0.25 + math.random()*0.3
			wave.Size = ((5-i)/4)*15 + math.random()*3
			wave.Duration = 0.5 + math.random()*0.2
			--
			local part = Instance.new('Part')
			part.FormFactor = 'Custom'
			part.BrickColor = BrickColor.new(23)
			part.Size = Vector3.new(1, 1, 1)
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = transformBase * CFrame.new(math.random()*4-2, 0, math.random()*4-2)
			part.TopSurface = 'Smooth'
			--
			local mesh = Instance.new('SpecialMesh', part)
			mesh.MeshType = 'Sphere'
			wave.Part = part
			wave.Mesh = mesh
			table.insert(waves, wave)
		end
		local function updateWaves(elapsed, dt)
			local allDone = true
			for _, wave in pairs(waves) do
				if elapsed > wave.Delay then
					if elapsed > wave.Delay + wave.Duration then
						wave.Part:Destroy()
					else
						allDone = false
						-- Normal case
						local frac = (elapsed - wave.Delay) / wave.Duration
						local fracIn = 1 - frac^0.25
						local fracOut = frac^5
						wave.Mesh.Scale = Vector3.new(wave.Size * fracIn, 0.1 + 9*fracOut, wave.Size * fracIn)
						wave.Part.Transparency = 0.3 + 0.7*fracOut
						wave.Part.Parent = effectModel
					end
				else
					allDone = false
				end
			end
			return allDone
		end
		local function destroyWaves()
			for _, wave in pairs(waves) do
				wave.Part:Destroy()
			end
		end
		effectSet[{
			Update = updateWaves;
			Destroy = destroyWaves;
		}] = true
	end
	
	-- Takeoff vertical risers
	do
		local risers = {}
		for i = 1, 6 do
			local riser = {}
			riser.Delay = 0.3 + math.random() * 0.4
			riser.Duration = 1 + math.random() * 1.5
			riser.Offset = CFrame.new(math.random()*4 - 2, 0, math.random()*4 - 2)
			riser.Width = 0.3 + math.random() * 0.5
			riser.Height = 1 + math.random() * 2
			--
			local part = Instance.new('Part')
			part.FormFactor = 'Custom'
			part.Size = Vector3.new(1, 1, 1)
			part.Anchored = true
			part.CanCollide = false
			part.BrickColor = BrickColor.new(23)
			part.TopSurface = 'Smooth'
			part.BottomSurface = 'Smooth'
			--
			local mesh = Instance.new('SpecialMesh', part)
			mesh.MeshType = 'Brick'
			riser.Part = part
			riser.Mesh = mesh
			table.insert(risers, riser)
		end
		local function updateRisers(elapsed, dt)
			local allDone = true
			for _, riser in pairs(risers) do
				if elapsed > riser.Delay then
					if elapsed > riser.Delay + riser.Duration then
						riser.Part:Destroy()
					else
						allDone = false
						-- Normal case
						local frac = (elapsed - riser.Delay) / riser.Duration
						local rampFrac = 1 - math.abs(frac - 0.5)
						local widthFrac = rampFrac^2
						local heightFrac = rampFrac
						riser.Mesh.Scale = Vector3.new(riser.Width * widthFrac, riser.Height * heightFrac, riser.Width * widthFrac)
						riser.Part.Transparency = 0.2 --widthFrac
						riser.Part.CFrame = transformBase * riser.Offset * CFrame.new(0, -riser.Height/2 + frac^2*(6 + riser.Height), 0) * CFrame.Angles(0, frac*8, 0)
						riser.Part.Parent = effectModel
					end
				else
					allDone = false
				end
			end
			return allDone
		end
		local function destroyRisers()
			for _, riser in pairs(risers) do
				riser.Part:Destroy()
			end
		end
		effectSet[{
			Update = updateRisers;
			Destroy = destroyRisers;
		}] = true
	end
	
	-- Main effect
	local blurEffect = CreateBlurEffect(effectModel, flyAwayPartSet)
	
	-- The ring effect
	local ringEffect = CreateSpinEffect(effectModel)
	
	-- Main transformation sequence
	while humanoid.Health > 0 and character.Parent do
		-- How much time has elapsed
		local now = tick()
		local dt = now - transformLast
		local elapsed = now - transformStart
		transformLast = now
		
		-- Run any effects
		for effect, _ in pairs(effectSet) do
			if effect.Update(elapsed, dt) then
				effect.Destroy()
				effectSet[effect] = nil
			end
		end
		
		-- Main timer
		local frac = math.min(1, elapsed / FLOAT_FINISH_TIME)
		local breakFrac = math.max(0, math.min(1, (elapsed - BREAKOFF_TIME) / (FLOAT_FINISH_TIME - BREAKOFF_TIME)))
		local moveFrac = frac^1.2
		
		-- Float up the torso
		if not Workspace.FilteringEnabled then
			torso.Anchored = false
			torso.CFrame = transformBase * CFrame.new(0, 3 + moveFrac * FLOAT_HEIGHT, 0)	
			torso.Anchored = true
		end
		
		-- Tween part positions + transparency
		for _, dat in pairs(partsToTween) do
			if dat.Mode == 'Fade' then
				dat.Part.Transparency = frac
			elseif dat.Mode == 'BreakAway' then
				if dat.Part.Name == 'Head' then
					dat.Part.Transparency = 0.99
				else
					dat.Part.Transparency = 1
				end
				if elapsed > BREAKOFF_TIME then
					if not dat.Broken then
						dat.BreakCFrame = dat.Part.CFrame
						for _, ch in pairs(dat.Part:GetChildren()) do
							if ch:IsA('Decal') then ch:Destroy() end
						end
						dat.BreakVelocity = Vector3.new(math.random()-0.5, 1, math.random()-0.5).unit * 4*(1+math.random())
						dat.BreakRotVelocity = Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5)*5
						dat.Broken = true
					end
					local rvelo = dat.BreakRotVelocity*dt
					dat.BreakCFrame = (dat.BreakCFrame + dat.BreakVelocity*dt) * CFrame.Angles(rvelo.X, rvelo.Y, rvelo.Z)
					dat.BreakAwayPart.CFrame = dat.BreakCFrame
					dat.BreakAwayPart.Transparency = (frac < 0.5) and 0 or ((frac-0.5)/0.5)^2
				else
					dat.BreakAwayPart.CFrame = dat.Part.CFrame
				end
			else
				assert(false, "unreachable")
			end
		end
		
		-- Fade in blur effect
		blurEffect:SetTransparency(1 - frac*0.7)
		blurEffect:Update(dt)
		
		-- Fade in ring effect
		ringEffect:SetCFrame(torso.CFrame)
		ringEffect:SetTransparency(1 - breakFrac*0.7)
		ringEffect:Update(dt)
		
		-- Exit
		if elapsed > FLOAT_FINISH_TIME + 0.5 then
			break
		end
		
		RunService.RenderStepped:wait()
	end
	
	for _, part in pairs(flyAwayParts) do
		part:Destroy()
	end
	for _, obj in pairs(effectModel:GetChildren()) do
		if obj:IsA('Clothing') then
			obj:Destroy()
		end
	end
	blurEffect:SetTransparency(0.3)
	blurEffect:Update(0)
	ringEffect:SetTransparency(0.3)
	ringEffect:Update(0)
	
	return addViewCn, effectModel, blurEffect, ringEffect
end

local mDirectionKey = {
	w = Vector3.new(0, 0, -1);
	s = Vector3.new(0, 0, 1);
	a = Vector3.new(-1, 0, 0);
	d = Vector3.new(1, 0, 0);
	[string.char(17)] = Vector3.new(0, 0, -1);
	[string.char(18)] = Vector3.new(0, 0, 1);
	[string.char(20)] = Vector3.new(-1, 0, 0);
	[string.char(19)] = Vector3.new(1, 0, 0);
}
local mKeySet = {}

local MouseDown = false

local Anim;

function RunController(addViewCn, character, effectModel, blurEffect, ringEffect)
	-- Already dead
	if not (character.Parent and character:FindFirstChild('Humanoid') and character.Humanoid.Health > 0) then
		effectModel:Destroy()
		if addViewCn then
			addViewCn:disconnect()
		end
		return nil
	end
	--
	local torso = character:WaitForChild('HumanoidRootPart')
	local humanoid = character:WaitForChild('Humanoid')
	local anim = script:WaitForChild('FlyAnimation')
	Anim = humanoid:LoadAnimation(anim)
	Anim:Play(2)
	--
	local turn, move;
	if Workspace.FilteringEnabled then
		turn = torso:WaitForChild('Turn')
		move = torso:WaitForChild('Move')
	else
		turn = Instance.new('BodyGyro', torso)
		turn.maxTorque = Vector3.new(10000, 10000, 10000)
		turn.cframe = torso.CFrame
		--
		move = Instance.new('BodyPosition', torso)
		move.maxForce = Vector3.new(10000, 10000, 10000)
		move.position = torso.Position
	end
	--
	local fireSound = Instance.new('Sound', effectModel)
	fireSound.SoundId = 'rbxassetid://69446845'
	fireSound.Pitch = 1.5
	fireSound.Volume = 0.25
	fireSound.Looped = true
	local fireSound2 = Instance.new('Sound', effectModel)
	fireSound2.SoundId = 'rbxassetid://69446845'
	fireSound2.Pitch = 1.5
	fireSound2.Volume = 0.25
	fireSound2.Looped = true	
	--
	local UpdateMove;
	if Workspace.FilteringEnabled then
		UpdateMove = Character:WaitForChild('RunGlobal_SSTool'):WaitForChild('UpdateMove')
		local val = Character:WaitForChild('RunGlobal_SSTool'):WaitForChild('ControlReady')
		while not val.Value do val.Changed:wait() end
	end
	--
	humanoid:ChangeState('Physics')
	torso.Anchored = false
	--
	local mMovementPosition = torso.Position
	local mMoveVelocity = Vector3.new()
	local mMoveYVelocity = 0
	--
	local function updateMove(dt)
		-- Get the local space move direction
		local moveDir = Vector3.new()
		for key, d in pairs(mDirectionKey) do
			if mKeySet[key] then
				moveDir = moveDir + d
			end
		end
		moveDir = moveDir.unit
		
		-- To global space
		local cam = Workspace.CurrentCamera.CoordinateFrame
		local dirCF = CFrame.new(cam.p, cam.p + Vector3.new(cam.lookVector.x, 0, cam.lookVector.z))
		moveDir = dirCF:vectorToWorldSpace(moveDir)
		
		-- Accelerate
		if moveDir.magnitude > 0.01 then
			mMoveVelocity = mMoveVelocity + moveDir*(dt*80)
			if mMoveVelocity.magnitude > 20 then
				mMoveVelocity = mMoveVelocity.unit*20
			end
		else
			if mMoveVelocity.magnitude > 0 then
				mMoveVelocity = mMoveVelocity.unit * math.max(0, mMoveVelocity.magnitude - dt*30)
			end
		end
		
		-- Move
		mMovementPosition = mMovementPosition + mMoveVelocity*dt
		
		-- Movement is blocked
		if (mMovementPosition - torso.Position).magnitude > 5 then
			mMovementPosition = mMovementPosition + (torso.Position - mMovementPosition).unit * 5
		end
		
		-- Adjust height
		local toIgnore = {Character}
		local downRay = Ray.new(mMovementPosition, Vector3.new(0, -1000, 0))
		local hit, at = Workspace:FindPartOnRayWithIgnoreList(downRay, toIgnore)
		while hit and not hit.CanCollide do
			table.insert(toIgnore, hit)
			downRay = Ray.new(at, Vector3.new(0, -1000, 0))
			hit, at = Workspace:FindPartOnRayWithIgnoreList(downRay, toIgnore)
		end
		local float = (at - mMovementPosition).magnitude
		if float > FLOAT_HEIGHT then
			mMoveYVelocity = mMoveYVelocity - 9.81*20*dt
			mMovementPosition = mMovementPosition + Vector3.new(0, math.min(float - FLOAT_HEIGHT, mMoveYVelocity*dt), 0)
		else
			mMoveYVelocity = 0
			mMovementPosition = mMovementPosition + Vector3.new(0, math.max(FLOAT_HEIGHT - float - 1), 0)
		end
		
		-- Update objects
		move.position = mMovementPosition
		if mMoveVelocity.magnitude > 0 then
			turn.cframe = CFrame.new(Vector3.new(), mMoveVelocity)
		end
	end
	--
	local lightningEffect = CreateLightningEffect(effectModel)
	lightningEffect:SetActive(true)
	--
	local lightningActive = false
	local lightningActiveSince = 0
	local lightningRunId = 0
	--
	local lastDamagedHum = nil
	local lastDamagedAt = 0
	local lastDamagedCreator;
	local DamagePerSecond = 70
	--
	Spawn(function()
		local lastTime = tick()
		while humanoid.Health > 0 and character.Parent do
			local now = tick()
			local dt = (now - lastTime)
			lastTime = now

			-- Movement
			updateMove(dt)
			if Workspace.FilteringEnabled then
				Spawn(function()
					UpdateMove:InvokeServer(Workspace.DistributedGameTime, mMovementPosition, mMoveVelocity, mMoveYVelocity)
				end)
			end

			-- Attack effect
			local toIgnore = {Character, effectModel}
			local ray = Ray.new(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction*999)
			local hit, at = Workspace:FindPartOnRayWithIgnoreList(ray, toIgnore)
			while hit and hit.Transparency == 1 do
				table.insert(toIgnore, hit)
				hit, at = Workspace:FindPartOnRayWithIgnoreList(ray, toIgnore)
			end
			--
			local hitHumanoid;
			if hit then
				local hum = hit.Parent:FindFirstChild('Humanoid')
				if hum then hitHumanoid = hum end
				if hit.Parent.Parent then
					hum = hit.Parent.Parent:FindFirstChild('Humanoid')
					if hum then hitHumanoid = hum end
				end
			end
			--
			local mouseAt = at
			local vec = mouseAt - torso.Position
			if not MouseDown or not hit or vec.magnitude > 60 then
				lightningEffect:SetActive(false)
				if lightningActive then
					lightningActive = false
					fireSound:Stop()
					fireSound2:Stop()
					lightningRunId = lightningRunId + 1
				end
				--
				if lastDamagedHum then
					if not Workspace.FilteringEnabled then
						-- Deal remaining damage to the old target
						lastDamagedHum:TakeDamage((now - lastDamagedAt)*DamagePerSecond)
						Game:GetService('Debris'):AddItem(lastDamagedCreator, 0.5)
						lastDamagedCreator = nil
						lastDamagedHum = nil
					end
				end
				--
				local sc = Character:WaitForChild('RunGlobal_SSTool')
				sc:WaitForChild('IsShooting').Value = false
				sc:WaitForChild('HumanoidToDamage').Value = nil
				if Workspace.FilteringEnabled then
					sc:WaitForChild('UpdateShoot'):FireServer(false, Vector3.new(), Vector3.new(), nil)
				end
			else
				if not lightningActive then
					lightningActive = true
					lightningActiveSince = now
					fireSound.Pitch = 1.5 - 0.7
					fireSound2.Pitch = 1.5 - 0.7
					fireSound:Play()
					lightningRunId = lightningRunId + 1
					local thisRunId = lightningRunId
					Delay(0.2, function()
						if lightningRunId == thisRunId then
							fireSound2:Play()
						end
					end)
				else
					local frac = math.min(1, (now - lightningActiveSince) / 0.3)
					local modPitch = 1.5 - 0.7*(1-frac)
					fireSound.Pitch = modPitch
					fireSound2.Pitch = modPitch
				end
				lightningEffect:Set(torso.Position, torso.Position + vec)
				lightningEffect:SetActive(true)
				lightningEffect:Update(dt)
				--
				if not Workspace.FilteringEnabled then
					-- Do damage on the client
					if lastDamagedHum ~= hitHumanoid then
						print("Switch target")
						if lastDamagedHum then
							lastDamagedHum:TakeDamage((now - lastDamagedAt)*DamagePerSecond)
							Game:GetService('Debris'):AddItem(lastDamagedCreator, 0.5)
						end
						lastDamagedHum = hitHumanoid
						lastDamagedCreator = Instance.new('ObjectValue')
						lastDamagedCreator.Value = Player
						lastDamagedCreator.Name = 'creator'
						lastDamagedCreator.Parent = hitHumanoid
						lastDamagedAt = now
					end
					if lastDamagedHum then
						print("Try damage target")
						if (now - lastDamagedAt) > 0.1 then
							print("Damage target")
							lastDamagedHum:TakeDamage((now - lastDamagedAt)*DamagePerSecond)
							lastDamagedAt = now
						end
					end
				end
				--
				local sc = Character:WaitForChild('RunGlobal_SSTool')
				sc:WaitForChild('ShootFrom').Value = torso.Position
				sc:WaitForChild('ShootTo').Value = torso.Position + vec
				sc:WaitForChild('HumanoidToDamage').Value = hitHumanoid
				sc:WaitForChild('IsShooting').Value = true
				if Workspace.FilteringEnabled then
					sc:WaitForChild('UpdateShoot'):FireServer(true, torso.Position, torso.Position + vec, hitHumanoid)
				end
			end
			
			-- Character effects
			blurEffect:Update(dt)
			blurEffect:SetVelocity(torso.Velocity)
			ringEffect:SetCFrame(torso.CFrame)
			ringEffect:Update(dt)
			--
			while _G.Stop do wait() end
			RunService.RenderStepped:wait()
		end
		
		if addViewCn then
			addViewCn:disconnect()
		end
		if lastDamagedCreator then
			Game:GetService('Debris'):AddItem(lastDamagedCreator, 1)
		end
		
		-- Destroy the movers
		turn:Destroy()
		move:Destroy()
		
		-- Turn off the lightning if still running
		fireSound:Stop()
		fireSound2:Stop()
		local sc = Character:WaitForChild('RunGlobal_SSTool')
		sc:WaitForChild('IsShooting').Value = false
		lightningEffect:SetActive(false)		
		
		-- Fade out the other effects
		local lastTime = tick()
		local trans = 0.3
		while character.Parent do
			local now = tick()
			local dt = (now - lastTime)
			lastTime = now
			trans = math.min(1, trans + 0.5*dt)
			blurEffect:SetTransparency(trans)
			ringEffect:SetTransparency(trans)
			blurEffect:Update(dt)
			ringEffect:Update(dt)
			RunService.RenderStepped:wait()
		end
		
		-- Finally Kill the effects and end
		effectModel:Destroy()
	end)
	--
	local this = {}
	--
	function this:ShootAt()
		
	end
	--	
	return this
end

local addViewCn, effectModel, blurEffect, ringEffect = TransformationSequence(Character)
local Controller = RunController(addViewCn, Character, effectModel, blurEffect, ringEffect)

if Controller then
	Mouse.Button1Down:connect(function()
		Controller:ShootAt()
		MouseDown = true
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
	Mouse.KeyDown:connect(function(key)
		print("Key:", string.byte(key))
		key = key:lower()
		mKeySet[key] = true
	end)
	Mouse.KeyUp:connect(function(key)
		key = key:lower()
		mKeySet[key] = nil
	end)
end












