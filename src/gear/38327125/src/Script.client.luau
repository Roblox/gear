local Tool = script.Parent

local newProjectile = nil
local oldSubject = nil
local oldCamType = nil

Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
      Tool.Enabled = false

	vCharacter = Tool.Parent
	humanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid == nil then Tool.Enabled = true return end
	if vCharacter.Name == "BackPack" then Tool.Enabled = true return end

 -- play sounds
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then return end
	magicSound:Play()

-- rest of script
	-- fire an invisible part :)
	newProjectile = Instance.new("Part")
	newProjectile.CanCollide = false
	newProjectile.Size = Vector3.new(0,0,0)
	newProjectile.Position = vCharacter.Head.Position
	--make it float 
	newBodyForce = Instance.new("BodyForce")
	newBodyForce.force = Vector3.new(0, 196.1*newProjectile:GetMass(), 0)
	newBodyForce.Parent = newProjectile

	newProjectile.Transparency = 1
	newProjectile.Parent = game.Workspace

-- play other sound
	magicSound2 = Tool.Handle:FindFirstChild("MagicSound2")
	if magicSound2 ~= nil then 
		magicSound3 = magicSound2:Clone()
		magicSound3.Parent = newProjectile
		magicSound3:Play()
	end

	cam = game.Workspace.CurrentCamera
	if cam then
		print("Found Camera")
		oldSubject = cam.CameraSubject
		oldCamType = cam.CameraType		
		cam.CameraSubject = newProjectile
		cam.CameraType = "Track"
	else
		print("Camera not found")
	end
	-- fire the projectile
	newProjectile.Velocity = (humanoid.TargetPoint - vCharacter.Head.Position).unit * 50
	game:GetService("Debris"):AddItem(newProjectile, 9) --Fix implemented by Luckymaxer
	wait(9)
	magicSound2 = newProjectile:FindFirstChild("MagicSound2")
	if magicSound2 ~= nil then
		magicSound2:Stop()
	end
	if oldSubject ~= nil then cam.CameraSubject = oldSubject end
	if oldCamType ~= nil then cam.CameraType = oldCamType end
	newProjectile.Parent = nil
	Tool.Enabled = true
end

function onEquipped()
	--oldSubject = nil
	--oldCamType = nil
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Tool.Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=35971304" --35971304 is newtnoise, 35886425 is flynoise
		magicSound.Name = "MagicSound"
	end

	magicSound2 = Tool.Handle:FindFirstChild("MagicSound2")
	if magicSound2 == nil then
		magicSound2 = Instance.new("Sound")
		magicSound2.Parent = Tool.Handle
		magicSound2.Volume = 1
		magicSound2.Looped = true
		magicSound2.SoundId = "http://www.roblox.com/asset/?id=35886425" --35971304 is newtnoise, 35886425 is flynoise
		magicSound2.Name = "MagicSound2"
	end
end


function onUnequipped()
	cam = game.Workspace.CurrentCamera
	if cam then
		if oldSubject ~= nil then cam.CameraSubject = oldSubject end
		if oldCamType ~= nil then cam.CameraType = oldCamType end
	end
	magicSound = Tool.Handle:FindFirstChild("MagicSound")
	if magicSound ~= nil then
		magicSound:Stop()
		magicSound.Parent = nil
	end
	magicSound2 = Tool.Handle:FindFirstChild("MagicSound2")
	if magicSound2 ~= nil then
		magicSound2:Stop()
		magicSound2.Parent = nil
	end
	if newProjectile ~= nil then
		magicSound2 = newProjectile:FindFirstChild("MagicSound2")
		if magicSound2 ~= nil then
			magicSound2:Stop()
			magicSound2.Parent = nil
		end
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
