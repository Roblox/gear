local Tool = script.Parent

--local gears = {27471379, 16924676, 33867401, 18210455, 18479357} --, 31839203} --remote control might be tricky to get...  save for l8r
local gears = {18210455, 35809502, 16924676, 33382537, 33867401, 30847779, 26014536} -- and put in Battle Sleighs here too!

function onActivated()
 -- play sound
	local randomIndicator = math.random(1, 3)
	magicSound = Tool.Handle:FindFirstChild("MagicSound"..tostring(randomIndicator))

	if magicSound == nil then return end
	magicSound:Play()

	-- shrink code
	local bagSize = 2
	for i = 1, 15 do
		bagSize = bagSize - .1
		Tool.Handle.Mesh.Scale = Vector3.new(bagSize, bagSize, bagSize)
		Tool.GripPos = Vector3.new(0, -2*bagSize/5, bagSize/2)
		wait(.1)
	end

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

-- 19259975 = loud hohoho
-- 19260023 = soft hohoho
-- 19358641 = jingle

	magicSound = Tool.Handle:FindFirstChild("MagicSound1")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = .5
		magicSound.SoundId = "http://www.roblox.com/asset/?id=19358641"
		magicSound.Name = "MagicSound1"
	end

	magicSound = Tool.Handle:FindFirstChild("MagicSound2")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=19259975"
		magicSound.Name = "MagicSound2"
	end

	magicSound = Tool.Handle:FindFirstChild("MagicSound3")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=19260023"
		magicSound.Name = "MagicSound3"
	end

end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
