local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local SpotLightProxy = Tool:WaitForChild('SpotLightProxy')
local Light = SpotLightProxy:WaitForChild('SpotLight')
local Humanoid;
local Character;

local Equipped = false
local Running = false

local ANIM_Hold, ANIM_Equip, ANIM_Swish;

local Swarm = {}

local function rand11()
	return math.random()*2 - 1
end

local CurrentSpeed = 20
local LastAnimate;
local function AnimateSwarm()
	local desiredSpeed = (Handle.Velocity.magnitude > 1) and 20 or 8
	--
	local time = tick()
	local dt = time-LastAnimate
	LastAnimate = time
	--
	if CurrentSpeed > desiredSpeed then
		CurrentSpeed = math.max(desiredSpeed, CurrentSpeed - dt*10)
	else
		CurrentSpeed = math.min(desiredSpeed, CurrentSpeed + dt*10)
	end
	--
	for i, swarmItem in pairs(Swarm) do
		local at = swarmItem.Part.Position
		local to = Handle.Position
		if Handle.Velocity.magnitude > 2 then
			to = to + Handle.Velocity.unit * 6
		end
		--
		swarmItem.Thrust.MaxSpeed = CurrentSpeed
		--
		local r = (at-to).magnitude
		if Running and r < 6 then
			swarmItem.TargetPart.Position = 
				swarmItem.Part.Position + 
					(CFrame.new(to,at)*CFrame.Angles(rand11()*0.9, 0, rand11()*0.9)).lookVector*5
		else
			if r > 8 or (not Running and r > 4)  then
				-- swarmItem.LastAnimated = tick()
				-- local randomPointNearby = (Handle.CFrame * 
				--                            CFrame.Angles(0, rand11()*math.pi, 0) * 
				--                            CFrame.Angles(math.acos(rand11()), 0, 0) *
				--                            CFrame.new(0, 0, (Running and -math.random(5,8) or -math.random(1,4)))).p
				swarmItem.TargetPart.Position = at + 
					(CFrame.new(at, to)*CFrame.Angles(rand11()*1, 0, rand11()*1)).lookVector*30
				-- local newTo = CFrame.new(at, randomPointNearby) * CFrame.new(0, 0, -15)
				-- swarmItem.TargetPart.Position = newTo.p
			end
		end
	end
end

local function CreateSwarm()
	for i = 1, 10 do
		local swarmItem = {}
		--
		local swarmPart = Instance.new('Part')
		swarmPart.TopSurface = 'Smooth'
		swarmPart.BottomSurface = 'Smooth'
		swarmPart.FormFactor = 'Custom'
		swarmPart.Size = Vector3.new()
		swarmPart.BrickColor = BrickColor.new('New Yeller') -- not a typo, our naming just sucks... I mean really, "yeller"?
		swarmPart.CanCollide = false
		swarmPart.CFrame = Handle.CFrame*CFrame.new(0,-0.1,0.1)
		swarmPart.Parent = Character
		--
		local swarmPartTarget = Instance.new('Part')
		swarmPartTarget.Parent = nil
		swarmPartTarget.Position = Handle.Position
		--
		local thrust = Instance.new('RocketPropulsion')
		thrust.TargetRadius = 0
		thrust.Target = swarmPartTarget
		thrust.MaxTorque = Vector3.new(2,2,2)
		thrust.MaxThrust = 200
		thrust.ThrustD = 0
		thrust.ThrustP = 100
		thrust.TurnD = 0
		thrust.TurnP = 200
		thrust.MaxSpeed = 20
		thrust.Parent = swarmPart
		--
		swarmItem.Part = swarmPart
		swarmItem.TargetPart = swarmPartTarget
		swarmItem.Thrust = thrust
		swarmItem.LastDirectionChange = 0
		swarmItem.LastAnimated = 0
		table.insert(Swarm, swarmItem)
		--
		thrust:Fire()
		--
		swarmPart.Velocity = Vector3.new(rand11(),rand11(),rand11()).unit*50
		swarmPartTarget.Position = Handle.Position + Vector3.new(rand11(),rand11(),rand11()).unit*(math.random()*4+2)
	end
	LastAnimate = tick()
	AnimateSwarm()
end

local function DestroySwarm()
	for _, item in pairs(Swarm) do
		item.Part:Destroy()
	end
	Swarm = {}
end

local function Flicker()
	--now everbody lets make some noise!
	local x = 4*tick()
	local frac = math.abs(math.cos(x/12)^5 * (math.sin(x)^4*math.cos(x+1)^2+
	                                          0.5*math.cos(x+2)-math.sin(3*x+2)))
	frac = math.min(frac, 1)
	Light.Brightness = (1-frac)*1.5
end

Tool.Equipped:connect(function(mouse)
	local w = Instance.new('Weld', Handle)
	w.Name = 'HandleWeld'
	w.C0 = CFrame.new(0,7,0)*CFrame.Angles(-math.pi/2,0,0)
	w.Part0 = Handle
	w.Part1 = SpotLightProxy
	--
	Equipped = true
	Character = Tool.Parent
	Humanoid = Character:WaitForChild('Humanoid')
	--
	ANIM_Equip = Humanoid:LoadAnimation(Tool:WaitForChild('ANIM_Equip'))
	ANIM_Hold  = Humanoid:LoadAnimation(Tool:WaitForChild('ANIM_Hold'))
	ANIM_Swish = Humanoid:LoadAnimation(Tool:WaitForChild('ANIM_Swish'))
	--
	ANIM_Equip:Play()
	repeat until ANIM_Equip.KeyframeReached:wait() == 'Complete'
	--
	ANIM_Hold:Play(0)
	CreateSwarm()
	--
	Running = false
	mouse.Button1Down:connect(function()
		if Running then return end
		Running = true
		--
		ANIM_Swish:Play()
		repeat until ANIM_Swish.KeyframeReached:wait() == 'Complete'
		--
		Running = false
	end)
	--
	while Equipped do
		AnimateSwarm()
		Flicker()
		wait()
	end
end)

Tool.Unequipped:connect(function()
	Equipped = false
	DestroySwarm()
	if ANIM_Swish then
		ANIM_Equip:Stop()
		ANIM_Hold:Stop()
		ANIM_Swish:Stop()
	end
end)