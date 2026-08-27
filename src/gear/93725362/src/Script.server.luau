local AnimationNames = {"Slash", "SlashAnim", "DarkenAnim", "ChargeAnim"}
local Tool = script.Parent
local Character = nil
local Humanoid = nil
local Torso = nil
local Animations = {}

local function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end


local GlowSpeed = WaitForChild(Tool, "GlowSpeed")
local SwingValue = WaitForChild(Tool, "SwingValue")
local Handle = WaitForChild(Tool, "Handle")
local FireMesh = WaitForChild(Tool, "FireMesh")

local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Name = "LeapForce"
BodyVelocity.P = 100000
BodyVelocity.maxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
BodyVelocity.velocity = Vector3.new(0, 0, 0)


local ForceField = Instance.new("Part")
ForceField.formFactor = "Custom"
ForceField.Size = Vector3.new(0.1, 0.1, 0.1)
ForceField.BrickColor = BrickColor.new("Deep blue")
ForceField.Transparency = .65
FireMesh:Clone().Parent = ForceField

local moreFields = ForceField:Clone()
moreFields.BrickColor = BrickColor.new("Navy blue")  -- "Really blue" and "Bright bluish green"
moreFields.Transparency = .65

local fieldsWeld = Instance.new("ManualWeld")
fieldsWeld.Part0 = ForceField
fieldsWeld.Part1 = moreFields
fieldsWeld.C0 = CFrame.new()
fieldsWeld.C1 = CFrame.Angles(0, math.pi/4, 0)

local moreFields2 = ForceField:Clone()
moreFields2.BrickColor = BrickColor.new("Really blue")  -- "Really blue" and "Bright bluish green"
moreFields2.Transparency = .65

local fieldsWeld2 = Instance.new("ManualWeld")
fieldsWeld2.Part0 = ForceField
fieldsWeld2.Part1 = moreFields2
fieldsWeld2.C0 = CFrame.new()
fieldsWeld2.C1 = CFrame.Angles(0, math.pi/2, 0)

local moreFields3 = ForceField:Clone()
moreFields3.BrickColor = BrickColor.new("Bright bluish green")  -- "Really blue" and "Bright bluish green"
moreFields3.Transparency = .65

local fieldsWeld3 = Instance.new("ManualWeld")
fieldsWeld3.Part0 = ForceField
fieldsWeld3.Part1 = moreFields3
fieldsWeld3.C0 = CFrame.new()
fieldsWeld3.C1 = CFrame.Angles(0, 3*math.pi/4, 0)

moreFields.Parent = ForceField
fieldsWeld.Parent = moreFields
moreFields2.Parent = ForceField
fieldsWeld2.Parent = moreFields2
moreFields3.Parent = ForceField
fieldsWeld3.Parent = moreFields3

local ForceFieldWeld = Instance.new("ManualWeld")
ForceFieldWeld.Part0 = Handle
ForceFieldWeld.Part1 = ForceField
ForceFieldWeld.C0 = CFrame.new()
ForceFieldWeld.C1 = CFrame.new(Vector3.new(0, 0, 0))
ForceFieldWeld.Parent = ForceField


local Mouse = nil

local lastMouseDownTime = 0
local lastMouseUpTime = 0

function onMouseDown()
	lastMouseDownTime = tick()
end

function onMouseUp()
	lastMouseUpTime = tick()
end

function onEquip()
	Character = Tool.Parent
	Torso = Character:FindFirstChild("Torso")
	if Torso then Torso.Anchored = false end
	Handle.CanCollide = true

	Animations = {}

	lastMouseUpTime = lastMouseDownTime
	GlowSpeed.Value = .05
	ForceField.Parent = nil

	if mouse then
		Mouse = mouse
		mouseDownConn = Mouse.Button1Down:connect(onMouseDown)
		mouseUpConn = Mouse.Button1Up:connect(onMouseUp)
	end

	if Character then
		Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			for i = 1, #AnimationNames do
				local animation = Humanoid:LoadAnimation(Tool[AnimationNames[i]])
				table.insert(Animations, animation)
			end
		end
	end
end

local mousehit = Vector3.new()
script.Parent.Click.OnServerEvent:connect(function(client, down, hit)
	if client.Character == script.Parent.Parent then
		mousehit = hit;
		(down and onMouseDown or onMouseUp)()
	end
end)

local whichAnim = 1
local debounce = false
local speed = .5

function adjustWalkspeed()
	if Humanoid then Humanoid.WalkSpeed = 16 + (speed - .5)*5 end
end

local lastSwing = 0
function onActivated()
	if #Animations < 1 or debounce then return end
	debounce = true
	Tool.Enabled = true

	-- count swings for debouncing purposes
	if SwingValue.Value > 100 then SwingValue.Value = 0
	else SwingValue.Value = SwingValue.Value + 1 end

	-- increase speed as they spam clicks
	local currTime = tick()
	local dTime = currTime - lastSwing
	if dTime < 1.75*(1/speed) then
		if speed < 2.5 then speed = speed + .15 end
	else
		if speed < .5 then speed = .5 end
	end
	adjustWalkspeed()
	lastSwing = currTime

	print("Playing: ", AnimationNames[whichAnim])
	Animations[whichAnim]:Play(.1, 1, speed)
	whichAnim = whichAnim + 1
	if whichAnim > 2 then whichAnim = 1 end  -- left, right, left, right

	wait(1/speed)
	Tool.Enabled = false
	debounce = false
end

function onUnequip()
	if Humanoid then Humanoid.WalkSpeed = 16 end
	Handle.CanCollide = true
	lastMouseUpTime = lastMouseDownTime

	GlowSpeed.Value = .05
	ForceField.Parent = nil

	if Torso then Torso.Anchored = false end
	Torso = nil
	Character = nil
	Humanoid = nil
	Mouse = nil
	if mouseDownConn then mouseDownConn:disconnect() mouseDownConn = nil end
	if mouseUpConn then mouseUpConn:disconnect() mouseUpConn = nil end

	for i = 1, #Animations do
		Animations[i]:Stop()
	end
	Animations = {}
end

Tool.Equipped:connect(onEquip)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequip)

local LEAP_THRUST = 600 * 4
local LEAP_TIME = 4
function calculateVelocity(percent, dirVector)
	local thrustVelocity = (.5 - percent) * (.5 - percent) * LEAP_THRUST
	if percent < .5 then
		return Vector3.new(dirVector.X, thrustVelocity, dirVector.Z)
	else
		return Vector3.new(dirVector.X, -thrustVelocity, dirVector.Z)
	end
end

function rotateFires()
	ForceFieldWeld.C1 = ForceFieldWeld.C1 * CFrame.Angles(0, .1, 0)
	fieldsWeld.C1 = fieldsWeld.C1 * CFrame.Angles(0, .1, 0)
	fieldsWeld2.C1 = fieldsWeld2.C1 * CFrame.Angles(0, .05, 0)
	fieldsWeld3.C1 = fieldsWeld3.C1 * CFrame.Angles(0, .075, 0)
end

function LeapAt(targetPoint)
	local currTorso = Torso -- to avoid race conditions
	if not currTorso then return end
	local dirVector = targetPoint - currTorso.CFrame.p
	if dirVector.magnitude > 500 then return end -- too far; didn't leap

	currTorso.CFrame = CFrame.new(currTorso.CFrame.p, currTorso.CFrame.p + dirVector.unit)

	BodyVelocity.velocity = Vector3.new(0, 0, 0)
	BodyVelocity.Parent = currTorso

	delay(LEAP_TIME/4, function() Tool.GripUp = -1*Tool.GripUp Handle.CanCollide = true end)

	local newForceField
	delay(LEAP_TIME*3/4, function() 
		newForceField = Instance.new("ForceField")
		newForceField.Parent = Character
	end)

	local startTime = tick()
	while tick() - startTime < LEAP_TIME-.1 do
		BodyVelocity.velocity = calculateVelocity((tick() - startTime)/LEAP_TIME, dirVector*(1/LEAP_TIME))
		rotateFires()
		wait(.01)
	end
	BodyVelocity.Parent = nil
	currTorso.Velocity = Vector3.new(0, 0, 0) -- don't fly through ground

	local newExplosion = Instance.new("Explosion")
	newExplosion.Position = currTorso.CFrame.p
	newExplosion.BlastRadius = 20
	newExplosion.BlastPressure = 1000000
	newExplosion.Parent = workspace

	wait(.75)
	if newForceField then newForceField.Parent = nil end
end

function darkenFlames()
	ForceField.BrickColor = BrickColor.new("Deep blue")
	moreFields.BrickColor = BrickColor.new("Navy blue")
	moreFields2.BrickColor = BrickColor.new("Really blue")
	moreFields3.BrickColor = BrickColor.new("Bright bluish green")
end

function lightenFlames()
	ForceField.BrickColor = BrickColor.new("Toothpaste")
	moreFields.BrickColor = BrickColor.new("Teal")
	moreFields2.BrickColor = BrickColor.new("Pastel blue-green")
	moreFields3.BrickColor = BrickColor.new("Bright bluish green")
end

-- decrease speed constantly over time; also check mouse hold activity
local debounceCharge = false
local fullyCharged = false
while true do
	local currTime = tick()
	if (lastMouseDownTime > lastMouseUpTime) and currTime > lastMouseDownTime + 2 then
		if not debounceCharge then
			debounceCharge = true
			-- play charge animation, if we've got it
			if Animations[3] then Animations[3]:Play(.1, 1, .1) end
		end
		if Torso and workspace:FindPartOnRay(Ray.new(Torso.CFrame.p, Vector3.new(0, -3, 0)), Character) then Torso.Anchored = true end
		if Humanoid then Humanoid.WalkSpeed = 0 end

		GlowSpeed.Value = GlowSpeed.Value + .004

		ForceField.FireMesh.Scale = GlowSpeed.Value/.5 * Vector3.new(1.2, 3.5, 1.2)
		moreFields.FireMesh.Scale = GlowSpeed.Value/.5 * Vector3.new(1.2, 3.5, 1.2)
		moreFields2.FireMesh.Scale = GlowSpeed.Value/.5 * Vector3.new(1.2, 3.5, 1.2)
		moreFields3.FireMesh.Scale = GlowSpeed.Value/.5 * Vector3.new(1.2, 3.5, 1.2)

		ForceField.Parent = Character
		ForceFieldWeld.Parent = ForceField
		fieldsWeld.Parent = moreFields
		fieldsWeld2.Parent = moreFields2
		fieldsWeld3.Parent = moreFields3
		ForceFieldWeld.C1 = CFrame.new(Vector3.new(0, 2-GlowSpeed.Value/.5*4, 0))
		rotateFires()

		if GlowSpeed.Value >= .5 then
			GlowSpeed.Value = .5

			lightenFlames()	

			if not fullyCharged then
				if Animations[3] then Animations[3]:Stop() end
			end
			fullyCharged = true
		end
	else
		if Torso then Torso.Anchored = false end
	
		if fullyCharged and Humanoid then
			Handle.CanCollide = false
			if Animations[4] then Animations[4]:Play(.1, 1, 1) end
			LeapAt(mousehit)
			Tool.GripUp = -1*Tool.GripUp
		end
		fullyCharged = false

		if debounceCharge then
			darkenFlames()
		end

		debounceCharge = false
		if Animations[3] then Animations[3]:Stop() end
		if Animations[4] then Animations[4]:Stop() end

		GlowSpeed.Value = .05
		
		ForceField.Parent = nil

		if speed > .5 and not debounce then
			speed = speed - .02
		end
		adjustWalkspeed()
	end
	if not fullyCharged then wait(.1) else wait(.01) end
end
