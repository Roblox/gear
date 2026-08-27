local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")

local TickEvent

local Charging = false
local Charge = 0
local ChargeRate = 25
local ChargeVis

local MinChargeTime = 1.3
local ChargeNeededToFire = ChargeRate * MinChargeTime

local Damage = 30

local R = math.random

local IceColors = {
	BrickColor.new("Bright blue"),
	BrickColor.new("Teal"),
	BrickColor.new("Deep blue"),
}

function RP()
	return R() * math.pi * 2
end

function iceColor()
	return IceColors[math.random(1, #IceColors)]
end

function getPlayer()
	local char = Tool.Parent
	local player = game:GetService("Players"):GetPlayerFromCharacter(char)
	return player
end

function lerp(a, b, r)
	return a + (b - a) * r
end

function createChargeVis()
	local part = Instance.new("Part")
	part.FormFactor = "Symmetric"
	part.Size = Vector3.new(1, 1, 1)
	part.CanCollide = false
	part.BrickColor = BrickColor.new("Bright blue")
	part.Transparency = 0.5
	part.Material = "Ice"
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "Sphere"
	mesh.Name = "Mesh"
	mesh.Parent = part
	
	local fire = Instance.new("Fire")
	fire.Name = "Fire"
	fire.Size = 2
	fire.Color = part.BrickColor.Color
	fire.SecondaryColor = part.BrickColor.Color
	fire.Parent = part
	
	return part
end

function visualizeCharge()
	if Charge > 0 then
		if not ChargeVis then
			ChargeVis = createChargeVis()
			ChargeVis.Parent = workspace
			
			local w = Instance.new("Weld")
			w.Part0 = Handle
			w.Part1 = ChargeVis
			w.C0 = CFrame.new(0, 0, -Handle.Size.Z / 2)
			w.Parent = w.Part0
		end
		
		local size = lerp(0, 5, Charge/100)
		ChargeVis.Mesh.Scale = Vector3.new(size, size, size)
		ChargeVis.Fire.Size = size
	else
		if ChargeVis then
			ChargeVis.Fire.Enabled = false
			ChargeVis.Transparency = 1
			game:GetService("Debris"):AddItem(ChargeVis, 1)
			ChargeVis = nil
		end
	end
end

function onTick(dt)
	if Charging then
		Charge = Charge + ChargeRate * dt
	else
		Charge = Charge - ChargeRate * dt
	end
	
	if Charge > 100 then
		Charge = 100
	elseif Charge < 0 then
		Charge = 0
	end
	
	visualizeCharge()
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
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function grow(part, totalTime)
	local startSize = Vector3.new(0, 0, 0)
	local endSize = part.Size
	local c = part.CFrame
	
	local t = 0
	local event
	event = game:GetService("RunService").Heartbeat:connect(function(dt)
		t = t + dt
		local size = lerp(startSize, endSize, t/totalTime)
		part.Size = size
		
		if t >= totalTime then
			event:disconnect()
			part.Size = endSize
			part.Sound:Play()
		end
		
		part.CFrame = c
	end)
	
	part.Size = startSize
	part.CFrame = c
end

function crystallize(position, size)
	local victims = {}
	local humans = {}
	
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = position
	anchor.Parent = workspace
	game:GetService("Debris"):AddItem(anchor, 2 + size)
	
	local sound = Handle.IceFormSound:Clone()
	sound.Pitch = math.random(50, 70)/100
	sound.Parent = anchor
	sound:Play()
	
	for crystalNumber = 1, 6 + size do
		local lower = math.max(0, crystalNumber - 3)
		local upper = crystalNumber + 1
		local growTime = crystalNumber / 3
		
		local crystal = Instance.new("Part")
		crystal.Transparency = 0.5
		crystal.FormFactor = "Custom"
		crystal.Anchored = true
		crystal.CanCollide = false
		crystal.TopSurface = "Smooth"
		crystal.BottomSurface = "Smooth"
		crystal.Material = "Ice"
		crystal.BrickColor = iceColor()
		crystal.CFrame = CFrame.new(position) * CFrame.Angles(RP(), RP(), RP())
		crystal.Size = Vector3.new(R(lower, upper), R(lower, upper), R(lower, upper))
		
		local sound = Handle.IceFormSound:Clone()
		sound.Name = "Sound"
		sound.Pitch = math.random(60,140)/100
		sound.Parent = crystal
		
		grow(crystal, growTime)
		crystal.Parent = workspace
		game:GetService("Debris"):AddItem(crystal, 2 + size)
				
		crystal.Touched:connect(function(part)
			if contains(victims, part) then return end
			if part.Anchored then return end
			
			table.insert(victims, part)
			
			local w = Instance.new("Weld")
			w.Part0 = anchor
			w.Part1 = part
			w.C0 = anchor.CFrame:toObjectSpace(part.CFrame)
			w.Parent = w.Part0
			
			if part.Parent and part.Parent:FindFirstChild("Humanoid") then
				local human = part.Parent.Humanoid
				if not contains(humans, human) then
					table.insert(humans, human)
					tagHuman(human)
					human:TakeDamage(Damage)
				end
			end
		end)
	end
end

function onBulletTouched(part, bullet)
	if part:IsDescendantOf(Tool.Parent) then return end
	if part == ChargeVis then return end
	if part.Transparency == 1 and part.CanCollide == false then return end
	
	local position = bullet.Position
	bullet:Destroy()
	crystallize(position, bullet.Size.X)
end

function fire(targetPos)
	if Charge < ChargeNeededToFire then return end
	
	local a = Handle.CFrame:pointToWorldSpace(Vector3.new(0, 0, -Handle.Size.Z/2))
	local b = targetPos
	local c = CFrame.new(a, b)
	
	local size = math.floor(lerp(1, 4, Charge/100))
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 150, 0)
	
	local bullet = createChargeVis()
	lift.Parent = bullet
	bullet.Size = Vector3.new(size, size, size)
	bullet.CFrame = c
	bullet.Velocity = bullet.CFrame.lookVector * 128
	bullet.Parent = workspace
	game:GetService("Debris"):AddItem(bullet)
	
	bullet.Touched:connect(function(part)
		onBulletTouched(part, bullet)
	end)
	
	Charge = 0
	
	Handle.Fire.Pitch = math.random(90, 110)/100
	Handle.Fire:Play()
end

function onEquipped()
	--ensure unequip
	onUnequipped()
	
	--tick
	TickEvent = game:GetService("RunService").Heartbeat:connect(onTick)
end

function onUnequipped()
	--stop tick
	if TickEvent then
		TickEvent:disconnect()
	end
	
	--stop the charge!
	Charging = false
	Charge = 0
	if ChargeVis then
		ChargeVis:Destroy()
		ChargeVis = nil
	end
end

function onRemote(player, func, ...)
	if player == getPlayer() then
		local args = {...}
		
		if func == "Start" then
			Charging = true
		elseif func == "End" then
			Charging = false
			fire(args[1])
		end
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnServerEvent:connect(onRemote)