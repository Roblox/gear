-- Made by SolarCrane

local Tool = script.Parent
local Handle = nil

local RS = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')
local Utility = require(RS:WaitForChild('Utility'))
local PlayersService = game:GetService("Players")
local MyPlayer = nil

local Character = nil

local SHOOT_VELOCITY = 150
local DEBRIS_TIME = 1.2
local COOLDOWN = 0.3
local TIME_BEFORE_RELEASE = 0.08

local NextCandyIndex = 1

local LastShot = tick()

local CANDY_MESHES =
{
	--179536104; --BloxyDrops
	--179536148; -- Bloxroll
	179536189; --BlueDark
	179536223; --BlueLight
	179536243; --Green
	179536282; --Orange
	179536309; --Pink
	179536326; -- Purple
	179536343; --Red
	179536364; --Yellow
	--179536390; --Chocoblox
	--179536422; --MrBloxBar
}
local CANDY_TX = "http://www.roblox.com/asset/?id=179535876"

local BP_MESH = "http://www.roblox.com/asset/?id=179522694"
local BP_TX = "http://www.roblox.com/asset/?id=179522826"

local RequestShootServer = Tool:WaitForChild('RequestShootServer')
local CandyPrefabScript = script:WaitForChild('CandyProjectileScript')

local Backpack = nil

local Equipped = false

local function CreateProjectile()
	local projectile = Utility.Create'Part'
	{
		Name = 'Projectile';
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		RotVelocity = Vector3.new(Utility.Random(-math.pi,math.pi),Utility.Random(-math.pi,math.pi),Utility.Random(-math.pi,math.pi)) * 8;
		Utility.Create'SpecialMesh'{
			MeshId = "http://www.roblox.com/asset/?id=" .. tostring(CANDY_MESHES[NextCandyIndex]);
			TextureId = CANDY_TX;
			Scale = Vector3.new(7,7,7);
		}
	}
	projectile.FormFactor = 'Custom'
	projectile.Size = Vector3.new(2,2,2)
	Utility.Create'BodyForce'
	{
		Name = "FloatForce";
		force = Vector3.new(0,projectile:GetMass() * 196.2 * 0.85,0);
		Parent = projectile;
	}
	
	local newCandyScript = CandyPrefabScript:Clone()
	local ownerTag = newCandyScript:WaitForChild('Owner')
	ownerTag.Value = MyPlayer
	newCandyScript.Parent = projectile
	newCandyScript.Disabled = false
	
	return projectile
end

local function GetShootOrigin()
	if Handle then
		return Handle.CFrame.p + Handle.CFrame.lookVector
	end
end

local debounce = false
local function OnShoot(player, desiredShootRay, localTime, desiredTarget, desiredTargetPosition)
	-- Someone else is trying to call shoot on my weapon; GET DENIED
	if player ~= MyPlayer then return end
	
	local now = tick()
	if now - LastShot < COOLDOWN then
		return
	end
	if debounce then return end
	debounce = true
	local timeDiff = (tick() - localTime)
	local timeToWait = Utility.Clamp(0, TIME_BEFORE_RELEASE, TIME_BEFORE_RELEASE - timeDiff)
	--spawn(function() error("Time diff: " .. tick() .. " " .. localTime .. " diff:" .. (tick() - localTime) .. " time to wait " .. timeToWait) end)
	wait(timeToWait) -- wait for before candy release
	if Equipped and Handle and Utility.CanFire(MyPlayer) then
		local adjustedShootVector = desiredShootRay.Direction
		local shootOrigin = GetShootOrigin()
		if desiredTarget and desiredTargetPosition then
			local deltaOffset = desiredTarget:GetModelCFrame().p - desiredTargetPosition
			adjustedShootVector = adjustedShootVector.unit * (desiredTargetPosition - shootOrigin).magnitude
			adjustedShootVector = adjustedShootVector + deltaOffset
			--print("Adjusting shootvector by:" , deltaOffset)
		end
		local projectile = CreateProjectile()
		projectile.CFrame = CFrame.new(shootOrigin)
		projectile.Velocity = adjustedShootVector.unit * SHOOT_VELOCITY
		

		local touchConn = projectile.Touched:connect(function(other)
			if Character and other then
				if other.CanCollide == true and not other:IsDescendantOf(Character) then
					projectile.CanCollide = true
				end
			end
		end)	
		
		-- this way the projectile doesn't hit our character; unfortunately it means it doesn't hit a lot of things.
		projectile.CanCollide = false
		delay(0.1, function() projectile.CanCollide = true touchConn:disconnect() end)
		
		Debris:AddItem(projectile, DEBRIS_TIME)
		projectile.Parent = workspace
		
		NextCandyIndex = math.random(1,#CANDY_MESHES)
		LastShot = now
		debounce = false
		return projectile
	end
	debounce = false
end


local function OnEquip()
	Equipped = true
	Handle = Tool:FindFirstChild('Handle')
	Character = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(Character)
end

local function OnUnequip()
	Equipped = false
	Character = nil
	MyPlayer = nil
end

RequestShootServer.OnServerInvoke = OnShoot

Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
