-- Hold space or tap thrice to jump higher --

Tool = script.Parent
Boots = Tool.Handle

local leftBootClone
local rightBootClone

local bootsActive
local bootWeld

local vCharacter
local connection

Tool.Enabled = true

newBV = Instance.new("BodyVelocity")
newBV.P = 10000
newBV.maxForce = Vector3.new(0.0, newBV.P, 0.0)
newBV.Name = "BootsBV"

function onJump()
	print("Jumping")
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")	
	if bootsActive.Value == 1 then 	
		BV = newBV:Clone()
		BV.velocity = Vector3.new(0.0, 20.0, 0.0)
		BV.Parent = myTorso		
	end
	
	wait(3.0)
	children = myTorso:GetChildren()
	for i = 1, #children do 
		if children[i].Name == "BootsBV" then 
			children[i]:Remove()			
		end 
	end	
end

function onActivated()

	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false

	bootsActive = Tool:FindFirstChild("BootsActive")

	vCharacter = Tool.Parent
	
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == false then 
		print("Humanoid not found")
		return
	end

	myLeftLeg = vCharacter:FindFirstChild("Left Leg")
	myRightLeg = vCharacter:FindFirstChild("Right Leg")
	
	if myLeftLeg == false or myRightLeg == false then 
		print("Legs not found")
		return
	end	

	if bootsActive.Value == 0 then
		
		leftBootClone = Boots:Clone()
		leftBootClone.Name = "Left Boots Clone"
		leftBootClone.Parent = vCharacter
		leftBootClone.Mesh.Scale = Vector3.new(1.0, 1.05, 1.1)

		leftBootWeld = Instance.new("Weld")	
		leftBootWeld.Part0 = myLeftLeg
		leftBootWeld.Part1 = leftBootClone
		leftBootWeld.C1 = CFrame.new(Vector3.new(0.0, -0.37, 0.3))	* CFrame.Angles(math.pi/2, 0.0, 0.0)
		leftBootWeld.Parent = myLeftLeg
		leftBootWeld.Name = "Left Boot Weld"

		rightBootClone = Boots:Clone()
		rightBootClone.Name = "Right Boots Clone"
		rightBootClone.Parent = vCharacter
		rightBootClone.Mesh.Scale = Vector3.new(1.0, 1.05, 1.1)

		rightBootWeld = Instance.new("Weld")	
		rightBootWeld.Part0 = myRightLeg
		rightBootWeld.Part1 = rightBootClone
		rightBootWeld.C1 = CFrame.new(Vector3.new(0.0, -0.37, 0.3))	* CFrame.Angles(math.pi/2, 0.0, 0.0)
		rightBootWeld.Parent = myRightLeg
		rightBootWeld.Name = "Right Boot Weld"	
		bootsActive.Value = 1
		Boots.Transparency = 1.0

		children = vCharacter:GetChildren()
		for i = 1, #children do			
			if children[i].className == "CharacterMesh" and children[i].BodyPart == Enum.BodyPart.LeftLeg then 				
				leftBootClone.Mesh.Scale = Vector3.new(0.85, 0.75, 1.2)
				leftBootWeld.C1 = CFrame.new(Vector3.new(-0.1, -0.27, 0.3))	* CFrame.Angles(math.pi/2, 0.0, 0.0)
			end
			
			if children[i].className == "CharacterMesh" and children[i].BodyPart == Enum.BodyPart.RightLeg then 
				rightBootClone.Mesh.Scale = Vector3.new(0.85, 0.75, 1.2)		
				rightBootWeld.C1 = CFrame.new(Vector3.new(0.1, -0.27, 0.3))	* CFrame.Angles(math.pi/2, 0.0, 0.0)
			end
		end
	end

	if bootsActive.Value == 1 then
		myHumanoid.WalkSpeed = 30
		if connection == nil then connection = myHumanoid.Jumping:connect(onJump) print(connection) end
	end
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	Boots.Transparency = 0.0
	bootsActive = Tool:FindFirstChild("BootsActive")
	bootsActive.Value = 0
	if connection then
		connection:disconnect() 
		connection = nil
	end
	if rightBootClone then rightBootClone:Remove() end
	if leftBootClone then leftBootClone:Remove() end
	if leftBootWeld then leftBootWeld:Remove() end
	if rightBootWeld then rightBootWeld:Remove() end
	if vCharacter then 
		vCharacter:FindFirstChild("Humanoid").WalkSpeed = 16
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
