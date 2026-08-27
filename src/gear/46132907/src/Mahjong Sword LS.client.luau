-- CHESS SWORD --

-- Handle to the game service, in case we need to get the time
r = game:service("RunService")


-- normal damage, when the sword touches a humanoid object
local damage = 5


-- Slash damage
local slash_damage = 10

-- Stab damage
local stab_damage = 10

-- Handle to tool
sword = script.Parent.Handle
Tool = script.Parent

-- For the Animations
local SlashAnim
local StabAnim

-- Sounds!
local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\SwordSlash.wav"
SlashSound.Parent = Tool
SlashSound.Volume = .7

local SwordStab = Instance.new("Sound")
SwordStab.SoundId = "http://www.roblox.com/asset/?id=45941860"
SwordStab.Parent = Tool
SwordStab.Volume = 1.0

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = Tool
UnsheathSound.Volume = 0.3

-- When a collision is detected between the player and another character
function blow(hit)
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1)
				untagHumanoid(humanoid)
			end
		end

	end
end

-- Tagging and Untagging primarily for the leaderboards 
function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end


 -- On, left click!
function attack()
	damage = slash_damage
	if SlashSound then SlashSound:Play() end
end

-- On double click!
function lunge()
	damage = stab_damage	
	-- Play the Stab Animation
	if SwordStab then SwordStab:Play() end
	-- 3D Rotation matrix, for the sword to spin with the character to perform the double handed stab
	for i = 1, 5 do
		-- These are the angles we need to rotate the sword by as the animation plays
		phi = (i*math.pi/10) 
		theta = i *math.pi/15 * 2
		psi = i *math.pi/20 + math.pi
		Tool.GripForward = Vector3.new(math.cos(theta) * math.cos(phi), - math.cos(psi) * math.cos(phi) + math.sin(phi) * math.sin(theta) * math.cos(psi), math.sin(phi) * math.sin(psi) + math.cos(phi) * math.sin(theta) * math.cos(psi))
		Tool.GripRight = Vector3.new(math.sin(psi) * math.cos(theta), math.cos(phi) * math.cos(psi) + math.sin(psi)* math.sin(theta) * math.sin(phi), - math.sin(phi) * math.cos(psi) + math.cos(phi) * math.sin(theta) * math.sin(psi))		
		Tool.GripUp = Vector3.new(-math.sin(theta), math.sin(phi) * math.cos(theta), math.cos(theta) * math.cos(phi))		
		wait(.1)
	end
	wait(1)	
	--Reset the sword back to its original Orientation
	Tool.GripForward = Vector3.new(-1.0, 0.0, 0.0)
	Tool.GripRight = Vector3.new(0.0, 1.0, 0.0)
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)
	-- Reset the damage back to default denying the unholy amounts of parry damage the Mahjong Sword is capable of doing
	damage = 5
end

-- Tentative lock
Tool.Enabled = true
local last_attack = 0

function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

-- Check if the handle to the Player is still available in the space
	local MyPlayer = Tool.Parent
	if MyPlayer == nil then 
		return 
	end	
	
	-- Check to see if the humanoid is still in the world
	local  MyHumanoid= MyPlayer:FindFirstChild("Humanoid")
	if MyHumanoid == nil then 
		return
	end
	-- Time between wait steps
	t = r.Stepped:wait()
	-- If, the mouse is clicked continously, perform the stab else perform the slash
	if (t - last_attack < .2) then	
		-- Stop slash sounds or animations that might have been invoked previously
		if SlashSound then SlashSound:Stop() end
		if SlashAnim then SlashAnim:Stop() end
		StabAnim = MyHumanoid:LoadAnimation(Tool.Stab)
		if StabAnim then StabAnim:Play()	end
		lunge()
		-- Wait for the animation to finish
		-- Total Animation time in this case is 2.5seconds
		wait(1.5)
	else
		attack()

		if SwordStab then SwordStab:Stop() end
		-- Load and play the animation
		SlashAnim = MyHumanoid:LoadAnimation(Tool.SideSlash)
		if SlashAnim then SlashAnim:Play() end
	end
	
	last_attack = t	
	Tool.Enabled = true
end


function onEquipped()	
	-- Play the default unsheath sound
	if UnsheathSound then UnsheathSound:Play() end
	if SwordStab then SwordStab:Stop() end
	if SlashSound then SlashSound:Stop() end
end

function onUnequipped()
	-- Remove the sounds and the animations
	SwordStab.Volume = 0
	SlashSound.Volume = 0
	if SlashAnim then SlashAnim:Stop() end
	if StabAnim then StabAnim:Stop() end
	if SwordStab then SwordStab:Stop() end
	if SlashSound then SlashSound:Stop() end
	if UnsheathSound then UnsheathSound:Stop()end
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(OnUnequipped)

connection = sword.Touched:connect(blow)


