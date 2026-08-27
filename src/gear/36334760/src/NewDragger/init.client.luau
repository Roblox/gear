local Tool = script.Parent

game:GetService("ContentProvider"):Preload("rbxasset://icons/freemove_sel.png")

local selectionBox
local currentSelection
local currentSelectionColors = {}
local Mouse = nil

local instances = {}
local maxDragDistance = 60

local connections = {}

function canSelectObject(part)
	return part and not (part.Locked) and (part.Position - script.Parent.Parent.Head.Position).Magnitude < maxDragDistance
end

function findModel(part)
	while part ~= nil do
		if part.className == "Model" then
			return part
		end
		part = part.Parent
	end

	return nil
end

function isPart(object)
	return (object:IsA("Part") or object:IsA("TrussPart") or object:IsA("WedgePart") or object:IsA("VehicleSeat"))
end

function positionPartsAtCFrame3(collection, aCFrame)

	local insertCFrame
	if collection[1]:IsA("Model") then
		-- we assume model has at least one part in it; need to find first part
		i = 1
		while (i < (#collection[1]:GetChildren()) and not isPart(collection[1]:GetChildren()[i])) do
			i = i + 1
		end
		insertCFrame = collection[1]:GetChildren()[i].CFrame

		for i, object in pairs(collection[1]:GetChildren()) do
			if isPart(object) then
				local posPartInWorld = object.Position
				local posPart1InWorld = insertCFrame.p
				local newPosPartInWorld = posPartInWorld - posPart1InWorld + aCFrame.p
	
				local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = object.CFrame:components()
				object.CFrame = CFrame.new(newPosPartInWorld.x, newPosPartInWorld.y, newPosPartInWorld.z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
			end
		end
	else
		collection[1].CFrame = aCFrame
	end

end

function getBoundingBox2(partOrModel)

-- for models, the bounding box is defined as the minimum and maximum individual part bounding boxes
-- relative to the first part's coordinate frame.

	local minVec = Vector3.new(math.huge, math.huge, math.huge)
	local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

	if isPart(partOrModel) then
		minVec = -0.5 * partOrModel.Size
		maxVec = -minVec
	else
		local part1 = partOrModel:GetChildren()[1]
		for i, object in pairs(partOrModel:GetChildren()) do
			if isPart(object) then
				boxMinInWorld = object.CFrame:pointToWorldSpace(-0.5 * object.Size)
				boxMinInPart1 = part1.CFrame:pointToObjectSpace(boxMinInWorld)
				boxMaxInWorld = object.CFrame:pointToWorldSpace(0.5 * object.Size)
				boxMaxInPart1 = part1.CFrame:pointToObjectSpace(boxMaxInWorld)

				local minX = minVec.x
				local minY = minVec.y
				local minZ = minVec.z
				local maxX = maxVec.x
				local maxY = maxVec.y
				local maxZ = maxVec.z
				if boxMinInPart1.x < minVec.x then
					minX = boxMinInPart1.x
				end
				if boxMinInPart1.y < minVec.y then
					minY = boxMinInPart1.y
				end
				if boxMinInPart1.z < minVec.z then
					minZ = boxMinInPart1.z
				end
				if boxMaxInPart1.x < minX then
					minX = boxMaxInPart1.x
				end
				if boxMaxInPart1.y < minY then
					minY = boxMaxInPart1.y
				end
				if boxMaxInPart1.z < minZ then
					minZ = boxMaxInPart1.z
				end

				if boxMinInPart1.x > maxVec.x then
					maxX = boxMinInPart1.x
				end
				if boxMinInPart1.y > maxVec.y then
					maxY = boxMinInPart1.y
				end
				if boxMinInPart1.z > maxVec.z then
					maxZ = boxMinInPart1.z
				end
				if boxMaxInPart1.x > maxX then
					maxX = boxMaxInPart1.x
				end
				if boxMaxInPart1.y > maxY then
					maxY = boxMaxInPart1.y
				end
				if boxMaxInPart1.z > maxZ then
					maxZ = boxMaxInPart1.z
				end

				minVec = Vector3.new(minX, minY, minZ)
				maxVec = Vector3.new(maxX, maxY, maxZ)
			end
		end
	end

	return minVec, maxVec

end

function getTargetPartBoundingBox(targetPart)

	if targetPart.Parent:FindFirstChild("RobloxModel") ~= nil then
		return getBoundingBox2(targetPart.Parent)
	else
		return getBoundingBox2(targetPart)
	end

end

function getMouseTargetCFrame(targetPart)

	if targetPart.Parent:FindFirstChild("RobloxModel") ~= nil then
		return targetPart.Parent:GetChildren()[1].CFrame
	else
		return targetPart.CFrame
	end

end

function getClosestAlignedWorldDirection(aVector3InWorld)

	local xDir = Vector3.new(1,0,0)
	local yDir = Vector3.new(0,1,0)
	local zDir = Vector3.new(0,0,1)
	local xDot = aVector3InWorld.x * xDir.x + aVector3InWorld.y * xDir.y + aVector3InWorld.z * xDir.z
	local yDot = aVector3InWorld.x * yDir.x + aVector3InWorld.y * yDir.y + aVector3InWorld.z * yDir.z
	local zDot = aVector3InWorld.x * zDir.x + aVector3InWorld.y * zDir.y + aVector3InWorld.z * zDir.z

	if math.abs(xDot) > math.abs(yDot) and math.abs(xDot) > math.abs(zDot) then
		if xDot > 0 then
			return 0
		else
			return 3
		end
	elseif math.abs(yDot) > math.abs(xDot) and math.abs(yDot) > math.abs(zDot) then
		if yDot > 0 then
			return 1
		else
			return 4
		end
	else
		if zDot > 0 then
			return 2
		else
			return 5
		end
	end 

end



function findConfigAtMouseTarget(collection)

-- *Critical Assumption* :
--				This function assumes the target CF axes are orthogonal with the target bounding box faces
--				And, it assumes the insert CF axes are orthongonal with the insert bounding box faces
--				Therefore, insertion will not work with angled faces on wedges or other "non-block" parts, nor
--				will it work for parts in a model that are not orthogonally aligned with the model's CF.

	local grid = 4.0
	local admissibleConfig = false
	local targetConfig = CFrame.new(0,0,0)

	local minBB, maxBB = getBoundingBox2(collection[1])
	local diagBB = maxBB - minBB

	local insertCFrame
	if collection[1]:IsA("Model") then
		i = 1
		while (i < (#collection[1]:GetChildren()) and not isPart(collection[1]:GetChildren()[i])) do
			i = i + 1
		end
		insertCFrame = collection[1]:GetChildren()[i].CFrame
	else
		insertCFrame = collection[1].CFrame
	end

	Mouse.TargetFilter = collection[1]

	local targetPart = Mouse.Target

	if targetPart == nil then
		return admissibleConfig, targetConfig
	end

	-- test mouse hit location
	local minBBTarget, maxBBTarget = getTargetPartBoundingBox(targetPart)
	local diagBBTarget = maxBBTarget - minBBTarget
	local targetCFrame = getMouseTargetCFrame(targetPart)
	local hitCFrame = Mouse.Hit
	local mouseHitInWorld = hitCFrame.p
	local mouseHitInTarget = targetCFrame:pointToObjectSpace(mouseHitInWorld)

	-- find which axis of the insertion objects should match with the target surface
	-- this should use targetPart CFrame, not the model CFrame
	local targetVectorInWorld = targetPart.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Mouse.TargetSurface))

	local targetRefPointInTarget
	local clampToSurface

	if getClosestAlignedWorldDirection(targetVectorInWorld) == 0 then
		targetRefPointInTarget = targetCFrame:vectorToObjectSpace(Vector3.new(1, -1, 1))
		insertRefPointInInsert = insertCFrame:vectorToObjectSpace(Vector3.new(-1, -1, 1))
		clampToSurface = Vector3.new(0,1,1)
	elseif getClosestAlignedWorldDirection(targetVectorInWorld) == 3 then
		targetRefPointInTarget = targetCFrame:vectorToObjectSpace(Vector3.new(-1, -1, -1))
		insertRefPointInInsert = insertCFrame:vectorToObjectSpace(Vector3.new(1, -1, -1))
		clampToSurface = Vector3.new(0,1,1)
	elseif getClosestAlignedWorldDirection(targetVectorInWorld) == 1 then
		targetRefPointInTarget = targetCFrame:vectorToObjectSpace(Vector3.new(-1, 1, 1))
		insertRefPointInInsert = insertCFrame:vectorToObjectSpace(Vector3.new(-1, -1, 1))
		clampToSurface = Vector3.new(1,0,1)		
	elseif getClosestAlignedWorldDirection(targetVectorInWorld) == 4 then
		targetRefPointInTarget = targetCFrame:vectorToObjectSpace(Vector3.new(-1, -1, 1))
		insertRefPointInInsert = insertCFrame:vectorToObjectSpace(Vector3.new(-1, 1, 1))
		clampToSurface = Vector3.new(1,0,1)
	elseif getClosestAlignedWorldDirection(targetVectorInWorld) == 2 then
		targetRefPointInTarget = targetCFrame:vectorToObjectSpace(Vector3.new(-1, -1, 1))
		insertRefPointInInsert = insertCFrame:vectorToObjectSpace(Vector3.new(-1, -1, -1))
		clampToSurface = Vector3.new(1,1,0)
	else
		targetRefPointInTarget = targetCFrame:vectorToObjectSpace(Vector3.new(1, -1, -1))
		insertRefPointInInsert = insertCFrame:vectorToObjectSpace(Vector3.new(1, -1, 1))
		clampToSurface = Vector3.new(1,1,0)
	end

	targetRefPointInTarget = targetRefPointInTarget * (0.5 * diagBBTarget) + 0.5 * (maxBBTarget + minBBTarget)
	insertRefPointInInsert = insertRefPointInInsert * (0.5 * diagBB) + 0.5 * (maxBB + minBB)
	
	-- To Do: For cases that are not aligned to the world grid, account for the minimal rotation
	-- needed to bring the Insert part(s) into alignment with the Target Part
	-- Apply the rotation here

	local delta = mouseHitInTarget - targetRefPointInTarget
	local deltaClamped = Vector3.new(grid * math.modf(delta.x/grid), grid * math.modf(delta.y/grid), grid * math.modf(delta.z/grid))
	deltaClamped = deltaClamped * clampToSurface
	local targetTouchInTarget = deltaClamped + targetRefPointInTarget

	local TargetTouchRelToWorld = targetCFrame:pointToWorldSpace(targetTouchInTarget)
	local InsertTouchInWorld = insertCFrame:vectorToWorldSpace(insertRefPointInInsert)
	local posInsertOriginInWorld = TargetTouchRelToWorld - InsertTouchInWorld

	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = insertCFrame:components()
	targetConfig = CFrame.new(posInsertOriginInWorld.x, posInsertOriginInWorld.y, posInsertOriginInWorld.z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
	admissibleConfig = true

	return admissibleConfig, targetConfig

end


function startDrag(mousePart, hitPoint, collection)
	dragger = Instance.new("Dragger")
	pcall(function() dragger:MouseDown(mousePart, hitPoint, collection) end)
end

function collectBaseParts(object, collection)
	if object == nil then return end
	--if object:IsA("BasePart") then
	if isPart(object) then
		collection[#collection+1] = object
	end
	for index,child in pairs(object:GetChildren()) do
		collectBaseParts(child, collection)
	end
end

function onMouseDown(mouse) 
	mouse.Icon ="rbxasset://textures\\GrabRotateCursor.png"
	local part = mouse.Target
	if canSelectObject(part) then
		local hitPoint = mouse.Hit:toObjectSpace(part.CFrame).p
		if trySelection(part) then
			instances = {}
			game.JointsService:ClearJoinAfterMoveJoints()
			game.JointsService:SetJoinAfterMoveInstance(mouse.Target)
			collectBaseParts(currentSelection, instances)
			startDrag(part, hitPoint, instances)
			return
		end
	end
end


function onMouseUp(mouse)
	mouse.Icon ="rbxasset://textures\\GrabCursor.png"
	if dragger ~= nil then
		Mouse.TargetFilter = nil
		pcall(function() dragger:MouseUp() end)
		game.JointsService:CreateJoinAfterMoveJoints()
		dragger = nil
	end
end

function trySelection(part)
	if canSelectObject(part) then
		local model = findModel(part)
		if model then 		
			return setSelection(model)
		else
			return setSelection(part)
		end
	else
		clearSelection()
		return false
	end
end

function onKeyDown(key)
	if dragger ~= nil then
		if key == 'R' or key == 'r'  then
			pcall(function() dragger:AxisRotate(Enum.Axis.Y) end)
		elseif key == 'T' or key == 't' then
			pcall(function() dragger:AxisRotate(Enum.Axis.Z) end)
		end
	end
end

local alreadyMoving = false
function onMouseMove(mouse)
	if alreadyMoving then
		return
	end

	alreadyMoving = true
	if dragger ~= nil then
		local thingToDrag = {}
		thingToDrag[1] = currentSelection 
	
		pcall(function() dragger:MouseMove(mouse.UnitRay) end)-- needed to break welds properly
		configFound, targetCFrame = findConfigAtMouseTarget(thingToDrag)
		if configFound then
			positionPartsAtCFrame3(thingToDrag, targetCFrame)
		end
	else
		trySelection(mouse.Target)
	end
	alreadyMoving = false
end


function saveSelectionColor(instance)
	if instance:IsA("BasePart") then
		currentSelectionColors[instance] = instance.BrickColor
		if instance.BrickColor == BrickColor.Blue() then
			instance.BrickColor = BrickColor.new("Deep blue")
		else
			instance.BrickColor = BrickColor.Blue()
		end
	end

	local children = instance:GetChildren() 
	if children then
		for pos, child in pairs(children) do
			saveSelectionColor(child)
		end
	end
end
	
function setSelection(partOrModel)
	if partOrModel ~= currentSelection then
		clearSelection()
		currentSelection = partOrModel
		saveSelectionColor(currentSelection)
		selectionBox.Adornee = currentSelection
		return true
	elseif partOrModel == nil then
		clearSelection()
		return false
	end

	return partOrModel == currentSelection
end

function clearSelection()
	if currentSelection ~= nil then
		for part, color in pairs(currentSelectionColors) do
			part.BrickColor = color
		end
		selectionBox.Adornee = nil
	end
	currentSelectionColors = {}
	currentSelection = nil

	if(selectionBox) then
		selectionBox.Adornee = nil
	end
end

function onEquippedLocal(mouse)
	Mouse = mouse

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	mouse.Icon ="rbxasset://textures\\GrabCursor.png"

	local con = mouse.Button1Down:connect(function() onMouseDown(mouse) end)
	table.insert(connections,con)
	con = mouse.Button1Up:connect(function() onMouseUp(mouse) end)
	con = table.insert(connections,con)
	con = mouse.Move:connect(function() onMouseMove(mouse) end)
	table.insert(connections,con)
	con = mouse.KeyDown:connect(function(string) onKeyDown(string) end)
	table.insert(connections,con)

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "Model Delete Selection"
	selectionBox.Color = BrickColor.Blue()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	alreadyMoving = false
end

function onUnequippedLocal()
	for i = 1, #connections do
		connections[i]:disconnect()
	end
	connections = {}

	clearSelection()
	selectionBox:Remove()
end

script.Active.Changed:connect(function()
	if script.Active.Value then
		onEquippedLocal(Tool.Mouse.Value)
	else
		onUnequippedLocal()
	end
end)