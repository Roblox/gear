local Tool = script.Parent.Parent

game:GetService("ContentProvider"):Preload("rbxasset://icons/freemove_sel.png")

local selectionBox
local currentSelection
local currentSelectionColors = {}
local Mouse = nil

local player = nil

local instances = {}
local maxDragDistance = 60

local connections = {}

while not Tool:FindFirstChild("ErrorBox") do Tool.ChildAdded:wait() end
local errorBox = Tool.ErrorBox

local lastTargetCFrame = nil

function canSelectObject(part)
	return part and not (part.Locked) and (part.Position - script.Parent.Parent.Parent.Head.Position).Magnitude < maxDragDistance
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
	return object and (object:IsA("Part") or object:IsA("TrussPart") or object:IsA("WedgePart") or object:IsA("VehicleSeat"))
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
	elseif partOrModel:IsA("Terrain") then
		minVec = Vector3.new(-2, -2, -2)
		maxVec = Vector3.new(2, 2, 2)
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


-- function to do the same as above, but in world coordinates (really only used for region3-based bounds-checking)
function getBoundingBoxInWorldCoordinates(partOrModel)
	local minVec = Vector3.new(math.huge, math.huge, math.huge)
	local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

	if partOrModel:IsA("Part") or partOrModel:IsA("WedgePart") or partOrModel:IsA("TrussPart")then
		vec1 = partOrModel.CFrame:pointToWorldSpace(-0.5 * partOrModel.Size)
		vec2 = partOrModel.CFrame:pointToWorldSpace(0.5 * partOrModel.Size)
		minVec = Vector3.new(math.min(vec1.X, vec2.X), math.min(vec1.Y, vec2.Y), math.min(vec1.Z, vec2.Z))
		maxVec = Vector3.new(math.max(vec1.X, vec2.X), math.max(vec1.Y, vec2.Y), math.max(vec1.Z, vec2.Z))
	elseif partOrModel:IsA("Terrain") then
		-- we shouldn't have to deal with this case
		--minVec = Vector3.new(-2, -2, -2)
		--maxVec = Vector3.new(2, 2, 2)
	else
		local part1 = partOrModel:GetChildren()[1]
		for i, object in pairs(partOrModel:GetChildren()) do
			if (object:IsA("Part") or object:IsA("WedgePart") or object:IsA("TrussPart")) then
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
				if boxMinInWorld.x < minVec.x then
					minX = boxMinInWorld.x
				end
				if boxMinInWorld.y < minVec.y then
					minY = boxMinInWorld.y
				end
				if boxMinInWorld.z < minVec.z then
					minZ = boxMinInWorld.z
				end
				if boxMaxInWorld.x < minX then
					minX = boxMaxInWorld.x
				end
				if boxMaxInWorld.y < minY then
					minY = boxMaxInWorld.y
				end
				if boxMaxInWorld.z < minZ then
					minZ = boxMaxInWorld.z
				end

				if boxMinInWorld.x > maxVec.x then
					maxX = boxMinInWorld.x
				end
				if boxMinInWorld.y > maxVec.y then
					maxY = boxMinInWorld.y
				end
				if boxMinInWorld.z > maxVec.z then
					maxZ = boxMinInWorld.z
				end
				if boxMaxInWorld.x > maxX then
					maxX = boxMaxInWorld.x
				end
				if boxMaxInWorld.y > maxY then
					maxY = boxMaxInWorld.y
				end
				if boxMaxInWorld.z > maxZ then
					maxZ = boxMaxInWorld.z
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

	--local targetVectorInWorld = targetCFrame:vectorToWorldSpace(Vector3.FromNormalId(Mouse.TargetSurface))

	if targetPart:IsA("Terrain") then
		if not cluster then cluster = game.Workspace.Terrain end

		-- the prefer solid is messing things up very slightly!! (because the TargetSurface stays correct when the cells are shifted very slightly prematurely)
		cellID = cluster:WorldToCellPreferSolid(mouseHitInWorld)
		targetCFrame = CFrame.new(cluster:CellCenterToWorld(cellID.x, cellID.y, cellID.z))
	end

	local targetVectorInWorld = targetCFrame:vectorToWorldSpace(Vector3.FromNormalId(Mouse.TargetSurface))
	local mouseHitInTarget = targetCFrame:pointToObjectSpace(mouseHitInWorld)

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
	lastTargetCFrame = nil
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



-- stampability-checking functions (copied from StampScript)

function flashRedBox(targetModel)
	if not player then return end
	errorBox.Parent = player.PlayerGui
	errorBox.Adornee = targetModel

	delay(0,function()
		for i = 1, 3 do
			errorBox.Visible = true
			wait(0.13)
			errorBox.Visible = false
			wait(0.13)
		end
		errorBox.Adornee = nil
		errorBox.Parent = Tool
	end)
end

-- below function should work as a Region3 query, returning true if a single cluster part is within this region
function clusterPartsInRegion(startVector, endVector)

	if not cluster then return false end

	local startCell = cluster:WorldToCell(startVector)
	local endCell = cluster:WorldToCell(endVector)

	local startX = startCell.X
	local startY = startCell.Y
	local startZ = startCell.Z

	local endX = endCell.X
	local endY = endCell.Y
	local endZ = endCell.Z

	if startX < cluster.MaxExtents.Min.X then startX = cluster.MaxExtents.Min.X end
	if startY < cluster.MaxExtents.Min.Y then startY = cluster.MaxExtents.Min.Y end
	if startZ < cluster.MaxExtents.Min.Z then startZ = cluster.MaxExtents.Min.Z end

	if endX > cluster.MaxExtents.Max.X then endX = cluster.MaxExtents.Max.X end
	if endY > cluster.MaxExtents.Max.Y then endY = cluster.MaxExtents.Max.Y end
	if endZ > cluster.MaxExtents.Max.Z then endZ = cluster.MaxExtents.Max.Z end

	--print(startX, endX)
	--print(startY, endY)
	--print(startZ, endZ)

	for x = startX, endX do
		for y = startY, endY do
			for z = startZ, endZ do
				--if game.Workspace.Cluster:GetCell(x, y, z) > 0 then return true end
				if (cluster:GetCell(x, y, z).Value) > 0 then return true end
			end
		end
	end

	return false
end


-- helper function to determine if a character can be pushed upwards by a certain amount
-- FILL THIS OUT!!!  -- character is 5 studs tall, we'll check a 1.5 x 1.5 x 4.5 box around char, with center .5 studs below torsocenter
function spaceAboveCharacter(charTorso, newTorsoY)
	local partsAboveChar = game.Workspace:FindPartsInRegion3(Region3.new(Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) - Vector3.new(.75, 2.75, .75), Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) + Vector3.new(.75, 1.75, .75)), charTorso.Parent, 100)
	for j = 1, #partsAboveChar do
		if partsAboveChar[j].CanCollide and not partsAboveChar[j]:IsDescendantOf(currentSelection) then return false end
	end

	if clusterPartsInRegion(Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) - Vector3.new(.75, 2.75, .75), Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) + Vector3.new(.75, 1.75, .75)) then return false end

	return true
end



local insertBoundingBoxOverlapVector = Vector3.new(1, 1, 1)

function onMouseUp(mouse)
	mouse.Icon ="rbxasset://textures\\GrabCursor.png"
	local thingToPlace = {}
	thingToPlace[1] = currentSelection

	if dragger ~= nil then
		local minBB, maxBB = getBoundingBoxInWorldCoordinates(currentSelection)
		local configFound, targetCFrame = findConfigAtMouseTarget(thingToPlace)

		if configFound then
			-- don't drag into terrain
			if clusterPartsInRegion(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector) then flashRedBox(currentSelection) return end
			
			local blockingParts = game.Workspace:FindPartsInRegion3(Region3.new(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector), currentSelection, 100)
			for b = 1, #blockingParts do
				-- put code back here if we want to prevent dragger from dragging into other stamped models (once Region3 fix goes out)
			end

			local alreadyPushedUp = {}
			-- if no blocking model below, then see if stamping on top of a character
			for b = 1, #blockingParts do
				if blockingParts[b].Parent and not alreadyPushedUp[blockingParts[b].Parent] and blockingParts[b].Parent:FindFirstChild("Humanoid") and blockingParts[b].Parent:FindFirstChild("Humanoid"):IsA("Humanoid") then
					local blockingPersonTorso = blockingParts[b].Parent:FindFirstChild("Torso")
					alreadyPushedUp[blockingParts[b].Parent] = true

					if blockingPersonTorso then
						-- if so, let's push the person upwards so they pop on top of the stamped model/part (but only if there's space above them)
						local newY = maxBB.Y + 3
						if spaceAboveCharacter(blockingPersonTorso, newY) then
							blockingPersonTorso.CFrame = blockingPersonTorso.CFrame + Vector3.new(0, newY - blockingPersonTorso.CFrame.p.Y, 0)
						else
							-- if no space, we just error
							flashRedBox(currentSelection)
							return
						end
					end
				end
			end

			Mouse.TargetFilter = nil
			pcall(function() dragger:MouseUp() end)
			game.JointsService:CreateJoinAfterMoveJoints()
			dragger = nil
		end
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
			local minBB, maxBB = getBoundingBoxInWorldCoordinates(currentSelection)
	
			-- need to offset by distance to be dragged
			local currModelCFrame
			if currentSelection:IsA("Model") then
				-- we assume model has at least one part in it; need to find first part
				i = 1
				while (i < (#currentSelection:GetChildren()) and not isPart(currentSelection:GetChildren()[i])) do
					i = i + 1
				end
				currModelCFrame = currentSelection:GetChildren()[i].CFrame
			else currModelCFrame = currentSelection.CFrame end
			minBB = minBB + targetCFrame.p - currModelCFrame.p
			maxBB = maxBB + targetCFrame.p - currModelCFrame.p

			-- don't drag into terrain
			if clusterPartsInRegion(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector) then 
				if lastTargetCFrame then positionPartsAtCFrame3(thingToDrag, lastTargetCFrame) end
				alreadyMoving = false 
				return 
			end
			
			local blockingParts = game.Workspace:FindPartsInRegion3(Region3.new(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector), currentSelection, 100)
			for b = 1, #blockingParts do
				-- put code back here if we want to prevent dragger from dragging into other stamped models (once Region3 fix goes out)
			end
			positionPartsAtCFrame3(thingToDrag, targetCFrame)
			lastTargetCFrame = targetCFrame
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

	local character = script.Parent.Parent.Parent
	player = game.Players:GetPlayerFromCharacter(character)

	mouse.Icon ="rbxasset://textures\\GrabCursor.png"

	local con = Mouse.Button1Down:connect(function() onMouseDown(Mouse) end)
	table.insert(connections,con)
	con = Mouse.Button1Up:connect(function() onMouseUp(Mouse) end)
	con = table.insert(connections,con)
	con = Mouse.Move:connect(function() onMouseMove(Mouse) end)
	table.insert(connections,con)
	con = Mouse.KeyDown:connect(function(string) onKeyDown(string) end)
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