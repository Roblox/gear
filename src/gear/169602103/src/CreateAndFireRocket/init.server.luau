-- RocketPropulsion Fields
local TARGET_RADIUS = 5
local MAX_SPEED = 150--60
local MAX_TORQUE = Vector3.new(40, 40, 0)
local MAX_THRUST = 40000
local THRUST_P = 100--500
local THRUST_D = 5

local DebrisService = Game:GetService('Debris')
local SwooshSound = script:WaitForChild('Swoosh')
local BoomSound = script:WaitForChild('Boom')

local TARGET_OVERSHOOT_DISTANCE = 10000000

local ROCKET_MESH_ID = 'http://www.roblox.com/asset/?id=168893996'
local ROCKET_MESH_SCALE = Vector3.new(1, 1, 1)
local ROCKET_PART_SIZE = Vector3.new(2, 2, 4)

script.Parent.FireRocket.OnServerEvent:connect(function(MyPlayer, targetPosition, spawnPosition)
	
	local function MakeBaseRocket()
		-- Set up the rocket part
		local rocket = Instance.new('Part')
		rocket.Name = 'Rocket'
		rocket.FormFactor = Enum.FormFactor.Custom --NOTE: This must be done before changing Size
		rocket.Size = ROCKET_PART_SIZE
		rocket.CanCollide = false
		rocket.BottomSurface = Enum.SurfaceType.Smooth
		rocket.TopSurface = Enum.SurfaceType.Smooth
	
		-- Add the mesh
		local mesh = Instance.new('SpecialMesh', rocket)
		mesh.MeshId = ROCKET_MESH_ID
		mesh.Scale = ROCKET_MESH_SCALE
		mesh.TextureId = "http://www.roblox.com/asset/?id=168893936"
	
		-- Add fire
		local fire = Instance.new('Fire', rocket)
		fire.Heat = 5
		fire.Size = 2
	
		-- Add the propulsion
		local rocketPropulsion = Instance.new('RocketPropulsion', rocket)
		rocketPropulsion.CartoonFactor = 1
		rocketPropulsion.TargetRadius = TARGET_RADIUS
		rocketPropulsion.MaxSpeed = MAX_SPEED
		rocketPropulsion.MaxTorque = MAX_TORQUE
		rocketPropulsion.MaxThrust = MAX_THRUST
		rocketPropulsion.ThrustP = THRUST_P
		rocketPropulsion.ThrustD = THRUST_D
		
		-- Clone the sounds
		local swooshSoundClone = SwooshSound:Clone()
		swooshSoundClone.Parent = rocket
		local boomSoundClone = BoomSound:Clone()
		boomSoundClone.PlayOnRemove = true
		boomSoundClone.Parent = rocket
	
		-- Attach creator tags
		local creatorTag = Instance.new('ObjectValue', rocket)
		creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
		creatorTag.Value = MyPlayer
	
		-- Finally, clone the rocket script and enable it
		local rocketScriptClone = script:WaitForChild("Rocket"):Clone()
		rocketScriptClone.Parent = rocket
		rocketScriptClone.Disabled = false
		
		return rocket
	end
	
	local RocketClone = MakeBaseRocket()
	
	RocketClone.CFrame = CFrame.new(spawnPosition, targetPosition) --NOTE: This must be done before assigning Parent
	DebrisService:AddItem(RocketClone, 30)
	RocketClone.Parent = Workspace
	
	-- Assign target and launch!
	local rocketPropulsion = RocketClone:FindFirstChild('RocketPropulsion')
	if rocketPropulsion then
		local direction = (targetPosition - RocketClone.Position).unit
		rocketPropulsion.TargetOffset = RocketClone.Position + (direction * TARGET_OVERSHOOT_DISTANCE)
		rocketPropulsion:Fire()
	end
	
end)