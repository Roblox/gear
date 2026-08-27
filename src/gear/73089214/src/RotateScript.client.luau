-- NOTES:
--      NEEDS:
--            X  1.)  Make single blocks rotate always (they rotate 2x, then seem to think of themselves as blockers of themselves...  whaaa?)
--				  X  2.)  Make scripts continue to work through rotations (or else error on any objects which can't be rotated...  prehaps elevators?)
--            3.)  File bug for #1 and for "# of parts counted BEFORE instance-filter is applied for game.Workspace:FindPartsInRegion3"
--            4.)  Make things rotate separately (break and make welds)
--				  5.)  When something else is attached to a single block, stuff still breaks X<

-- general functions
function waitForProperty(instance, name)
	while not instance[name] do
		instance.Changed:wait()
	end
end
function waitForChild(instance, name)
	while not instance:FindFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

local Tool = script.Parent
local player
local playerArea = nil
local selectionBox = nil
local selectedModel = nil

local terrainSelectionBox = Instance.new("Part")
terrainSelectionBox.Parent = nil
terrainSelectionBox.formFactor = "Custom"
terrainSelectionBox.Size = Vector3.new(4, 4, 4)
terrainSelectionBox.CFrame = CFrame.new()

local cluster = nil

waitForChild(Tool, "ErrorBox")
local errorBox = Tool.ErrorBox

waitForChild(Tool, "PlayerOwner")
local playerOwner = Tool.PlayerOwner

waitForProperty(game,"PlaceId")
local isRestricted = (game.PlaceId == 41324860 or game.PlaceId == 129686177)

game:GetService("ContentProvider"):Preload("rbxasset://icons/configure_sel.png")


function getBoundingBox2(partOrModel)
-- for models, the bounding box is defined as the minimum and maximum individual part bounding boxes
-- relative to the first part's coordinate frame.

	local minVec = Vector3.new(math.huge, math.huge, math.huge)
	local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

	if partOrModel:IsA("Part") or partOrModel:IsA("WedgePart") or partOrModel:IsA("TrussPart")then
		minVec = partOrModel.CFrame:pointToWorldSpace(-0.5 * partOrModel.Size)
		maxVec = partOrModel.CFrame:pointToWorldSpace(0.5 * partOrModel.Size)
	else
		local part1 = partOrModel:GetChildren()[1]
		for i, object in pairs(partOrModel:GetChildren()) do
			if (object:IsA("Part") or object:IsA("WedgePart") or object:IsA("TrussPart")) then
				boxMinInWorld1 = object.CFrame:pointToWorldSpace(-0.5 * object.Size)
				--boxMinInPart1 = part1.CFrame:pointToObjectSpace(boxMinInWorld)
				boxMaxInWorld1 = object.CFrame:pointToWorldSpace(0.5 * object.Size)
				--boxMaxInPart1 = part1.CFrame:pointToObjectSpace(boxMaxInWorld)

				local minX = minVec.x
				local minY = minVec.y
				local minZ = minVec.z
				local maxX = maxVec.x
				local maxY = maxVec.y
				local maxZ = maxVec.z
				if boxMinInWorld1.x < minVec.x then
					minX = boxMinInWorld1.x
				end
				if boxMinInWorld1.y < minVec.y then
					minY = boxMinInWorld1.y
				end
				if boxMinInWorld1.z < minVec.z then
					minZ = boxMinInWorld1.z
				end
				if boxMaxInWorld1.x < minX then
					minX = boxMaxInWorld1.x
				end
				if boxMaxInWorld1.y < minY then
					minY = boxMaxInWorld1.y
				end
				if boxMaxInWorld1.z < minZ then
					minZ = boxMaxInWorld1.z
				end

				if boxMinInWorld1.x > maxVec.x then
					maxX = boxMinInWorld1.x
				end
				if boxMinInWorld1.y > maxVec.y then
					maxY = boxMinInWorld1.y
				end
				if boxMinInWorld1.z > maxVec.z then
					maxZ = boxMinInWorld1.z
				end
				if boxMaxInWorld1.x > maxX then
					maxX = boxMaxInWorld1.x
				end
				if boxMaxInWorld1.y > maxY then
					maxY = boxMaxInWorld1.y
				end
				if boxMaxInWorld1.z > maxZ then
					maxZ = boxMaxInWorld1.z
				end

				minVec = Vector3.new(minX, minY, minZ)
				maxVec = Vector3.new(maxX, maxY, maxZ)
			end
		end
	end

	return minVec, maxVec
end

function isInRobloxModel(part)
	if part == game.Workspace then
		return false, nil
	elseif part:FindFirstChild("RobloxModel") then 
		return true, part
	else
		return isInRobloxModel(part.Parent)
	end
end

function isInMyArea(part)
	if playerArea:FindFirstChild("PlayerArea")then
		return playerArea.PlayerArea:IsAncestorOf(part)
	end
	return false
end


function on3dButton1Down(mouse)
	-- don't do anything for now (can fix later: for now this means you can click one model, drag mouse to second model, and release mouse, and this will activate second model)
end


function offsetPartsByVector3(partOrModel, offsetVector)
	local insertCFrame
	if partOrModel:IsA("Model") then
		for i, object in pairs(partOrModel:GetChildren()) do
			if (object:IsA("Part") or object:IsA("WedgePart") or object:IsA("TrussPart")) then
				object.CFrame = object.CFrame + offsetVector
			end
		end
	else
		partOrModel.CFrame = partOrModel.CFrame + offsetVector
	end
end

function storeAndDisableScriptsInModel(parent, scriptTable)
	for i, object in pairs(parent:GetChildren()) do
		if object:IsA("Script") or object:IsA("LocalScript") then if not object.Disabled then object.Disabled = true table.insert(scriptTable, object) end end
		if object.GetChildren then storeAndDisableScriptsInModel(object, scriptTable) end
	end
end

function isInternalWeld(weld, model)
	return (not weld.Part0 or weld.Part0:IsDescendantOf(model)) and (not weld.Part1 or weld.Part1:IsDescendantOf(model))
end

function storeAndRemoveWeldsInModel(initialmodel, model, welds, weldParents)
	for i, object in pairs(model:GetChildren()) do
		if object.className == "ManualWeld" then if isInternalWeld(object, initialmodel) then table.insert(welds, object) table.insert(weldParents, object.Parent) object.Parent = nil end end
		if object.GetChildren then storeAndRemoveWeldsInModel(initialmodel, object, welds, weldParents) end
	end
end


local debris = game:GetService("Debris")
function flashRedBox(modelToFlash)
	if not modelToFlash then return end 

	errorBox.Parent = player.PlayerGui
	errorBox.Adornee = modelToFlash

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

	for x = startX, endX do
		for y = startY, endY do
			for z = startZ, endZ do
				if (cluster:GetCell(x, y, z).Value) > 0 then return true end
			end
		end
	end

	return false
end

function waterDirectionRotated(waterDirection)
	if waterDirection == Enum.WaterDirection.NegX then return Enum.WaterDirection.NegZ end
	if waterDirection == Enum.WaterDirection.NegZ then return Enum.WaterDirection.X end
	if waterDirection == Enum.WaterDirection.X then return Enum.WaterDirection.Z end
	if waterDirection == Enum.WaterDirection.Z then return Enum.WaterDirection.NegX end

	return waterDirection
end


local debounce = false
function on3dButton1Up(mouse)
	local modelToRotate = selectedModel -- so that other mouse events can't give us race conditions

	if modelToRotate and not debounce then
		debounce = true

		if modelToRotate == terrainSelectionBox then
			-- just rotate the terrain cell if we're selecting on terrain
			local cellPos = game.Workspace.Terrain:WorldToCell(terrainSelectionBox.CFrame.p)
			local cellMat, cellType, cellOrient = game.Workspace.Terrain:GetCell(cellPos.X, cellPos.Y, cellPos.Z)
			local isWater, waterForce, waterDirection = game.Workspace.Terrain:GetWaterCell(cellPos.X, cellPos.Y, cellPos.Z)
			if isWater then
				game.Workspace.Terrain:SetWaterCell(cellPos.X, cellPos.Y, cellPos.Z, waterForce, waterDirectionRotated(waterDirection))
			else
				game.Workspace.Terrain:SetCell(cellPos.X, cellPos.Y, cellPos.Z, cellMat, cellType, (cellOrient.Value + 1)%4)
			end


			debounce = false
			return
		end

		-- get the model centroid
		local minBB, maxBB = getBoundingBox2(modelToRotate)
		local oldModelCentroid = (minBB + maxBB) / 2  -- point to rotate around

		local diagVector = minBB - oldModelCentroid
		local rotatedDiagVector = Vector3.new(diagVector.Z, diagVector.Y, diagVector.X)
		local rotatedMinBB = oldModelCentroid + rotatedDiagVector
		local rotatedMaxBB = oldModelCentroid - rotatedDiagVector

		-- check if part rotation will cause collision
		local fudgeVector = Vector3.new(0.4, 0.4, 0.4)  -- mmmmmm, fudge

		-- we need to check the even/odd parity on the x and z axes of the model.  If there is a difference, then the rotation will push the model off-grid, so we will
			--   need to adjust
		local adjustVector = Vector3.new(0, 0, 0)
		local diffVector = minBB - maxBB
		local garbage, xParity = math.modf(math.modf(math.abs(diffVector.X)/4 + .5)/2)
		local garbage, zParity = math.modf(math.modf(math.abs(diffVector.Z)/4 + .5)/2)
		xParity = math.floor(xParity*2 + .5)
		zParity = math.floor(zParity*2 + .5)
		if xParity ~= zParity then
			-- need to shift
			adjustVector = Vector3.new(2, 0, 2)
			local mouseHitFrame = mouse.Hit
			if mouseHitFrame then
				local mouseHit = mouseHitFrame.p
				if math.abs(diffVector.X) > math.abs(diffVector.Z) then
					-- longest axis is X-axis
					if mouseHit.X > oldModelCentroid.X then
						adjustVector = Vector3.new(2, 0, 2)
					else
						adjustVector = Vector3.new(-2, 0, -2)
					end
				else
					-- longest axis is Z-axis
					if mouseHit.Z > oldModelCentroid.Z then
						adjustVector = Vector3.new(-2, 0, 2)
					else
						adjustVector = Vector3.new(2, 0, -2)
					end
				end
			end
		end
		-- below line checks CURRENT BB, not post-rotation BB
		--local blockingParts = game.Workspace:FindPartsInRegion3(Region3.new(minBB + fudgeVector, maxBB - fudgeVector), modelToRotate, 100)

		-- if blocked by the cluster, then exit out
		if cluster and clusterPartsInRegion(minBB + fudgeVector, maxBB - fudgeVector) then
			debounce = false
			flashRedBox(modelToRotate)
			return
		end

		local blockingParts = game.Workspace:FindPartsInRegion3(Region3.new(rotatedMinBB + fudgeVector + adjustVector, rotatedMaxBB - fudgeVector + adjustVector), modelToRotate, 100)

		if #blockingParts > 1 or (#blockingParts > 0 and blockingParts[1] ~= modelToRotate) then
			-- BLOCKED!!  MAKE ERROR NOISE!
			for j = 1, #blockingParts do 
				if blockingParts[j].className ~= "WedgePart" and (blockingParts[j].Size / 2):Dot(blockingParts[j].Size / 2) > 9 and blockingParts[j] ~= modelToRotate then
					debounce = false
					flashRedBox(modelToRotate)
					return
				end
			end
		--else
		end
			-- do the rotation! :D
			local rotCF = CFrame.fromEulerAnglesXYZ(0, math.pi/2, 0)

			game.JointsService:SetJoinAfterMoveInstance(modelToRotate)
			game.JointsService:ClearJoinAfterMoveJoints()

		
			-- below simple script disabling/re-enabling works for all scripts in normal usabilityset except for elevators and retracting spike [see if just need to change "Weld" in spikescript to "ManualWeld"... may need to also make sure below script-table can store all descendent scripts of modelToRotate, and not just immediate children...]
				-- and elevator scripts only break if you rotate when the elevator is in the "fully down" position...  probably just need some sort of check in ElevatorScript for this case

			local scriptsToTurnBackOn = {}
			storeAndDisableScriptsInModel(modelToRotate, scriptsToTurnBackOn)

			local weldsToReturn = {}
			local weldParentsToReturn = {}
			storeAndRemoveWeldsInModel(modelToRotate, modelToRotate, weldsToReturn, weldParentsToReturn)

			modelToRotate:BreakJoints()

			if modelToRotate:IsA("Model") then
				for i, object in pairs(modelToRotate:GetChildren()) do
					if object:IsA("Part") or object:IsA("TrussPart") or object:IsA("WedgePart") then object.CFrame = rotCF * object.CFrame end
				end
			else
				modelToRotate.CFrame = rotCF * modelToRotate.CFrame
			end

			-- fix position so centroid remains in same place [and then move centroid by adjustVector so it stays on grid]
			local newMinBB, newMaxBB = getBoundingBox2(modelToRotate)
			local newModelCentroid = (newMinBB + newMaxBB) / 2
			offsetPartsByVector3(modelToRotate, oldModelCentroid - newModelCentroid + adjustVector)

			game.JointsService:CreateJoinAfterMoveJoints()
			modelToRotate:MakeJoints()

			-- return all manual welds
			for i = 1, #weldsToReturn do weldsToReturn[i].Parent = weldParentsToReturn[i] end

			-- turn back on scripts
			for i = 1, #scriptsToTurnBackOn do scriptsToTurnBackOn[i].Disabled = false end
		--end

		--[[ for debugging
		local tempPart = Instance.new("Part")
		tempPart.CanCollide = false
		tempPart.Anchored = true
		tempPart.Size = maxBB - minBB
		tempPart.CFrame = CFrame.new((minBB + maxBB)/2)
		tempPart.Parent = game.Workspace
		game:GetService("Debris"):AddItem(tempPart, .5) ]]--


		debounce = false
	end
end

function on3dMouseMove(mouse)
	local mouseModel

	if mouse.Target and mouse.Target:IsA("Terrain") and not isRestricted and mouse.Hit and (mouse.Hit.p - Tool.Parent.Head.Position).magnitude < 60 then
		-- do something special if we're selecting close-by terrain
		selectedModel = terrainSelectionBox

		local cell = game.Workspace.Terrain:WorldToCellPreferSolid(mouse.Hit.p)
		local cellCenter = game.Workspace.Terrain:CellCenterToWorld(cell.X, cell.Y, cell.Z)
		terrainSelectionBox.CFrame = CFrame.new(cellCenter)

		selectionBox.Adornee = selectedModel
		return
	end

	if mouse.Target == nil then mouseModel = nil
	else boolGarbage, mouseModel = isInRobloxModel(mouse.Target) end

	if mouseModel == nil or (isRestricted and (not isInMyArea(mouseModel))) then mouseModel = nil end

	-- see if need to switch selectionBox
	if mouseModel ~= selectedModel then
		selectedModel = mouseModel
		selectionBox.Adornee = selectedModel
	end
end

function canSelectObject(part)
	if isRestricted then
		waitForChild(playerArea,"PlayerArea")
		if playerArea:FindFirstChild("PlayerArea") and part:IsDescendantOf(playerArea.PlayerArea) then
			return part and not (part.Locked) and part:IsA("BasePart")
		else
			return false
		end
	end

	return part and not (part.Locked) and part:IsA("BasePart")
end

function onEquippedLocal(mouse)
	if game.Workspace:FindFirstChild("Terrain") then
		cluster = game.Workspace.Terrain
	end

	local character = script.Parent.Parent
	player = game.Players:GetPlayerFromCharacter(character)

	if player == nil then return end
	if playerOwner.Value and playerOwner.Value ~= player then return end
	playerOwner.Value = player

	if isRestricted then
		waitForChild(game.Workspace,"BuildingAreas")
		waitForChild(game.Workspace.BuildingAreas,"Area1")
		waitForChild(game.Workspace.BuildingAreas.Area1,"Player")
		local areas = game.Workspace.BuildingAreas:GetChildren()
		for i = 1, #areas do
			if areas[i]:FindFirstChild("Player") and areas[i].Player.Value == player.Name then
				playerArea = areas[i]
				break
			end
		end
	end

	if game.Workspace:FindFirstChild("BaseplateBumpers") then mouse.TargetFilter = game.Workspace.BaseplateBumpers end

	mouse.Icon = "http://www.roblox.com/asset?id=67163124"
	mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	mouse.Button1Up:connect(function() on3dButton1Up(mouse) end)
	mouse.Move:connect(function() on3dMouseMove(mouse) end)
	
	selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "MainSelectionBox"
	selectionBox.Color = BrickColor.Blue()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui;

	on3dMouseMove(mouse) -- so if they unequip/reequip, they still have selection box
end

function onUnequippedLocal()
	if selectionBox then selectionBox:Remove() end
	selectedModel = nil
	player = nil
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

