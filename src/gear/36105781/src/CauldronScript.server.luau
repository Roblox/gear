local Tool = script.Parent


Tool.Enabled = true
function onActivated()
	vCharacter = Tool.Parent
	if vCharacter == nil then return end
	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then return end
	if not Tool.Enabled or humanoid.Jump then return end
	Tool.Enabled = false
	print("started activation")
	rightArm = Tool.Parent:FindFirstChild("Right Arm")
	if rightArm == nil then return end
	fog = {}
	newBF = {}

	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35895627"
		-- 35895627 is cauldronFire
		-- 35895661 is cauldronWater
		magicSound.Name = "MagicSound"
	end
	slushy = Tool.Handle:FindFirstChild("SlushySound")
	if slushy == nil then
		slushy = Instance.new("Sound")
		slushy.Parent = Tool.Handle
		slushy.Volume = 1
		slushy.SoundId = "http://www.roblox.com/asset/?id=35895661"
		slushy.Name = "SlushySound"
	end
	magicSound.Looped = true
	slushy.Looped = true
	magicSound:Play()
	slushy:Play()

	for i = 1,10 do
		fog[i] = rightArm:Clone()
		fog[i].Name = "Fog"
		fog[i].Velocity = Vector3.new(5*math.sin(i*math.pi/5),5,5*math.cos(i*math.pi/5))
		fog[i].Transparency = 1
		fog[i].CanCollide = false
		fog[i].Parent = Tool.Parent -- for now 
		foggy = Instance.new("Smoke")
		foggy.Color = Color3.new(1,1,1)
		foggy.Size = Vector3.new(27,27,27)
		foggy.Parent = fog[i]
		newBF[i] = Instance.new("BodyForce")
		newBF[i].force = Vector3.new(0, 195*fog[i]:GetMass(), 0)
		newBF[i].Name = "FogLift"
		newBF[i].Parent = fog[i]
		foggy.Enabled = true
		wait(.1)
	end

	

	wait(1)
	for i = 1, 10 do
		fog[i].Velocity = Vector3.new(0,0,0)
		wait(.1)
	end

	wait(2)
	magicSound:Stop()
	slushy:Stop()
	wait(2)
	for i = 1, 10 do
		fog[i].Velocity = Vector3.new(0,0,0)
		newBF[i].force = Vector3.new(0, 196*fog[i]:GetMass(), 0)
		wait (.1)
	end
	wait(6)
	for i = 1, 10 do 
		fog[i].Parent = nil
		wait(.1)
	end
	print("ended activation")
	Tool.Enabled = true
end

function onEquipped()
	print("started equipping")
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35895627"
		-- 35895627 is cauldronFire
		-- 35895661 is cauldronWater
		magicSound.Name = "MagicSound"
	end
	slushy = Tool.Handle:FindFirstChild("SlushySound")
	if slushy == nil then 
		slushy = Instance.new("Sound")
		slushy.Parent = Tool.Handle
		slushy.Volume = 1
		slushy.SoundId = "http://www.roblox.com/asset/?id=35895661"
		slushy.Name = "SlushySound"
	end
	print("finished equipping")
end

function onUnequip()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	slushy = Tool.Handle:FindFirstChild("SlushySound")
	if magicSound ~= nil then 
		magicSound:Stop()
		magicSound.Parent = nil 
	end
	if slushy ~= nil then
		slushy:Stop()
		slushy.Parent = nil 
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequip)

