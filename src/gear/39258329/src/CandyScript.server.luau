local Tool = script.Parent

local speedSpeed = 200 -- 400 if you allow y-axis pushing, 200 otherwise
local jitterSpeed = 20

Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
      Tool.Enabled = false

	vCharacter = Tool.Parent
	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then Tool.Enabled = true return end
	if vCharacter.Name == "BackPack" then Tool.Enabled = true return end


	local startVect = Vector3.new(-0.7, 0.05, 0)
	local endVect = Vector3.new(-1.5, -0.7, -.7)
	for i = 1, 20 do
		Tool.GripPos = (startVect*(20-i) + endVect*(i))/20
		wait(.05)
	end

	wait(1)

 -- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then return end
	magicSound:Play()

	selector = math.random(0,1)
	if selector == 0 then magicSound.SoundId = "http://www.roblox.com/asset/?id=39211465" -- yeehaw
		else magicSound.SoundId = "http://www.roblox.com/asset/?id=39211527" -- hooyah
	end


-- rest of script
	Tool.Handle.Transparency = 1
	
	Tool.GripPos = Vector3.new(-0.7, 0.05, 0)

	local newBP = Instance.new("BodyPosition")
	newBP.position = vCharacter.Torso.Position
	newBP.maxForce = Vector3.new(100000, 0, 100000)
	--newBP.maxForce = Vector3.new(100000, 100000, 100000)
	--newBP.Parent = vCharacter.Torso

	humanoid.WalkSpeed = speedSpeed

	--[[for i = 1, 140 do
		selector = math.random(1,3)
		if selector == 1 then
			-- jitter them
			newBP.position = vCharacter.Torso.Position + 5*Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)
			newBP.Parent = vCharacter.Torso
		elseif selector == 2 then
			-- don't jitter
			newBP.Parent = nil
		else
			-- do nothing?
			-- for now, remove jitter
			newBP.Parent = nil
		end
		wait(.05)
	end]]--

	for i = 1, 70 do
		newBP.position = vCharacter.Torso.Position + jitterSpeed*Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)
		newBP.Parent = vCharacter.Torso
		wait(.05)
		newBP.Parent = nil
		wait(.05)
	end

	humanoid.WalkSpeed = 16
	newBP.Parent = nil

	Tool.Handle.Transparency = 0

	Tool.Enabled = true
end

function onEquipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		selector = math.random(0,1)
		if selector == 0 then magicSound.SoundId = "http://www.roblox.com/asset/?id=39211465" -- yeehaw
			else magicSound.SoundId = "http://www.roblox.com/asset/?id=39211527" -- hooyah
		end
		magicSound.Name = "MagicSound"
	end
end


function onUnequipped()
	Tool.Handle.Transparency = 0
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then
		magicSound:Stop()
		magicSound.Parent = nil
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
