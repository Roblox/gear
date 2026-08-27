local Tool = script.Parent

local gears = {16214845, 29100449, 16726030, 15177716, 17237662, 29939404, 22596452, 28492363, 10472779}


function onActivated()
 -- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then return end
	magicSound:Play()

-- GOOD RANDOMIZATION CODE!!
--	numLoops = math.random(0,math.floor(tick()*time()))
--	numLoops = numLoops - (math.floor(numLoops / 10000)*10000)
	for i = 1,100 do
		whichNum = math.random(1,9)
	end
-- END OF GOOD RANDOMIZATION CODE!

	print("Picked: ")
	print(whichNum)
	local root = game:GetService("InsertService"):LoadAsset(gears[whichNum])

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	root = root:GetChildren()
	if #root == 1 then
		root = root[1]
	else return end
	print(root)
	root.Parent = Tool.Parent
	Tool:remove()
end

function onEquipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35571070"
		magicSound.Name = "MagicSound"
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
