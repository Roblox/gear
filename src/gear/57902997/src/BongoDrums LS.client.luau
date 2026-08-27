-- Yay, more music! Mechanic is effectively identical to the Silly Guitar's.
math.randomseed(tick()); math.random()

function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

math.randomseed(tick()); math.random()

local Tool = script.Parent
local Drums = Tool.Handle

local myCharacter
local myHumanoid
local Torso
local TorsoWeld
local RightArm
local LeftArm
local RightGrip

local ReadyBongos
local LeftBongoLowHit
local LeftBongoHighHit
local RightBongoLowHit
local RightBongoHighHit

local LeftBongoLowSound
local LeftBongoHighSound
local RightBongoLowSound
local RightBongoHighSound

local TimeTillEnabled
local WaitScript

--local SongSound = Tool:FindFirstChild("SongSound")
local waitTime = 0
local timeWaited = 0
local stepTime = 0.1

local randNum

local gripCo

local soundTable
local animTable
local armTable

-- What, isn't this standard music notation?
local song1String = "mxjbxjmxmxjbxjmxmxjbxjmxmxjbhxhxmxjbxjmxmxjbxjmxmxjbxjmxm"
local song2String = "bbbbbbbxxmxxjxxjxxmxjmxxbbbbbbbxxmxxjxxmxxhxxxxxbbbbbbbxxmmmjxxbbbh"
local song3String = "mmbmhmbjmmbmhmbjmmhmmbmmjmmbmmhmhmbmjmbjmhbmjmbjhmbmjmbjmbbbh"

function reformGrip()
	myCharacter = Tool.Parent
	Torso = myCharacter:FindFirstChild("Torso")
	RightArm = myCharacter:FindFirstChild("Right Arm")
	if RightArm then RightGrip = RightArm:FindFirstChild("RightGrip") end

	if Torso then
		if RightGrip then RightGrip:Remove() end
		if not Torso:FindFirstChild("BongoDrumsTorsoWeld") then
			Drums.CanCollide = false
			TorsoWeld = Instance.new("Weld")
			TorsoWeld.Part0 = Torso
			TorsoWeld.Part1 = Drums
			TorsoWeld.C1 = CFrame.new(0, 1.3, 0.5) * CFrame.Angles(math.pi/2, math.pi, 0)
			TorsoWeld.Name = "BongoDrumsTorsoWeld"
			TorsoWeld.Parent = game.Workspace
		end
	end
end

function play(key)
	local lowKey = key:lower()

	local HitAnim = animTable[lowKey]
	local HitSound = soundTable[lowKey]
	local HitArm = armTable[lowKey]	-- We can't play with an absent arm, hence this check.

	if HitSound and HitArm then 
		if HitAnim then HitAnim:Play() end
		HitSound:Play() 
	end
end

function playSong(str)
	-- Each letter in the song string represents a different sound (or lack thereof), so we
	--  iterate through the string to play a song.
	local length = string.len(str)
	for i = 1, length do
		play(string.sub(str, i, i))
		wait(2/15)
	end
end
	

function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	local randNum = math.random()
	if (randNum > 2/3) then
		playSong(song1String)
	elseif (randNum > 1/3) then
		playSong(song2String)
	else
		playSong(song3String)
	end
	Tool.Enabled = true
end

function onEquipped(mouse)
	if mouse then mouse.KeyDown:connect(play) end

	myCharacter = Tool.Parent
	-- Load animation nao, so we don't have to do it every time we play a note.
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	if myHumanoid then 
		ReadyBongos = myHumanoid:LoadAnimation(waitForChild(Tool, "ReadyBongos"))
		LeftBongoLowHit = myHumanoid:LoadAnimation(waitForChild(Tool, "LeftBongoLowHit")) 
		LeftBongoHighHit = myHumanoid:LoadAnimation(waitForChild(Tool, "LeftBongoHighHit"))
		RightBongoLowHit = myHumanoid:LoadAnimation(waitForChild(Tool, "RightBongoLowHit"))
		RightBongoHighHit = myHumanoid:LoadAnimation(waitForChild(Tool, "RightBongoHighHit"))
	end

	-- Same with sounds.
	LeftBongoLowSound = waitForChild(Drums, "LeftBongoLowSound")
	LeftBongoHighSound = waitForChild(Drums, "LeftBongoHighSound")
	RightBongoLowSound = waitForChild(Drums, "RightBongoLowSound")
	RightBongoHighSound = waitForChild(Drums, "RightBongoHighSound")

	-- And all the tables!
	RightArm = myCharacter:FindFirstChild("Right Arm")
	LeftArm = myCharacter:FindFirstChild("Left Arm")
	
	soundTable = {
		["b"] = LeftBongoLowSound,
		["h"] = LeftBongoHighSound,
		["m"] = RightBongoLowSound,
		["j"] = RightBongoHighSound
	}

	armTable = {
		["b"] = LeftArm,
		["h"] = LeftArm,
		["m"] = RightArm,
		["j"] = RightArm
	}

	animTable = {
		["b"] = LeftBongoLowHit,
		["h"] = LeftBongoHighHit,
		["m"] = RightBongoLowHit,
		["j"] = RightBongoHighHit
	}	

	-- Break right grip, and weld bongos to torso instead.
	if RightArm then 
		RightArm.ChildAdded:connect(function(child)
			if child.Name == "RightGrip" then	-- Take THAT, RightGrip!
				reformGrip()
			end
		end)
	end
	reformGrip()
		
	-- And play the animation that gets us in position to play.
	if ReadyBongos then ReadyBongos:Play() end
end

function onUnequipped()
	-- Stop ready anim.
	if ReadyBongos then ReadyBongos:Stop() end
	-- And delete everything in the tables.
	soundTable = {}
	animTable = {}

	-- Break weld, and (if it was backspaced) get scary bongos away from us and re-enable the tool.
	TorsoWeld.Parent = nil
	if Tool.Parent == game.Workspace then
		Tool.Enabled = true
		if Torso then
			Drums.Position = Torso.Position + 8 * Torso.CFrame.lookVector + Vector3.new(0, 5, 0)
		else	
			Drums.Position = Vector3.new(0, 5, 0)
		end
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)