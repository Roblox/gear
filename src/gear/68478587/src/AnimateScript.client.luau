local Tool = script.Parent 
local Sword = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer 
local rightArm
local leftArm

local holster
local leftSword 

local bladesNotActive = true 

local unfoldAnim 
local swingAnim
local swordWalk
local lungeSlash

Tool.Enabled = true 

local damage = 17

-- To gauge key presses
local lungeTime = 0
local spinTime = 0

-- game service
local r = game:GetService("RunService")

local lastKeyDown = 0
local dashTime = 0
local lastSlash = 0

local newBV = nil

function lungeOnDash(key)
	key = key:lower()
	if key == "w" then 
		t = r.Stepped:wait()
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t
	end
end

function slashIt(hum, torso)
	lungeSlash = hum:LoadAnimation(Tool["LungeSlash"])
	if lungeSlash == nil then Tool.Enabled = true return end
	
	lungeSlash:Play()

	local target = hum.TargetPoint
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1)
	newBV = nil
	if direction.magnitude > .01 then 
		-- make 'em dash forwards too
		direction = direction.unit
		newBV = Instance.new("BodyVelocity")
		newBV.P = 100000
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
		newBV.velocity = direction * 50
		newBV.Parent = torso

		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0))
	end
	
	wait(.5)
	if dashSound then dashSound:Play() end 
	if newBV ~= nil then newBV:remove() end
	wait(.5)
end

function blow(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 		
		tagHumanoid(humanoid, vPlayer)				
		humanoid:TakeDamage(damage)
		wait(1.0)
		untagHumanoid(humanoid)					
	end	
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil and player ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag:Remove()
		end			
	end
end

function reMoveBlade()
	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripPos = Vector3.new(0, 0, -1.3)
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(-1, 0, 0)
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false

	if bladesNotActive then 
		bladesNotActive = false 
		unfoldAnim = myHumanoid:LoadAnimation(Tool:FindFirstChild("UnfoldAnim"))
		if unfoldAnim then unfoldAnim:Play() end 
		wait(0.75)
		while rightArm:FindFirstChild("TorsoGrip") do
			print("Doing it")
			local rightGrip = rightArm.TorsoGrip
			rightGrip.Name = "RightGrip"
			rightGrip.Part0 = rightArm 
			print(rightGrip.Part0)
			--rightGrip.C1 = CFrame.new(0, 0, -1.3, 0, 0, 1, 1, 0, 0, 0, 1, 0)
			reMoveBlade()
			wait()
		end 

		if leftArm:FindFirstChild("LeftGrip") then 
			local leftGrip = leftArm.LeftGrip 
			leftGrip.Part0 = leftArm 
			leftGrip.C1 = CFrame.new(1, 0, -1.70000005, 0, 1, -4.37113883e-008, 1, 0, 0, 0, -4.37113883e-008, -1)
		end 
	else 
		local t = r.Stepped:wait()
		if t - dashTime < 0.2 then 	
			slashIt(myHumanoid, myTorso)
			wait(0.5)
			amAnimating = false	
			wait(1.5)
		else 
			swingAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
			if swingAnim then swingAnim:Play() end 
			wait(1.0)
			amAnimating = false
		end 
	end 
	wait(0.25)
	Tool.Enabled = true
end 

function holdBlade()
	Tool.GripForward = Vector3.new(-0.7431, 0, 0.6691)
	--Tool.GripPos = Vector3.new(0.37, -1.15, -0.6)
	Tool.GripPos = Vector3.new(1.51999974, -1.14999998, -1.60000002)
	Tool.GripRight = Vector3.new(0, -1, 0)
	Tool.GripUp = Vector3.new(0.6691, 0, -0.7431)
	Tool.GripForward = Vector3.new(-0.7431, 0, 0.6691)
end 

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myHead = vCharacter:FindFirstChild("Head")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	local myCF = myTorso.CFrame 
	print(myCF)

	rightArm = vCharacter:FindFirstChild("Right Arm")
	leftArm = vCharacter:FindFirstChild("Left Arm")

	swordWalk = myHumanoid:LoadAnimation(Tool.SwordWalk)
	if swordWalk then swordWalk:Play() end

	if vCharacter:FindFirstChild("Holster") == nil then 
		holster = Instance.new("Part")
		holster.Name = "Holster"
		holster.FormFactor = 3
		holster.Size = Vector3.new(1, 1, 1)	

		local holsterMesh = Instance.new("SpecialMesh")
		holsterMesh.MeshId = "http://www.roblox.com/asset/?id=68254867"
		holsterMesh.TextureId = "http://www.roblox.com/asset/?id=68254909"
		holsterMesh.Scale = Vector3.new(1.1, 1.1, 1.1)
		holsterMesh.Parent = holster 
	
		local holsterGrip = Instance.new("Weld")		
		holsterGrip.Part1 = holster 
		holsterGrip.Part0 = myTorso
		holsterGrip.C1 = CFrame.new(0, 0, 1.2) * CFrame.Angles(math.pi/2, 0, 0)
		holsterGrip.Name = "HolsterGrip"
		holsterGrip.Parent = holster
		holster.Parent = vCharacter 
	end 

	while rightArm:FindFirstChild("RightGrip") == nil do 
		wait()
	end 
	if rightArm:FindFirstChild("RightGrip") then 
		local rightGrip = rightArm.RightGrip
		--rightGrip.Parent = nil
		rightGrip.Part0 = myHead
		rightGrip.Name = "TorsoGrip"
		Tool.GripPos = Vector3.new(0, 0, 0)
		print("Setting CFrame") 
		--rightGrip.C1 = CFrame.new(0.369999945, -1.14999998, -0.600000024, 0, -0.669130445, 0.743144751, -1, 1.9490335e-007, 1.75491749e-007, -2.62268344e-007, -0.743144751, -0.669130445)
		holdBlade() 
		--rightGrip.Parent = rightArm
		rightGrip.C1 = Tool.Grip
		--Tool.Grip = CFrame.new(0.369999945, -1.14999998, -0.600000024, 0, -0.669130445, 0.743144751, -1, 1.9490335e-007, 1.75491749e-007, -2.62268344e-007, -0.743144751, -0.669130445)
		--while rightGrip.C1 ~= CFrame.new(0.369999945, -1.14999998, -0.600000024, 0, -0.669130445, 0.743144751, -1, 1.9490335e-007, 1.75491749e-007, -2.62268344e-007, -0.743144751, -0.669130445) do 
			--rightGrip.C1 = CFrame.new(0.369999945, -1.14999998, -0.600000024, 0, -0.669130445, 0.743144751, -1, 1.9490335e-007, 1.75491749e-007, -2.62268344e-007, -0.743144751, -0.669130445)
			--Tool.Grip = CFrame.new(0.369999945, -1.14999998, -0.600000024, 0, -0.669130445, 0.743144751, -1, 1.9490335e-007, 1.75491749e-007, -2.62268344e-007, -0.743144751, -0.669130445)
			--wait()
		--end

		print("Done Setting CFrame")
		print(myTorso.CFrame)
	end 

	if vCharacter:FindFirstChild("LeftSword") == nil then 
		leftSword = Sword:Clone()
		if leftSword.Mesh then leftSword.Mesh.MeshId = "http://www.roblox.com/asset/?id=68258780" end
		leftSword.Name = "LeftSword"
		leftSword.Parent = vCharacter 		

		local leftGrip = Instance.new("Weld")
		leftGrip.Parent = leftArm 
		leftGrip.Name = "LeftGrip"
		leftGrip.Part0 = myTorso 
		leftGrip.Part1 = leftSword 
		leftGrip.C1 = CFrame.new(-1.03000009, -1.14999986, -1.29999971, 7.07265144e-008, -0.743144751, -0.669130683, 1, 1.93668001e-007, -1.09390982e-007, 2.10882533e-007, -0.669130683, 0.743144751)
		while leftGrip.C1 ~= CFrame.new(-1.03000009, -1.14999986, -1.29999971, 7.07265144e-008, -0.743144751, -0.669130683, 1, 1.93668001e-007, -1.09390982e-007, 2.10882533e-007, -0.669130683, 0.743144751) do 
			leftGrip.C1 = CFrame.new(-1.03000009, -1.14999986, -1.29999971, 7.07265144e-008, -0.743144751, -0.669130683, 1, 1.93668001e-007, -1.09390982e-007, 2.10882533e-007, -0.669130683, 0.743144751)
			wait()
		end 		
		leftSword.Touched:connect(blow)		
	end 

	--[[while myTorso.CFrame ~= myCF do 
		myTorso.CFrame = myCF
		wait()
	end]]

	myHumanoid.WalkSpeed = 19.0
	if mouse then 
		mouse.KeyDown:connect(lungeOnDash) 	
	end 
	Tool.GripPos = Tool.GripPos + Vector3.new(0, 0, 0.1) -- Massive hack, what does this even achieve?
end 

function onUnequipped()
	if holster then holster:Destroy() end 
	if leftSword then leftSword:Destroy() end 
	bladesNotActive = true 
	if swordWalk then swordWalk:Stop() end
	if rightArm then 
		if rightArm:FindFirstChild("TorsoGrip") then 
			rightArm.TorsoGrip:Destroy() 
		end
	end 
	if myHumanoid then myHumanoid.WalkSpeed = 16.0 end 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Sword.Touched:connect(blow)
