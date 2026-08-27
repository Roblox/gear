-- Made by SolarCrane

-- GRIP: _G.S.Grip = CFrame.Angles(0,math.pi/6,0) + Vector3.new(0,-0.4,0.9)

local RS = game:GetService('ReplicatedStorage')
local PlayersService = game:GetService("Players")
local Debris = game:GetService('Debris')

local Utility = require(RS:WaitForChild('Utility'))
local Signal = require(RS:WaitForChild('Signal'))
local CreateLocalWelder = require(RS:WaitForChild('LocalEquipWeld'))

local CANDY_MESH = "http://www.roblox.com/asset/?id=130899509"
local CANDY_TX = "http://www.roblox.com/asset/?id=130899523"

local COOLDOWN = 0.3
local TIME_BEFORE_RELEASE = 0.08
local LastShot = tick()

local LocalPlayer = PlayersService.LocalPlayer
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local FireSound = Handle:WaitForChild('Fire')

local FireAnimTrack = nil
local ReloadAnimTrack = nil
local IdleAnimTrack = nil

local RequestShootServer = Tool:WaitForChild('RequestShootServer')


-- Code from http://www.miguelcasillas.com/?p=53
local function RayDistanceFromSphereSurface(tRay, sphereCenter, radius)
    -- Create a vector from the ray's start to the sphere's center
    local vecV1 = sphereCenter - tRay.Origin

    -- Project this vector onto the ray's direction vector
    local fD = vecV1:Dot(tRay.Direction.unit)

    -- If the ray is pointing away
    if fD < 0 then
        return math.huge, math.rad(360)
	end

    -- Calculate the closest point to the sphere on the ray
    local vecClosestPoint = tRay.Origin + (tRay.Direction.unit * fD)

	local distanceToSphereSurface = math.max(0, ((sphereCenter - vecClosestPoint).magnitude - radius))

	local angle = math.acos((vecClosestPoint - tRay.Origin).unit:Dot(tRay.Direction.unit))
	if angle == nil then
		angle = math.rad(360) 
	end
	--print("fD" , fD , "vecV1" , vecV1, "vecClosestPoint" , vecClosestPoint,  "distanceToSphereSurface", distanceToSphereSurface, "angle", angle)
    return distanceToSphereSurface, angle
end


local function FindMonsterAlongRay(ray)
	local monstersByDistance = {}
	local monsterContainer = workspace:FindFirstChild("MonsterContainer")
	--local monsterContainer = workspace:FindFirstChild("TestDummies")
	if monsterContainer then
		for _, monster in pairs(monsterContainer:GetChildren()) do
			if monster:IsA('Model') then
				local monsterCFrame = monster:GetModelCFrame()
				local monsterSize = monster:GetExtentsSize()
				local distance, theta = RayDistanceFromSphereSurface(ray, monsterCFrame.p, math.min(math.min(monsterSize.X, monsterSize.Y), monsterSize.Z)) --monsterSize.magnitude)
				table.insert(monstersByDistance, {Monster = monster; Distance = distance; Theta = theta})
			end
		end
	end
	-- TODO: also sort by distance from player in this heuristic
	table.sort(monstersByDistance, function(a,b) return a['Distance'] < b['Distance'] end)
	return monstersByDistance
end

local function GetShootOrigin()
	if Handle then
		return Handle.CFrame.p + Handle.CFrame.lookVector
	end
end


local debounce = false
local function OnShoot()
	local now = tick()
	if now - LastShot < COOLDOWN then
		return
	end
	if debounce then return end
	debounce = true
	local humanoid = Utility.GetHumanoid(LocalPlayer)
	if humanoid and Utility.CanFire(LocalPlayer) then
		local targetPos = humanoid.TargetPoint		
		local shootOrigin = GetShootOrigin(targetPos)
		local shootDirection = targetPos - shootOrigin
		if targetPos and shootOrigin and shootDirection then
			local shootRay = Ray.new(shootOrigin, shootDirection)
	
			local monsters = FindMonsterAlongRay(shootRay)
			local desiredShootTarget = monsters and monsters[1] and monsters[1]['Monster']
			local desiredShootTargetPos = desiredShootTarget and desiredShootTarget:GetModelCFrame().p
			
			spawn(function()
				FireAnimTrack:Play(.1,1,4)
				FireSound.Pitch = 0.5 + math.random()/5
				FireSound:Play()
			end)
			-- Send shoot data
			spawn(function()
				local projectile = RequestShootServer:InvokeServer(shootRay, tick() + (_G.ClientTimeDiff or 0), desiredShootTarget, desiredShootTargetPos)
				-- Server will only return a projectile if the shot was successfully completed.
				if projectile then
					local character = LocalPlayer.Character
					
					local touchConn = projectile.Touched:connect(function(other)
						if character and other then
							if other.CanCollide == true and not other:IsDescendantOf(character) then
								projectile.CanCollide = true
							end
						end
					end)
					
					-- this way the projectile doesn't hit our character; unfortunately it means it doesn't hit a lot of things.
					delay(0.1, function() touchConn:disconnect() end)	
				end
			end)
			LastShot = now
		end
	end
	debounce = false
end

local MouseDown = false
local CurrentLoop = nil
local function OnMouseDown()
	MouseDown = true
	local thisLoop = nil
	thisLoop = coroutine.create(function()
		-- Stop two loops from happening at the same time
		while MouseDown and thisLoop == CurrentLoop do
			OnShoot()
			wait(COOLDOWN)
		end
	end)
	CurrentLoop = thisLoop
	coroutine.resume(CurrentLoop)
end

local function OnMouseUp()
	MouseDown = false
end

local MouseDownConn = nil
local MouseUpConn = nil
local function DisconnectMouseEvents()
	if MouseDownConn then
		MouseDownConn:disconnect()
		MouseDownConn = nil
	end
	if MouseUpConn then
		MouseUpConn:disconnect()
		MouseUpConn = nil
	end
end


local Equipped = false
local function OnEquip(mouse)
	Equipped = true
	
	DisconnectMouseEvents()
	MouseDownConn = mouse.Button1Down:connect(OnMouseDown)
	MouseUpConn = mouse.Button1Up:connect(OnMouseUp)
	
	local humanoid = Utility.GetHumanoid(LocalPlayer)
	if humanoid then
		local FireAnim = Tool:FindFirstChild('Fire')
		local ReloadAnim = Tool:FindFirstChild('Reload')		
		local IdleAnim = Tool:FindFirstChild('Idle')
				
		FireAnimTrack = FireAnim and humanoid:LoadAnimation(FireAnim)
		ReloadAnimTrack = ReloadAnim and humanoid:LoadAnimation(ReloadAnim)
		IdleAnimTrack = IdleAnim and humanoid:LoadAnimation(IdleAnim)
	end
	if IdleAnimTrack then
		IdleAnimTrack:Play()
	end
end

local function OnUnequip()
	Equipped = false
	if FireAnimTrack then
		FireAnimTrack:Stop()
	end
	if ReloadAnimTrack then
		ReloadAnimTrack:Stop()
	end
	if IdleAnimTrack then
		IdleAnimTrack:Stop()
	end
	DisconnectMouseEvents()
end

local function OnActivated()
	if Equipped then
		OnShoot()
	end
end

CreateLocalWelder(Tool)

Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
Tool.Activated:connect(OnActivated)
