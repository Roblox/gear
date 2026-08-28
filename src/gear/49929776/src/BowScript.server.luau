local Tool = script.Parent
local Bow = Tool.Handle

local vCharacter
local quiver
local quiverWeld
local arrows = {}

local debris = game:GetService("Debris")

Tool.Enabled = true 

arrow = Instance.new("Part")
arrow.FormFactor = 3
arrow.Shape = "Block"
arrow.Size = Vector3.new(0.5, 3.0, 0.5)
arrow.CanCollide = false 
arrow.Name = "Arrow"


arrowMesh = Instance.new("SpecialMesh")
arrowMesh.MeshId = "http://www.roblox.com/asset/?id=49925357"
arrowMesh.TextureId =  "http://www.roblox.com/asset/?id=49846927"
arrowMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
arrowMesh.Parent = arrow

local arrowWeld

local fireArrow 

function shoot(arrow, direction)
	vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 
		return
	end
	
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	
	local spawnPos = vCharacter.Torso.Position
	spawnPos = spawnPos + direction.unit * 7.0
	
	arrow.CFrame = CFrame.new(spawnPos, spawnPos + direction) * CFrame.Angles(-math.pi/2, math.pi/2, 0)

	local arrowFloat = Instance.new("BodyForce")
	arrowFloat.force =  Vector3.new(0.0, arrow:GetMass() * 196.1, 0.0)
	arrowFloat.Parent = arrow

	arrow.Velocity = direction.unit * 75.0
	arrow.RotVelocity = Vector3.new(0.0, 0.0, 0.0)
	arrow.Name ="arrow"
	arrow.Parent = game.Workspace
	arrow.CanCollide =  false	

	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Name = "creator"
	creatorTag.Value = vPlayer
	creatorTag.Parent = arrow

	local newScript = Tool:FindFirstChild("OnTouchScript"):Clone()
	newScript.Disabled = false
	newScript.Parent = arrow

	fireArrow = Tool:FindFirstChild("FireArrow")
	if fireArrow.Value == 1 then 
		fire = Instance.new("Fire")
		fire.Parent = arrow
	end
	debris:addItem(arrow, 5)
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end		

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if torso == nil then 
		return
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	arrowClone = arrow:Clone()

	wait(0.6)
	target = myHumanoid.TargetPoint 
	direction = (target - vCharacter.Torso.Position).unit
	shoot(arrowClone, direction)
		

	wait(2.0)
		
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
		quiver.FormFactor = 3
		quiver.Size = Vector3.new(1.2, 0.5, 2.0)
		quiver.CanCollide = false
		quiver.Parent = vCharacter
		
		quiverMesh = Instance.new("SpecialMesh")
		quiverMesh.MeshId = "http://www.roblox.com/asset/?id=49848728"
		quiverMesh.TextureId = "http://www.roblox.com/asset/?id=49848743"
		quiverMesh.Scale = Vector3.new(1.2,1.2,1.2)
		quiverMesh.Parent = quiver

		quiverWeld = Instance.new("Weld")
		quiverWeld.Name = "QuiverHolder"
		quiverWeld.Part0 = torso
		quiverWeld.Part1 = quiver
		quiverWeld.C1 = CFrame.new(Vector3.new(0, -0.8, 0.0)) * CFrame.Angles(math.pi/2, math.pi, 0)
		quiverWeld.Parent = torso

		rightArm = vCharacter:FindFirstChild("Right Arm")
		leftArm = vCharacter:FindFirstChild("Left Arm")
		if rightArm then rightGrip = rightArm:FindFirstChild("RightGrip") end
		if rightGrip then 
			rightGrip.Parent = leftArm
			rightGrip.Name = "LeftGrip"
			rightGrip.Part0 = leftArm
			rightGrip.Part1 = Bow
		end

		
		for i = 1, 3 do 	
			local sign = 0
			if i > 1 then if i%2 == 0 then sign = -1 else sign = 1 end end
			arrows[i] = Instance.new("Part")
			arrows[i].Name = "Arrow"
			arrows[i].Shape = "Block"
			arrows[i].FormFactor = 3
			arrows[i].Size = Vector3.new(0.8, 0.1, 0.1)
			arrows[i].CanCollide = false
			arrows[i].Parent = quiver
		
			arrowMesh = Instance.new("SpecialMesh")
			arrowMesh.MeshId = "http://www.roblox.com/asset/?id=49849692"
			arrowMesh.TextureId = "http://www.roblox.com/asset/?id=49846927"
			arrowMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
			arrowMesh.Parent = arrows[i]			

			arrowWeld = Instance.new("Weld")
			arrowWeld.Name = "ArrowHolder"..i
			arrowWeld.Part0 = quiver
			arrowWeld.Part1 = arrows[i]
			arrowWeld.C1 = CFrame.new(Vector3.new(2.5, 0.8, 0)) * CFrame.Angles(math.pi/2, sign * math.pi/20, 0)
			arrowWeld.Parent = quiver
		end
		
	end
end

function onUnequipped()
	if vCharacter then
		torso = vCharacter:FindFirstChild("Torso")
	end
		
	if torso then
		quiver = vCharacter:FindFirstChild("Quiver")
		quiverWeld = torso:FindFirstChild("QuiverHolder")
	end

	if quiver then quiver:Remove() end
	if quiverWeld then quiverWeld:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)