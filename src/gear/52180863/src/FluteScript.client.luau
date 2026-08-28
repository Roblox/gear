-- FLUTE UMG --

local Tool = script.Parent
local Flute = Tool.Handle

local vCharacter

local fluteSound
local fluteAnim

Tool.Enabled = true 

fluteAOE = Vector3.new(15, 15, 15)

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false 

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")

	if myHumanoid == nil then 
		return
	end

	if myTorso == nil then 
		return
	end

	fluteSound = Tool:FindFirstChild("FluteSound")
	fluteAnim = myHumanoid:LoadAnimation(Tool.FluteAnim)

	if fluteSound then fluteSound:Play() end
	if fluteAnim then fluteAnim:Play() end 

	Tool.GripForward = Vector3.new(0, -1, 0)
	Tool.GripPos = Vector3.new(-0.5, 0, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(1, 0, 0)

	parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - fluteAOE, myTorso.Position + fluteAOE), vCharacter, 100)
	for i = 1, #parts do 
		tempChar = parts[i].Parent
		tempHumanoid = tempChar:FindFirstChild("Humanoid")
		if tempHumanoid then 
			script = tempChar:FindFirstChild("DanceScript")
			if not script then 
				danceScript = Tool.DanceScript:Clone()
				danceScript.Parent = tempChar
				danceScript.Disabled = false
			end
		end
	end
	
	wait(9.0) 
	
	Tool.GripForward = Vector3.new(0, 0, -1)
	Tool.GripPos = Vector3.new(0, 0, 0.1)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1, 0)
	Tool.Enabled = true

end

function onEquipped()
end

function onUnequipped()	
	if fluteSound then fluteSound:Stop() end
	if fluteAnim then fluteAnim:Stop() end
	
	Tool.GripForward = Vector3.new(0, 0, -1)
	Tool.GripPos = Vector3.new(0, 0, 0.1)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1, 0)
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
