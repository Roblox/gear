local Tool = script.Parent;

enabled = true

local debris = game:GetService("Debris")

function fire(v)

	local vCharacter = Tool.Parent
	if vCharacter.Name == "Backpack" then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=33677366"
		PewPew.Parent = Tool.Handle
		PewPew.Volume = 1
	end

	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.Shape = 0
	missile.Elasticity = 0
	missile.formFactor = 0
	missile.Size = Vector3.new(1.5,1.5,1.5)
	missile.Velocity = v * 150
	missile.BrickColor = BrickColor.new("Really black")
	missile.Material = Enum.Material.CorrodedMetal
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Locked = true
	missile.Name = "CannonBall"


	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,300,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	PewPew:Play()

	local forceVal = 85000
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(forceVal,forceVal,forceVal) * -v
	force.Parent = vCharacter.Torso
	debris:AddItem(force,0.5)

end

function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end


function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local reload = 8

	if Tool:FindFirstChild("Part") then
		Tool.Part.Fire.Enabled = true
	end

	local fuseSound = Tool.Handle:FindFirstChild("fuseSound")
	if fuseSound == nil then
		fuseSound = Instance.new("Sound")
		fuseSound.Name = "fuseSound"
		fuseSound.SoundId = "http://www.roblox.com/asset/?id=33677615"
		fuseSound.Parent = Tool.Handle
		fuseSound.Volume = 1
	end
	fuseSound:Play()

	wait(3)
	if Tool:FindFirstChild("Part") then
		Tool.Part.Fire.Enabled = false
	end
	local explosion = Instance.new("Explosion")

	explosion.BlastPressure = 0
	explosion.BlastRadius = 3
	explosion.Position = Tool.Handle.Position + (character.Torso.CFrame.lookVector.unit * 5)
	explosion.Parent = Tool

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit
	fire(lookAt)
	wait(reload)

	enabled = true

end

local equipping = false

function onEquipped()

	if equipping then return end
	equipping = true

	Tool.Handle.EquipSound:play()

	local firePart = Instance.new("Part")
	firePart.Position = Tool.Handle.Position
	firePart.Transparency = 1
	firePart.Locked = true
	firePart.formFactor = 2
	firePart.Size = Vector3.new(1,0.4,1)
	firePart.Parent = Tool

	local firer = Instance.new("Fire")
	firer.Color = Color3.new(1,204/255,102/255)
	firer.Heat = 25
	firer.Size = 2
	firer.Enabled = false
	firer.Parent = firePart

	local weld = Instance.new("Weld")
	weld.Parent = firePart
	weld.Part0 = firePart
	weld.Part1 = Tool.Handle
	weld.C0 = CFrame.new(0,-1,-2)

	wait(0.1)
	equipping = false

end

function onUnequipped()
	if Tool:FindFirstChild("Part") then
		Tool.Part:remove()
	end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
