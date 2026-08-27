local Tool = script.Parent
numClicks = 0

Tool.Enabled = true

function returnZombie()
	Tool.GripForward = Vector3.new(0, 1, 0)
	--Tool.GripPos = Vector3.new(0, 0, 0)
	Tool.GripPos = Vector3.new(0.2, 0, -0.2)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function placeA()
	Tool.GripForward = Vector3.new(0, -1, 0)
	--Tool.GripPos = Vector3.new(0, 0, 0)
	Tool.GripPos = Vector3.new(-0.2, 0, -0.2)
	Tool.GripRight = Vector3.new(-1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function placeB()
	Tool.GripForward = Vector3.new(0, -1, 0)
	Tool.GripPos = Vector3.new(0, -.6, -1.7)
	Tool.GripRight = Vector3.new(-.707, -0, -.707)
	Tool.GripUp = Vector3.new(-.707, 0, .707)	
end

function placeC()
	Tool.GripForward = Vector3.new(0, .707, .707)
	--Tool.GripPos = Vector3.new(1.5, 3, -.4)
	Tool.GripPos = Vector3.new(1.5, 2.8, .4)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0, -.707, .707)
end


function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	
	-- play sound
	zombESound = Tool.Handle:FindFirstChild("ZombESound")
	if zombESound == nil then
		zombESound = Instance.new("Sound")
		zombESound.Parent = Tool.Handle
		zombESound.Volume = 1
		zombESound.SoundId = "http://www.roblox.com/asset/?id=35971877"
		zombESound.Name = "ZombESound"
	end
	zombESound2 = Tool.Handle:FindFirstChild("ZombESound2")
	if zombESound2 == nil then
		zombESound2 = Instance.new("Sound")
		zombESound2.Parent = Tool.Handle
		zombESound2.Volume = 1
		zombESound2.SoundId = "http://www.roblox.com/asset/?id=35971915"
		zombESound2.Name = "ZombESound2"
	end
	omnom = Tool.Handle:FindFirstChild("Omnomnom")
	if omnom == nil then
		omnom = Instance.new("Sound")
		omnom.Parent = Tool.Handle
		omnom.Volume = 1
		omnom.SoundId = "http://www.roblox.com/asset/?id=12544690"
		omnom.Name = "Omnomnom"
	end

	numClicks = numClicks + 1
	if numClicks > 5 then 
		omnom:Play()
		placeB()
		wait(4)
	else
		whichSound = math.random(0,100)
		if whichSound < 50 then zombESound:Play()
		else zombESound2:Play() end
		whichPlace = math.random(0,100)
		if whichPlace < 50 then placeA()
		else placeC() end
	end

	wait(1)
	returnZombie()
	Tool.Enabled = true

	wait(5)
	numClicks = numClicks - 1
	if numClicks < 0 then numClicks = 0 end
end

function onEquipped()
	zombESound = Tool.Handle:FindFirstChild("ZombESound")
	if zombESound == nil then
		zombESound = Instance.new("Sound")
		zombESound.Parent = Tool.Handle
		zombESound.Volume = 1
		zombESound.SoundId = "http://www.roblox.com/asset/?id=35971877"
		zombESound.Name = "ZombESound"
	end
	zombESound2 = Tool.Handle:FindFirstChild("ZombESound2")
	if zombESound2 == nil then
		zombESound2 = Instance.new("Sound")
		zombESound2.Parent = Tool.Handle
		zombESound2.Volume = 1
		zombESound2.SoundId = "http://www.roblox.com/asset/?id=35971915"
		zombESound2.Name = "ZombESound2"
	end
	omnom = Tool.Handle:FindFirstChild("Omnomnom")
	if omnom == nil then
		omnom = Instance.new("Sound")
		omnom.Parent = Tool.Handle
		omnom.Volume = 1
		omnom.SoundId = "http://www.roblox.com/asset/?id=12544690"
		omnom.Name = "Omnomnom"
	end

 -- 35971877 is first zombESound
 -- 35971915 is second zombESound
 -- 12544690 is omnom

end

function onUnequipped()
	zombESound = Tool.Handle:FindFirstChild("ZombESound")
	if zombESound ~= nil then
		zombESound:Stop()
		zombESound.Parent = nil
	end
	zombESound2 = Tool.Handle:FindFirstChild("ZombESound2")
	if zombESound2 ~= nil then
		zombESound2:Stop()
		zombESound2.Parent = nil
	end
	omnom = Tool.Handle:FindFirstChild("Omnomnom")
	if omnom ~= nil then
		omnom:Stop()
		omnom.Parent = nil
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
