local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Tool = script.Parent
local Bow = Tool.Handle

local vCharacter
local quiver
local quiverWeld
local arrows = {}
local quiverArrow

local PlayShoot

local LAUNCH_SPEED = 90
local SPREAD_IN_STUDS = 20

local debris = game:GetService("Debris")

Tool.Enabled = true 

arrow = Instance.new("Part")
arrow.FormFactor = 'Custom'
arrow.Shape = "Block"
arrow.Size = Vector3.new(0.5, 0.5, 3.0)
arrow.CanCollide = false 
arrow.Name = "Arrow"


arrowMesh = Instance.new("SpecialMesh")
arrowMesh.MeshId = "http://www.roblox.com/asset/?id=99168062"
arrowMesh.TextureId = "http://www.roblox.com/asset/?id=99168250"
arrowMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
arrowMesh.Parent = arrow

local arrowWeld

function shoot(arrow, direction)
	vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 
		return
	end
	
	local BowSound = Bow:FindFirstChild('BowSound')
	if BowSound then
		BowSound:Play()
	end
	local ArrowSound = Bow:FindFirstChild('ArrowSound')
	if ArrowSound then
		local cloneSound = ArrowSound:Clone()
		cloneSound.Parent = arrow
	end
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	
	local spawnPos = vCharacter.Torso.Position
	spawnPos = spawnPos + direction.unit * 7.0
	
	arrow.CFrame = CFrame.new(spawnPos, spawnPos + direction) -- * CFrame.Angles(0, math.pi, 0)

	local arrowFloat = Instance.new("BodyForce")
	arrowFloat.force =  Vector3.new(0.0, arrow:GetMass() * 196.1, 0.0)
	arrowFloat.Parent = arrow

	arrow.Velocity = direction.unit * LAUNCH_SPEED
	arrow.RotVelocity = Vector3.new(0.0, 0.0, 0.0)
	arrow.Name ="arrow"
	arrow.Parent = game.Workspace
	arrow.CanCollide =  false	

	local arrowTrail = Instance.new('Smoke')
	arrowTrail.RiseVelocity = 0
	arrowTrail.Size = 0.25
	arrowTrail.Parent = arrow

	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Name = "creator"
	creatorTag.Value = vPlayer
	creatorTag.Parent = arrow

	local newScript = Tool:FindFirstChild("OnTouchScript"):Clone()
	newScript.Disabled = false
	newScript.Parent = arrow

	debris:AddItem(arrow, 5)
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end		

	Tool.Enabled = false

	if PlayShoot then
		PlayShoot.Value = not PlayShoot.Value
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if torso == nil then 
		return
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	
	wait(0.3)
	if quiverArrow then
		quiverArrow.Transparency = 1
	end

	local handArrow
	local rightArm = vCharacter:FindFirstChild('Right Arm')
	if rightArm then
		handArrow = arrow:Clone()
		handArrow.Parent = rightArm

		local handWeld = Instance.new('Weld')
		handWeld.Name = 'HandWeld'
		handWeld.Part0 = rightArm
		handWeld.Part1 = handArrow
		--handWeld.C0 = CFrame.new(0,0,2)--CFrame.new(0.95,0,2)
		handWeld.C1 = (CFrame.Angles(0,math.pi/3,0) + Vector3.new(0.95, 0, 2)) * CFrame.Angles(math.pi/2, 0, 0)
		handWeld.Parent = handArrow
	end


	wait(0.5)
	if handArrow then
		handArrow:Destroy()
	end
	target = myHumanoid.TargetPoint 
	direction = (target - vCharacter.Torso.Position).unit
	
	local theta = math.atan((SPREAD_IN_STUDS / 2) / math.min(50, (target - vCharacter.Torso.Position).magnitude))
	print("atan(" .. SPREAD_IN_STUDS / 2 .. "/" .. (target - vCharacter.Torso.Position).magnitude .. ") =" ..  theta)
	theta = math.min(theta, math.pi/3)
	for i = -theta, theta, theta/3 do
		shoot(arrow:Clone(), CFrame.Angles(0, i, 0) * direction)
	end

	wait(1.7)
	if quiverArrow then
		quiverArrow.Transparency = 0
	end	
	Tool.Enabled = true
end

function onEquipped()
	print("On equip")
	vCharacter = Tool.Parent 
	torso = vCharacter:FindFirstChild("Torso")
	if torso ~= nil and vCharacter:FindFirstChild("Quiver") == nil then 
		quiver = Instance.new("Part")
		quiver.Name = "Quiver"
		quiver.Shape = "Block"
		quiver.FormFactor = 'Custom'
		quiver.Size = Vector3.new(0.8, 2.6, 0.5)
		quiver.CanCollide = false
		quiver.Parent = vCharacter
		
		quiverMesh = Instance.new("SpecialMesh")
		quiverMesh.MeshId = "http://www.roblox.com/asset/?id=99175197"
		quiverMesh.TextureId = "http://www.roblox.com/asset/?id=99175144"
		quiverMesh.Scale = Vector3.new(1.2,1.2,1.2)		
		quiverMesh.Parent = quiver

		quiverWeld = Instance.new("Weld")
		quiverWeld.Name = "QuiverHolder"
		quiverWeld.Part0 = torso
		quiverWeld.Part1 = quiver
		quiverWeld.C1 = CFrame.new(Vector3.new(-0.15, -0.2, -0.65)) * CFrame.Angles(0,0,math.pi / 8) 
		quiverWeld.Parent = torso

		quiverArrow = arrow:Clone()
		quiverArrow.Name = 'QuiverArrow'
		quiverArrow.Parent = vCharacter
		
		local quiverArrowWeld = Instance.new('Weld')
		quiverArrowWeld.Name = 'ArrowHolder'
		quiverArrowWeld.Part0 = quiver
		quiverArrowWeld.Part1 = quiverArrow
		quiverArrowWeld.C1 = CFrame.new(-0.15, 0, -0.4) * CFrame.Angles(math.pi/2, 0, 0)
		quiverArrowWeld.Parent = quiver

		rightArm = vCharacter:FindFirstChild("Right Arm")
		leftArm = vCharacter:FindFirstChild("Left Arm")
		---[[
		if rightArm then rightGrip = rightArm:FindFirstChild("RightGrip") end
		if rightGrip then 
			rightGrip.Parent = leftArm
			rightGrip.Name = "LeftGrip"
			rightGrip.Part0 = leftArm
			rightGrip.Part1 = Bow
		end
		--]]
	end
	PlayShoot = WaitForChild(Tool, 'PlayShoot')
end

function onUnequipped()
	if vCharacter then
		torso = vCharacter:FindFirstChild("Torso")
	end
		
	if torso then
		quiver = vCharacter:FindFirstChild("Quiver")
		quiverWeld = torso:FindFirstChild("QuiverHolder")
	end
	if quiverArrow then quiverArrow:Destroy() end
	if quiver then quiver:Destroy() end
	if quiverWeld then quiverWeld:Destroy() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
