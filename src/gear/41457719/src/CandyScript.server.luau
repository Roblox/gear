-- SOUNDS:
 -- 41410287 - crunch
 -- 41410408 - mmm1 
 -- 41410429 - mmm2
 -- 41410443 - mmm3
 -- 41410464 - yummy
 -- (phone sounds):
 -- 41440521 - click
 -- 41440567 - beep
 -- 41440601 - startupSound

--  41434307 = GoldCoinMesh
--  41434337 = PureChocoMesh



local Tool = script.Parent

Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
      Tool.Enabled = false

	vCharacter = Tool.Parent
	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then Tool.Enabled = true return end
	if vCharacter.Name == "BackPack" then Tool.Enabled = true return end

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=41385678"
	local startVect = Vector3.new(0.3, -0.15, 0)
	local endVect = Vector3.new(1.5, 0.7, -.7)
	for i = 1, 20 do
		Tool.GripPos = (startVect*(20-i) + endVect*(i))/20
		wait(.05)
	end

	

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=41434337"

	crunchSound = Tool.Handle:FindFirstChild("CrunchSound")
	if crunchSound == nil then Tool.Enabled = true return end
	crunchSound:Play()


	wait(1)
	
 -- play sound
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then Tool.Enabled = true return end
	magicSound:Play()


	selector = math.random(0,1)
	if selector == 0 then magicSound.SoundId = "http://www.roblox.com/asset/?id=41410464" -- yummy
		else magicSound.SoundId = "http://www.roblox.com/asset/?id=41410443" -- mmm3
	end


-- rest of script
	wait(1)
	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=41434307"
	Tool.GripPos = Vector3.new(0.3, -0.15, 0)
	Tool.Enabled = true
end

function onEquipped()
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.SoundId = "http://www.roblox.com/asset/?id=41410464"
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		selector = math.random(0,1)
		if selector == 0 then magicSound.SoundId = "http://www.roblox.com/asset/?id=41410464" -- yummy
			else magicSound.SoundId = "http://www.roblox.com/asset/?id=41410443" -- mmm3
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

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=41434307"
	Tool.GripPos = Vector3.new(0.3, -0.15, 0)
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
