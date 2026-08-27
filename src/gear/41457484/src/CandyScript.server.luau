-- 41410287 - crunch
 -- 41410408 - mmm1 
 -- 41410429 - mmm2
 -- (phone sounds):
 -- 41440521 - click
 -- 41440567 - beep
 -- 41440601 - startupSound

--  41450987 - latkeCake
--  41451052 - latkePlate


local Tool = script.Parent

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
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=41450987"
	for i = 1, 20 do
		Tool.GripPos = (startVect*(20-i) + endVect*(i))/20
		wait(.05)
	end

	crunchSound = Tool.Handle:FindFirstChild("CrunchSound")
	if crunchSound == nil then Tool.Enabled = true return end
	crunchSound:Play()

	wait(1)

 -- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then Tool.Enabled = true return end
	magicSound:Play()

	selector = math.random(0,1)
	if selector == 0 then magicSound.SoundId = "http://www.roblox.com/asset/?id=41410408" -- mmm1
		else magicSound.SoundId = "http://www.roblox.com/asset/?id=41410429" -- mmm2
	end


-- rest of script
	Tool.Handle.Transparency = 1	
	Tool.GripPos = Vector3.new(-0.7, 0.05, 0)

	wait(2)
	
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=41385697"

	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end


function onEquipped()
	if Tool.Enabled then Tool.Handle.Transparency = 0 Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=41385697" end
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		selector = math.random(0,1)
		if selector == 0 then magicSound.SoundId = "http://www.roblox.com/asset/?id=41410408" -- mmm1
			else magicSound.SoundId = "http://www.roblox.com/asset/?id=41410429" -- mmm2
		end
		magicSound.Name = "MagicSound"
	end

	crunchSound = Tool.Handle:FindFirstChild("CrunchSound")
	if crunchSound == nil then
		crunchSound = Instance.new("Sound")
		crunchSound.Volume = 1
		crunchSound.SoundId = "http://www.roblox.com/asset/?id=41410287"
		crunchSound.Name = "CrunchSound"
		crunchSound.Parent = Tool.Handle
	end
end


function onUnequipped()
	local Handle = Tool:FindFirstChild("Handle")
	if Handle then
		magicSound = Tool.Handle:FindFirstChild("MagicSound")
		if magicSound ~= nil then
			magicSound:Stop()
			magicSound.Parent = nil
		end
	
		crunchSound = Tool.Handle:FindFirstChild("CrunchSound")
		if crunchSound ~= nil then
			crunchSound:Stop()
			crunchSound.Parent = nil
		end
	end
	Tool.GripPos = Vector3.new(-0.7, 0.05, 0)
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
