-----------------
--| Constants |--
-----------------

local FORCE_GRANULARITY = 2
local RADIUS_FACTOR = 0.75

local BLAST_RADIUS = 13
local BLAST_PRESSURE = 1000000 * FORCE_GRANULARITY

-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')
local ServerScriptService = game:GetService('ServerScriptService')

local TimeBomb = script.Parent

local BombMesh = TimeBomb:WaitForChild('Mesh')

local BoomSound = TimeBomb:WaitForChild('Boom')
local BeepSound = TimeBomb:WaitForChild('Beep')

local CreatorTag = TimeBomb:WaitForChild('creator')


local MonsterContainer = workspace:WaitForChild("MonsterContainer")
local MonsterManager = require(ServerScriptService.MonsterManager)

local Connection = nil
local XGraceDistance = 2.5
local YGraceDistance = 2.5

local doBlastBack = false

-----------------
--| Functions |--
-----------------


-- Returns the ancestor that contains a Humanoid, if it exists
local function FindCharacterAncestor(subject)
	if subject and subject ~= workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end


local function cl0(n)
	return (n > 0) and n or 0
end
local abs = math.abs
local function RealDistanceFrom(point, part)
	local p = part.CFrame:vectorToObjectSpace(point-part.Position)
	local hz = part.Size/2
	local sep = Vector3.new(cl0(abs(p.x)-hz.x), cl0(abs(p.y)-hz.y), cl0(abs(p.z)-hz.z))
	return sep.magnitude
end


local function TryDoDamage(humanoid, damage)
	local hitBindable = humanoid:FindFirstChild('Hit')
	local wasAlive = humanoid.Health > 0
	if hitBindable then
		hitBindable:Invoke(damage, CreatorTag)
	else
		humanoid:TakeDamage(damage)
		MonsterManager:TagPlayerCollection(CreatorTag.Value, humanoid)
	end
end


-- Needless to say, this should only be called once
local Exploded = false
local function Explode()
	if Exploded then
		return
	end
	Exploded = true
	if Connection then
		Connection:disconnect()
	end
	local damagedMonsterSet = {}
	local function onExplosionHit(p, r)
		local isInCharacter = false
		if p.Size.magnitude/2 < 20 then
			--world->ticklePrimitive(p, true);
			
			local doBreakjoints = false
			local hitCharacter, hitHumanoid = FindCharacterAncestor(p)
			if hitCharacter then
				-- flag as character
				isInCharacter = true				
				
				-- don't breakjoints characters
				doBreakjoints = false
				
				-- work out what damage to do					
				local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
				local hitMonster = MonsterContainer and hitCharacter:IsDescendantOf(MonsterContainer) and hitCharacter
				local myPlayer = CreatorTag.Value
				if hitMonster and not damagedMonsterSet[hitMonster] then									
					-- how much damage to do
					local damageFrac;
					if r < BLAST_RADIUS/2 then
						damageFrac = 1
					elseif r < BLAST_RADIUS then
						damageFrac = 1 - (r - BLAST_RADIUS/2)/(BLAST_RADIUS/2)
					else
						damageFrac = 0
					end
					
					-- flag as hit
					damagedMonsterSet[hitMonster] = true
					
					-- do damage. See how much damage to do						
					TryDoDamage(hitHumanoid, 30 + 70*damageFrac)
					--print("Doing damage to:" , hitMonster , "of damage:" , 30 + 70*damageFrac)
				end
			end		
			
			-- breakjoints stuff
			if doBreakjoints then
				-- Don't breakjoints stuff too far away to reduce lag
				if RealDistanceFrom(TimeBomb.Position, p) > BLAST_RADIUS*RADIUS_FACTOR then
					return
				end
				p:BreakJoints()
			end
			if doBlastBack then
				--Vector3 delta = (p->getCoordinateFrame().translation - position);
				local delta = p.Position - TimeBomb.Position
				
				--Vector3 normal = 
				--	(delta == Vector3::zero())
				--	? Vector3::unitY()
				--	: delta.direction();
				local normal = (delta == Vector3.new(0,0,0))
				               and Vector3.new(0,1,0)
				               or  delta.unit
				
				--float radius = p->getRadius();
				local radius = p.Size.magnitude / 2				
				
				--float surfaceArea = radius * radius;
				local surfaceArea = radius * radius
				
				--Vector3 impulse = normal * blastPressure * surfaceArea * (1.0f / 4560.0f); // normalizing factor
				local impulse = normal * BLAST_PRESSURE * surfaceArea * (1.0 / 4560.0)
				
				-- How much force to apply (for characters, ramp it down towards the edge)
				local frac;
				if isInCharacter then
					frac = 1 - math.max(0, math.min(1, (r-2)/BLAST_RADIUS))
				else
					frac = 1
				end					
				
				--p->getBody()->accumulateLinearImpulse(impulse, p->getCoordinateFrame().translation);
				local currentVelocity = p.Velocity
				local deltaVelocity = impulse / p:GetMass() -- m * del-v = F * del-t = Impulse
				local bodyV = Instance.new('BodyVelocity', p)
				bodyV.velocity = currentVelocity + deltaVelocity
				local forceNeeded = 196.2 * p:GetMass() -- F = ma
				bodyV.maxForce = Vector3.new(forceNeeded, forceNeeded, forceNeeded) * 10 * frac
				game.Debris:AddItem(bodyV, 0.2/FORCE_GRANULARITY)
				
				--p->getBody()->accumulateRotationalImpulse(impulse * 0.5 * radius); // a somewhat arbitrary, but nice torque
				local rotImpulse = impulse * 0.5 * radius
				local currentRotVelocity = p.RotVelocity
				local momentOfInertia = (2 * p:GetMass() * radius * radius / 5) -- moment of inertia = 2/5*m*r^2 (assuming roughly spherical)
				local deltaRotVelocity = rotImpulse / momentOfInertia 
				local rot = Instance.new('BodyAngularVelocity', p)
				local torqueNeeded = 20 * momentOfInertia -- torque = r x F, want about alpha = 20 rad/s^2, alpha * P = torque
				rot.maxTorque = Vector3.new(torqueNeeded, torqueNeeded, torqueNeeded) * 10 * frac
				rot.angularvelocity = currentRotVelocity + deltaRotVelocity
				game.Debris:AddItem(rot, 0.2/FORCE_GRANULARITY)
			end
		end
	end	

	local explosion = Instance.new('Explosion')
	explosion.BlastRadius = BLAST_RADIUS
	explosion.BlastPressure = 0
	explosion.Position = TimeBomb.Position
	explosion.Hit:connect(onExplosionHit)
	explosion.Parent = workspace

	BoomSound:Play()

	-- NOTE:
	-- If we just destroyed the bomb at this point, the boom sound would be destroyed too,
	-- so instead we will hide the bomb, keep it in the same spot, and schedule it for deletion

	TimeBomb.Transparency = 1
	TimeBomb.CanCollide = false
	TimeBomb.Anchored = true
	DebrisService:AddItem(TimeBomb, 3)
end

--------------------
--| Script Logic |--
--------------------

--Distance check to see if can collide should be true
--[[
spawn(function()
	while not TimeBomb.CanCollide and ParentTorso.Value do
		local TorsoPosition = ParentTorso.Value.CFrame.p
		local XZOffset = TorsoPosition-Vector3.new(TimeBomb.CFrame.p.x,TorsoPosition.y,TimeBomb.CFrame.p.z)
		if XZOffset.magnitude>XGraceDistance or math.abs(TorsoPosition.y-TimeBomb.CFrame.p.y)>YGraceDistance then
			TimeBomb.CanCollide=true
		end
		wait(1/30)
	end
end)
--]]

local Character = CreatorTag and CreatorTag.Value and CreatorTag.Value.Character

local touchConn = TimeBomb.Touched:connect(function(other)
	if Character and other and TimeBomb then
		if other.CanCollide == true and not other:IsDescendantOf(Character) then
			TimeBomb.CanCollide = true
		end
	end
end)
delay(0.2, function()
	if TimeBomb then TimeBomb.CanCollide = true end 
	if touchConn then touchConn:disconnect() end
end)

Connection = TimeBomb.Touched:connect(function(other)
	local hitCharacter, hitHumanoid = FindCharacterAncestor(other)
	if hitCharacter and hitCharacter ~= CreatorTag.Value.Character then
		print("HitCharacter")
		local hitMonster = MonsterContainer and hitCharacter:IsDescendantOf(MonsterContainer)
		if hitMonster then
			print("HitMonster")
			Explode()
		end
	end
end)

-- Flash red and beep increasingly fast for about 3 seconds
local tickTime = 0.4
local red = true
repeat
	BombMesh.VertexColor = red and Vector3.new(1,0,0) or Vector3.new(1, 1, 1)
	BeepSound:Play()
	wait(tickTime)
	red = not red
	tickTime = tickTime * 0.9
until tickTime < 0.1 or Exploded

Explode()
