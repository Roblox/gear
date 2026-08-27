-- Made by SolarCrane

local RS = game:GetService('ReplicatedStorage')
local PlayersService = game:GetService("Players")
local Debris = game:GetService('Debris')
local ServerScriptService = game:GetService('ServerScriptService')

local Utility = require(RS:WaitForChild('Utility'))
local Signal = require(RS:WaitForChild('Signal'))
local Pathfinding = require(ServerScriptService.Pathfinding)
local MonsterManager = require(ServerScriptService.MonsterManager)

local TrollManager = require(ServerScriptService.TrollManager)

local DEBRIS_TIME = 6
local COOLDOWN = 60.0 * 5
local MAX_SPAWN_DISTANCE = 150

local LastShot = 0
local Equipped = false
local MyPlayer = nil
local Character = nil
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Boom = script:WaitForChild('Boom')
local RequestShootServer = Tool:WaitForChild('RequestShootServer')
local TimeLeftUntilSummon = Tool:WaitForChild('TimeLeftUntilSummon')

local EXIT_CODES =
{
	SUCCESS = "SUCCESS";
	BAD_LOC = "Invalid Spawn Location";
	COOLDOWN = "On Cooldown";
	INVALID_ARG = "Invalid Arguements";
	ERROR = "Error";
}

-- Pure functional
local function DoSpawnEffects(point)
	local pillar = Utility.Create'Part'
	{
		Name = 'SpawnPillar';
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		CanCollide = false;
		Anchored = true;
	}
	pillar.FormFactor = 'Custom'	
	pillar.Size = Vector3.new(1, 50, 1)
	pillar.CFrame = CFrame.new(point + Vector3.new(0,25,0));

	delay(0.1, function()
		local boomClone = Boom:Clone()
		boomClone.Parent = pillar
		boomClone:Play()
	end)
	
	local mesh = Utility.Create'CylinderMesh'{
			Scale = Vector3.new(1,1,1);
			Parent = pillar;
		};
	
	Utility.PropertyTweener(mesh, "Scale", Vector3.new(0.1,1,0.1), Vector3.new(18,1,18), 0.3, Utility.EaseInOutQuad, function()
		wait(3)
		if mesh then
			Utility.PropertyTweener(mesh, "Scale", mesh.Scale, Vector3.new(0,1,0), 0.3, Utility.EaseOutQuad)
		end
	end)
	spawn(function()
		for i = 1, 10 do
			if pillar then
				-- flicker it on and off
				pillar.Transparency = i % 2
			end
			wait(0.3/10)
		end
		if pillar then
			pillar.Transparency = 0
		end
	end)
	
	local numProjectiles = 10
	for i = 1, numProjectiles do
		local shootOffDirection = (CFrame.Angles(0, i * ((2*math.pi)/10), 0) * Vector3.new(0,0,1)).unit + Vector3.new(0,1,0)
			local projectile = Utility.Create'Part'
			{
				Name = 'Effect';
				TopSurface = 'Smooth';
				BottomSurface = 'Smooth';
				CanCollide = false;
			}
			projectile.CFrame = CFrame.new(point) + shootOffDirection.unit
			projectile.FormFactor = 'Custom'	
			projectile.Size = Vector3.new(.2,.2,.2)
			projectile.Velocity = shootOffDirection.unit * 80
			-- Add fire
			local fire = Instance.new('Fire', projectile)
			fire.Heat = 20
			fire.Size = 20
			Debris:AddItem(projectile, 3)
			projectile.Parent = workspace
			local touchConn = nil
			touchConn = projectile.Touched:connect(function(other)
				if other.CanCollide == true then
					touchConn:disconnect()
					local explosion = Utility.Create'Explosion'
					{
						BlastPressure = 0;
						BlastRadius = 10;
						Position = projectile.CFrame.p;
						Parent = workspace;
					}
				end
			end)
	end
	
	Debris:AddItem(pillar, 5)
	pillar.Parent = workspace

	return pillar
end

local function OnShoot(player, desiredSpawnPoint, localTime)
	-- Someone else is trying to call shoot on my weapon; GET DENIED
	if player ~= MyPlayer then
		return EXIT_CODES.INVALID_ARG
	end
	if not desiredSpawnPoint then
		return EXIT_CODES.INVALID_ARG
	end
	
	local oldActivation = TrollManager:GetLastActivation(player)	
	local now = tick()	
	TrollManager:SetLastActivation(player, now)
	if now - oldActivation < COOLDOWN then
		TrollManager:SetLastActivation(player, oldActivation)
		return EXIT_CODES.COOLDOWN
	end
	if Equipped and Handle and Utility.CanFire(MyPlayer) then
		local character = MyPlayer.Character
		if MyPlayer:DistanceFromCharacter(desiredSpawnPoint) > MAX_SPAWN_DISTANCE then
			TrollManager:SetLastActivation(player, oldActivation)
			return EXIT_CODES.BAD_LOC
		end
		
		local characterCframe = character and character:GetModelCFrame()
		local foundPath = characterCframe and Pathfinding:GetPath(desiredSpawnPoint, characterCframe.p)
		-- Check if it is a legit spawning locations
		if characterCframe and foundPath then
			if foundPath then
				DoSpawnEffects(desiredSpawnPoint)
				-- Spawn the troll
				local spawnSuccess = MonsterManager:SpawnTroll(desiredSpawnPoint + Vector3.new(0,4,0))
				if spawnSuccess then
					return EXIT_CODES.SUCCESS
				else
					TrollManager:SetLastActivation(player, oldActivation)
					return EXIT_CODES.ERROR
				end
			end
		else
			TrollManager:SetLastActivation(player, oldActivation)
			return EXIT_CODES.BAD_LOC
		end
	end
	TrollManager:SetLastActivation(player, oldActivation)
	return EXIT_CODES.ERROR
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
TimeLeftUntilSummon.OnServerInvoke = function(player)
	return COOLDOWN - (tick() - TrollManager:GetLastActivation(player))
end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

