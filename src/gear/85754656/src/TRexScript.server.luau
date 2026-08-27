-- First Plushie!

-- Needed for calculating time
-- r = game:service("RunService")

-- Store the Tool information
local Tool = script.Parent

-- Variable for making sure our function is entered only once during a particular instance
enabled = true

local character_is_trex = false


-- Sound
local sound1 = Instance.new("Sound")
sound1.SoundId = "http://www.roblox.com/asset/?id=85469452"
sound1.Parent = Tool.Handle

local sound2 = Instance.new("Sound")
sound2.SoundId = "http://www.roblox.com/asset/?id=85469664"
sound2.Parent = Tool.Handle


-- Three functions for onActivate, onEquip and onUnEquip

function onActivated()

	-- Need to do this particular check, so that it disables multiple instances of this function getting activated
	if not enabled then return
	end
	-- If the above constraint fails, then lock it
	-- This lock is tentative since during multithreading there is still a chance for there to be multiple instances of this function
	enabled = false	
	
	-- Check to see if the character is a TRex
	if not character_is_trex then
		character_is_trex = true
		Tool.GripPos = Vector3.new(1.5, -3.4, -1.5)
		sound1:Play()
		wait(2)
	else
		character_is_trex = false
		Tool.GripPos = Vector3.new(0, 0, 0)
		sound2:Play()
		wait(2)
	end
	enabled = true	
end

function onEquipped()
	sound1.Volume = 1
	sound2.Volume = 1
end

function onUnequipped()
	sound1.Volume = 0
	sound2.Volume = 0
end

-- This is to connect our function to the Activate functionality of the Player Character!
script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
