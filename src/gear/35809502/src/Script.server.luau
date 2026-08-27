local Tool = script.Parent
local gears = {31839203, 30847779, 27902303, 12848902, 28664212, 18479357, 25158998, 16924676, 18210455}

function onActivated()
 -- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then return end
	magicSound:Play()

-- GOOD RANDOMIZATION CODE!!
--	numLoops = math.random(0,math.floor(tick()*time()))
--	numLoops = numLoops - (math.floor(numLoops / 10000)*10000)
	for i = 1,100 do
		whichNum = math.random(2,9)
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
	-- needed for irregularity in hippo gear
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
