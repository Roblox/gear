local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

local MyPlayer,MyCharacter,MyHumanoid

local Fire = Tool:WaitForChild("Remote")

local BaseRocket = nil
local RocketClone = nil

local RocketScript = script:WaitForChild("Rocket"):Clone()

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	ReloadSound = Handle:WaitForChild("ReloadSound"),
	HoldLock =  Handle:WaitForChild("holdlock"),
	LockOn = Handle:WaitForChild("lockon")
}

local AnimationFolder = Tool:WaitForChild("Animations")

local ShootReloadAnim

local COOLDOWN = 5 -- Seconds until tool can be used again

-- RocketPropulsion Fields
local TARGET_RADIUS = 5
local MAX_SPEED = 200--60
local MAX_TORQUE = Vector3.new(40, 40, 0)
local MAX_THRUST = 50000
local THRUST_P = 100--500
local THRUST_D = 5


local TARGET_OVERSHOOT_DISTANCE = 10000000

local ROCKET_MESH_ID = 'http://www.roblox.com/asset/?id=103970395'
local ROCKET_MESH_SCALE = Vector3.new(1, 1, 1)
local ROCKET_PART_SIZE = Vector3.new(1, 1, 4)

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
	mesh.TextureId = Handle.Mesh.TextureId

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
	local swooshSoundClone = script.Swoosh:Clone()
	swooshSoundClone.Parent = rocket
	local boomSoundClone = script.Boom:Clone()
	boomSoundClone.PlayOnRemove = true
	boomSoundClone.Parent = rocket

	-- Attach creator tags
	local creatorTag = Instance.new('ObjectValue', rocket)
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	creatorTag.Value = MyPlayer
	local nameTag = Instance.new('StringValue', creatorTag)
	nameTag.Name = 'weaponName'
	nameTag.Value = Tool.Name
	local iconTag = Instance.new('StringValue', creatorTag)
	iconTag.Name = 'weaponIcon'
	iconTag.Value = Tool.TextureId

	-- Finally, clone the rocket script and enable it
	local rocketScriptClone = RocketScript:Clone()
	rocketScriptClone.Parent = rocket
	rocketScriptClone.Disabled = false

	return rocket
end

local function OnActivated(Player,targetOverride,LockedPlayer)
	wait(0) --TODO: Remove when Mouse.Hit and Humanoid.TargetPoint update properly on iPad
	if not MyPlayer or not Player or Player ~= MyPlayer then return end
	if Tool.Enabled and MyCharacter and MyHumanoid and MyHumanoid.Health > 0 then
		Tool.Enabled = false
	
		ShootReloadAnim:Play()
		-- Pick a target
		local targetPosition = targetOverride or MyCharacter.Humanoid.TargetPoint

		-- Position the rocket clone
		local spawnPosition = Handle.Position + (Handle.CFrame.lookVector * (Handle.Size.Z / 2))
		RocketClone.CFrame = CFrame.new(spawnPosition, targetPosition) --NOTE: This must be done before assigning Parent
		Services.Debris:AddItem(RocketClone, 30)
		RocketClone.Parent = workspace
		RocketClone:SetNetworkOwner(MyPlayer)
		-- Assign target and launch!
		local rocketPropulsion = RocketClone:FindFirstChild('RocketPropulsion')
		if rocketPropulsion then
			
			if not LockedPlayer then
				local direction = (targetPosition - RocketClone.Position).unit
				rocketPropulsion.TargetOffset = RocketClone.Position + (direction * TARGET_OVERSHOOT_DISTANCE)
			else
				rocketPropulsion.Target = LockedPlayer.Character:FindFirstChild('HumanoidRootPart') or LockedPlayer.Character:FindFirstChild('Torso')
				--rocketPropulsion.ReachedTarget:connect(rocketPropulsion:Destroy())
			end
			rocketPropulsion:Fire()
		end

		-- Prepare the next rocket to be fired
		RocketClone = BaseRocket:Clone()

		Sounds.ReloadSound:Play()

		wait(COOLDOWN)

		-- Stop the reloading sound if it hasn't already finished
		Sounds.ReloadSound:Stop()

		Tool.Enabled = true
	end
end

function Equipped()
	MyCharacter = Tool.Parent
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter)
	Sounds.Equip:Play()
	BaseRocket = MakeBaseRocket()
	RocketClone = BaseRocket:Clone()
	ShootReloadAnim = MyHumanoid:LoadAnimation(AnimationFolder:WaitForChild(MyHumanoid.RigType.Name):WaitForChild("FireAndReload"))
end

function Unequipped()
	ShootReloadAnim:Stop()
	MyCharacter = nil
	MyHumanoid = nil
	MyPlayer = nil
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Fire.OnServerEvent:Connect(OnActivated)

