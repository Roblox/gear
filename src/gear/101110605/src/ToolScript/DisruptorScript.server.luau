-----------------
--| Constants |--
-----------------

local TIME_TO_LIVE = 30

local ANTIGRAVITY_FACTOR = 1.1

local RADIUS = 15
local SPHERE_SCALE_TARGET_MAGNITUDE = Vector3.new(10, 10, 10).magnitude
local SPHERE_GROW_SPEED = 1

local SPHERE_MESH_ID = 'http://www.roblox.com/asset/?id=94736101'
local SPHERE_TEXTURE_ID = 'http://www.roblox.com/asset/?id=101054992'
local SPHERE_VERTEX_COLOR = Vector3.new(0.6, 0, 0.8)

local FIRE_COLOR = Color3.new(145/255, 46/255, 206/255)
local FIRE_COLOR_SECONDARY = Color3.new(23/255, 0/255, 198/255)

local RBX_GRAVITY = 196.2

local FORCE_NAME = 'Antigravity'

local ONE_STEP = 1 / 30

-----------------
--| Variables |--
-----------------

local PlayersService = Game:GetService('Players')
local ContentProviderService = Game:GetService('ContentProvider')

local Disruptor = script.Parent

local ForceRegistry = {}

-----------------
--| Functions |--
-----------------

-- Returns total mass of instance and all children
local function GetMassRecursive(instance)
	local mass = 0
	if instance:IsA('BasePart') then
		mass = mass + instance:GetMass()
	end
	for _, child in pairs(instance:getChildren()) do
		if child then
			mass = mass + GetMassRecursive(child)
		end
	end
	return mass
end

local function RegisterForce(part)
	if not ForceRegistry[part] then
		part.Velocity = part.Velocity * 0.9
		local bodyForce = Instance.new('BodyForce')
		bodyForce.Name = FORCE_NAME
		bodyForce.force = Vector3.new(0, GetMassRecursive(part.Parent) * RBX_GRAVITY * ANTIGRAVITY_FACTOR, 0)
		ForceRegistry[part] = bodyForce
		bodyForce.Parent = part

		local fire = Instance.new('Fire')
		fire.Color = FIRE_COLOR
		fire.SecondaryColor = FIRE_COLOR_SECONDARY
		fire.Parent = part
	end
end

local function DeRegisterForce(part)
	local force = ForceRegistry[part]
	if force then
		force:Destroy()
		ForceRegistry[part] = nil

		local fire = part:FindFirstChild('Fire')
		if fire then
			fire:Destroy()
		end
	end
end

local function DeRegisterAllForces()
	for part in pairs(ForceRegistry) do
		DeRegisterForce(part)
	end
end

--------------------
--| Script Logic |--
--------------------

ContentProviderService:Preload(SPHERE_MESH_ID)
ContentProviderService:Preload(SPHERE_TEXTURE_ID)

Disruptor.CFrame = CFrame.new(Disruptor.Position)

-- Slowly rotate and rise into the air
local startTime = tick()
while tick() - startTime < 3 do
	Disruptor.CFrame = (Disruptor.CFrame * CFrame.Angles(0, 0.05, 0)) + Vector3.new(0, 0.1, 0)
	wait(ONE_STEP)
end

local burstSound = Disruptor:FindFirstChild('Burst')
if burstSound then burstSound:Play() end

local humSound = Disruptor:FindFirstChild('Hum')
if humSound then humSound:Play() end

-- Turn into a sphere
Disruptor.Transparency = 0.5
local sphere = Disruptor:FindFirstChild('Mesh') or Instance.new('SpecialMesh')
--sphere.MeshType = Enum.MeshType.Sphere
sphere.MeshId = SPHERE_MESH_ID
sphere.TextureId = SPHERE_TEXTURE_ID
sphere.VertexColor = SPHERE_VERTEX_COLOR
sphere.Parent = Disruptor

Spawn(function()
	-- Grow the sphere very quickly
	--local scaleTarget = (1 / Disruptor.Size) * RADIUS * 2
	--while sphere.Scale.magnitude < scaleTarget.magnitude do
	while sphere.Scale.magnitude < SPHERE_SCALE_TARGET_MAGNITUDE do
		sphere.Scale = sphere.Scale + Vector3.new(SPHERE_GROW_SPEED, SPHERE_GROW_SPEED, SPHERE_GROW_SPEED)
		wait(ONE_STEP)
	end
end)

-- Check for players entering and leaving
local startTime = tick()
while tick() - startTime < TIME_TO_LIVE do
	for _, player in pairs(PlayersService:GetPlayers()) do
		local character = player.Character
		if character then
			local torso = character:FindFirstChild('Torso')
			if torso then
				local distance = (torso.Position - Disruptor.Position).magnitude
				if distance <= RADIUS then -- Within range
					RegisterForce(torso)
				else -- Out of range
					DeRegisterForce(torso)
				end
			end
		end
	end
	wait(ONE_STEP)
end

DeRegisterAllForces()
Disruptor:Destroy()
