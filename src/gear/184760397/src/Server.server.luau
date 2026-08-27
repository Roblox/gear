local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")
local Power = Tool:WaitForChild("Power")
local Charging = Tool:WaitForChild("Charging")

local ChargeRate = 25
local QuickestAttackRate = 0.6
local PreviousPower = 0
local ChargeNoise = Handle:WaitForChild("ChargeNoise")

local TickEvent

local Damage = 35

local Projectiles = {}

function powerCrossed(threshold)
	return Power.Value >= threshold and PreviousPower < threshold
end

function powersCrossed(powers)
	local bool = false
	for _, power in pairs(powers) do
		bool = bool or powerCrossed(power)
	end
	return bool
end

function onTick(dt)
	--handle the power!
	if Charging.Value then
		Power.Value = Power.Value + ChargeRate * dt
	else
		Power.Value = Power.Value - ChargeRate * dt
	end
	
	if Power.Value > 100 then
		Power.Value = 100
	elseif Power.Value < 0 then
		Power.Value = 0
	end
	
	if Charging.Value then
		if powersCrossed{15, 30, 45, 60, 75, 90} then
			ChargeNoise.Pitch = 0.6 + 0.4 * (Power.Value / 100)
			ChargeNoise:Play()
		end
	end
	
	PreviousPower = Power.Value
end

function launchProjectile(c)
	local p = projectile()
	p.CFrame = c
	p.Velocity = c.lookVector * (64 + Power.Value)
	p.Parent = workspace
	game:GetService("Debris"):AddItem(p, 10)
	
	local event
	event = p.Touched:connect(function(part)
		projectileTouched(part, p, event)
	end)
	
	table.insert(Projectiles, p)
end

function attack(pos)
	if Power.Value < ChargeRate * QuickestAttackRate then return end
	
	local a = Handle.CFrame:pointToWorldSpace(Vector3.new(0, 0, -1))
	local b = pos
	local c = CFrame.new(a, b)
	launchProjectile(c)
	if Power.Value >= 100 then
		local r = math.pi/32
		launchProjectile(c * CFrame.Angles(0, r, 0))
		launchProjectile(c * CFrame.Angles(0, -r, 0))
	end
	
	Handle.Fire.Pitch = math.random(90,110)/100
	Handle.Fire:Play()
	
	Power.Value = 0
end

function getPlayerChar()
	local char = Tool.Parent
	local player = game:GetService("Players"):GetPlayerFromCharacter(char)
	return player, char
end

function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

function tagHuman(human)
	local player, char = getPlayerChar()
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = player
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function projectileTouched(part, proj, event)
	--not another arrow
	if contains(Projectiles, part) then return end
	
	--not my character
	local char = Tool.Parent
	if part:IsDescendantOf(char) then return end
	
	--damage
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		tagHuman(human)
		human:TakeDamage(Damage)
	end
	
	--control
	event:disconnect()
	
	--weld/physics
	local w = Instance.new("Weld")
	w.Part0 = part
	w.Part1 = proj
	w.C0 = part.CFrame:toObjectSpace(proj.CFrame)
	w.Parent = w.Part0
	
	proj.CanCollide = false
	
	--graphics/sound
	proj.Fire.Enabled = false
	proj.ArrowHit:Play()
end

function projectile()
	local part = Instance.new("Part")
	part.FormFactor = "Custom"
	part.Size = Vector3.new(0.2, 0.2, 1.4)
	part.Material = "CorrodedMetal"
	part.CanCollide = false
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 8, 0)
	lift.Parent = part
	
	local steam = Instance.new("Fire")
	steam.Size = 2
	steam.Heat = 0
	steam.Color = Color3.new(1, 1, 1)
	steam.SecondaryColor = Color3.new(1, 1, 1)
	steam.Parent = part
	
	local sound = Handle.ArrowHit:Clone()
	sound.Pitch = math.random(90, 110)/100
	sound.Parent = part
	
	return part
end

function onRemote(caller, func, ...)
	local player, char = getPlayerChar()
	
	if caller == player then
		local args = {...}
		
		if func == "Start" then
			Charging.Value = true
		end
		
		if func == "End" then
			Charging.Value = false
			attack(args[1])
		end
	end
end

function onEquipped()
	--ensure unequip
	onUnequipped()
	
	--start ticking
	TickEvent = game:GetService("RunService").Heartbeat:connect(onTick)
end

function onUnequipped()
	--stop ticking
	if TickEvent then
		TickEvent:disconnect()
	end
	
	--charge off and power down
	Charging.Value = false
	Power.Value = 0
end

--connect
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnServerEvent:connect(onRemote)