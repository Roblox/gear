local Tool = script.Parent
local Staff = Tool.Handle

local vCharacter 
local numChar = 0

Tool.Enabled = true
local staffSound 

local staffAOE = Vector3.new(20.0, 20.0, 20.0)

local healField = Instance.new("Part")
healField.Name = "Field"
healField.Size = Vector3.new(1, 1, 1)
healField.Transparency = 0.8


local fieldMesh = Instance.new("SpecialMesh")
fieldMesh.MeshType = "FileMesh"
fieldMesh.Name = "Mesh"
fieldMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
fieldMesh.TextureId = "http://www.roblox.com/asset/?id=49457234"
fieldMesh.Scale = Vector3.new(0.2, 0.2, 0.2)
fieldMesh.Parent = healField

function onActivated()

	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")

	if myTorso == nil then 
		return
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then
		return
	end

	staffSound = Tool:FindFirstChild("StaffSound")
	if staffSound then staffSound:Play() end

	parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - staffAOE, myTorso.Position + staffAOE), vCharacter, 100)
	
	for i = 1, #parts do 
		tempChar = parts[i].Parent
		tempHumanoid = tempChar:FindFirstChild("Humanoid")
		if tempHumanoid ~= nil then 
			healing = tempHumanoid:FindFirstChild("Healing")
			if healing == nil then 
				healing = Instance.new("StringValue")
				healing.Name = "Healing"
				healing.Parent = tempHumanoid
				healing.Value = "Healing"
				
				newScript = Tool.LightInsertScript:Clone()
				newScript.Parent = tempChar
				newScript.Disabled = false
				numChar = numChar + 1
	
				field = healField:Clone()
				field.Parent = tempChar.Torso

				fieldWeld = Instance.new("Weld")
				fieldWeld.Part0 = tempChar.Torso
				fieldWeld.Part1 = field
				fieldWeld.Parent = tempChar.Torso				
			end
		end
	end

	charScript = vCharacter:FindFirstChild("CharScript")
	if numChar > 0 and charScript == nil then 

		field = healField:Clone()
		field.Parent = vCharacter	

		fieldWeld = Instance.new("Weld")
		fieldWeld.Part0 = myTorso
		fieldWeld.Part1 = field
		fieldWeld.Parent = myTorso
		fieldWeld.Name = "FieldWeld"

		buff = Instance.new("StringValue")
		buff.Name = "Buff"
		buff.Parent = myHumanoid
		buff.Value = "Buff"	

		newScript = Tool.CharScript:Clone()
		newScript.Parent = vCharacter

		nChar = newScript.NumChar
		nChar.Value = numChar
		newScript.Disabled = false	
	
	end

	wait(8.0)
	Tool.Enabled = true
	numChar = 0
end

function onEquipped()
end

function onUnequipped()
	if staffSound then staffSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
