-- Made by SolarCrane

local RS = game:GetService('ReplicatedStorage')
local PlayersService = game:GetService("Players")
local Debris = game:GetService('Debris')

local Utility = require(RS:WaitForChild('Utility'))
local Signal = require(RS:WaitForChild('Signal'))

local SHOOT_VELOCITY = 80
local DEBRIS_TIME = 6
local COOLDOWN = 4 -- Seconds until tool can be used again
local TIME_BEFORE_RELEASE = 0.2

local LastShot = 0
local Equipped = false
local MyPlayer = nil
local Character = nil
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')

local BeepSound = Handle:WaitForChild('Beep')
local BoomSound = Handle:WaitForChild('Boom')

local ThrowAnimTrack = nil
local HoldAnimTrack = nil

local BOMB_MESHID = 'http://www.roblox.com/asset?id=179628795'
local BOMB_TXID = 'http://www.roblox.com/asset?id=179628830'

local BombPrefabScript = script:WaitForChild('CandyBombExplosionScript')

local RequestShootServer = Tool:WaitForChild('RequestShootServer')

-- Pure functional
local function MakeBaseBomb(myPlayer, bombMesh, bombTexture)
	local bomb = Utility.Create'Part'
	{
		Name = 'Bomb';
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		CanCollide = false;
		RotVelocity = Vector3.new(Utility.Random(-math.pi,math.pi),
		                          Utility.Random(-math.pi,math.pi),
		                          Utility.Random(-math.pi,math.pi)) * 2;
		Utility.Create'SpecialMesh'{
			MeshId = bombMesh;
			TextureId = bombTexture;
			Scale = Vector3.new(1,1,1);
		};
	}
	bomb.Shape = Enum.PartType.Ball
	bomb.FormFactor = 'Custom'	
	bomb.Size = Vector3.new(1.5, 1.5, 1.5)
	Utility.Create'BodyForce'
	{
		Name = "FloatForce";
		force = Vector3.new(0, bomb:GetMass() * 196.2 * 0.25, 0);
		Parent = bomb;
	}

	-- Attach creator tags to the bomb early on
	local creatorTag = Instance.new('ObjectValue', bomb)
	creatorTag.Name = 'creator'
	creatorTag.Value = myPlayer

	return bomb
end

local function GetShootOrigin()
	return Handle.CFrame.p
end


local function OnShoot(player, desiredShootRay, localTime, desiredTarget, desiredTargetPosition)
	-- Someone else is trying to call shoot on my weapon; GET DENIED
	if player ~= MyPlayer then return end
	
	local now = tick()
	if now - LastShot < COOLDOWN then
		return
	end
	local timeDiff = (tick() - localTime)
	local timeToWait = Utility.Clamp(0, TIME_BEFORE_RELEASE, TIME_BEFORE_RELEASE - timeDiff)
	wait(timeToWait) -- wait for before release, syncing up to our round-trip-time to make it looks smooth back on the local client.
	if Equipped and Handle and Utility.CanFire(MyPlayer) then
		-- TODO: Add handle velocity to the velocity?
		local adjustedShootVector = desiredShootRay.Direction
		local shootOrigin = GetShootOrigin()
		if shootOrigin then
			if desiredTarget and desiredTargetPosition then
				local deltaOffset = desiredTarget:GetModelCFrame().p - desiredTargetPosition
				adjustedShootVector = adjustedShootVector.unit * (desiredTargetPosition - shootOrigin).magnitude
				adjustedShootVector = adjustedShootVector + deltaOffset
				if adjustedShootVector.magnitude == 0 then
					adjustedShootVector = Vector3.new(0, 1, 0)
				end
			end
			local projectile = MakeBaseBomb(MyPlayer, BOMB_MESHID, BOMB_TXID)
			projectile.CFrame = CFrame.new(shootOrigin)
			projectile.Velocity = adjustedShootVector.unit * SHOOT_VELOCITY

			projectile.CanCollide = false
			-- this way the projectile doesn't hit our character; unfortunately it means it doesn't hit a lot of things.
			local touchConn = projectile.Touched:connect(function(other)
				if Character and other then
					if other.CanCollide == true and not other:IsDescendantOf(Character) then
						projectile.CanCollide = true
					end
				end
			end)
			delay(0.2, function() projectile.CanCollide = true touchConn:disconnect() end)
			
			Debris:AddItem(projectile, DEBRIS_TIME)
			projectile.Parent = workspace
			
			BeepSound:Clone().Parent = projectile
			BoomSound:Clone().Parent = projectile	
			
			local bombScript = BombPrefabScript:Clone()
			bombScript.Parent = projectile
			bombScript.Disabled = false
			
			LastShot = now
			return projectile
		end
	end
end

local function OnEquipped()
	Equipped = true
	Character = Tool.Parent
	if Character then
		MyPlayer = PlayersService:GetPlayerFromCharacter(Character)
	end
end

local function OnUnequipped()
	Equipped = false
end

--------------------
--| Script Logic |--
--------------------

RequestShootServer.OnServerInvoke = OnShoot

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

print"ServeBombLoaded"
