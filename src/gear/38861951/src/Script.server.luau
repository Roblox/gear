local Tool = script.Parent

Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
      Tool.Enabled = false

	vCharacter = Tool.Parent
	humanoid = vCharacter:FindFirstChild("Humanoid")
	local torso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if humanoid == nil then Tool.Enabled = true return end
	if vCharacter.Name == "BackPack" then Tool.Enabled = true return end

 -- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then return end
	magicSound:Play()

-- rest of script
	Tool.Handle.Transparency = 1
	newBV = Instance.new("BodyVelocity")
	newBV.velocity = 40*vCharacter.HumanoidRootPart.CFrame:vectorToWorldSpace(Vector3.new(0,0,-1)).unit
	newBV.maxForce = Vector3.new(100000, 0, 100000)
	newBV.Parent = torso

	newFire = Instance.new("Fire")
	newFire.Color = Color3.new(0,1,0)
	newFire.SecondaryColor = Color3.new(1,1,0)
	newFire.Parent = vCharacter.HumanoidRootPart

	for i = 0,9 do
		humanoid.Jump = true
		newBV.velocity = 40*vCharacter.HumanoidRootPart.CFrame:vectorToWorldSpace(Vector3.new(0,0,-1)).unit
		wait(.5)
	end

	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then magicSound:Play() end

	for i = 0,9 do
		humanoid.Jump = true
		newBV.velocity = 40*vCharacter.HumanoidRootPart.CFrame:vectorToWorldSpace(Vector3.new(0,0,-1)).unit
		wait(.5)
	end

	newFire.Parent = nil
	newBV.Parent = nil

	Tool.Handle.Transparency = 0

	Tool.Enabled = true
end

function onEquipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		--magicSound.SoundId = "http://www.roblox.com/asset/?id=35571070"
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35895627" --35895627, --35895661, --10722059
		magicSound.Name = "MagicSound"
	end
end


function onUnequipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then
		magicSound:Stop()
		magicSound.Parent = nil
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
