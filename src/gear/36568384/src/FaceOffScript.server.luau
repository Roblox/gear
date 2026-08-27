local Tool = script.Parent

Tool.Enabled = true


function drinkBottle()
	Tool.GripForward = Vector3.new(0, .707, .707)
	Tool.GripPos = Vector3.new(1.6, .2, -.5)
	Tool.GripUp = Vector3.new(0, .707, .707)
end

function lowerBottle()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripPos = Vector3.new(0, -.2, -.4)
	Tool.GripUp = Vector3.new(0, 0, 1)
end



function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	local vCharacter = Tool.Parent

	myFace = vCharacter.Head:FindFirstChild("face")
	if myFace == nil then Tool.Enabled = true return end
	myFace.Parent = nil

	magicSound:Play()
	drinkBottle()
	wait(1)
	lowerBottle()
	wait(4)
	myFace.Parent = vCharacter.Head
	Tool.Enabled = true
end

function onEquipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35873214"
		magicSound.Name = "MagicSound"
	end
end

function onUnequipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then
		magicSound.Parent = nil
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
