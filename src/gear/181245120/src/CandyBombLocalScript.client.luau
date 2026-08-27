-- Made by SolarCrane

local RS = game:GetService('ReplicatedStorage')
local PlayersService = game:GetService("Players")

local Utility = require(RS:WaitForChild('Utility'))
local Signal = require(RS:WaitForChild('Signal'))
local CreateLocalWelder = require(RS:WaitForChild('LocalEquipWeld'))



local LocalPlayer = PlayersService.LocalPlayer
local Character = nil
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')

local RequestShootServer = Tool:WaitForChild('RequestShootServer')

local COOLDOWN = 4 -- Seconds until tool can be used again
local TIME_BEFORE_RELEASE = 0.3

local ThrowAnimTrack = nil
local HoldAnimTrack = nil
local LastShot = 0
local Equipped = false

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
	return Handle.CFrame.p
end

local function OnMouseDownChanged(down)
	--wait(0) --TODO: Remove when Mouse.Hit and Humanoid.TargetPoint update properly on iPad
	local now = tick()
	if now - LastShot < COOLDOWN then
		return
	end
	if Equipped and Handle and Utility.CanFire(LocalPlayer) then
		if down then -- Player just clicked
			if HoldAnimTrack then
				HoldAnimTrack:Play(.1,1,1)
			end
		else -- Player just released click
			local humanoid = Utility.GetHumanoid(LocalPlayer)
			local targetPos = humanoid and humanoid.TargetPoint
			local shootOrigin = targetPos and GetShootOrigin(targetPos)
			local shootDirection = targetPos and shootOrigin and (targetPos - shootOrigin)
			
			if targetPos and shootOrigin and shootDirection then
				local shootRay = Ray.new(shootOrigin, shootDirection)
		
				local monsters = FindMonsterAlongRay(shootRay)
				local desiredShootTarget = monsters and monsters[1] and monsters[1]['Monster']
				local desiredShootTargetPos = desiredShootTarget and desiredShootTarget:GetModelCFrame().p
				
				if HoldAnimTrack then
					HoldAnimTrack:Stop()
				end
				if ThrowAnimTrack then
					ThrowAnimTrack:Play(0.1,1,0.75)
				end
				
				spawn(function()
					local projectile = RequestShootServer:InvokeServer(shootRay, tick() + (_G.ClientTimeDiff or 0), desiredShootTarget, desiredShootTargetPos)
				end)
			end
			LastShot = now
			Tool.Enabled = false
			delay(COOLDOWN - (tick() - LastShot), function()
				Tool.Enabled = true
			end)
		end
	end
end

local mouseButton1DownConn = nil
local mouseButton1UpConn = nil

local function DisconnectMouseEvents()
	if mouseButton1DownConn then
		mouseButton1DownConn:disconnect()
	end
	if mouseButton1UpConn then
		mouseButton1UpConn:disconnect()
	end
end

local function OnEquipped(mouse)
	Equipped = true
	local Character = LocalPlayer and LocalPlayer.Character
	DisconnectMouseEvents()
	mouseButton1DownConn = mouse.Button1Down:connect(function() OnMouseDownChanged(true) end)
	mouseButton1UpConn = mouse.Button1Up:connect(function() OnMouseDownChanged(false) end)
	local humanoid = Utility.GetHumanoid(LocalPlayer)
	if humanoid then
		local ThrowAnim = Tool:FindFirstChild('Throw')
		local HoldAnim = Tool:FindFirstChild('Hold')		
		
		ThrowAnimTrack = ThrowAnim and humanoid:LoadAnimation(ThrowAnim)
		HoldAnimTrack = HoldAnim and humanoid:LoadAnimation(HoldAnim)
	end
end

local function OnUnequipped()
	Equipped = false
	OnMouseDownChanged(false)
	DisconnectMouseEvents()
	if HoldAnimTrack then
		HoldAnimTrack:Stop()
	end
	if ThrowAnimTrack then
		ThrowAnimTrack:Stop()
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

CreateLocalWelder(Tool)

print"LocalBombLoaded"
