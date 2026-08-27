-----------------
--| Constants |--
-----------------

local COOLDOWN = 4 -- Seconds until tool can be used again

-- RocketPropulsion Fields
local TARGET_RADIUS = 5
local MAX_SPEED = 75
local MAX_TORQUE = Vector3.new(4e6, 4e6, 0)
local MAX_THRUST = 50000
local THRUST_P = 500
local THRUST_D = 50000

local TARGET_OVERSHOOT_DISTANCE = 10000000

local ROCKET_MESH_ID = 'http://www.roblox.com/asset/?id=94690081'
local ROCKET_MESH_SCALE = Vector3.new(2, 2, 2)
local ROCKET_PART_SIZE = Vector3.new(2,2.4,1)

local VELOCITY = 110 -- constant
local VELOCITY_SQAURED = VELOCITY * VELOCITY
local VELOCITY_TO_FOURTH = VELOCITY_SQAURED * VELOCITY_SQAURED

-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local Remote = Instance.new("RemoteEvent")
Remote.Name = "Remote"
Remote.Parent = Tool

local RocketScript = script:WaitForChild("Rocket")

local SwooshSound = script:WaitForChild("Swoosh")
local BoomSound = script:WaitForChild("Boom")
local ReloadSound = ToolHandle:WaitForChild("ReloadSound")
local EquipSound

local MyModel = nil
local MyPlayer = nil

local BaseRocket = nil
local RocketClone = nil

local RocketMeshes = Tool:WaitForChild("RocketMeshes")

local textGui= Tool:WaitForChild("textGui")

local Kills= Tool:WaitForChild("Kills")

local InUltra=false

-----------------
--| Functions |--
-----------------

function computeLaunchAngle(dx,dy,grav)
	-- arcane
	-- http://en.wikipedia.org/wiki/Trajectory_of_a_projectile
	
	local g = math.abs(grav)
	local inRoot = (VELOCITY_TO_FOURTH) - (g * ((g*dx*dx) + (2*dy*VELOCITY_SQAURED)))
	if inRoot <= 0 then
		return .25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((VELOCITY_SQAURED) + root) / (g*dx)

	local inATan2 = ((VELOCITY_SQAURED) - root) / (g*dx)
	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)
	return math.min(answer1,answer2)
end

local function MakeBaseRocket()
	-- Set up the rocket part
	local rocket = Instance.new('Part')
	rocket.Name = 'Rocket'
	--rocket.FormFactor = Enum.FormFactor.Custom --NOTE: This must be done before changing Size
	rocket.Size = ROCKET_PART_SIZE
	rocket.CanCollide = false
	rocket.BottomSurface = Enum.SurfaceType.Smooth
	rocket.TopSurface = Enum.SurfaceType.Smooth

	-- Add the mesh
	local mesh = RocketMeshes[math.random(1,#RocketMeshes:GetChildren())]:Clone()--Instance.new('SpecialMesh', rocket)
	--mesh.MeshId = 
	mesh.Scale = ROCKET_MESH_SCALE
	--mesh.TextureId = ToolHandle.Mesh.TextureId
	mesh.Parent=rocket

	-- Add fire
	local fire = Instance.new('Fire', rocket)
	fire.Heat = 5
	fire.Size = 2


	local spin = Instance.new('BodyAngularVelocity')
	spin.maxTorque=Vector3.new(999999,999999,999999)
	spin.angularvelocity=Vector3.new(math.random()*30-15,math.random()*30-15,math.random()*30-15)
	spin.Parent=rocket
	
	-- Clone the sounds
	local swooshSoundClone = SwooshSound:Clone()
	swooshSoundClone.Parent = rocket
	local boomSoundClone = BoomSound:Clone()
	boomSoundClone.Parent = rocket

	-- Attach creator tags
	local creatorTag = Instance.new('ObjectValue', rocket)
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	creatorTag.Value = MyPlayer
	local iconTag = Instance.new('StringValue', creatorTag)
	iconTag.Name = 'icon'
	iconTag.Value = Tool.TextureId

	-- Finally, clone the rocket script and enable it
	local rocketScriptClone = RocketScript:Clone()
	rocketScriptClone.Parent = rocket
	rocketScriptClone.Disabled = false

	return rocket
end

local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	BaseRocket = MakeBaseRocket()
	RocketClone = BaseRocket:Clone()
	EquipSound = ToolHandle:WaitForChild("Equip")
	EquipSound:Play()
end

local function OnActivated(Player,targetOverride)
	if (Tool.Enabled or InUltra) and MyModel and MyModel:FindFirstChildOfClass('Humanoid') and MyModel.Humanoid.Health > 0 then
		Tool.Enabled = false

		-- Pick a target
		local targetPosition = targetOverride

		-- Position the rocket clone
		local spawnPosition = ToolHandle.Position + (ToolHandle.CFrame.lookVector * (ToolHandle.Size.z / 2))
		RocketClone.CFrame = CFrame.new(spawnPosition, targetPosition) --NOTE: This must be done before assigning Parent
		DebrisService:AddItem(RocketClone, 30)
		RocketClone.Parent = workspace
		RocketClone:SetNetworkOwner(MyPlayer)

		local startPosition = spawnPosition
		local mouse_pos=targetPosition
		local dir = mouse_pos - startPosition
		dir = dir.unit
	
		local launch = startPosition + 3 * dir
	
		local delta = mouse_pos - launch
		
		local dy = delta.y
		
		local new_delta = Vector3.new(delta.x, 0, delta.z)
		delta = new_delta
	
		local dx = delta.Magnitude
		local unit_delta = delta.Unit
		
		-- acceleration due to gravity in RBX units
		local g = (-9.81 * 20)
	
		local theta = computeLaunchAngle( dx, dy, g)

		local vy = math.sin(theta)
		local xz = math.cos(theta)
		local vx = unit_delta.x * xz
		local vz = unit_delta.z * xz
		
		RocketClone.Velocity = Vector3.new(vx,vy,vz) * VELOCITY


		--wait(0) --TODO: Remove when sounds realize they can be played as soon as they enter the Workspace
		
		-- Swoosh!
		local swooshSound = RocketClone:FindFirstChild('Swoosh')
		if swooshSound then
			swooshSound:Play()
		end

		-- Prepare the next rocket to be fired
		BaseRocket:Destroy()
		BaseRocket = MakeBaseRocket()
		RocketClone = BaseRocket:Clone()

		ReloadSound:Play()
		--if not InUltra then
			wait((InUltra and .05) or COOLDOWN)
		--end

		-- Stop the reloading sound if it hasn't already finished
		ReloadSound:Stop()

		Tool.Enabled = true
	end
end

local function OnUnequipped()
	ReloadSound:Stop() --TODO: This does not work online
end

function updateUltra()
	if Kills.Value>2 then 
		Kills.Value=0
		InUltra=true
		local tgui=textGui:Clone()
		tgui.Parent=MyPlayer.PlayerGui
		game.Debris:AddItem(tgui,10)
		local startTime=tick()
		while tick()-startTime<10 do
			--OnActivated()
			wait(.5)
		end
		InUltra=false
	end
end

--------------------
--| Script Logic |--
--------------------

Remote.OnServerEvent:Connect(OnActivated)

Kills.Changed:Connect(updateUltra)
Tool.Equipped:Connect(OnEquipped)
--Tool.Activated:Connect(OnActivated)
Tool.Unequipped:Connect(OnUnequipped)
--Tool.ChildAdded:Connect(OnChildAdded) --NOTE: Added for Action Button

