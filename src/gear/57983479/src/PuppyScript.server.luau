local Tool = script.Parent
local Puppy = Tool.Handle

-- handles
local vCharacter
local myTorso
local myHumanoid

-- Sounds
local pSound = Instance.new("Sound")
pSound.SoundId = "http://www.roblox.com/asset/?id=57906779"
pSound.Parent = Puppy
pSound.Volume = 1.0
pSound.Pitch = 1.0

local pSound2 = pSound:Clone()
pSound2.SoundId = "http://www.roblox.com/asset/?id=57906784"
pSound2.Parent = Puppy

local pSound3 = pSound:Clone()
pSound3.SoundId = "http://www.roblox.com/asset/?id=57906798"
pSound3.Parent = Puppy

local puppySounds = {pSound, pSound2, pSound3}

local playSound

Tool.Enabled = true

local puppyInHand = true

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
	if myTorso == nil or rightArm == nil then 
		return
	end
	
	if puppyInHand then 
		rightGrip = rightArm:FindFirstChild("RightGrip")
		if rightGrip then
			rightGrip.Part0 = myTorso
			rightGrip.Part1 = Puppy
			rightGrip.Name = "PuppyGrip"			
			rightGrip.C1 = CFrame.new(Vector3.new(0.6, 0.8, -1.3)) * CFrame.Angles(0, -0.7, math.pi)
			
		end
		puppyInHand = false
	else 
		puppyGrip = rightArm:FindFirstChild("PuppyGrip")
		if puppyGrip then 
			puppyGrip.Part0 = rightArm
			puppyGrip.Part1 = Puppy
			puppyGrip.Name = "RightGrip"
			puppyGrip.C1 = CFrame.new(Vector3.new(0, 0, 0))	* CFrame.Angles(math.pi/2, 0, 0)		
			puppyGrip.Parent = rightArm
		end
		puppyInHand = true
	end
	
	
	playSound = puppySounds[math.random(1, 3)]
	if playSound then playSound:Play() end
	wait(2.0)
	Tool.Enabled = true
end

function onUnequipped()
	if playSound then playSound:Stop() end
	puppyInHand = true
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)
