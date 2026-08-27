-- RHKMan!! --

-- Have a handle to the game service in case we need to get the time object
r = game:service("RunService")

-- Tool and the Object, in this case RHKMan
local Tool = script.Parent

-- Just a partial lock, which disallows multiple instances of the onActivated function
Tool.Enabled = true

-- Initialize the Animation variable
local RHKAnim = nil

-- Damage!!
local RHK_damage = 50

-- To Connect with our blow function
local connection = nil

-- RHK Sound File
local RHKS = Instance.new("Sound")
RHKS.SoundId = "http://www.roblox.com/asset/?id=45763159"
RHKS.Parent = Tool
RHKS.Volume = 1.0

--Blow function, called when the character touches another character
function blow(hit)
	if cantHitNow then return end
   -- find, the humanoid object of the character that got hit
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	-- Find the our tool's character
	local vCharacter = Tool.Parent
	-- Get a handle to our player from the game space
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	-- Get the humanoid object our the player character
	local hum = vCharacter:findFirstChild("Humanoid") 
	-- if the humanoid object is not nil and is not the same as the hit character
	if humanoid~= nil and humanoid ~= hum and hum ~= nil then
		-- Get the handle to the left leg
		local left_leg = vCharacter:FindFirstChild("Left Leg")			
		if(left_leg ~= nil) then			
			-- If the left leg of the player tocuhes the humanoid then tag him			
			tagHumanoid(humanoid, vPlayer)
			-- Do the @#$% damage to him
			humanoid:TakeDamage(RHK_damage)
			if connection then connection:disconnect() connection = nil end
			wait(1.0)
			-- and untag him after a second so that the damage isn't applied continously
			untagHumanoid(humanoid)
		end
	end
end

-- Tagging and Untagging are done for leaderboards to find the source of the incoming damage
-- Function, to tag the player to the humanoid object
function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	-- Creates a value for the player and makes the humanoid its parent
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

-- Function, to untag the player from the humanoid
function untagHumanoid(humanoid)
	if humanoid ~= nil then
		-- Check if the creator tag is enabled
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
		-- if so, nullify the tag
			tag.Parent = nil
		end
	end
end
-- Actions to do when an item is activated
function onActivated()
	-- Make the Ninja potion transparent
	Tool.Handle.Transparency = 1
	-- Tentative lock, to disable multiple instances of this function
	if not Tool.Enabled then 
		return
	end
-- Check if the handle to the Player is still available in the space
	local MyPlayer = Tool.Parent
	if MyPlayer == nil then 
		return 
	end	

	-- Get a handle to the Torso of our character to rotate it
	local MyTorso = Tool.Parent:FindFirstChild("Torso")
	if MyTorso == nil then
		return
	end

	-- Check to see if the humanoid is still in the world
	local  MyHumanoid= MyPlayer:FindFirstChild("Humanoid")
	if MyHumanoid == nil then 
		return
	end

	-- Get a handle to the left leg of our character to check for hit
	local MyLeftLeg = Tool.Parent:FindFirstChild("Left Leg")
	if MyLeftLeg == nil then
		return
	end

	Tool.Enabled = false

	-- Load the Animation
	RHKAnim = MyHumanoid:LoadAnimation(Tool.RHK2)	
	-- Play Animation
	RHKAnim:Play()	
	
	-- Here, we are creating different frames of reference for our character's
	-- torso, so that we can rotate him 360 degrees. 6 steps of 60 deg each 
	torsoFrame1 = MyTorso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0)
	torsoFrame2 = MyTorso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0)
	torsoFrame3 = MyTorso.CFrame * CFrame.Angles(0, math.pi, 0)
	torsoFrame4 = MyTorso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0)
	torsoFrame5 = MyTorso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0)
	torsoFrame6 = MyTorso.CFrame

	-- Applying a force in the direction that we require on the body
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 100000
	bodyGyro.D = 3000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)
	bodyGyro.cframe = torsoFrame1
	bodyGyro.Parent = MyTorso

	-- The Animation lasts for a total of 0.8 seconds
	-- Match the Torso rotation with the animation
	wait(.4/3)
	bodyGyro.cframe = torsoFrame2
	wait(.4/3)
	-- Make the character jump for the kick
	MyHumanoid.Jump = true
	-- Check for the blow hit only after the character has jumped
	connection = MyLeftLeg.Touched:connect(blow)

	-- play the sound
	RHKS:Play()
	bodyGyro.cframe = torsoFrame3	
	wait(.4/3)
	bodyGyro.cframe = torsoFrame4
	wait(.4/3)
	bodyGyro.cframe = torsoFrame5
	wait(.4/3)
	bodyGyro.cframe = torsoFrame6
	wait(.4/3)

	wait(.5)
	-- Once the animation is played, disable the connection so that damage isn't
	-- applied for normal left leg collisions
	if connection then connection:disconnect() connection = nil end
	bodyGyro:remove()
	wait(.5)

	Tool.Enabled = true	
	-- Bring back the Ninja Potion!
	Tool.Handle.Transparency = 0
end

-- On Equip re-enable our sound
function onEquipped()
	RHKS.Volume = 1.0
end

-- On Unequip, stop the animation, remove the sound and disable the connection
function onUnequipped()	
	if RHKAnim ~= nil then RHKAnim:Stop() end
	if connection then connection:disconnect() connection = nil end	
	if RHKS ~= nil then RHKS:Stop() RHKS.Volume = 0.0 end
end
	
-- Connect our function to the Tool's Activate and other interfaces
Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

