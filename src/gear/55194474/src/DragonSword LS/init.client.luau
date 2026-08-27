-- Aspects of group damage are copied from / based heavily on the Trident's

math.randomseed(tick())

local Tool = script.Parent
local Sword = Tool.Handle

local TOUCH_DAMAGE = 5
local SLASH_DAMAGE = 10
local STAB_DAMAGE = 5
local FIRE_DAMAGE = 5
local CLOSE_RAGE_DAMAGE = 75
local FAR_RAGE_DAMAGE = 40
local CLOSE_FIRE_PROB = 1.0
local FAR_FIRE_PROB = 0.5
local RAGE_AOE = 10
local damage = TOUCH_DAMAGE

local toDamage = {}

local oldTheta
local oldPhi
local oldPsi
local newTheta
local newPhi
local newPsi
local theta
local phi
local psi

-- Using standard unsheath and slash sounds, from EelSword (or MahjongSword, etc.)
local unsheathSound = Instance.new("Sound")
unsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
unsheathSound.Parent = Sword
unsheathSound.Volume = 0.5
local stabSound = Instance.new("Sound")
stabSound.SoundId = "http://www.roblox.com/asset/?id=45941860"
stabSound.Parent = Tool
stabSound.Volume = 1.0
local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
slashSound.Parent = Sword
slashSound.Volume = 0.7
local shotSound
local chingSound
local ignitionSound

local rageVelocity = Instance.new("BodyVelocity")
rageVelocity.P = 10000
rageVelocity.Name = "DragonSwordRageVelocity"
rageVelocity.maxForce = Vector3.new(10000, 10000, 10000)

local recoilVelocity = rageVelocity:Clone()
recoilVelocity.Name = "DragonSwordRecoilVelocity"

local slashAnim
local stabAnim
local rageAnim

local shootScript

local runServ = game:service("RunService") -- To keep track of time between attacks, so double-clicks work.
local debris = game:service("Debris")
local co45	-- Wait(45) coroutine; ensures that rage can be used only once every 45 seconds

local myCharacter
local myHumanoid
local myPlayer
local RightArm
local RightGrip
local Torso
local initialTorsoPos
local initialTorsoFrame
local otherHum
local distance
local radiusVector

-- We need a transparent part on the sword's tip from which to shoot off fireballs, too.
local Tip
local TipWeld
local TipFire
local Projectile

Tool.Enabled = true

local lastAttackTime = 0

-- Standard tagging and untagging functions for kill-counting purposes
function tagHumanoid(humanoid, player)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if not humanoid then return end
	local creatorTag = humanoid:FindFirstChild("creator")
	if creatorTag then creatorTag:Remove() end
end

-- Typical slash attack
function blow(hit)
	if not hit or not hit.Parent then return end

	myCharacter = Tool.Parent
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myCharacter or not myPlayer then return end

	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	local hitHumanoid = hit.Parent:FindFirstChild("Humanoid")

	if myHumanoid and hitHumanoid and myHumanoid ~= hitHumanoid then
		RightArm = myCharacter:FindFirstChild("Right Arm")
		if not RightArm then return end
		RightGrip = RightArm:FindFirstChild("RightGrip")
		if RightGrip and (RightGrip.Part0 == Sword or RightGrip.Part1 == Sword) then
			tagHumanoid(hitHumanoid, myPlayer)
			hitHumanoid:TakeDamage(damage)
			wait(1)
			untagHumanoid(hitHumanoid, myPlayer)
		end
	end
end 

-- Damage and knockback from dragonRage
function rageDamage(center, radius, attackDamage, fireProb)
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myPlayer then return end

	toDamage = {}

	-- Find all parts in a cube of side length 2*radius about the center of explosion...
	radiusVector = Vector3.new(radius, radius, radius)
	parts = game.Workspace:FindPartsInRegion3(Region3.new(center - radiusVector, center + radiusVector), myCharacter, 150)
	for i = 1, #parts do
		-- First find the humanoids among them.
		local possibleCharacter = parts[i].Parent
		local possibleHumanoid = possibleCharacter:FindFirstChild("Humanoid")
		if possibleHumanoid then
			toDamage[possibleCharacter] = 1
		end
		-- Then send all of them (except the sword user) flying!
		local newVel = rageVelocity:Clone()
		newVel.velocity = (parts[i].Position - center).unit * 50
		newVel.Parent = parts[i]
	end
	-- Now actually do damage.
	for key, val in pairs(toDamage) do
		local otherHumanoid = key:FindFirstChild("Humanoid")
		if otherHumanoid then
			tagHumanoid(otherHumanoid, myPlayer)
			otherHumanoid:TakeDamage(attackDamage)
			if (math.random() < fireProb) then
				local damageScript = key:FindFirstChild("FireDamageScript")
				if damageScript == nil then
					damageScript = script.FireDamageScript:Clone()
					damageScript.Parent = key
					damageScript.Disabled = false
				end
			end
		end
	end
	wait(1.0)
	for i = 1, #parts do
		-- Remove the velocities.
		local vel = parts[i]:FindFirstChild("DragonSwordRageVelocity")
		if vel then vel:Remove() end
	end
	for key, val in pairs(toDamage) do
		local otherHum = key:FindFirstChild("Humanoid")
		if otherHum then untagHumanoid(otherHum, myPlayer) end
	end
end

-- Create the projectile-shooting sword tip.
function instantiateTipAndWeld()
	Tip = Instance.new("Part")
	Tip.Name = "DragonSwordTip"
	Tip.CanCollide = false
	Tip.formFactor = 3	--Custom
	Tip.Shape = 0	--Ball
	Tip.Size = Vector3.new(.5, .5, .5)
	Tip.Locked = true
	Tip.Parent = game.Workspace
	Tip.CFrame = CFrame.new(Vector3.new(-0.15, 0, -1.85))
	Tip.Transparency = 1.0
	Tip.BrickColor = BrickColor.new(106)	-- Bright orange
	Tip.Material = Enum.Material.CorrodedMetal
	
	TipWeld = Instance.new("Weld")
	TipWeld.Name = "DragonSwordTipWeld"
	TipWeld.Part0 = Sword
	TipWeld.Part1 = Tip
	TipWeld.C1 = CFrame.new(Vector3.new(-0.15, 0, -1.85))
	TipWeld.Parent = game.Workspace
end

-- Not really a stab function as much as part of the shooting attack; shoot() actually fires off the projectile, while
--   stab() does the animations and sets touch damage during the attack
function stab()
	if Tip then Tip:Remove() end
	if TipWeld then TipWeld:Remove() end
	instantiateTipAndWeld()
	damage = STAB_DAMAGE	
	stabAnim = myHumanoid:LoadAnimation(Tool.DragonSwordCharge)
	if stabAnim then stabAnim:Play() end
	if stabSound then stabSound:Play() end
	-- rotate the sword; copied and pasted from Mahjong Sword's example... AND light the tip on fire.
	TipFire = Instance.new("Fire")
	TipFire.Size = .5
	TipFire.Parent = Tip
	for i = 1, 5 do
		-- These are the angles we need to rotate the sword by as the animation plays; modified slightly. (These are more... correct? than the ones in EelSword.)
		phi = i*math.pi/10
		theta = 3*math.pi/8 + i *math.pi/30
		psi = 17*math.pi/20+ i *math.pi/20
		Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))		
		TipFire.Size = i/5 + 1/2
		wait(.1)
	end
	-- The animation stays in stab position for two seconds, so the fire can still grow...
	for i = 1, 10 do
		TipFire.Size = i/5 + 3/2
		Tip.Transparency = 1.0 - i/10.0
		wait(.1)
	end
	-- THEN we can shoot it off (on a projectile), removing the actual fire.
	shootScript = Tool:FindFirstChild("ShootScript")
	if shootScript then 
		local newShootScript = shootScript:Clone()
		newShootScript.Parent = Tool
		newShootScript.Disabled = false
	end
	--shoot()
	Tip.Transparency = 1.0
	TipFire:Remove()
	--Reset the sword back to its original Orientation
	for i = 1, 10 do
		phi = math.pi/2 - i*math.pi/20
		theta = 13*math.pi/24 - i*math.pi/60
		psi = 11*math.pi/10 - i *math.pi/40
		Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))		
		wait(.01)
	end
	Tool.GripForward = Vector3.new(1.0, 0.0, 0.0)
	Tool.GripRight = Vector3.new(0.0, -1.0, 0.0)
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)
end

-- Boring rotation functions for the animation in dragonRage
function rotateSwordUp()
	oldTheta = 0
	oldPhi = 0
	oldPsi = math.pi
	theta = oldTheta
	phi = oldPhi
	psi = oldPsi
	newTheta = math.pi/2
	newPhi = -math.pi/2
	newPsi = math.pi/4

	for i = 1, 10 do
		theta = theta + (newTheta - oldTheta) / 10.0
		phi = phi + (newPhi - oldPhi) / 10.0
		psi = psi + (newPsi - oldPsi) / 10.0
		Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))
		wait(.02)
	end
	-- Just to check
	theta = newTheta
	phi = newPhi
	psi = newPsi
	Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
	Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
	Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))
end

function rotateSwordDown()
	oldTheta = math.pi/2
	oldPhi = -math.pi/2
	oldPsi = math.pi/4
	newTheta = 5*math.pi/16
	newPhi = -7*math.pi/8
	newPsi = math.pi/4
	theta = oldTheta
	phi = oldPhi
	psi = oldPsi
	
	for i = 0, 5 do
		theta = theta + (newTheta - oldTheta) / 5.0
		phi = phi + (newPhi - oldPhi) / 5.0
		psi = psi + (newPsi - oldPsi) / 5.0
		Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))
		wait(.01)
	end
	-- Just to check
	theta = newTheta
	phi = newPhi
	psi = newPsi
	Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
	Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
	Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))
end

function rotateSwordBack()
	oldTheta = 5*math.pi/16
	oldPhi = -7*math.pi/8
	oldPsi = math.pi/4
	newTheta = 0
	newPhi = 0
	newPsi = math.pi
	theta = oldTheta
	phi = oldPhi
	psi = oldPsi
	
	for i = 1, 10 do
		theta = theta + (newTheta - oldTheta) / 10.0
		phi = phi + (newPhi - oldPhi) / 10.0
		psi = psi + (newPsi - oldPsi) / 10.0
		Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))
		wait(.05)
	end
	-- Just to check
	theta = newTheta
	phi = newPhi
	psi = newPsi
	Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(psi), -math.cos(phi) * math.sin(psi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
	Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), -math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
	Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))
end

-- Special attack, creates two explosions (but not Explosions) around the point at which user is standing
--   when she starts the attack.
function dragonRage(key)	-- Please say this isn't copyright infringement...
	if not Tool.Enabled then return end
	if key:lower() ~= "x" then return end
	
	if co45 == nil or coroutine.status(co45) == 'dead' then
		co45 = coroutine.create(function() wait(45) end)
		coroutine.resume(co45)

		myCharacter = Tool.Parent
		if not myCharacter then return end
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		if not myHumanoid then return end
		Torso = myCharacter:FindFirstChild("Torso")
		if not Torso then return end
		initialTorsoFrame = Torso.CFrame
		initialTorsoPos = Torso.Position

		rageAnim = myHumanoid:LoadAnimation(Tool.DragonSwordRage)
		if rageAnim then rageAnim:Play() end

		rotateSwordUp()
		chingSound = Tool:FindFirstChild("ChingSound")
		if chingSound then chingSound:Play() end
		wait(0.5)
		rotateSwordDown()

		ignitionSound = Tool:FindFirstChild("IgnitionSound")
		if ignitionSound then ignitionSound:Play() end

		
		local FakeExplosion = Instance.new("Explosion")
		FakeExplosion.Position = initialTorsoPos
		FakeExplosion.BlastPressure = 0
		FakeExplosion.BlastRadius = 50
		FakeExplosion.Parent = game.Workspace
	

		local Fireball = Instance.new("Part")
		Fireball.CanCollide = false
		Fireball.Anchored = true
		Fireball.Locked = true
		Fireball.Transparency = 1.0
		Fireball.Size = Vector3.new(1, 1, 1)
		Fireball.CFrame = initialTorsoFrame
		Fireball.Parent = game.Workspace
		
		local Fire = Instance.new("Fire")
		Fire.Size = 30
		Fire.Heat = 30
		Fire.Parent = Fireball

		rageDamage(initialTorsoPos, RAGE_AOE, CLOSE_RAGE_DAMAGE, CLOSE_FIRE_PROB)
		--rageDamage includes a wait(1) inside itself, so we don't need to wait here.

		rotateSwordBack()

		debris:AddItem(Fireball, 2)

		if ignitionSound then ignitionSound:Play() end
		for i = 1, 4 do
			local Fireball = Instance.new("Part")
			Fireball.CanCollide = false
			Fireball.Anchored = true
			Fireball.Locked = true
			Fireball.Transparency = 1.0
			Fireball.Size = Vector3.new(1, 1, 1)
			Fireball.CFrame = initialTorsoFrame + Vector3.new(RAGE_AOE * math.cos(i*math.pi/2), 0, RAGE_AOE * math.sin(i*math.pi/2))
			Fireball.Parent = game.Workspace
			
			local Fire = Instance.new("Fire")
			Fire.Size = 30
			Fire.Heat = 30
			Fire.Parent = Fireball

			debris:AddItem(Fireball, 1)
		end

		rageDamage(initialTorsoPos, 2*RAGE_AOE, FAR_RAGE_DAMAGE, FAR_FIRE_PROB)
		
	end
end

function onActivated()
	-- Checking for double clicks is based on (i.e. copied from) that in EelSword, which was itself from MahjongSword...

	-- Check that tool is enabled,
	if not Tool.Enabled then return end
	Tool.Enabled = false
	-- And that character has use of his right arm.
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	if not myHumanoid then return end
	RightArm = myCharacter:FindFirstChild("Right Arm")
	if not RightArm then return end

	-- Get the time, to determine whether it was a double click or not.
	local thisAttackTime = runServ.Stepped:wait()

	if (thisAttackTime - lastAttackTime < 0.2) then	-- It was a double click.
		if slashSound then slashSound:Stop() end
		if slashAnim then slashAnim:Stop() end

		stab()
	else	-- It was a single click.
		damage = SLASH_DAMAGE
		slashAnim = myHumanoid:LoadAnimation(Tool.Slash)

		if slashSound then slashSound:Play() end
		if slashAnim then slashAnim:Play() end
	end
	
	lastAttackTime = thisAttackTime
	Tool.Enabled = true
	damage = TOUCH_DAMAGE
end
	

function onEquipped(mouse)
	if mouse then mouse.KeyDown:connect(dragonRage) end
	if unsheathSound then unsheathSound:Play() end
end

function onUnequipped()
	-- Stop sounds and animations
	if unsheathSound then unsheathSound:Stop() end
	if slashSound then slashSound:Stop() end
	if slashAnim then slashAnim:Stop() end
	if stabSound then stabSound:Stop() end
	if stabAnim then stabAnim:Stop() end
	if shotSound then shotSound:Stop() end
	if chingSound then chingSound:Stop() end
	if ignitionSound then ignitionSound:Stop() end
	if rageAnim then rageAnim:Stop() end

	if Tip then Tip:Remove() end
	if TipWeld then TipWeld:Remove() end

	-- Also reset sword position, just in case we unequipped in the middle of one of the animations.
	Tool.GripForward = Vector3.new(1.0, 0.0, 0.0)
	Tool.GripRight = Vector3.new(0.0, -1.0, 0.0)
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)
end
	
Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)
