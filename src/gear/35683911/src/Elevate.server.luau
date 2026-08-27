local Tool = script.Parent
local torso = nil
local sticky = false
local welds = {}
local touched = false
local coolDown = 0
--local origLookVector = nil
local debris = game:GetService("Debris")
--[[
local stickyLeftFire = Instance.new("Fire")
stickyLeftFire.Color = Color3.new(0,102/255,1)
stickyLeftFire.SecondaryColor = Color3.new(0,0,102/255)
stickyLeftFire.Heat = -3
stickyLeftFire.Size = 3

local stickyRightFire = stickyLeftFire:clone()

local bodyForce = Instance.new("BodyForce")

local bodyPos = Instance.new("BodyPosition")
bodyPos.P = 5000000
bodyPos.D = 5000
bodyPos.maxForce = Vector3.new(bodyPos.P,0,bodyPos.P)

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.P = 5000000
bodyGyro.D = 5000
bodyGyro.maxTorque = Vector3.new(bodyGyro.P,bodyGyro.P,bodyGyro.P)]]

function onEquipped()
	torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
end

function onUnequipped()
	--[[bodyGyro.Parent = nil
	bodyForce.Parent = nil
	bodyPos.Parent = nil
	origLookVector = nil
	stickyLeftFire.Parent = nil
	stickyRightFire.Parent = nil]]
	sticky = false
	Tool.Handle.Sparkles.Enabled = false
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

function onActivated()
	if coolDown > 0 then return end

	sticky = not sticky
	if not sticky then
		onUnequipped()
		Tool.Handle.Sparkles.Enabled = false
	else
		Tool.Handle.Sparkles.Enabled = true
	end
end

Tool.Activated:connect(onActivated)
--[[
function getMass()

	local mass = 0
	local parts = torso.Parent:GetChildren()
	for i = 1, #parts do

		if parts[i].className == "Part" then
			mass = mass + parts[i]:GetMass()
		elseif parts[i].className == "Hat" or parts[i].className == "Tool" then
			mass = mass + parts[i].Handle:GetMass()
		end

	end

	return mass

end

function runUpWall()
	while sticky do
		if torso.Position.y > height + torso.Size.y then
			sticky = false
			bodyForce.Parent = nil
			stickyLeftFire.Parent = nil
			stickyRightFire.Parent = nil
			bodyPos.Parent = nil
			bodyGyro.Parent = nil

			local forwardForce = Instance.new("BodyForce")
			forwardForce.force = Vector3.new(origLookVector.x * getMass() * 40, 0, origLookVector.z * getMass() * 40)
			forwardForce.Parent = torso
			wait(0.5)
			forwardForce:remove()
		end
		wait()

	end
end]]

function elevate(elevator)

	while torso.Position.y < height + torso.Size.y and elevator.Parent == game.Workspace do
		wait()
	end

	Tool.Handle.Sparkles.Enabled = false
	-- never made it to the top, so get out of here
	if elevator.Parent ~= game.Workspace then return end

	elevator.Bottom.BodyVelocity.velocity = elevator.Bottom.BodyVelocity.velocity * 0.1

	wait(5)

	for i = 1, #welds do
		welds[i]:remove()
	end

	elevator.Bottom.BodyVelocity:remove()
	elevator.Bottom.Velocity = Vector3.new(math.random(3,4),-20,math.random(-3,-1))
	elevator.Top.Velocity = Vector3.new(0,20,0)
	elevator.BackGlass.Velocity = Vector3.new(elevator.BackGlass.CFrame.lookVector.x * 20,0,elevator.BackGlass.CFrame.lookVector.z * 20)
	elevator.LeftGlass.Velocity = Vector3.new(elevator.LeftGlass.CFrame.lookVector.x * 20,0,elevator.LeftGlass.CFrame.lookVector.z * 20)
	elevator.RightGlass.Velocity = Vector3.new(elevator.RightGlass.CFrame.lookVector.x * 20,0,elevator.RightGlass.CFrame.lookVector.z * 20)

	elevator.fireEmitter.Fire.Enabled = false

end

function weldElevator(elevator)

	local leftGlassWeld = Instance.new("Weld")
	leftGlassWeld.Part0 = elevator.Bottom
	leftGlassWeld.Parent = elevator.Bottom
	leftGlassWeld.Part1 = elevator.LeftGlass
	leftGlassWeld.C0 = CFrame.new(5,5.2,0)
	table.insert(welds,leftGlassWeld)

	local rightGlassWeld = Instance.new("Weld")
	rightGlassWeld.Part0 = elevator.Bottom
	rightGlassWeld.Parent = elevator.Bottom
	rightGlassWeld.Part1 = elevator.RightGlass
	rightGlassWeld.C0 = CFrame.new(-5,5.2,0)
	table.insert(welds,rightGlassWeld)

	local backGlassWeld = Instance.new("Weld")
	backGlassWeld.Part0 = elevator.Bottom
	backGlassWeld.Parent = elevator.Bottom
	backGlassWeld.Part1 = elevator.BackGlass
	backGlassWeld.C0 = CFrame.new(0,5.2,-5)
	backGlassWeld.C1 = CFrame.Angles(0,math.pi/2,0)
	table.insert(welds,backGlassWeld)

	local leftSupportBeamWeld = Instance.new("Weld")
	leftSupportBeamWeld.Part0 = elevator.Bottom
	leftSupportBeamWeld.Parent = elevator.Bottom
	leftSupportBeamWeld.Part1 = elevator.LeftSupportBeam
	leftSupportBeamWeld.C0 = CFrame.new(3.5,5.2,4.5)
	leftSupportBeamWeld.C1 = CFrame.Angles(0,math.pi/2,0)
	table.insert(welds,leftSupportBeamWeld)

	local rightSupportBeamWeld = Instance.new("Weld")
	rightSupportBeamWeld.Part0 = elevator.Bottom
	rightSupportBeamWeld.Parent = elevator.Bottom
	rightSupportBeamWeld.Part1 = elevator.RightSupportBeam
	rightSupportBeamWeld.C0 = CFrame.new(-3.5,5.2,4.5)
	rightSupportBeamWeld.C1 = CFrame.Angles(0,math.pi/2,0)
	table.insert(welds,rightSupportBeamWeld)

	local topWeld = Instance.new("Weld")
	topWeld.Part0 = elevator.Bottom
	topWeld.Parent = elevator.Bottom
	topWeld.Part1 = elevator.Top
	topWeld.C0 = CFrame.new(0,10.8,0)
	table.insert(welds,topWeld)

	local fireEmitter = Instance.new("Part")
	fireEmitter.Name = "fireEmitter"
	fireEmitter.Transparency = 1
	fireEmitter.Parent = elevator
	
	local fireWeld = Instance.new("Weld")
	fireWeld.Part0 = elevator.Bottom
	fireWeld.Parent = elevator.Bottom
	fireWeld.Part1 = elevator.fireEmitter
	fireWeld.C0 = CFrame.new(0,-4,0)

	local fire = Instance.new("Fire")
	fire.Heat = -20
	fire.Size = 12
	fire.Color = Color3.new(1,102/255,1)
	fire.SecondaryColor = Color3.new(102/255,0,102/255)
	fire.Parent = elevator.fireEmitter

end

function onTouched(part)

	if not sticky or touched then return end
	if not part:IsA("MeshPart") and part.Shape ~= Enum.PartType.Block then return end

	touched = true
	sticky = false

	welds = {}

	local oldPos = torso.Position

	--This call will cause a "wait" until the data comes back
	local elevator = game:GetService("InsertService"):LoadAsset(32094048)

	local instances = elevator:GetChildren()
	if #instances == 0 then
		elevator:Remove()
		return nil
	end
	elevator = elevator:FindFirstChild("elevator")
	weldElevator(elevator)

	torso.Parent:MoveTo(torso.Position - (torso.CFrame.lookVector.unit * 7))

	elevator.Parent = game.Workspace
	elevator:MoveTo(torso.Position)

	elevator.Bottom.BodyGyro.cframe = torso.CFrame * CFrame.Angles(0,math.pi,0)
	elevator.Bottom.BodyVelocity.velocity = Vector3.new(1 * torso.CFrame.lookVector.x,8,1 * torso.CFrame.lookVector.z)

	local weld = Instance.new("Weld")
	weld.Part0 = elevator.Bottom
	weld.Parent = elevator.Bottom
	weld.Part1 = torso.Parent:FindFirstChild("Right Leg") or torso.Parent:FindFirstChild("RightUpperLeg")
	weld.C0 = CFrame.new(0,1.7,0)

	height = part.Position.y + part.Size.y/2

	debris:AddItem(weld,1.5)
	debris:AddItem(elevator,20)

	Tool.Handle.Sound:Play()
	elevate(elevator)
	coolDown = 20
	Tool.Handle.Sound:Stop()
	wait(coolDown)
	coolDown = 0

	touched = false
	
--[[
	stickyLeftFire.Parent = torso.Parent:FindFirstChild("Left Leg")
	stickyRightFire.Parent = torso.Parent:FindFirstChild("Right Leg")

	origLookVector = torso.CFrame.lookVector.unit
	origLookVector = Vector3.new(origLookVector.x/math.abs(origLookVector.x + origLookVector.z),0,origLookVector.z/math.abs(origLookVector.x + origLookVector.z))

	bodyGyro.Parent = torso
	bodyGyro.cframe =  torso.CFrame * CFrame.Angles(math.pi/2,0,0)

	bodyForce.force = Vector3.new(0,getMass() * 230,0)
	bodyForce.Parent = torso

	bodyPos.position = torso.Position
	bodyPos.Parent = torso

	runUpWall()]]

end


Tool.Handle.Touched:connect(onTouched)
