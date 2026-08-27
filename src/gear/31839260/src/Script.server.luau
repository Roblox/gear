local Tool = script.Parent
local humanoid = nil
local Torso = nil
local enabled = false

function onActivated()
	if enabled then
		return
	end

	enabled = true

	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	Torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")

	Tool.GripForward = Vector3.new(1,0,0)
	Tool.GripRight = Vector3.new(0,-1,0)
	Tool.GripUp = Vector3.new(0,0,1)
	Tool.GripPos = Vector3.new(-1,-1.5,0)

	Tool.Handle.Mesh.Scale = Vector3.new(1,1,1)

	local amountInFront = 15
	local lookVector = Torso.CFrame.lookVector
	local denom = math.abs(lookVector.x) + math.abs(lookVector.z)
	local xFactor =  (lookVector.x/denom)
	local zFactor = (lookVector.z/denom)
	local posX = amountInFront * xFactor
	local posZ = amountInFront * zFactor

	local barrel = Tool.Handle:Clone()
	barrel.CanCollide = true
	barrel.Name = "Barrel"
	barrel.Shape = 1
	barrel.formFactor = 1
	barrel.Size = Vector3.new(2,3.6,2)
	barrel.Position = Vector3.new(posX + barrel.Position.x,Torso.Position.y,posZ + barrel.Position.z)
	barrel.CFrame = CFrame.new(barrel.Position,Vector3.new(Torso.Position.x,barrel.Position.y + 10, Torso.Position.z))
	barrel.CFrame = barrel.CFrame * CFrame.Angles(0,0,math.pi/2)

	local sound = Instance.new("Sound")
	sound.SoundId = "http://www.roblox.com/asset/?id=31033396"
	sound.Name = "GameOver"
	sound.Parent = barrel

	local roll = Instance.new("Sound")
	roll.SoundId = "http://www.roblox.com/asset/?id=31036019"
	roll.Name = "Roll"
	roll.Looped = true
	roll.Parent = barrel
	roll:Play()

	wait(0.6)
	Tool.Handle.Transparency = 1
	barrel.Parent = game.Workspace
	barrel.Velocity = Torso.CFrame.lookVector * 80

	local force = Instance.new("BodyForce")
--	force.force = Vector3.new(0,2600,0)
	force.force = Vector3.new(0, barrel:GetMass() * 200, 0)
	force.Parent = barrel

	local script = Tool.BarrelScript:clone()
	script.Parent = barrel
	script.Disabled = false

	wait(0.4)

	Tool.Handle.Transparency = 0
	Tool.Handle.Mesh.Scale = Vector3.new(0.45,0.45,0.45)
	Tool.GripPos = Vector3.new(-0.4, -0.05, 0.11)

	Tool.GripUp = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(0,0,1)
	Tool.GripForward = Vector3.new(1,0,0)

	Tool.GripRight = Vector3.new(0,0,1)
	Tool.GripUp = Vector3.new(0,1,0)
	Tool.GripForward = Vector3.new(1,0,0)

	enabled = false

end


function onEquipped()
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	Torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
end

function onUnequipped()
	humanoid = nil
	Torso = nil
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
