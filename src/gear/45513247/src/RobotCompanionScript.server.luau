-- First Plushie! 

-- Needed for calculating time
-- r = game:service("RunService")

-- Store the Tool information 
local Tool = script.Parent

-- Variable for making sure our function is entered only once during a particular instance
enabled = true
local sitting_on_character = false

-- Sounds

local onPickup_s1 = Instance.new("Sound")
onPickup_s1.SoundId = "http://www.roblox.com/asset/?id=45428575"
onPickup_s1.Parent = Tool.Handle

local onSit_s1 = Instance.new("Sound")
onSit_s1.SoundId = "http://www.roblox.com/asset/?id=45428516"
onSit_s1.Parent = Tool.Handle

local onSit_s2 = Instance.new("Sound")
onSit_s2.SoundId = "http://www.roblox.com/asset/?id=45428590"
onSit_s2.Parent = Tool.Handle

local onSit_s3 = Instance.new("Sound")
onSit_s3.SoundId = "http://www.roblox.com/asset/?id=45428545"
onSit_s3.Parent = Tool.Handle

local onDrop_s1 = Instance.new("Sound")
onDrop_s1.SoundId = "http://www.roblox.com/asset/?id=45428486"
onDrop_s1.Parent =Tool.Handle

local sit_sounds = {onSit_s1, onSit_s2, onSit_s3}
local hold_sounds = {onPickup_s1, onDrop_s1}
local all_sounds = {onSit_s1, onSit_s2, onSit_s3, onPickup_s1, onDrop_s1}


-- Three functions for onActivate, onEquip and onUnEquip

function onActivated()

	-- Need to do this particular check, so that it disables multiple instances of this function getting activated
	if not enabled then return
	end
	-- If the above constraint fails, then lock it
	-- This lock is tentative since during multithreading there is still a chance for there to be multiple instances of this function
	enabled = false	
	
	-- Check to see if the robot is sitting on the character
	if not sitting_on_character then
		sitting_on_character = true	
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=45450768"	
		Tool.GripForward = Vector3.new(0, -1, 0)
		Tool.GripPos = Vector3.new(-0.5, -1.5, -0.5)
		Tool.GripRight = Vector3.new(-1, 0, 0)
		Tool.GripUp = Vector3.new(0, 0, 1)
		sit_sounds[math.random(1, #sit_sounds)]:Play()	
		wait(2)	

	else 
		sitting_on_character = false
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=45450798"
		Tool.GripForward = Vector3.new(0, -1, 0)
		Tool.GripPos = Vector3.new(0, 0, 0)
		Tool.GripRight = Vector3.new(-1, 0, 0)
		Tool.GripUp = Vector3.new(0, 0, 1)
		hold_sounds[math.random(1, #hold_sounds)]:Play()
		wait(2)	
	end
	enabled = true	
end


function onEquipped()
	-- Unmute all Sounds
	for i=1, #all_sounds do
		all_sounds[i].Volume = 1
	end
end

function onUnequipped()
	-- Mute all Sounds
	for i=1,#all_sounds do
		all_sounds[i].Volume = 0
	end
end

-- This is to connect our function to the Activate functionality of the Player Character!
script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)


