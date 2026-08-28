local Tool = script.Parent
local Wand = Tool.Handle

Tool.Enabled = true
local vCharacter


local giggle
local wandAOE = Vector3.new(15.0, 15.0, 15.0)

function onActivated()
	if Tool.Enabled == false then 
		return 
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")

	if myTorso == nil then 
		print("Torso not found")
		return
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end

	giggle = Tool:FindFirstChild("Giggle")
	if giggle then giggle:Play() end

	wait(0.6)
	
	parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - wandAOE, myTorso.Position + wandAOE), vCharacter, 100)

	for i = 1, #parts do 
		tempChar = parts[i].Parent		
		tempHumanoid = tempChar:FindFirstChild("Humanoid")
		if tempHumanoid then 
			clown = tempHumanoid:FindFirstChild("Clowned")
			if clown == nil then 
				newScript = Tool.ClownedScript:Clone()				
				newScript.Parent = tempChar
				newScript.Disabled = false 
				
				clown = Instance.new("StringValue")
				clown.Name = "Clowned"
				clown.Value = "CLOWN"
				clown.Parent = tempHumanoid
				break
			end
		end
	end

	wait(4.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if giggle then giggle:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)