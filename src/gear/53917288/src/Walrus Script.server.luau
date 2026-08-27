-- New plushie, script based on that for RobotCompanion

-- Set parent
local Tool = script.Parent
-- Handle to walrus
local Walrus = Tool.Handle
-- And initial position
local standing_on_head = false;
-- And enabled variable.
Tool.Enabled = true

-- Then initialize sounds
local standingSound1 = Tool:FindFirstChild("WalrusSound1")
local standingSound2 = Tool:FindFirstChild("WalrusSound2")
local standingSound3 = Tool:FindFirstChild("WalrusSound3")

local lyingSound1 = Tool:FindFirstChild("WalrusSound4")
local lyingSound2 = Tool:FindFirstChild("WalrusSound5")
local lyingSound3 = Tool:FindFirstChild("WalrusSound6")

local standingSounds = {standingSound1, standingSound2, standingSound3}
local lyingSounds = {lyingSound1, lyingSound2, lyingSound3}
local allSounds = {standingSound1, standingSound2, standingSound3, lyingSound1, lyingSound2, lyingSound3}

-- clone for the walrus handle
local walrusClone
-- Handle to character
local vCharacter


-- Activation function makes walrus stand on player's head (for now)
function onActivated()
	-- Check to make sure walrus is enabled
	if not Tool.Enabled then return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHead = vCharacter:FindFirstChild("Head")
	if myTorso == nil or myHead == nil then 
		return	
	end
	

	if not standing_on_head then
		-- Make it stand on the character's head
		walrusClone = Walrus:Clone()
		walrusClone.Parent = vCharacter
		Walrus.Transparency = 1.0
		-- Welding the clone to the head
		weld = Instance.new("Weld")
		weld.Part0 = myHead
		weld.Part1 = walrusClone
		weld.Parent = myHead
		weld.Name = "HeadWeld"
		weld.C1 = CFrame.new(Vector3.new(0, -2.2, -0.5))

		standing_on_head = true
		Tool.GripUp = Vector3.new(0, 1, 0)
		Tool.GripForward = Vector3.new(0, 0, -1)
		Tool.GripPos = Vector3.new(1.5, -3, -1.75)
		Tool.GripRight = Vector3.new(1, 0, 0)
		rand = standingSounds[math.random(1, #standingSounds)]
		if rand then
			rand:Play()
		end
		wait(3.5)
	else
		-- Bring it back to its standard position, sitting on arm.
		if walrusClone then walrusClone:Destroy() end
		Walrus.Transparency = 0.0
		standing_on_head = false
		Tool.GripUp = Vector3.new(0, 0, 1)
		Tool.GripForward = Vector3.new(0, 1, 0)
		Tool.GripPos = Vector3.new(0, 1, -1)
		Tool.GripRight = Vector3.new(1, 0, 0)
		rand = lyingSounds[math.random(1, #lyingSounds)]
		if rand then
			rand:Play()
		end
		wait(3.5)
	end

	Tool.Enabled = true

end


-- onUnequipped mutes all sounds
function onUnequipped()
	for i = 1, #allSounds do
		allSounds[i]:Stop()
	end
	if walrusClone then walrusClone:Destroy() end
	Walrus.Transparency = 0.0
end
	
-- Connect all functions to their listeners...
script.Parent.Activated:connect(onActivated)
script.Parent.Unequipped:connect(onUnequipped)
