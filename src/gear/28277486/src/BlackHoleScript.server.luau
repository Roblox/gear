local Tool = script.Parent
local enabled = true
local reload = 15
local detonateTime = 10
local radius = 50
local debris = game:GetService("Debris")
local bomb = nil
local children = {}
local humanoid = nil
local sphereOut  = nil

function onActivated()

	if not enabled  then
		return
	end

	enabled = false

	print("clicked")

	local t = Tool.Parent:FindFirstChild("Torso",false) or Tool.Parent:FindFirstChild("UpperTorso", false)

	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - Tool.Parent.Head.Position).unit

	dropBomb(t)

	bombEffect()

	blackHole()

	wait(reload)

	Tool.Handle.Transparency = 0

	enabled = true

end

function bombEffect()

	sphereOut = Instance.new("Part")
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType =  3
	mesh.Parent = sphereOut
	sphereOut.Material = Enum.Material.Foil
	sphereOut.BottomSurface = 0
	sphereOut.TopSurface = 0
	sphereOut.BackSurface = 0
	sphereOut.FrontSurface = 0
	sphereOut.LeftSurface = 0
	sphereOut.RightSurface = 0
	sphereOut.Size = Vector3.new(0,0,0)
	sphereOut.CanCollide = false
	sphereOut.Position = bomb.Position
	sphereOut.Anchored = true
	sphereOut.Transparency = 0.5
	sphereOut.BrickColor = BrickColor.new(1,1,1)
	sphereOut.Parent = game.Workspace

	local scaleSpeed = 2
	local count = 0
	while count < 5 do
		wait()
		sphereOut.Position = bomb.Position
		mesh.Scale = Vector3.new(mesh.Scale.x + scaleSpeed,mesh.Scale.y + scaleSpeed,mesh.Scale.z + scaleSpeed)
		bomb.smoke.Size = bomb.smoke.Size + scaleSpeed
		if mesh.Scale.x > radius * 2 then
			count = count + 1
			if count ~= 5 then
				mesh.Scale = Vector3.new(1, 1, 1)
				bomb.smoke.Size = 0
				sphereOut.BrickColor = BrickColor.new(1,1 - (count/4),1 - (count/4))
				bomb.smoke.Color = Color3.new(1,1 - (count/4),1 - (count/4))
			end
		end
	end

	debris:AddItem(sphereOut,10)

end

function dropBomb(t)

	bomb = Tool.Handle:clone()
	Tool.Handle.Transparency = 1
	bomb.Name = "BlackHoleGenerator"
	bomb.CanCollide = true
	local unitVector =  t.CFrame.lookVector.unit
	local addX = unitVector.x / (math.abs(unitVector.x) + math.abs(unitVector.z))
	addX = addX * 4
	local addZ = unitVector.z / (math.abs(unitVector.x) + math.abs(unitVector.z))
	addZ = addZ * 4
	bomb.Position = Vector3.new(t.Position.x + addX, t.Position.y, t.Position.z + addZ)
	bomb.Parent = game.Workspace

	local sparkles = Instance.new("Sparkles")
	sparkles.Parent = bomb
	sparkles.Color = Color3.new(50,0,0)

	local smoke = Instance.new("Smoke")
	smoke.Name = "smoke"
	smoke.Size = 0
	smoke.Color = Color3.new(1,1,1)
	smoke.Parent = bomb
	
	bomb.TickTock:Play()

	debris:AddItem(bomb, 18)

end

function blackHole()

	children = {}
	recursiveGetChildren(game.Workspace)

	bringPartsIn()

	wait(9)
	local GeneratingHole = bomb:FindFirstChild("GeneratingHole")
	if GeneratingHole then
		bomb.GeneratingHole:Stop()
	end

end

function bringPartsIn()

	local bodyPos = Instance.new("BodyPosition")
	bomb.Anchored = true
	bodyPos.position = bomb.Position
	
	bomb.TickTock:Stop()
	bomb.GeneratingHole:Play()

	for i = 1, #children do

		if (children[i].className == "Part") and (children[i].Anchored == false) and ((children[i].Position - bomb.Position).magnitude < radius) then
			local force = bodyPos:clone()
			force.P = children[i]:GetMass() * 2000
			force.maxForce = Vector3.new(force.P, force.P, force.P)
			force.D = force.P *2
			force.Parent  = children[i]
			debris:AddItem(force, 10)
		end

	end

end

function recursiveGetChildren(parent)

	local kids = parent:GetChildren()

	if kids ~= nil then
		for i =1, #kids do
			
			table.insert(children,kids[i])
			recursiveGetChildren(kids[i])

		end
	end

end

function onEquipped()

	if Tool.Handle.EquipSound.IsPlaying == false then
		Tool.Handle.EquipSound:Play()
	end

end

function onUnequipped()

	Tool.Handle.EquipSound:Stop()

end


Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)

