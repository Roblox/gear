-- Microphone!! --

-- Have a handle to the game service in case we need to get the time object
r = game:service("RunService")

-- Tool and the Object, in this case Microphone
local Microphone = script.Parent.Handle
local Tool = script.Parent

-- Just a partial lock, which disallows multiple instances of the onActivated function
Tool.Enabled = true

local BBAnim = nil
local fakeMic = nil


-- Create an instance of the beatbox music that is stored in the server and append it to the microphone object
local BeatboxS = Instance.new("Sound")
BeatboxS.SoundId = "http://www.roblox.com/asset/?id=45503715"
BeatboxS.Parent = Tool
BeatboxS.Volume = 1.0 -- Just to fiddle with the Volume values

local MaleS = Instance.new("Sound")
MaleS.SoundId = "http://www.roblox.com/asset/?id=45517845"
MaleS.Parent = Tool
MaleS.Volume = 1.0

local FemaleS = Instance.new("Sound")
FemaleS.SoundId = "http://roblox.com/asset/?id=45517873"
FemaleS.Parent = Tool
FemaleS.Volume = 1.0

-- Array to hold the songs
local AllSongs = {BeatboxS, MaleS, FemaleS}

-- Actions to do when an item is activated
function onActivated()
	-- Tentative lock, to disable multiple instances of this function
	if not Tool.Enabled then 
		return
	end
-- Check if the handle to the Player is still available in the space
	local MyPlayer = Tool.Parent
	if MyPlayer == nil then 
		return 
	end

	local MyRightArm = Tool.Parent:FindFirstChild("Right Arm")
	if MyRightArm == nil then 
		return
	end

	local MyTorso = Tool.Parent:FindFirstChild("Torso")
	if MyTorso == nil then
		return
	end

	-- Check to see if the humanoid is still in the world
	local  MyHumanoid= MyPlayer:FindFirstChild("Humanoid")
	if MyHumanoid == nil then 
		return
	end

	Tool.Enabled = false

	-- Load the Animation
	BBAnim = MyHumanoid:LoadAnimation(Tool.BeatBox)	
	-- Play Animation
	BBAnim:Play()	

	-- Play the Music!
	AllSongs[math.random(1, #AllSongs)]:Play()
	
	--[[ This massive chunk of code is used to animate the Microphone model to move with the hand
			This is done after playing through with the values with the Editor and knowing how the 
			timings of the Animation look]]

	fakeMic = Tool.Handle:Clone()
	fakeMic.CanCollide = false
	fakeMic.Parent = game.Workspace
	Tool.Handle.Transparency = 1

	local newWeld = Instance.new("Weld")
	newWeld.Part1 = MyTorso
	newWeld.Part0 = fakeMic
	newWeld.C1 = CFrame.new(Vector3.new(1.5, .3, -1.5)) * CFrame.Angles(-math.pi/2, 0, 0) 
	newWeld.Parent = MyTorso

	for i = 1.5,-1.5, -0.3 do
		-- Playing with the editor, we already know that we need to move only the Y part
		newWeld.C1 = CFrame.new(Vector3.new(i, .3, -1.5)) * CFrame.Angles(-math.pi/2, 0, 0) 		
		wait(0.1)
	end
	wait(.75)
	-- 2nd position
	for i = -1.5, 0, 0.3 do
		--Tool.GripPos = Vector3.new(0, i, 0.2)		
		newWeld.C1 = CFrame.new(Vector3.new(i, .3, -1.5)) * CFrame.Angles(-math.pi/2, 0, 0) 
		--Tool.GripPos = MyRightArm.CFrame:vectorToObjectSpace(MyTorso.CFrame:vectorToWorldSpace(Vector3.new(i, .3, -1.5)) + MyRightArm.Position - MyTorso.Position)
		wait(0.1)
	end	
	wait(3)	
	-- 3rd position
	for i = 0, -1.0, -0.2 do
		newWeld.C1 = CFrame.new(Vector3.new(i, .3, -1.5)) * CFrame.Angles(-math.pi/2, 0, 0) 
		wait(0.1)
	end
	-- 4th position	
	for i = -1.0, 0.5, .12 do
		newWeld.C1 = CFrame.new(Vector3.new(i, .3, -1.5)) * CFrame.Angles(-math.pi/2, 0, 0) 
		wait(0.1)
	end
	fakeMic:remove()
	Tool.Handle.Transparency = 0

	wait(3)

	Tool.Enabled = true	
end

function onEquipped()
	for i =1,#AllSongs do
		AllSongs[i].Volume = 1
	end
end

function onUnequipped()
	for i=1, #AllSongs do
		AllSongs[i].Volume = 0
		AllSongs[i]:Stop()
	end
	if fakeMic ~= nil then fakeMic.Transparency = 1 end
	if BBAnim ~= nil then BBAnim:Stop() end
end
	
-- Connect our function to the Tool's Activate and other interfaces
Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
