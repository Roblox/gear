local Tool = script.Parent
local Staff = Tool.Handle

Tool.Enabled = true

local staffAOE = Vector3.new(15, 15, 15)

bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.P = 10000
bodyVelocity.maxForce = Vector3.new(bodyVelocity.P, bodyVelocity.P, bodyVelocity.P)
bodyVelocity.Name = "BV"

bodyForce = Instance.new("BodyForce")
bodyForce.Name = "BF"

bodyAngularVelocity = Instance.new("BodyAngularVelocity")
bodyAngularVelocity.angularvelocity = Vector3.new(10.0, 10.0, 10.0)
bodyAngularVelocity.P = 10000
bodyAngularVelocity.Name =  "BAV"

local tempBV
local tempHumanoid
local myHumanoid
local myTorso

local scifiLiftSound
local scifiBlastSound

local spatialUniqueness = {}
-- Now the script is unique!

local forceField = Instance.new("Part")
forceField.Name = "Field"
forceField.Size = Vector3.new(1, 1, 1)
forceField.Transparency = 0.8
--forceField.CanCollide = true

local fieldMesh = Instance.new("SpecialMesh")
fieldMesh.MeshType = "FileMesh"
fieldMesh.Name = "Mesh"
fieldMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
fieldMesh.TextureId = "http://www.roblox.com/asset/?id=48536588"
fieldMesh.Scale = Vector3.new(0.2, 0.2, 0.2)
fieldMesh.Parent = forceField


function onActivated()
	
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent 

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		print("Humanoid not found")
		return
	end

	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myTorso == nil then 
		print("Torso not found")
		return
	end

	if myTorso:FindFirstChild("BV") ~= nil then 
		print("Meet the force")
		return
	end

	myHead = vCharacter:FindFirstChild("Head")
	if myHead == nil then
		print("Head not found")
		return
	end

	scifiLiftSound = Tool:FindFirstChild("ScifiLiftSound")
	scifiBlastSound = Tool:FindFirstChild("ScifiBlastSound")
	
--	myHumanoid.Jump = true
--	myTorso.Anchored = true	

	if scifiLiftSound then scifiLiftSound:Play() end
	
	parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - staffAOE, myTorso.Position + staffAOE), vCharacter, 84)
	for i = 1, #parts do		
		tempHumanoid = parts[i].Parent:FindFirstChild("Humanoid")
		if parts[i].Anchored == false and tempHumanoid == nil then 
			tempBV = bodyVelocity:Clone()
			tempBV.Parent = parts[i]
			tempBV.velocity = Vector3.new(0.0, 7.0, 0.0)		
			fieldClone = forceField:Clone()
			fieldClone.Parent = parts[i]
	
			newWeld = Instance.new("Weld")
			newWeld.Part0 = fieldClone
			newWeld.Part1 = parts[i]
			newWeld.Name = "FieldWeld"
			newWeld.C1 = CFrame.new(Vector3.new(0, 0, 0))
			newWeld.Parent = parts[i]

		else
			tempBV = bodyVelocity:Clone()
			tempBV.velocity = Vector3.new(0.0, 10.0, 0.0)			
			torso = parts[i].Parent:FindFirstChild("Torso") or parts[i].Parent:FindFirstChild("UpperTorso")
			if torso and torso:FindFirstChild("BV") == nil then
				tempBV.Parent = torso
				fieldClone = forceField:Clone()
				fieldClone.Parent = torso		

				newWeld = Instance.new("Weld")
				newWeld.Part0 = fieldClone
				newWeld.Part1 = torso
				newWeld.Name = "FieldWeld"
				newWeld.C1 = CFrame.new(Vector3.new(0, 0, 0))
				newWeld.Parent = torso
			end
		end
	end

	wait(1.7)
--	myHumanoid.Jump = true


	if scifiBlastSound then scifiBlastSound:Play() end
	for i = 1, #parts do
		tempHumanoid = parts[i].Parent:FindFirstChild("Humanoid")
		if parts[i].Anchored == false and tempHumanoid == nil then 
			BF = bodyForce:Clone()
			BAV = bodyAngularVelocity:Clone()
			BF.force = Vector3.new(parts[i].Position.X - myTorso.Position.X, 0.0, parts[i].Position.Z - myTorso.Position.Z) * 100.0
			BF.Parent = parts[i]
			BAV.Parent = parts[i]
		else 
			BF = bodyForce:Clone()
			BAV = bodyAngularVelocity:Clone()					
			torso = parts[i].Parent:FindFirstChild("Torso") or parts[i].Parent:FindFirstChild("UpperTorso")
			if torso and torso:FindFirstChild("BF") == nil then 
				BF.force = Vector3.new(torso.Position.X - myTorso.Position.X, 0.0, torso.Position.Z - myTorso.Position.Z) * 500.0
				BF.Parent = torso
				BAV.Parent = torso					
				if tempHumanoid and tempHumanoid.Health > 0 then					
					tempHumanoid:TakeDamage(50)					
				end
			end	
			
			if tempHumanoid then
				tempHumanoid:ChangeState(Enum.HumanoidStateType.FallingDown)	
			end
		end			
	end

	wait(0.5)
	if myTorso.Anchored then myHumanoid.Jump = true end
	
	for i = 1, #parts do 
		tempHumanoid = parts[i].Parent:FindFirstChild("Humanoid")
		BV = parts[i]:FindFirstChild("BV")
		BAV = parts[i]:FindFirstChild("BAV")
		field = parts[i]:FindFirstChild("Field")
		weld = parts[i]:FindFirstChild("FieldWeld")
		if BV ~= nil then 
			BV:Remove()
		end			
		if BAV ~= nil then 
			BAV:Remove()
		end		
		if field ~= nil then field:Remove() end
		if weld ~= nil then weld:Remove() end
	end

	wait(0.5)

	for i = 1, #parts do 
		BF = parts[i]:FindFirstChild("BF")
		if BF ~= nil then 
			BF:Remove()
		end
	end		

	wait(1)
	myTorso.Anchored = false	
	Tool.Enabled = true
	
end

function onEquipped()
	wait(1)
end

function onUnequipped()
	wait(1.5)	
	
	if scifiLiftSound then scifiLiftSound:Stop() end
	if scifiBlastSound then scifiBlastSound:Stop() end
	if myTorso then myTorso.Anchored = false end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)