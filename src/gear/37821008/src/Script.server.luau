local Tool = script.Parent

local gears = {11999279, 18210455, 11999247, 15668963, 27133214, 29532138}



function onActivated()
 -- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then return end
	magicSound:Play()

-- GOOD RANDOMIZATION CODE!!
	numLoops = math.random(0,math.floor(1000*time()))
	numLoops = numLoops - (math.floor(numLoops / 10000)*10000)
	for i = 1,numLoops do
		whichNum = math.random(1,#gears)
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
