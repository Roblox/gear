-----------------
--| Constants |--
-----------------

local COOLDOWN = 1 -- Seconds until tool can be used again

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
local ROCKET_PART_SIZE = Vector3.new(0.9, 1.23, 2.54)

local VELOCITY = 110 -- constant
local VELOCITY_SQAURED = VELOCITY * VELOCITY
local VELOCITY_TO_FOURTH = VELOCITY_SQAURED * VELOCITY_SQAURED

local CAT_SOUNDS = 
{
	105177975,105178048,105178068,105178079,105178092,105178092,105178116
}

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do print('waiting for'..childName) wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local RocketScript = WaitForChild(script, 'Rocket')

local SwooshSound = WaitForChild(script, 'Swoosh')
local BoomSound = WaitForChild(script, 'Boom')
local ReloadSound = WaitForChild(ToolHandle, 'ReloadSound')
local EquipSound

local MyModel = nil
local MyPlayer = nil

local BaseRocket = nil
local RocketClone = nil

local RocketMeshes = WaitForChild(Tool,'RocketMeshes')

local textGui=WaitForChild(Tool,'textGui')

local Kills=WaitForChild(Tool,'Kills')

local aniScript=WaitForChild(script,'aniScript')

local InUltra=false

local TemplateCatapult = game:GetService("InsertService"):LoadAsset(105292979):GetChildren()[1]
TemplateCatapult.Name = '_$_CATMODEL_$_'

do
	local tgyro = Instance.new('BodyGyro')
	tgyro.maxTorque = Vector3.new(math.huge,math.huge,math.huge)	
	tgyro.Parent = WaitForChild(TemplateCatapult,'Torso')
	--local tmesh = Instance.new('SpecialMesh')
	--tmesh.MeshId = 'http://www.roblox.com/asset/?id=98331889'
	--tmesh.TextureId = 'http://www.roblox.com/asset/?id=98332070'
	--tmesh.Parent = TemplateCatapult
	local tpos = Instance.new('BodyPosition')
	tpos.maxForce = Vector3.new(math.huge,0,math.huge)
	tpos.Parent = WaitForChild(TemplateCatapult,'Torso')
end

local GroundCatapult= nil

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
	rocket.FormFactor = Enum.FormFactor.Custom --NOTE: This must be done before changing Size
	rocket.Size = ROCKET_PART_SIZE
	rocket.CanCollide = false
	rocket.BottomSurface = Enum.SurfaceType.Smooth
	rocket.TopSurface = Enum.SurfaceType.Smooth

	-- Add the mesh
	local mesh = RocketMeshes[math.random(RocketMeshes.Value)]:Clone()--Instance.new('SpecialMesh', rocket)
	--mesh.MeshId = 
	mesh.Scale = ROCKET_MESH_SCALE
	--mesh.TextureId = ToolHandle.Mesh.TextureId
	mesh.Parent=rocket


	local spin = Instance.new('BodyAngularVelocity')
	spin.maxTorque=Vector3.new(999999,999999,999999)
	spin.angularvelocity=Vector3.new(math.random()*30-15,math.random()*30-15,math.random()*30-15)
	spin.Parent=rocket
	
	-- Clone the sounds
	local swooshSoundClone = SwooshSound:Clone()
	swooshSoundClone.SoundId= 'http://www.roblox.com/asset/?id='..CAT_SOUNDS[math.random(#CAT_SOUNDS)]
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
	EquipSound = WaitForChild(ToolHandle, 'Equip')
	EquipSound:Play()
end

function PlayAnimation()
	WaitForChild(aniScript,'animator').Value = WaitForChild(GroundCatapult,'Humanoid')	
	for _,i in pairs(game.Players:GetPlayers()) do
		local tscript = aniScript:Clone()
		tscript.Parent = i.Backpack
		tscript.Disabled=false		
		
	end
end

function FireCatapult(targetOverride)
	if (Tool.Enabled or InUltra) and MyModel and MyModel:FindFirstChild('Humanoid') and MyModel.Humanoid.Health > 0 then
		Tool.Enabled = false
		PlayAnimation()
		wait(.3)
		-- Pick a target
		local targetPosition = targetOverride or MyModel.Humanoid.TargetPoint

		-- Position the rocket clone
		local spawnPosition = GroundCatapult.Torso.Position + Vector3.new(0,10,0)--(GroundCatapult.CFrame.lookVector * (GroundCatapult.Size.z / 6))
		RocketClone.CFrame = CFrame.new(spawnPosition, targetPosition) --NOTE: This must be done before assigning Parent
		DebrisService:AddItem(RocketClone, 30)
		RocketClone.Parent = Workspace

		local startPosition = spawnPosition
		local mouse_pos=targetPosition
		local dir = mouse_pos - startPosition
		dir = dir.unit
	
		local launch = startPosition + 3 * dir
	
		local delta = mouse_pos - launch
		
		local dy = delta.y
		
		local new_delta = Vector3.new(delta.x, 0, delta.z)
		delta = new_delta
	
		local dx = delta.magnitude
		local unit_delta = delta.unit
		
		-- acceleration due to gravity in RBX units
		local g = (-9.81 * 20)
	
		local theta = computeLaunchAngle( dx, dy, g)

		local vy = math.sin(theta)
		local xz = math.cos(theta)
		local vx = unit_delta.x * xz
		local vz = unit_delta.z * xz
		
		RocketClone.Velocity = Vector3.new(vx,vy,vz) * VELOCITY


		wait(0) --TODO: Remove when sounds realize they can be played as soon as they enter the Workspace
		
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
		if not InUltra then
			wait(COOLDOWN)
		end

		-- Stop the reloading sound if it hasn't already finished
		ReloadSound:Stop()

		Tool.Enabled = true
	end
end

function FollowTarget()
	local human = WaitForChild(MyModel,'Humanoid')
	while GroundCatapult do
		if GroundCatapult.Torso:FindFirstChild('BodyGyro') then
			GroundCatapult.Torso['BodyGyro'].cframe = CFrame.new(Vector3.new(0,0,0),
				Vector3.new(human.TargetPoint.x-GroundCatapult.Torso.CFrame.p.x,
				0,--GroundCatapult.CFrame.p.y,
				human.TargetPoint.z-GroundCatapult.Torso.CFrame.p.z))
		end
		
		wait()
	end	
end


function DropCatapult()
	GroundCatapult = TemplateCatapult:Clone()
	WaitForChild(GroundCatapult,'Torso').CFrame = WaitForChild(MyModel,'Torso').CFrame+MyModel.Torso.CFrame.lookVector*4
	WaitForChild(GroundCatapult.Torso,'BodyPosition').position = GroundCatapult.Torso.CFrame.p
	GroundCatapult.Parent = game.Workspace
	Spawn(FollowTarget)
end


function OnActivated(targetOverride)
	if GroundCatapult then
		print(GroundCatapult)
		FireCatapult(targetOverride)
	else
		print('dropping pult')
		DropCatapult()
	end
end

local function OnUnequipped()
	if GroundCatapult then
		GroundCatapult:Destroy()
		GroundCatapult=nil
	end
	
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
			OnActivated()
			wait(.5)
		end
		InUltra=false
	end
end

--------------------
--| Script Logic |--
--------------------


Kills.Changed:connect(updateUltra)
Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)
Tool.ChildAdded:connect(OnChildAdded) --NOTE: Added for Action Button

