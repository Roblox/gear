-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')
local VELOCITY = 110 -- constant
local VELOCITY_SQAURED = VELOCITY * VELOCITY
local VELOCITY_TO_FOURTH = VELOCITY_SQAURED * VELOCITY_SQAURED
local ASSET_PREFIX = "http://www.roblox.com/asset/?id="

local MyMouse

local SlingShotMeshIds = {Ammo = 94689434, AttachMe = 94689472, Full = 94689497, Handle = 94689515}

local DebrisService = game:GetService('Debris')
local ContentProvider = Game:GetService("ContentProvider")
local Pellet = Instance.new("Part")
Pellet.Locked = true
Pellet.BackSurface = 0
Pellet.BottomSurface = 0
Pellet.FrontSurface = 0
Pellet.LeftSurface = 0
Pellet.RightSurface = 0
Pellet.TopSurface = 0
Pellet.Shape = 0
Pellet.Size = Vector3.new(1,1,1)
--Pellet.BrickColor = BrickColor.new('Bright red') --BrickColor.new(2)
local PelletMesh = Instance.new('SpecialMesh')
PelletMesh.MeshId = ASSET_PREFIX .. SlingShotMeshIds['Ammo']
PelletMesh.TextureId = ASSET_PREFIX .. 94689543
PelletMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
PelletMesh.Name = 'PelletMesh'
PelletMesh.Parent = Pellet

local SlingShotMesh

local EquipSound
local SlingshotSounds

local PelletCopy

WaitForChild(Tool, 'PelletScript'):clone().Parent = Pellet

function Fire(mouse_pos)

	if SlingshotSounds then
		local soundNum = math.random(1, #SlingshotSounds)
		SlingshotSounds[soundNum]:Play()
	end

-- find player's head pos

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	local head = vCharacter:findFirstChild("Head")
	if head == nil then return end

	local startPosition = Tool.Handle.Position + Vector3.new(0,1,0)

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
	

	local missile = Pellet:clone()

	missile.CFrame = CFrame.new(launch, launch+Vector3.new(vx,vy,vz))
        
	--missile.Position = launch
	missile.Velocity = Vector3.new(vx,vy,vz) * VELOCITY

	missile.PelletScript.Disabled = false
	

	missile.PelletMesh.Scale = Vector3.new(2,2,2)

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	local weaponNameTag = Instance.new('StringValue')
	weaponNameTag.Name = 'weaponName'
	weaponNameTag.Value = Tool.Name
	weaponNameTag.Parent = creator_tag
	local weaponIconTag = Instance.new('StringValue')
	weaponIconTag.Name = 'weaponIcon'
	weaponIconTag.Value = Tool.TextureId
	weaponIconTag.Parent = creator_tag
	creator_tag.Parent = missile
	
	DebrisService:AddItem(missile,2.0)
	missile.Parent = game.Workspace

end


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


Tool.Enabled = true
function OnActivated(targetOverride)
	wait(0) --TODO: Remove when Mouse.Hit and Humanoid.TargetPoint update properly on iPad
	if not Tool.Enabled then
		return
	end
	local character = Tool.Parent;
	local humanoid = character:FindFirstChild('Humanoid')
	if humanoid == nil or humanoid.Health <= 0 then
		print("Humanoid not found, or not alive")
		return
	end

	Tool.Enabled = false
	local targetPos = targetOverride or MyMouse.Hit.p

	Fire(targetPos)
	if PelletCopy then PelletCopy.Transparency = 1 end
	-- swap meshes here
	--[[
	for i = 0, 0.2, 0.05 do
		SlingShotMesh.Scale = Vector3.new(0.5, 0.5, 0.5 + i * 8)
		wait(0.05)
	end
	SlingShotMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
	--]]
	wait(0.2)
	if PelletCopy then PelletCopy.Transparency = 0 end

	Tool.Enabled = true
end

function OnEquipped(mouse)
	--print('equipped')
	MyMouse = mouse
	Spawn(function()
		wait()
		if Tool:IsDescendantOf(Workspace) then
			local leftArm = Tool.Parent:FindFirstChild("Left Arm")
			if leftArm and not PelletCopy then
				PelletCopy = Pellet:Clone()
				PelletCopy.CanCollide = false
				local pelletWeld = Instance.new("Weld")
				pelletWeld.Part0 = leftArm
				pelletWeld.Part1 = PelletCopy
				pelletWeld.C1 = CFrame.new(-.3,1.3,0)
				PelletCopy.Parent = Tool
				pelletWeld.Parent = PelletCopy
			end
		end
	end)
	--MyMouse.TargetFilter = PelletCopy
	SlingShotMesh = WaitForChild(Handle, 'Mesh')
	SlingshotSounds = {WaitForChild(Handle, 'SlingshotSound1'),
									WaitForChild(Handle, 'SlingshotSound2'),
								  WaitForChild(Handle, 'SlingshotSound3')}
	wait(0.3)
	EquipSound = WaitForChild(Handle, 'Equip')
	EquipSound:Play()
--[[
	for _, id in pairs(SlingShotMeshIds) do
		ContentProvider:Preload(ASSET_PREFIX .. id)
	end
--]]
end

function OnUnequipped()
	if PelletCopy then 
		PelletCopy:Destroy()
		PelletCopy = nil
	end
end

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
