local Tool = script.Parent
local humanoid = nil
local mouseDown = nil
local anim = nil

function onEquippedLocal(mouse)
	Tool.Handle.Sound:Stop()
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	mouseDown = mouse.Button1Down:connect(onActivated)
	anim = humanoid:LoadAnimation(Tool.launchhand)
end
Tool.Equipped:connect(onEquippedLocal)


function onUnequippedLocal()
	Tool.Handle.Sound:Stop()
	humanoid = nil
	mouseDown:disconnect()
	anim:Stop()
	anim:remove()
	anim = nil
end
Tool.Unequipped:connect(onUnequippedLocal)


function fire(lookAt)

	anim:Play()
	Tool.Handle.Sound:Play()

	local hand = Instance.new("Part")
	hand.Name = "EvilHand"
	hand.BrickColor = BrickColor.new("Really black")
	hand.formFactor = 0
	hand.Size = Vector3.new(4,4,2)
	
	local smoke = Instance.new("Smoke")
	smoke.Color = Color3.new(0,0,0)
	smoke.Parent = hand
	smoke.RiseVelocity = 10
	smoke.Enabled = false

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = "http://www.roblox.com/asset/?id=32054761"
	mesh.Parent = hand
	local torso = humanoid.Parent:FindFirstChild("Torso")
	hand.Position = Vector3.new(torso.Position.x + (lookAt.x * 10),torso.Position.y + 3,torso.Position.z + (lookAt.z * 10))
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.cframe = CFrame.new(hand.Position, Vector3.new(hand.Position.x + (lookAt.x * 1000),hand.Position.y + 1000,hand.Position.z + (lookAt.z * 1000)))
	bodyGyro.cframe = bodyGyro.cframe * CFrame.Angles(math.pi/2,math.pi,0)
	bodyGyro.P = 10000
	bodyGyro.D = 1000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P,bodyGyro.P,bodyGyro.P)
	bodyGyro.Parent = hand

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,6100,0)
	force.Parent = hand

	Tool.Player.Value = Tool.Parent
	local PosVal = Tool.Player:clone()
	PosVal.Parent = hand

	local script = Tool.ReturnScript:clone()
	script.Parent = hand
	script.Disabled = false

	hand.Parent = game.Workspace
	hand.Velocity = lookAt * 50

	wait(0.03)
	smoke.Enabled = true
end

function staffOut()
	Tool.GripPos = Vector3.new(0,-0.5,0)
	Tool.GripForward = Vector3.new(0,0.707,0.707)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,-0.707,0.707)
end


function staffUp()
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripPos = Vector3.new(0.25,0,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

local reload = 12
local enabled = false
function onActivated()

	if enabled then return end
	enabled = true

	local head = Tool.Parent:FindFirstChild("Head")
	if head and humanoid then
		local lookAt = (humanoid.TargetPoint - head.Position).unit
		staffOut()
		fire(lookAt)
		wait(0.9)
		staffUp()
	end

	wait(reload)
	enabled = false

end

Tool.Activated:connect(onActivated)

