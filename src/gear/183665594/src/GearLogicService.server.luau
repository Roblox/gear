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
local DamageAmount = 35
local SwingType = "Normal1"

local NumberCharges = 0
local MaxCharges = 5
local ChargeTimer = 0
local ChargeParts = {}

local JumpAttackVelocity = 120
--this table holds the armor
local Armor = {}
local EquippingArmor = false

--this function decrements the swing timer if we're unable to swing
function handleSwingTimer(dt)
	if not CanSwing then
		SwingTimer = SwingTimer - dt
		if SwingTimer <= 0 then
			CanSwing = true
		end
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
			charge.CFrame = Handle.CFrame:toWorldSpace(CFrame.new(dx, dy, 0))
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

--this functon returns whether or not a table contains a value
function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

--this is the main part of the weapon, a central tick
function onTick(dt)
	--first, handle the swing timer
	handleSwingTimer(dt)
	
	--next, the charge timer
	handleCharges(dt)
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

--welds stuff
function weldArmor(part1, part0, c0)
	local w = Instance.new("Weld")
	w.Part0 = part0
	w.Part1 = part1
	w.C0 = c0
	w.Parent = w.Part0
end

--puts armor on
function armorOn()
	EquippingArmor = true
	
	armorOff()
	
	local char = Tool.Parent
	if not char then return end
	
	--armor piece
	local armor = Cube:Clone()
	armor.BrickColor = BrickColor.new("Bright yellow")
	armor.Material = "Marble"
	armor.Reflectance = 0.5
	armor.Anchored = false
	
	--arms
	local arm = armor:Clone()
	arm.Size = Vector3.new(1.1, 1.8, 1.1)
	arm.BrickColor = BrickColor.new("Deep orange")
	local armFame = CFrame.new(0, 0.2, 0)
	
	if char:FindFirstChild("Left Arm") then
		local larm = arm:Clone()
		larm.Parent = char
		weldArmor(larm, char["Left Arm"], armFame)
		table.insert(Armor, larm)
	end
	
	if char:FindFirstChild("Right Arm") then
		local rarm = arm:Clone()
		rarm.Parent = char
		weldArmor(rarm, char["Right Arm"], armFame)
		table.insert(Armor, rarm)
	end
	
	--torso
	if char:FindFirstChild("Torso") then
		local torso = armor:Clone()
		torso.Parent = char
		torso.Size = Vector3.new(2.1, 2.1, 1.1)
		weldArmor(torso, char["Torso"], CFrame.new())
		
		local light = Instance.new("PointLight")
		light.Color = BrickColor.new("Bright yellow").Color
		light.Range = 24
		light.Brightness = 4
		light.Parent = torso
		
		local fire = Instance.new("Fire")
		fire.Color = BrickColor.new("Bright yellow").Color
		fire.SecondaryColor = BrickColor.new("New Yeller").Color
		fire.Parent = torso
		
		table.insert(Armor, torso)
	end
	
	--legs
	local leg = armor:Clone()
	leg.Size = Vector3.new(1.1, 2.1, 1.1)
	local legFrame = CFrame.new()
	
	if char:FindFirstChild("Left Leg") then
		local lleg = leg:Clone()
		lleg.Parent = char
		weldArmor(lleg, char["Left Leg"], legFrame)
		table.insert(Armor, lleg)
	end
	
	if char:FindFirstChild("Right Leg") then
		local rleg = leg:Clone()
		rleg.Parent = char
		weldArmor(rleg, char["Right Leg"], legFrame)
		table.insert(Armor, rleg)
	end
	
	EquippingArmor = false
end

function armorOff()
	for _, armor in pairs(Armor) do
		armor:Destroy()
	end
end

--when we equip, we start up the clock
function onEquipped()
	--prevent reentrancy
	if EquippingArmor then return end
	
	--make SURE that we unequipped
	onUnequipped()
	
	--connect the heartbeat
	Connection = Heartbeat:connect(onTick)
	
	--put the charges into the tool
	toggleCharges(true)
	
	--armor up!
	armorOn()
	playSound("SunFireSound")

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
	
	--armor down!
	armorOff()
end

--this function plays a sound with a random pitch
function playSound(name, pitch)
	local sound = Handle:FindFirstChild(name)
	if sound then
		sound.Pitch = pitch or math.random(90, 110)/100
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

--this function performs a special jump attack
function jumpAttack()
	if Tool.Parent:FindFirstChild("HumanoidRootPart") then
		local root = Tool.Parent.HumanoidRootPart
		
		if NumberCharges > 1 then
			root.Velocity = Vector3.new(0, JumpAttackVelocity, 0)
			
			NumberCharges = NumberCharges - 1
			toggleCharges(true)
			
			CanSwing = false
			SwingTimer = 0.65
			
			Remote:FireClient(getPlayer(), "PlayAnimation", "Special", 2.4)
			
			playSound("FireSound", math.random(140, 160)/100)
			playSound("SunFireSound", math.random(200, 220)/100)
		else
			local origin = root.Position
			local direction = Vector3.new(0, -500, 0)
			local ray = Ray.new(origin, direction)
			local part, hitPos = workspace:FindPartOnRay(ray, Tool.Parent)
			local pos = hitPos + Vector3.new(0, 2.5, 0)
			local delta = pos - origin
			root.CFrame = root.CFrame + delta
			
			--sunbeam
			local beam = Cylinder:Clone()
			beam.BrickColor = BrickColor.new("Bright yellow")
			beam.Material = "Marble"
			beam.Transparency = 0.5
			beam.Position = (origin + pos) / 2
			beam.Size = Vector3.new(0.5, delta.magnitude, 0.5)
			beam.Parent = workspace
			game:GetService("Debris"):AddItem(beam, 0.25)
			
			--crater
			crater(hitPos, 6)
			
			--sound
			playSound("Explosion")
			
			--charges
			NumberCharges = NumberCharges - 1
			toggleCharges(true)
			
			--calculate damage of explosion
			local damage = delta.magnitude / 2
			
			--explosion
			local e = Instance.new("Explosion")
			e.BlastRadius = 16
			e.BlastPressure = 500000 + delta.magnitude * 1000
			e.DestroyJointRadiusPercent = 0
			e.Position = hitPos
			local victims = {}
			e.Hit:connect(function(part, distance)
				if part.Parent and part.Parent:FindFirstChild("Humanoid") and part.Parent ~= Tool.Parent then
					local human = part.Parent.Humanoid
					if not contains(victims, human) then
						tagHuman(human)
						human:TakeDamage(damage)
						table.insert(victims, human)
					end
				end
			end)
			e.Parent = workspace
		end
	end
end

--this function performs a normal strike with the blade
function normalAttack()
	--if we can't swing, don't bother
	if not CanSwing then return end
	
	if NumberCharges > 0 then
		if Tool.Parent:FindFirstChild("Humanoid") then
			if Tool.Parent.Humanoid.Jump then
				jumpAttack()
				return
			end
		end
	end
	
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
		delay(0.15, function() playSound("SwingSound") playSound("FireSound") end)
		SwingType = "Normal2"
	else
		SwingType = "Normal1"
		playSound("SwingSound")
		playSound("FireSound")
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
			normalAttack()
		end
	end)
end

setUp()