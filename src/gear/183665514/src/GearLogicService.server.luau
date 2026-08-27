--get a quick reference to the tool and handle
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
--a short reference to math.random
local R = math.random
--this remote receives input events from the client
local Remote = Tool:WaitForChild("Remote")
--these parts will serve as the basis for some effects
local Cube = Instance.new("Part")
Cube.FormFactor = "Custom"
Cube.Size = Vector3.new(1, 1, 1)
Cube.Anchored = true
Cube.CanCollide = false
Cube.TopSurface = "Smooth"
Cube.BottomSurface = "Smooth"
Cube.Material = "SmoothPlastic"
local Cylinder = Cube:Clone()
Instance.new("CylinderMesh", Cylinder)
local Sphere = Cube:Clone()
Instance.new("SpecialMesh", Sphere).MeshType = "Sphere"
--this is a quick reference to heartbeat
local Heartbeat = Game:GetService("RunService").Heartbeat
--this variable holds our heartbeat connection
local Connection
--this variable holds the motor so we can destroy it on an unequip
local Motor
--the following variables affect the behavior of the weapon
local CanSwing = true
local SwingReload = 1.5
local SwingTimer = 0
local CanDamage = false
local DamageAmount = 20
local SwingType = "Normal1"

local NumberCharges = 0
local MaxCharges = 5
local ChargeTimer = 0
local ChargeParts = {}

local SpecialAttackDamage = 45
local SpecialAttackEffectTimer = 0
local SpecialAttackEffectLastPosition
local SpecialAttackEffectDamage = 7.5

--this function decrements the swing timer if we're unable to swing
function handleSwingTimer(dt)
	if not CanSwing then
		SwingTimer = SwingTimer - dt
		if SwingTimer <= 0 then
			CanSwing = true
		end
	end
end

--this function handles the graphical repercussions of the coolness of the special attack
function handleSpecialAttackGraphics(dt)
	if SpecialAttackEffectTimer > 0 then
		SpecialAttackEffectTimer = SpecialAttackEffectTimer - dt
		
		local a = Handle.CFrame:pointToWorldSpace(Vector3.new(0, 1.5, 0))
		if SpecialAttackEffectLastPosition then
			sunbeam(a, SpecialAttackEffectLastPosition, 1/2)
		end
		SpecialAttackEffectLastPosition = a
	else
		SpecialAttackEffectLastPosition = nil
	end
end

--this function handles the graphical consequences of having charges
function handleCharges(dt)
	ChargeTimer = ChargeTimer + dt
	if NumberCharges > 0 then
		local theta = ChargeTimer * 4
		local thetaStep = (math.pi * 2) / NumberCharges
		local radius = 2
		for index = 1, NumberCharges do
			local charge = ChargeParts[index]
			local dx = math.cos(theta) * radius
			local dy = math.sin(theta) * radius
			charge.CFrame = Handle.CFrame:toWorldSpace(CFrame.new(dx, 1.25, dy))
			theta = theta + thetaStep
		end
	end
end

--this function tags the target for integration of the default leaderboard
function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

--this helper function returns if a table contains a value
function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

--this function makes a sunbeam between two points
function sunbeam(a, b, t)
	local middle = (a + b) / 2
	local length = (b - a).magnitude
	
	local beam = Cylinder:Clone()
	beam.Size = Vector3.new(0.2, length, 0.2)
	beam.BrickColor = BrickColor.new("Bright yellow")
	beam.Transparency = 0.5
	beam.Material = "Marble"
	beam.CFrame = CFrame.new(middle, b) * CFrame.Angles(math.pi / 2, 0, 0)
	beam.Parent = workspace
	game:GetService("Debris"):AddItem(beam, t)
end

--this function makes a crater
function crater(pos, t)
	local twoPi = math.pi * 2
	local thetaStep = twoPi / 12
	
	for theta = thetaStep, twoPi, thetaStep do
		local length = math.random() * 2.5
		local dx = math.cos(theta) * (length / 2)
		local dz = math.sin(theta) * (length / 2)
		local d = pos + Vector3.new(dx, 0, dz)
		
		local burn = Cube:Clone()
		burn.Size = Vector3.new(0.4, 0.2, length)
		burn.CFrame = CFrame.new(d, pos)
		burn.BrickColor = BrickColor.new("Really black")
		burn.Parent = workspace
		game:GetService("Debris"):AddItem(burn, t)
	end
end

--this function deals the special attack damage using explosions
function specialAttackDamage(position)
	local affectedHumans = {}
	
	local e = Instance.new("Explosion")
	e.BlastRadius = 6
	e.BlastPressure = 0
	e.Position = position
	e.Hit:connect(function(part, distance)
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local human = part.Parent.Humanoid
			if not contains(affectedHumans, human) then
				tagHuman(human)
				human:TakeDamage(SpecialAttackDamage)
				table.insert(affectedHumans, human)
			end
		end
	end)
	e.Parent = workspace
end

--this is the main part of the weapon, a central tick
function onTick(dt)
	--first, handle the swing timer
	handleSwingTimer(dt)
	
	--next, the charge timer
	handleCharges(dt)
	
	--special attack graphics
	handleSpecialAttackGraphics(dt)
end

--this function returns the player of this weapon
function getPlayer()
	local char = Tool.Parent
	if char then
		return game:GetService("Players"):GetPlayerFromCharacter(char)
	end
end

--this function converts a weld to a motor for animation
function convertWeldToMotor(weld)
	local m = Instance.new("Motor6D")
	m.Name = weld.Name
	m.Part0 = weld.Part0
	m.Part1 = weld.Part1
	m.C0 = weld.C0
	m.C1 = weld.C1
	
	local parent = weld.Parent
	weld:Destroy()
	m.Parent = parent
	
	Motor = m
end

--when we equip, we start up the clock
function onEquipped()
	--make SURE that we unequipped
	onUnequipped()
	
	--connect the heartbeat
	Connection = Heartbeat:connect(onTick)
	
	--put the charges into the tool
	toggleCharges(true)
	
	--as soon as we can, replace "right grip" with a motor
	while not Tool.Parent do wait() end
	while not Tool.Parent:FindFirstChild("Right Arm") do wait() end
	convertWeldToMotor(Tool.Parent["Right Arm"]:WaitForChild("RightGrip"))
end

--when we unequip, stop the clock
function onUnequipped()
	if Connection then
		Connection:disconnect()
	end
	
	--prevent the motor from causing problems
	if Motor then
		Motor:Destroy()
	end
	
	--put the charges back into nil
	toggleCharges(false)
end

--this function plays a sound with a random pitch
function playSound(name)
	local sound = Handle:FindFirstChild(name)
	if sound then
		sound.Pitch = math.random(90, 110)/100
		sound:Play()
	end
end

--when the blade is touched, if we can damage, we deal damage and add a charge
function onTouched(part)
	--if we can't damage, don't bother
	if not CanDamage then return end
	
	--if the part's parent exists and has a humanoid, damage it
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		--damage the person
		local human = part.Parent.Humanoid
		tagHuman(human)
		human:TakeDamage(DamageAmount)
		--charge up
		addCharge()
		--turn off the damage
		CanDamage = false
		--play a sound
		playSound("HitSound")
		
		--special buff!?
		if SpecialAttackEffectTimer > 0 then
			human:TakeDamage(SpecialAttackEffectDamage)
			playSound("SpecialHitSound")
			
			if human.Parent:FindFirstChild("Torso") then
				local fire = Instance.new("Fire")
				fire.Color = BrickColor.new("New Yeller").Color
				fire.SecondaryColor = BrickColor.new("Bright yellow").Color
				fire.Parent = human.Parent.Torso
				delay(1, function() fire.Enabled = false end)
				game:GetService("Debris"):AddItem(fire, 2)
			end
		end
	end
end

--this function adds a charge to the blade, handling some math and rendering for us
function addCharge()
	--add a charge, but ensure we don't pass the max
	NumberCharges = NumberCharges + 1
	if NumberCharges > MaxCharges then
		NumberCharges = MaxCharges
	end
	--show off the charges!
	toggleCharges(true)
end

--this function easily toggles charges on or off, as well as refreshing the number of them
function toggleCharges(on)
	if on then
		toggleCharges(false)
		
		for index = 1, NumberCharges do
			local charge = ChargeParts[index]
			charge.Parent = Tool
		end
	else
		for index = 1, MaxCharges do
			local charge = ChargeParts[index]
			charge.Parent = nil
		end
		ChargeTimer = 0
	end
end

--this function performs a special attack with the axe
function specialAttack()
	--can't swing? can't special
	if not CanSwing then return end
	
	--animate!
	Remote:FireClient(getPlayer(), "PlayAnimation", "Special")
	wait(0.1)
	
	--make sure we have a root part
	if Tool.Parent and Tool.Parent:FindFirstChild("HumanoidRootPart") then
		--explosions!
		local root = Tool.Parent.HumanoidRootPart
		local feet = root.Position - Vector3.new(0, 2.5, 0)
		local radius = 14
		local rads = math.pi * 2
		local thetaStep = rads / 5
		for theta = thetaStep, rads, thetaStep do
			local dx = math.cos(theta) * radius
			local dz = math.sin(theta) * radius
			local pos = feet + Vector3.new(dx, 0, dz)
			specialAttackDamage(pos)
			
			local a = Handle.CFrame:pointToWorldSpace(Vector3.new(0, 2, 0))
			local b = pos
			sunbeam(a, b, 1/10)
			crater(b, 8)
		end
		
		--sounds!
		playSound("SunFireExplosion")
		
		--charge control
		NumberCharges = 0
		toggleCharges(true)
		
		--special attack effect timer
		SpecialAttackEffectTimer = 6
	end
end

--this function performs a normal strike with the blade
function normalAttack()
	--if we can't swing, don't bother
	if not CanSwing then return end
	
	--tell our touched handler we can deal damage
	CanDamage = true
	--after a short delay, we can't damage anymore.
	delay(1, function()
		CanDamage = false
	end)
	
	--we can't swing for another bit
	CanSwing = false
	SwingTimer = SwingReload
	
	--swing the sword and play a sound!
	Remote:FireClient(getPlayer(), "PlayAnimation", SwingType)
	if SwingType == "Normal1" then
		delay(0.15, function() playSound("SwingSound") end)
		SwingType = "Normal2"
	else
		SwingType = "Normal1"
		playSound("SwingSound")
	end
end

--this function is called once, right away, in order to prep the sword for use
--all events are connected here in order to ensure everything is ready
function setUp()
	--create and store the charges we may need
	for index = 1, MaxCharges do
		local charge = Sphere:Clone()
		charge.Mesh.Scale = Vector3.new(3/4, 3/4, 3/4)
		charge.BrickColor = BrickColor.new("Bright yellow")
		charge.Transparency = 0.5
		charge.Material = "Marble"
		ChargeParts[index] = charge
	end
	
	--connect events
	Tool.Equipped:connect(onEquipped)
	Tool.Unequipped:connect(onUnequipped)
	Handle.Touched:connect(onTouched)
	
	--this remote event connection is more complex
	Remote.OnServerEvent:connect(function(player, func, ...)
		--if it isn't our player, don't bother
		if player.Character ~= Tool.Parent then return end
		
		--store the arguments in a table
		local args = {...}
		
		--start the logic
		if func == "AttackStarted" then
			--if we don't have all the charges, do a normal attack
			--otherwise, we start the pew pew process
			if NumberCharges < MaxCharges then
				normalAttack()
			else
				specialAttack()
			end
		end
	end)
end

setUp()