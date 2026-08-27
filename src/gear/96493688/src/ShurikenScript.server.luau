-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end


local NUM_OF_PROJECTILES = 8
local CIRCLE_RADIUS = 7

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')
local SampleProjectile = Handle:Clone()
SampleProjectile.CanCollide = false
SampleProjectile.Transparency = 0
local Projectiles = {}


local vChar = Tool.Parent
local torso = nil
local RightShoulder = nil
local RightArm = nil
local Shooting = false
local debris = game:GetService("Debris")


Tool.Enabled = true
function fire(dPos, missile)

	local vCharacter = Tool.Parent
	if vCharacter == nil then return end
	local vHum = vCharacter:FindFirstChild("Humanoid")
	if vHum == nil then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	

	if missile:FindFirstChild('BodyPosition') then
		missile.BodyPosition.position = missile.BodyPosition.position + Vector3.new(0, 8, 0)
	end
	wait(1.5)
	if missile:FindFirstChild('BodyPosition') then
		missile.BodyPosition:Destroy()
	end
	
	--local missile = Tool.Handle:Clone()
	missile.Transparency = 0
	
	--missile.CFrame = CFrame.new(spawnPos, spawnPos + dPos) * CFrame.Angles(math.pi/2, 0, 0)

	missile.Velocity = dPos * 58
	missile.RotVelocity = Vector3.new(0, 0, 0)
	missile.Name = "LeafShuriken"
	missile.CanCollide = true

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, missile:GetMass()*196.1,0)
	force.Parent = missile

	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = vPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = missile
	
	local newScript = Tool.ProjectileScript:clone()
	newScript.Disabled = false
	newScript.Parent = missile

	missile.Parent = game.Workspace

	debris:AddItem(missile, 3.5)
end

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		Tool.Enabled = true
		return 
	end
	local reload = 3.25
	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.PrimaryPart.Position).unit

	confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
	if confettiBang ~= nil then 
		confettiBang.Volume = 0.6
		confettiBang:Play() 
	end

	--[[
	for i = 1, NUM_OF_PROJECTILES do
		xNoise = (math.random()-.5)*.1
		yNoise = (math.random()-.5)*.1
		zNoise = (math.random()-.5)*.1
		fire(CFrame.Angles(xNoise, yNoise, zNoise) * lookAt)

		RightShoulder.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = 1.9 -- 3.14
		wait(0.1)
	end 
	--]]
	Shooting = true
	local ProjectilesCopy = {}
	for projectile, _ in pairs(Projectiles) do
		table.insert(ProjectilesCopy, projectile)
		Projectiles[projectile] = nil
	end
	table.sort(ProjectilesCopy, function(a, b) return (a.Position - targetPos).magnitude < (b.Position - targetPos).magnitude end)
	for _, projectile in pairs(ProjectilesCopy) do
		projectile.Parent = Workspace
		coroutine.wrap(fire)(lookAt, projectile)
		RightShoulder.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = 2.5
		wait(0.2)
	end
	wait(reload)
	Shooting = false
	Reload()
	confettiBang = Tool.Handle:FindFirstChild("ThrowSound")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	Tool.Enabled = true
end

function PointOnCircle(originX, originZ, radius, theta)
	local X = originX + radius * math.cos(theta)
	local Z = originZ + radius * math.sin(theta)
	return X, Z
end

function Reload()
	for projectile, _ in pairs(Projectiles) do
		projectile:Destroy()
	end
	Projectiles = {}
	for i = 1, NUM_OF_PROJECTILES do
		local projectile = SampleProjectile:Clone()
		local X, Z = PointOnCircle(torso.Position.X, torso.Position.Z, CIRCLE_RADIUS + math.random() * 2, (2 * math.pi) * (i / NUM_OF_PROJECTILES))
		projectile.CFrame = CFrame.new(Vector3.new(X, torso.Position.Y, Z))
		projectile.RotVelocity = Vector3.new(math.random(), math.random(), math.random())
		local bp = Instance.new('BodyPosition')
		bp.maxForce = Vector3.new(120, 10000, 120)
		bp.position = projectile.CFrame.p
		bp.Parent = projectile
		projectile.Parent = Tool
		Projectiles[projectile] = i
		--table.insert(Projectiles, projectile)
	end
end

function AreAllProjectilesClose()
	local result = true
	for projectile, index in pairs(Projectiles) do
		if projectile:FindFirstChild('BodyPosition') then
			if not projectile.BodyPosition.position:isClose(projectile.Position, 1) then
				result = false
			end
		else
			--result = false
		end
	end
	return result
end

local Spinning = false

function SpinProjectiles()
	if Spinning then return end
	Spinning = true
	while true do
		if Tool.Enabled and AreAllProjectilesClose() then
			for projectile, index in pairs(Projectiles) do
				if projectile:FindFirstChild('BodyPosition') then
					local X, Z = PointOnCircle(torso.Position.X, torso.Position.Z, CIRCLE_RADIUS + math.random() * 5, (2 * math.pi) * (index / NUM_OF_PROJECTILES))
					projectile.BodyPosition.position = Vector3.new(X, torso.CFrame.p.Y, Z)
					Projectiles[projectile] = Projectiles[projectile] + 1
				end
			end
		end
		wait(0.05)
	end
	Spinning = false
end

local Equiping = false

function onEquipped()
	if Equiping then return end
	Equiping = true
	vChar = Tool.Parent
	torso = nil
	RightShoulder = nil
	RightArm = nil
	Handle.Transparency = 1
	while vChar == nil or vChar.Name == "BackPack" or torso == nil or RightShoulder == nil or RightArm == nil do
		vChar = Tool.Parent
		if vChar ~= nil and vChar.Name ~= "BackPack" then
			torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
			if torso ~= nil then
				RightArm = vChar:FindFirstChild("Right Arm") or vChar:FindFirstChild("RightUpperArm")
				RightShoulder = torso:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")
			end
		end
		wait(1)
	end
	Reload()
	Spawn(SpinProjectiles)
	Equiping = false
end
local UnEquipping = false
function onUnequipped()
	if UnEquipping then return end
	UnEquipping = true
	for projectile, _ in pairs(Projectiles) do
		projectile:Destroy()
	end
	Projectiles = {}
	Handle.Transparency = 0
	UnEquipping = false
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
