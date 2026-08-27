-- Script for eel sword, based on Mahjong Sword's example code.

-- Game service, which allows us to get the time
local runServ = game:service("RunService")

-- For eel sword stab is presumably more powerful than slash, since it lets the eel shock!
-- (Also it takes way more time due to our double-click detection difficulties.)
-- So damage values will be adjusted accordingly.

local TOUCH_DAMAGE = 5        -- Touch damage...
local SLASH_DAMAGE = 8     	-- Slash damage...
local STAB_DAMAGE = 12    	   -- ... and stab damage.
local damage = TOUCH_DAMAGE	-- The CURRENT damage, set to one of the three below

-- Getting the tool and its handle:
local sword = script.Parent.Handle
local tool = script.Parent

-- Variables for the animations
local slashAnim
local stabAnim

-- Particle effects!
local sparkles = Instance.new("Sparkles")
sparkles.SparkleColor = Color3.new(1, 1, 35/255)
local fire = Instance.new("Fire")
fire.Color = Color3.new(1, 1, 35/255)
fire.SecondaryColor = Color3.new(1, 1, 1)
fire.Size = 3

-- Using same sounds as Sorcus's Sword of Judgment, because I can
local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
slashSound.Parent = sword
slashSound.Volume = 0.7

local stabSound = tool:FindFirstChild("EelSound")

local unsheathSound = Instance.new("Sound")
unsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
unsheathSound.Parent = sword
unsheathSound.Volume = 0.5

-- blow: calculates and applies the damage form an attack or touch
function blow(hit)
	if hit == nil or hit.Parent == nil then return end
	
	-- Set up local variables for "my" character (the one holding this eel sword) and the "other" one (the one I'm hitting with it)
	local myCharacter = tool.Parent
	local myPlayer = game.Players:playerFromCharacter(vCharacter)
	local myHum = myCharacter:findFirstChild("Humanoid")
	local otherHum = hit.Parent:findFirstChild("Humanoid")

	-- Check to make sure everything's non-nil, and that the sword is actually in "my" right hand (so it hasn't been chopped off)
	-- Also check to make sure I'm not damaging myself.
	if myHum ~= nil and myHum ~= otherHum	and otherHum ~= nil then
		local rightArm = myCharacter:findFirstChild("Right Arm")
		if rightArm ~= nil then
			local joint = rightArm:findFirstChild("RightGrip")
			if joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword) then
				tagHumanoid(otherHum, myPlayer)
				otherHum:TakeDamage(damage)
				wait(1)
				untagHumanoid(otherHum)
			end
		end
	end
end

-- tagHumanoid and untagHumanoid: For leaderboard functionality (?)
function tagHumanoid(humanoid, player)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

-- slash: slash attack
function slash()
	damage = SLASH_DAMAGE
	if slashSound then slashSound:Play() end
end

-- stab: stab attack

function stab()
	damage = STAB_DAMAGE
	if stabSound then stabSound:Play() end
	-- rotate the sword; copied and pasted from Mahjong Sword's example
	for i = 1, 5 do
		-- These are the angles we need to rotate the sword by as the animation plays
		phi = (i*math.pi/10) 
		theta = -i *math.pi/30
		psi = i *math.pi/20 + math.pi
		tool.GripForward = Vector3.new(math.cos(theta) * math.cos(phi), - math.cos(psi) * math.cos(phi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), - math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))		
		wait(.1)
	end
	wait(2)	
	--Reset the sword back to its original Orientation
	-- Try to rotate it back smoothly.
	for i = 1, 10 do
		phi = math.pi/2 - i*math.pi/20
		theta = (math.pi/3 + i*math.pi/30)
		psi = 5*math.pi/4 - i *math.pi/40
		tool.GripForward = Vector3.new(math.cos(theta) * math.cos(phi), - math.cos(psi) * math.cos(phi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), - math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))		
		wait(.02)
	end
	-- Just in case, manually set it back.
	tool.GripForward = Vector3.new(0.0 -1.0, 0.0)
	tool.GripRight = Vector3.new(-1.0, 0.0, 0.0)
	tool.GripUp = Vector3.new(0.0, 0.0, 1.0)
	-- Reset the damage
	damage = TOUCH_DAMAGE
end

-- Tentative lock (?)
tool.Enabled = true
local lastAttack = 0

-- onActivated: function that gets called when sword is activated
function onActivated()
	-- Check that tool is enabled
	if (not tool.Enabled) then return end

	-- Then disable it, so it can't be used again immediately
	tool.Enabled = false

	-- Checks to make sure player and humanoid are still available
	local myCharacter = tool.Parent
	if (myCharacter == nil) then return end
	local myHumanoid = myCharacter:findFirstChild("Humanoid")
	if (myHumanoid == nil) then return end

	-- Time between attacks...
	local t = runServ.Stepped:wait()
	
	-- If there was a very short time between this click and the last one, it was a double click, so STAB!
	if (t - lastAttack < 0.2) then
		-- End slash sound/animation that will have started (less than .2 seconds ago)
		if slashSound then slashSound:Stop() end
		if slashAnim then slashAnim:Stop() end

		-- Then play the stab animation...
		stabAnim = myHumanoid:LoadAnimation(tool.Stab)
		if stabAnim then stabAnim:Play() end
		-- ... shock...
		shock()
		-- ... and actually stab.
		stab()
		-- Wait a little while,
		wait(.3)
		-- remove the shock,
		removeShock()
		-- and wait enough time for the animation (2.5 s) to finish.
		wait(.2)
	else	-- If it's been a longish time since the last click, it was a single click, so SLASH!
		-- Stop the stab sound, just in case?
		if stabSound then stabSound:Stop() end
		
		-- Load and play the slash animation...
		slashAnim = myHumanoid:LoadAnimation(tool.FastSlash)
		if slashAnim then slashAnim:Play() end
		-- ... and actually slash.
		slash()
	end

	-- Update the time
	lastAttack = t
	-- And re-enable the tool.
	tool.Enabled = true
end

function onEquipped()
	-- Fix position of sword if necessary
	tool.GripForward = Vector3.new(0.0 -1.0, 0.0)
	tool.GripRight = Vector3.new(-1.0, 0.0, 0.0)
	tool.GripUp = Vector3.new(0.0, 0.0, 1.0)
	-- Unmute unsheath...
	unsheathSound.Volume = 0.5
	-- Play the unsheath sound, stop other sounds.
	if unsheathSound then unsheathSound:Play() end
	if stabSound then stabSound:Stop() end
	if slashSound then slashSound:Stop() end
	-- And stop the shock effect, just in case
	removeShock()
end

function onUnequipped()
	-- Stop any sounds and animations
	if stabAnim then stabAnim:Stop() end
	if slashAnim then slashAnim:Stop() end
	if stabSound then
		print ("Stopping")
		stabSound:Stop() 
	end
	
	if slashSound then slashSound:Stop() end
	if unsheathSound then unsheathSound:Stop() end
	-- And stop the shock effect, just in case
	removeShock()
end

-- shock: Creates a non-damaging shock effect using fire and sparkles particles.
function shock()
	sparkles.Parent = sword
	fire.Parent = sword
end

-- removeShock: gets rid of the effects created by shock.
function removeShock()
	if sparkles then sparkles.Parent = nil end
	if fire then fire.Parent = nil end
end

tool.Activated:connect(onActivated)
tool.Equipped:connect(onEquipped)
tool.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)
	




		
		


			




