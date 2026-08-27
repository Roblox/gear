-- basic functions

function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end
----------------------------------------------------------------------------------------

-- Locals

local Tool = script.Parent

local Mouse
local mouseMoveCon
local mouseButton1DownCon
local mouseButton1UpCon
local cameraChangeCon

local walking = false

local pressedEsc = false

local billBoardOwnerGui = nil

local cluster = game.Workspace:FindFirstChild("Terrain")

local gInitial90DegreeRotations = 0
local gStaticTrans = 1
local gDesiredTrans = 0.7
local transFadeInTime = 0.5
local fadeInDelayTime = 0.5
local eyedropperOffGridTolerance = 0.01

local insertBoundingBoxOverlapVector = Vector3.new(1, 1, 1) -- we can still stamp if our character extrudes into the target stamping space by 1 or fewer units

local useAssetVersionId = false


-- for high-scalability display
local adornPart = Instance.new("Part")
adornPart.Parent = nil
adornPart.formFactor = "Custom"
adornPart.Size = Vector3.new(4, 4, 4)
adornPart.CFrame = CFrame.new()

local adorn = Instance.new("SelectionBox")
adorn.Color = BrickColor.new("Toothpaste")
adorn.Adornee = adornPart
adorn.Visible = true
adorn.Transparency = 0
adorn.Name = "HighScalabilityStamperLine"
adorn.Parent = nil

local terrainSelectionBox = Instance.new("Part")
terrainSelectionBox.Parent = nil
terrainSelectionBox.formFactor = "Custom"
terrainSelectionBox.Size = Vector3.new(4, 4, 4)
terrainSelectionBox.CFrame = CFrame.new()

local HighScalabilityLine = {}
HighScalabilityLine.Start = nil
HighScalabilityLine.End = nil
HighScalabilityLine.Adorn = adorn
HighScalabilityLine.AdornPart = adornPart
HighScalabilityLine.InternalLine = nil
HighScalabilityLine.NewHint = true

-- for higher dimensional megacluster part stamping
HighScalabilityLine.MorePoints = {nil, nil}
HighScalabilityLine.MoreLines = {nil, nil}
HighScalabilityLine.Dimensions = 1

waitForChild(Tool,"LuaGlobalVariables")
local variables = Tool.LuaGlobalVariables
waitForChild(variables,"ShowInvalidPlacement")
waitForChild(variables, "Stamped")
waitForChild(Tool,"ErrorBox")
waitForChild(variables, "ShowAdminCategories")
local errorBox = Tool.ErrorBox

waitForChild(variables, "IsRestricted")
waitForChild(variables, "MouseClick")
click = variables.MouseClick

local Data = {}
Data.Stamp = {}
Data.Loading = {}

local guiScriptIsLoadingSomething = false
local unstampableSurface = false

local eyeDropperConnection, eyeDropperMoveConnection

local playerModel
local player

local lastTargetCFrame = nil
local lastTargetTerrainOrientation = 0

-- For Restricting Stamper Tool
local isRestricted = variables.IsRestricted.Value
local adminAccess = variables.ShowAdminCategories.Value

-- For Delete highlighting
local selectionBox
local currentSelection
local currentSelectionColors = {}

if isRestricted then waitForChild(game.Workspace, "BaseplateBumpers") end
----------------------------------------------------------------------------------------

-- Functions
function hint(label)
	-- Pass in a string, it shows a top hint.  (Replaces previous hint, if exists)
	_player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if(_player.PlayerGui:FindFirstChild("topHint")~=nil) then
		local topHint = _player.PlayerGui.topHint
		topHint.Add.Label.Value = label
		topHint.Add.Width.Value = 3 -- widest width
		topHint.Add.Time.Value = 5
		topHint.Add.Disabled = true
		topHint.Add.Disabled = false
	end
end


function getClosestColorToTerrainMaterial(terrainValue)
	if terrainValue == 1 then
		return BrickColor.new("Bright green")
	elseif terrainValue == 2 then
		return BrickColor.new("Bright yellow")
	elseif terrainValue == 3 then
		return BrickColor.new("Bright red")
	elseif terrainValue == 4 then
		return BrickColor.new("Medium stone grey")
	else
		return BrickColor.new("Bright green")
	end
end


local manualWeldTable = {}
local manualWeldParentTable = {}
function saveTheWelds(object)
	if object:IsA("ManualWeld") or object:IsA("Rotate") then
		table.insert(manualWeldTable, object)
		table.insert(manualWeldParentTable, object.Parent)
	else
		local children = object:GetChildren()
		for i = 1, #children do
			saveTheWelds(children[i])
		end
	end
end

function restoreTheWelds()
	for i = 1, #manualWeldTable do
		manualWeldTable[i].Parent = manualWeldParentTable[i]
	end
end


function findSeatsInModel(parent, seatTable)
	if not parent then return end

	if parent.className == "Seat" or parent.className == "VehicleSeat" then
		table.insert(seatTable, parent)
	end
	local myChildren = parent:GetChildren()
	for j = 1, #myChildren do
		findSeatsInModel(myChildren[j], seatTable)
	end
end

function setSeatEnabledStatus(model, isEnabled)
	local seatList = {}
	findSeatsInModel(model, seatList)

	if isEnabled then
		-- remove any welds called "SeatWeld" in seats
		for i = 1, #seatList do
			local nextSeat = seatList[i]:FindFirstChild("SeatWeld")
			while nextSeat do nextSeat:Remove() nextSeat = seatList[i]:FindFirstChild("SeatWeld") end
		end
	else
		-- put a weld called "SeatWeld" in every seat
		--   this tricks it into thinking there's already someone sitting there, and it won't make you sit XD
		for i = 1, #seatList do
			local fakeWeld = Instance.new("Weld")
			fakeWeld.Name = "SeatWeld"
			fakeWeld.Parent = seatList[i]
		end
	end
end


function UnlockInstances(object)

	if object:IsA("BasePart") then
		object.Locked = false
	end
	for index,child in pairs(object:GetChildren()) do
		UnlockInstances(child)
	end

end

function generateOwnerGui(playerName)
	local gui = Instance.new("BillboardGui")
	gui.Name = "PlayerStamperTagGui"
	gui.StudsOffset = Vector3.new(0,1,0)
	gui.ExtentsOffset = Vector3.new(0,1,0)
	gui.Size = UDim2.new(5,0,2,0)
	pcall(function() gui.PlayerToHideFrom = game.Players.LocalPlayer end)

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.new(0,0,0)
	frame.BackgroundTransparency = 0.5
	frame.Name = "OwnerFrame"
	frame.Size = UDim2.new(1,0,1,0)
	frame.Parent = gui
	
	local ownerName = Instance.new("TextLabel")
	ownerName.Name = "OwnerName"
	ownerName.Size = UDim2.new(1,0,1,0)
	ownerName.Text = playerName
	ownerName.Font = Enum.Font.ArialBold
	ownerName.FontSize = Enum.FontSize.Size14
	ownerName.TextWrap = true
	ownerName.TextColor3 = Color3.new(1,1,1)
	ownerName.TextStrokeTransparency = 0
	ownerName.BackgroundTransparency = 1
	ownerName.Parent = frame

	return gui
end



function getPlayer()
	return game.Players:GetPlayerFromCharacter(script.Parent.Parent)
end

function beginInsertAssetStamp(assetName, assetId, image, stampMode)
	-- trying to stop assets, gone back to Main Stamp Dialog
	if assetId == 0 then
		guiScriptIsLoadingSomething = true
		cancelAssetPlacement()
		return
	end
	if assetId < 0 then
		guiScriptIsLoadingSomething = true
		cancelAssetPlacement()
		setupDraggableClone()
		wait() -- need this so onInsertMouseMove() can sync up with setupDraggableClone()
		onInsertMouseMove()
		guiScriptIsLoadingSomething = false
		return
	end
	-- This call will cause a "wait" until the data comes back
	-- below we wait a max of 8 seconds before deciding to bail out on loading
	local root
	local loader
	loading = true
	if useAssetVersionId then
		loader = coroutine.create(function()	
			root = game:GetService("InsertService"):LoadAssetVersion(assetId)
			loading = false
		end)
		coroutine.resume(loader)
	else
		loader = coroutine.create(function()	
			root = game:GetService("InsertService"):LoadAsset(assetId)
			loading = false
		end)
		coroutine.resume(loader)
	end

	local lastGameTime = 0
	local totalTime = 0
	local maxWait = 8
	while loading and totalTime < maxWait do
		lastGameTime = tick()
		wait(1)
		totalTime = totalTime + tick() - lastGameTime
	end
	loading = false

	if totalTime >= maxWait or pressedEsc then
		Data.Loading.Cancelled = true
		pressedEsc = false
	else
		Data.Loading.Cancelled = false
	end


	if Data.Loading.Cancelled then
		--The user got bored and wandered off
		--Just delete the model from the world... a shame we loaded it when they got bored
		-- 12/28/2010: Putting this inside a pcall (on gametest, first time equipping stamper, this was being called with root=nil.) (Jahr)
		pcall(function() root:Remove() end)
		signalInsertComplete("Main")
	else
		if root == nil then
			signalInsertComplete("Main")
			return
		end

		if not root:IsA("Model") then
			signalInsertComplete("Main")
			return
		end

		local instances = root:GetChildren()
		if #instances == 0 then
			root:Remove()
			signalInsertComplete("Main")
			return
		end

		--Unlock all parts that are inserted, to make sure they are editable
		UnlockInstances(root)

		--Continue the insert process
		root.Name = "InsertedObject" .. assetId

		--Examine the contents and decide what it looks like
		for pos, instance in pairs(instances) do
			--Single instance objects might be treated special, decals/skyboxes
			if instance:IsA("Decal") then
				--Current system here stops after finding one Decal (and gives you Decal tool)
				--We should do the same (probably)
				beginInsertDecal(instance)
				root:Remove()

				Window.Stamp.Frame.Visible = true
				return
			elseif instance:IsA("Team") then
				instance.Parent = game:GetService("Teams")
			elseif instance:IsA("SpawnLocation") then
				-- uh.............
			elseif instance:IsA("HopperBin") then
				-- Must go into the starterPack, prompt user?
			elseif instance:IsA("Tool") then
				-- Ask them if it should go in StarterPack?
			elseif instance:IsA("Sky") then
				local lightingService = game:GetService("Lighting")
				for index,child in pairs(lightingService:GetChildren()) do
					if child:IsA("Sky") then
						child:Remove();
					end
				end
				instance.Parent = lightingService
				return
			else

			end
		end

		if #root:GetChildren() == 0 then
			root:Remove()
			signalInsertComplete("Main")
			return
		end

		signalInsertComplete("SideDialog")
		
		cancelAssetPlacement()
		Data.Stamp.Model = root
		setupDraggableClone()
		guiScriptIsLoadingSomething = false
	end

end

function beginInsertDecal(decal)

	Data.Stamp.DecalSelection = Instance.new("SurfaceSelection")
	Data.Stamp.DecalSelection.Color = BrickColor.new("Bright orange")
	Data.Stamp.DecalSelection.archivable = false
	Data.Stamp.DecalSelection.Parent = getPlayer().PlayerGui

	--Save the decal in our Lua code for later use
	Data.Stamp.Decal = decal
	Data.Stamp.Decal.Parent = nil

end


-- signal to gui to switch frames
function signalInsertComplete(type)

	if type == "SideDialog" then
		variables.SwitchLoaderToDialog.DialogType.Value = "SideDialog"
		variables.SwitchLoaderToDialog.Value = true
	elseif type == "Main" then
		variables.SwitchLoaderToDialog.DialogType.Value = "Main"
		variables.SwitchLoaderToDialog.Value = true
	elseif type == "EyeDropper" then
		variables.SwitchLoaderToDialog.DialogType.Value = "EyeDropper"
		variables.SwitchLoaderToDialog.Value = true
	end

	-- needed to make sure we disconnect eyedroper handler
	if type ~= "EyeDropper" then
		if eyeDropperConnection then
			eyeDropperConnection:disconnect()
			eyeDropperConnection = nil
		end
		if eyeDropperMoveConnection then eyeDropperMoveConnection:disconnect() end

		if Mouse and not mouseButton1UpCon then mouseButton1UpCon = Mouse.Button1Up:connect(onInsertMouseButton1Up) end
	end
	clearSelection()

end


function p(assetName, assetId, image, stampMode)
	-- trying to stop assets, gone back to Main Stamp Dialog
	if assetId == 0 then
		cancelAssetPlacement()
		return
	end

	-- This call will cause a "wait" until the data comes back
	-- below we wait a max of 8 seconds before deciding to bail out on loading
	local root
	local loader
	loading = true
	if useAssetVersionId then
		loader = coroutine.create(function()
			root = game:GetService("InsertService"):LoadAssetVersion(assetId)
			loading = false
		end)
		coroutine.resume(loader)
	else
		loader = coroutine.create(function()	
			root = game:GetService("InsertService"):LoadAsset(assetId)
			loading = false
		end)
		coroutine.resume(loader)
	end

	local lastGameTime = 0
	local totalTime = 0
	local maxWait = 8
	while loading and totalTime < maxWait do
		lastGameTime = tick()
		wait(1)
		totalTime = totalTime + tick() - lastGameTime
	end
	loading = false

	if totalTime >= maxWait or pressedEsc then
		Data.Loading.Cancelled = true
		pressedEsc = false
	else
		Data.Loading.Cancelled = false
	end


	if Data.Loading.Cancelled then
		--The user got bored and wandered off
		--Just delete the model from the world... a shame we loaded it when they got bored
		-- 12/28/2010: Putting this inside a pcall (on gametest, first time equipping stamper, this was being called with root=nil.) (Jahr)
		pcall(function() root:Remove() end)
		signalInsertComplete("Main")
	else
		local instances = root:GetChildren()
		if #instances == 0 then
			root:Remove()
			signalInsertComplete("Main")
			return
		end

		--Unlock all parts that are inserted, to make sure they are editable
		UnlockInstances(root)

		--Continue the insert process
		root.Name = "InsertedObject" .. assetId

		--Examine the contents and decide what it looks like
		for pos, instance in pairs(instances) do
			--Single instance objects might be treated special, decals/skyboxes
			if instance:IsA("Decal") then
				--Current system here stops after finding one Decal (and gives you Decal tool)
				--We should do the same (probably)
				beginInsertDecal(instance)
				root:Remove()

				Window.Stamp.Frame.Visible = true
				return
			elseif instance:IsA("Team") then
				instance.Parent = game:GetService("Teams")
			elseif instance:IsA("SpawnLocation") then
				-- uh.............
			elseif instance:IsA("HopperBin") then
				-- Must go into the starterPack, prompt user?
			elseif instance:IsA("Tool") then
				-- Ask them if it should go in StarterPack?
			elseif instance:IsA("Sky") then
				local lightingService = game:GetService("Lighting")
				for index,child in pairs(lightingService:GetChildren()) do
					if child:IsA("Sky") then
						child:Remove();
					end
				end
				instance.Parent = lightingService
				return
			else

			end
		end

		if #root:GetChildren() == 0 then
			root:Remove()
			signalInsertComplete("Main")
			return
		end

		signalInsertComplete("SideDialog")
		
		cancelAssetPlacement()
		Data.Stamp.Model = root
		setupDraggableClone()
	end

end


function positionPartsAtCFrame3(partOrModel, aCFrame)

	local insertCFrame
	if Data.Stamp.CurrentParts[1]:IsA("Model") or Data.Stamp.CurrentParts[1]:IsA("Tool") then
		--insertCFrame = Data.Stamp.CurrentParts[1]:GetChildren()[1].CFrame
		-- we assume model has at least one part in it; need to find first part
		i = 1
		while (i < (#Data.Stamp.CurrentParts[1]:GetChildren()) and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("Part") and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("TrussPart") and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("WedgePart") and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("CornerWedgePart")) do
			i = i + 1
		end
		insertCFrame = Data.Stamp.CurrentParts[1]:GetChildren()[i].CFrame

		for i, object in pairs(Data.Stamp.CurrentParts[1]:GetChildren()) do
			if object:IsA("Flag") then object = object.Handle end
			if (object:IsA("Part") or object:IsA("WedgePart") or object:IsA("CornerWedgePart") or object:IsA("TrussPart") or object:IsA("Seat") or object:IsA("VehicleSeat")) then
				local posPartInWorld = object.Position
				local posPart1InWorld = insertCFrame.p
				local newPosPartInWorld = posPartInWorld - posPart1InWorld + aCFrame.p
	
				local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = object.CFrame:components()
				object.CFrame = CFrame.new(newPosPartInWorld.x, newPosPartInWorld.y, newPosPartInWorld.z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
			end
		end
		else
		Data.Stamp.CurrentParts[1].CFrame = aCFrame
	end

end


-- For Restricting Stamper Tool (isRestricted)
function inBounds(object)

	for part, transparency in pairs(object) do
		if part:IsA("Part") or part:IsA("WedgePart") or part:IsA("CornerWedgePart") or part:IsA("TrussPart") then
			if not partInBounds(part) then return false end
		elseif part:IsA("Model") then
			local primPart = object.PrimaryPart
			if not partInBounds(primPart) then return false end
		end
	end
	return true

end

function partInBounds(part)

	if part == nil then return false end

	local xOne= buildingPlate.Position.x + buildingPlate.Size.x/2
	local xTwo = buildingPlate.Position.x - buildingPlate.Size.x/2
	local zOne = buildingPlate.Position.z + buildingPlate.Size.z/2
	local zTwo = buildingPlate.Position.z - buildingPlate.Size.z/2

	if part.Position.x > xOne or part.Position.x < xTwo then return false end
	if part.Position.z > zOne or part.Position.z < zTwo then return false end

	return true

end



function canSelectObject(part)
	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end

function canEyeDropperObject(part)
	local stamperTag = part.Parent:FindFirstChild("RobloxStamper")
	if stamperTag == nil then stamperTag = part:FindFirstChild("RobloxStamper") end

	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60 and stamperTag ~= nil
end

function isOnGrid(partOrModel)
	-- first check to see if off-grid, and if so, prevent eyedropperage
		local modelExtentsInWorldCoords
		if partOrModel:IsA("Model") then
			modelExtentsInWorldCoords = partOrModel:GetModelCFrame():vectorToWorldSpace(partOrModel:GetModelSize())
		else
			modelExtentsInWorldCoords = partOrModel.CFrame:vectorToWorldSpace(partOrModel.Size)
		end

		-- we now simply check to see if the above property fits in a 4x4x4 gridspace
		offX = math.fmod(math.abs(modelExtentsInWorldCoords.X), 4)
		offY = math.fmod(math.abs(modelExtentsInWorldCoords.Y), 4)
		offZ = math.fmod(math.abs(modelExtentsInWorldCoords.Z), 4)

		local numberOfAxesOffGrid = 0
		if math.min(offX, 4 - offX) > eyedropperOffGridTolerance then numberOfAxesOffGrid = numberOfAxesOffGrid + 1 end
		if math.min(offY, 4 - offY) > eyedropperOffGridTolerance then numberOfAxesOffGrid = numberOfAxesOffGrid + 1 end
		if math.min(offZ, 4 - offZ) > eyedropperOffGridTolerance then numberOfAxesOffGrid = numberOfAxesOffGrid + 1 end

		if numberOfAxesOffGrid > 1 then return false -- we allow one axis to be not fit to grid, since any rotation must necessarily affect >= 2 axes (some of the models are like 4x4x6 :(  ).
		else return true end
end


-- below is a helper function to help get the model surface instead of the part surface [for allowing a side to elect out of making joints automatically]
function calcRayHitTime(rayStart, raySlope, intersectionPlane)
	if math.abs(raySlope) < .01 then return 0 end -- 0 slope -->  we just say intersection time is 0, and sidestep this dimension
	-- rayStart + t*raySlope = intersectionPlane, so t = (intersectionPlane - rayStart) / raySlope
	return (intersectionPlane - rayStart) / raySlope
end


function modelTargetSurface(partOrModel, rayStart, rayEnd)
	if not partOrModel then
		return 0
	end

	local modelCFrame = nil
	local modelSize = nil
	if partOrModel:IsA("Model") then
		modelCFrame = partOrModel:GetModelCFrame()
		modelSize = partOrModel:GetModelSize()
	else
		modelCFrame = partOrModel.CFrame
		modelSize = partOrModel.Size
	end

	local mouseRayStart = modelCFrame:pointToObjectSpace(rayStart)
	local mouseRayEnd = modelCFrame:pointToObjectSpace(rayEnd)
	local mouseSlope = mouseRayEnd - mouseRayStart

	local xPositive = 1
	local yPositive = 1
	local zPositive = 1
	if mouseSlope.X > 0 then xPositive = -1 end
	if mouseSlope.Y > 0 then yPositive = -1 end
	if mouseSlope.Z > 0 then zPositive = -1 end

	-- find which surface the transformed mouse ray hits (using modelSize):
	local xHitTime = calcRayHitTime(mouseRayStart.X, mouseSlope.X, modelSize.X/2 * xPositive)
	local yHitTime = calcRayHitTime(mouseRayStart.Y, mouseSlope.Y, modelSize.Y/2 * yPositive)
	local zHitTime = calcRayHitTime(mouseRayStart.Z, mouseSlope.Z, modelSize.Z/2 * zPositive)

	local hitFace = 0

	--if xHitTime >= 0 and yHitTime >= 0 and zHitTime >= 0 then
	if xHitTime > yHitTime then
		if xHitTime > zHitTime then
			-- xFace is hit
			hitFace = 1*xPositive
		else
			-- zFace is hit
			hitFace = 3*zPositive
		end
	else
		if yHitTime > zHitTime then
			-- yFace is hit
			hitFace = 2*yPositive
		else
			-- zFace is hit
			hitFace = 3*zPositive
		end
	end

	return hitFace
end


-- helper function for truncating to 45-degree angles on a 2D plane
function truncateToCircleEighth(bigValue, littleValue)
	local big = math.abs(bigValue)
	local little = math.abs(littleValue)
	local hypotenuse = math.sqrt(big*big + little*little)
	local frac = little / hypotenuse

	local bigSign = 1
	local littleSign = 1
	if bigValue < 0 then bigSign = -1 end
	if littleValue < 0 then littleSign = -1 end

	if frac > .382683432 then
		-- between 22.5 and 45 degrees, so truncate to 45-degree tilt
		return .707106781 * hypotenuse * bigSign, .707106781 * hypotenuse * littleSign
	else 
		-- between 0 and 22.5 degrees, so truncate to 0-degree tilt
		return hypotenuse * bigSign, 0
	end
end

function onInsertMouseMove()

	if Data.Stamp.MovingLock then
		return
	end

	-- check to see if mouse is still active, and return otherwise!
	if not pcall(function () if Mouse and Mouse.Target and Mouse.Target.Parent:FindFirstChild("RobloxModel") == nil then return true else return false end end) then print("ERRORED OUT") game.JointsService:SetJoinAfterMoveTarget(nil) Mouse = nil return end

	if isRestricted and Mouse then
		Mouse.TargetFilter = game.Workspace.BaseplateBumpers
	end

	Data.Stamp.MovingLock = true
	if Data.Stamp.Dragger == nil then
		if Data.Stamp.Model ~= nil then
			if isRestricted then
				if checkPartLimit() then
					setupDraggableClone()
				else
					variables.ShowMaxedOut.Value = true
				end
			else
				setupDraggableClone()
			end
		end
	else
		-- REM TL: Data.Stamp.Dragger:MouseMove(Mouse.UnitRay)
		-- don't move with dragger - will move in one step on mouse down
		-- draw ghost at acceptable positions
		configFound, targetCFrame, targetSurface = findConfigAtMouseTarget(Data.Stamp.TransparencyTable)
		if configFound then

				if autoAlignToFace() and targetSurface ~= 1 and targetSurface ~= 4 then
				-- pre-rotate the flag or portrait so it's aligned correctly
				--local currCFrame
				--if Data.Stamp.CurrentParts[1]:IsA("Model") or Data.Stamp.CurrentParts[1]:IsA("Tool") then currCFrame = Data.Stamp.CurrentParts[1]:GetModelCFrame()
				--else currCFrame = Data.Stamp.CurrentParts[1].CFrame end

				local numRotations = 0 -- update this according to how many rotations you need to get it to target surface
				if targetSurface == 3 then numRotations = 0 - gInitial90DegreeRotations + autoAlignToFace()
				elseif targetSurface == 0 then numRotations = 2 - gInitial90DegreeRotations + autoAlignToFace()
				elseif targetSurface == 5 then numRotations = 3 - gInitial90DegreeRotations + autoAlignToFace()
				elseif targetSurface == 2 then numRotations = 1 - gInitial90DegreeRotations + autoAlignToFace() end
				

				local ry = math.pi/2
				local rotCF = CFrame.fromEulerAnglesXYZ(0, ry*numRotations, 0)
				gInitial90DegreeRotations = gInitial90DegreeRotations + numRotations
				if Data.Stamp.CurrentParts[1]:IsA("Model") or Data.Stamp.CurrentParts[1]:IsA("Tool") then
					for i, object in pairs(Data.Stamp.CurrentParts[1]:GetChildren()) do
						if object:IsA("Flag") then object = object.Handle end
						if object:IsA("Part") or object:IsA("TrussPart") or object:IsA("WedgePart") or object:IsA("CornerWedgePart") or object:IsA("Seat") or object:IsA("VehicleSeat") then
							object.CFrame = rotCF * object.CFrame
						end
					end
				else
					Data.Stamp.CurrentParts[1].CFrame = rotCF * Data.Stamp.CurrentParts[1].CFrame
				end
			end



			-- CODE TO CHECK FOR DRAGGING GHOST PART INTO A COLLIDING STATE
			local minBB, maxBB = getBoundingBoxInWorldCoordinates(Data.Stamp.CurrentParts[1])
	
			-- need to offset by distance to be dragged
			local currModelCFrame
			if Data.Stamp.CurrentParts[1]:IsA("Model") then
				-- we assume model has at least one part in it; need to find first part
				i = 1
				while i < (#Data.Stamp.CurrentParts[1]:GetChildren()) and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("BasePart") do
					i = i + 1
				end
				currModelCFrame = Data.Stamp.CurrentParts[1]:GetChildren()[i].CFrame
			else currModelCFrame = Data.Stamp.CurrentParts[1].CFrame end
			minBB = minBB + targetCFrame.p - currModelCFrame.p
			maxBB = maxBB + targetCFrame.p - currModelCFrame.p

			-- don't drag into terrain
			if clusterPartsInRegion(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector) then 
				if lastTargetCFrame then 
					positionPartsAtCFrame3(thingToDrag, lastTargetCFrame) 
					if (Data.Stamp.CurrentParts[1].Name == "MegaClusterCube") and (Data.Stamp.CurrentParts[1]:FindFirstChild("ClusterMaterial")) and (Data.Stamp.CurrentParts[1].ClusterMaterial:IsA("Vector3Value")) then 
						local clusterMat = Data.Stamp.CurrentParts[1].ClusterMaterial
						clusterMat.Value = Vector3.new(clusterMat.Value.X, clusterMat.Value.Y, lastTargetTerrainOrientation)
					end
				end
				Data.Stamp.MovingLock = false
				return 
			end
			
			local blockingParts = game.Workspace:FindPartsInRegion3(Region3.new(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector), currentSelection, 100)
			for b = 1, #blockingParts do
				-- put code back here if we want to prevent stamper from dragging ghost parts into other stamped models (once Region3 fix goes out)
			end

			positionPartsAtCFrame3(Data.Stamp.CurrentParts[1], targetCFrame)
			lastTargetCFrame = targetCFrame  -- successful positioning, so update 'dat cframe
			if (Data.Stamp.CurrentParts[1].Name == "MegaClusterCube") and (Data.Stamp.CurrentParts[1]:FindFirstChild("ClusterMaterial")) and (Data.Stamp.CurrentParts[1].ClusterMaterial:IsA("Vector3Value")) then lastTargetTerrainOrientation = Data.Stamp.CurrentParts[1].ClusterMaterial.Value.Z end


			-- auto break joints code
			if Mouse and Mouse.Target and Mouse.Target.Parent then
				local modelInfo = Mouse.Target:FindFirstChild("RobloxModel")
				if not modelInfo then modelInfo = Mouse.Target.Parent:FindFirstChild("RobloxModel") end
				
				local myModelInfo = Data.Stamp.CurrentParts[1]:FindFirstChild("UnstampableFaces")

				--if (modelInfo and modelInfo.Parent:FindFirstChild("UnstampableFaces")) or (modelInfo and myModelInfo) then  -- need better targetSurface calcs
				if (true) then
					local breakingFaces = ""
					local myBreakingFaces = ""
					if modelInfo and modelInfo.Parent:FindFirstChild("UnstampableFaces") then breakingFaces = modelInfo.Parent.UnstampableFaces.Value end
					if myModelInfo then myBreakingFaces = myModelInfo.Value end
					local hitFace = 0

					if modelInfo then hitFace = modelTargetSurface(modelInfo.Parent, game.Workspace.CurrentCamera.CoordinateFrame.p, Mouse.Hit.p) end

					-- are we stamping TO an unstampable surface?
					for bf in string.gmatch(breakingFaces, "[^,]+") do
						if hitFace == tonumber(bf) then
							-- return before we hit the JointsService code below!
							unstampableSurface = true
							game.JointsService:ClearJoinAfterMoveJoints() -- clear the JointsService cache
							Data.Stamp.MovingLock = false
							return
						end
					end

					-- now we have to cast the ray back in the other direction to find the surface we're stamping FROM
					hitFace = modelTargetSurface(Data.Stamp.CurrentParts[1], Mouse.Hit.p, game.Workspace.CurrentCamera.CoordinateFrame.p)

					-- are we stamping WITH an unstampable surface?
					for bf in string.gmatch(myBreakingFaces, "[^,]+") do
						if hitFace == tonumber(bf) then
							unstampableSurface = true
							game.JointsService:ClearJoinAfterMoveJoints() -- clear the JointsService cache
							Data.Stamp.MovingLock = false
							return
						end
					end

					-- just need to match breakingFace against targetSurface using rotation supplied by modelCFrame
					-- targetSurface: 1 is top, 4 is bottom, 
				end
			end

		end

		-- to show joints during the mouse move
		unstampableSurface = false
      game.JointsService:SetJoinAfterMoveInstance(Data.Stamp.CurrentParts[1])

		-- most common mouse inactive error occurs here, so check mouse active one more time in a pcall
		if not pcall(function () if Mouse and Mouse.Target and Mouse.Target.Parent:FindFirstChild("RobloxModel") == nil then return true else return false end end) then print("ERRORED OUT") game.JointsService:ClearJoinAfterMoveJoints() Mouse = nil Data.Stamp.MovingLock = false return end

      if Mouse and Mouse.Target and Mouse.Target.Parent:FindFirstChild("RobloxModel") == nil then
			game.JointsService:SetJoinAfterMoveTarget(Mouse.Target)
      else
			game.JointsService:SetJoinAfterMoveTarget(nil)
      end
      game.JointsService:ShowPermissibleJoints()

		-- here we allow for a line of high-scalability parts
		if (Data.Stamp.CurrentParts[1] and Data.Stamp.CurrentParts[1].Name == "MegaClusterCube") and HighScalabilityLine.Start then
			HighScalabilityLine.End = Data.Stamp.CurrentParts[1].CFrame.p

			local line
			local line2 = Vector3.new(0, 0, 0)
			local line3 = Vector3.new(0, 0, 0)

			if HighScalabilityLine.Dimensions == 1 then
				-- extract the line from these positions and limit to a 2D plane made from 2 of the world axes
				--   then use dominating axis to limit line to be at 45-degree intervals
				--   will use this internal representation of the line for the actual stamping
				line = (HighScalabilityLine.End - HighScalabilityLine.Start)

				if math.abs(line.X) < math.abs(line.Y) then
					if math.abs(line.X) < math.abs(line.Z) then
						-- limit to Y/Z plane, domination unknown
						local newY, newZ
						if (math.abs(line.Y) > math.abs(line.Z)) then 
							newY, newZ = truncateToCircleEighth(line.Y, line.Z)
						else 
							newZ, newY = truncateToCircleEighth(line.Z, line.Y)
						end
						line = Vector3.new(0, newY, newZ)
					else
						-- limit to X/Y plane, with Y dominating
						local newY, newX = truncateToCircleEighth(line.Y, line.X)
						line = Vector3.new(newX, newY, 0)
					end
				else
					if math.abs(line.Y) < math.abs(line.Z) then
						-- limit to X/Z plane, domination unknown
						local newX, newZ
						if math.abs(line.X) > math.abs(line.Z) then
							newX, newZ = truncateToCircleEighth(line.X, line.Z)
						else
							newZ, newX = truncateToCircleEighth(line.Z, line.X)
						end
						line = Vector3.new(newX, 0, newZ)
					else 
						-- limit to X/Y plane, with X dominating
						local newX, newY = truncateToCircleEighth(line.X, line.Y)
						line = Vector3.new(newX, newY, 0)
					end
				end
				HighScalabilityLine.InternalLine = line

			elseif HighScalabilityLine.Dimensions == 2 then
				line = HighScalabilityLine.MoreLines[1]
				line2 = HighScalabilityLine.End - HighScalabilityLine.MorePoints[1]
		
				-- take out any component of line2 along line1, so you get perpendicular to line1 component
				line2 = line2 - line.unit*line.unit:Dot(line2)

				tempCFrame = CFrame.new(HighScalabilityLine.Start, HighScalabilityLine.Start + line)

				-- then zero out whichever is the smaller component
				local yAxis = tempCFrame:vectorToWorldSpace(Vector3.new(0, 1, 0))
				local xAxis = tempCFrame:vectorToWorldSpace(Vector3.new(1, 0, 0))
				
				local xComp = xAxis:Dot(line2)
				local yComp = yAxis:Dot(line2)

				if math.abs(yComp) > math.abs(xComp) then
					line2 = line2 - xAxis*xComp
				else
					line2 = line2 - yAxis*yComp
				end

				HighScalabilityLine.InternalLine = line2
			elseif HighScalabilityLine.Dimensions == 3 then
				line = HighScalabilityLine.MoreLines[1]
				line2 = HighScalabilityLine.MoreLines[2]
				line3 = HighScalabilityLine.End - HighScalabilityLine.MorePoints[2]

				-- zero out all components of previous lines
				line3 = line3 - line.unit*line.unit:Dot(line3)
				line3 = line3 - line2.unit*line2.unit:Dot(line3)

				HighScalabilityLine.InternalLine = line3
			end

			-- resize the "line" graphic to be the correct size and orientation
			tempCFrame = CFrame.new(HighScalabilityLine.Start, HighScalabilityLine.Start + line)
			
			if HighScalabilityLine.Dimensions == 1 then  -- faster calculation for line
				HighScalabilityLine.AdornPart.Size = Vector3.new(4, 4, line.magnitude + 4)
				HighScalabilityLine.AdornPart.CFrame = tempCFrame + tempCFrame:vectorToWorldSpace(Vector3.new(2, 2, 2) - HighScalabilityLine.AdornPart.Size/2)
			else
				local boxSize = tempCFrame:vectorToObjectSpace(line + line2 + line3)
				HighScalabilityLine.AdornPart.Size = Vector3.new(4, 4, 4) + Vector3.new(math.abs(boxSize.X), math.abs(boxSize.Y), math.abs(boxSize.Z))
				HighScalabilityLine.AdornPart.CFrame = tempCFrame + tempCFrame:vectorToWorldSpace(boxSize/2)
			end

			-- make player able to see this ish
			if player then HighScalabilityLine.Adorn.Parent = player.PlayerGui end
			if HighScalabilityLine.NewHint then 
				if HighScalabilityLine.Dimensions == 1 and line and (line.magnitude > 4) then hint("Press C to stamp in 2D") HighScalabilityLine.NewHint = false  
				elseif HighScalabilityLine.Dimensions == 2 and line2 and (line2.magnitude > 4) then hint("Press C again to stamp in 3D") HighScalabilityLine.NewHint = false 
				elseif HighScalabilityLine.Dimensions == 3 then HighScalabilityLine.NewHint = false end  -- if we do cyclic, then let them know they're going back to line stamping
			end
		end
	end

	Data.Stamp.MovingLock = false

end


function onInsertMouseButton1Down()

	if Data.Stamp.Dragger or Data.Stamp.Decal then
		Data.Stamp.MouseDown = true
	end

	if (Data.Stamp.CurrentParts and Data.Stamp.CurrentParts[1] and Data.Stamp.CurrentParts[1].Name == "MegaClusterCube") and not eyeDropperConnection then
			-- only let them drag if they start dragging on the cluster!
			if Mouse and Mouse.Target and Mouse.Target:IsA("Terrain") then
				HighScalabilityLine.Dimensions = 1
				HighScalabilityLine.Start = Data.Stamp.CurrentParts[1].CFrame.p
			end
	end
end


function cancelAssetPlacement()
	HighScalabilityLine.Start = nil
	HighScalabilityLine.Adorn.Parent = nil

	gInitial90DegreeRotations = 0
	Data.Stamp.Cancelled = true

	if Data.Stamp["Model"] then
		Data.Stamp.Model.Parent = nil
	end

	if Data.Stamp.CurrentParts then
		for index, object in pairs(Data.Stamp.CurrentParts) do
			object.Parent = nil
		end
	
		Data.Stamp.CurrentParts.Parent = nil
	end

	if Data.Stamp.DecalSelection then
		Data.Stamp.DecalSelection:Remove()
		Data.Stamp.DecalSelection = nil
	end
	if Data.Stamp.Decal then
		Data.Stamp.Decal:Remove()
		Data.Stamp.Decal = nil
	end

	if Mouse then
		Mouse.Icon = "http://www.roblox.com/asset?id=66887745"
	end
	game.JointsService:ClearJoinAfterMoveJoints()

end


function collectParts(object, baseParts, scripts, decals)

	if object:IsA("BasePart") then
		baseParts[#baseParts+1] = object
	elseif object:IsA("Script") then
		scripts[#scripts+1] = object
	elseif object:IsA("Decal") then
		decals[#decals+1] = object
	end

	for index,child in pairs(object:GetChildren()) do
		collectParts(child, baseParts, scripts, decals)
	end

end

function getTargetPartBoundingBox(targetPart)

	if targetPart.Parent:FindFirstChild("RobloxModel") ~= nil then
		return getBoundingBox2(targetPart.Parent)
	else
		return getBoundingBox2(targetPart)
	end

end


function getBoundingBox2(partOrModel)

-- for models, the bounding box is defined as the minimum and maximum individual part bounding boxes
-- relative to the first part's coordinate frame.

	local minVec = Vector3.new(math.huge, math.huge, math.huge)
	local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

	if partOrModel:IsA("Part") or partOrModel:IsA("WedgePart") or partOrModel:IsA("CornerWedgePart") or partOrModel:IsA("TrussPart")then
		minVec = -0.5 * partOrModel.Size
		maxVec = -minVec
	elseif partOrModel:IsA("Terrain") then
		minVec = Vector3.new(-2, -2, -2)
		maxVec = Vector3.new(2, 2, 2)
	else
		local part1 = partOrModel:GetChildren()[1]
		if partOrModel:IsA("Tool") then part1 = partOrModel.Handle if not part1 then return end end
		if part1:IsA("Flag") then part1 = partOrModel:FindFirstChild("Part") if not part1 then return end end
		for i, object in pairs(partOrModel:GetChildren()) do
			if (object:IsA("Part") or object:IsA("WedgePart") or object:IsA("CornerWedgePart") or object:IsA("TrussPart")) then
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

	-- Adjust bounding box to reflect what the model or part author wants in  terms of justification
	local justifyValue = partOrModel:FindFirstChild("Justification")
	if justifyValue ~= nil then
		-- find the multiple of 4 that contains the model
		justify = justifyValue.Value
		two = Vector3.new(2, 2, 2)
		actualBox = maxVec - minVec - Vector3.new(0.01, 0.01, 0.01)
		containingGridBox = Vector3.new(4 * math.ceil(actualBox.x/4), 4 * math.ceil(actualBox.y/4), 4 * math.ceil(actualBox.z/4))
		adjustment = containingGridBox - actualBox
		minVec = minVec - 0.5 * adjustment * justify
		maxVec = maxVec + 0.5 * adjustment * (two - justify)
	end

	return minVec, maxVec

end


function getBoundingBoxInWorldCoordinates(partOrModel)
	local minVec = Vector3.new(math.huge, math.huge, math.huge)
	local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

	if partOrModel:IsA("BasePart")then
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
			if object:IsA("BasePart") then
				boxMinInWorld = object.CFrame:pointToWorldSpace(-0.5 * object.Size)
				boxMaxInWorld = object.CFrame:pointToWorldSpace(0.5 * object.Size)

				local minX = minVec.x
				local minY = minVec.y
				local minZ = minVec.z
				local maxX = maxVec.x
				local maxY = maxVec.y
				local maxZ = maxVec.z
				if boxMinInWorld.x < minX then
					minX = boxMinInWorld.x
				end
				if boxMinInWorld.y < minY then
					minY = boxMinInWorld.y
				end
				if boxMinInWorld.z < minZ then
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

				if boxMinInWorld.x > maxX then
					maxX = boxMinInWorld.x
				end
				if boxMinInWorld.y > maxY then
					maxY = boxMinInWorld.y
				end
				if boxMinInWorld.z > maxZ then
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


function getMouseTargetCFrame(targetPart)

	if targetPart.Parent:FindFirstChild("RobloxModel") ~= nil then
		if targetPart.Parent:IsA("Tool") then return targetPart.Parent.Handle.CFrame
		else return targetPart.Parent:GetChildren()[1].CFrame end
	else
		return targetPart.CFrame
	end

end


function surfaceToVector(surf)
	local vect = 1
	if surf < 0 then
		surf = surf * -1
		vect = vect * -1
	end
	if surf == 1 then return vect*Vector3.new(1, 0, 0)
	elseif surf == 2 then return vect*Vector3.new(0, 1, 0)
	elseif surf == 3 then return vect*Vector3.new(0, 0, 1)
	elseif Mouse then return Vector3.FromNormalId(Mouse.TargetSurface) end  -- if we somehow got a "0", then we just revert to old behavior
	return Vector3.new(0,0,0)
end

function findConfigAtMouseTarget(partsTable)

-- *Critical Assumption* :
--				This function assumes the target CF axes are orthogonal with the target bounding box faces
--				And, it assumes the insert CF axes are orthongonal with the insert bounding box faces
--				Therefore, insertion will not work with angled faces on wedges or other "non-block" parts, nor
--				will it work for parts in a model that are not orthogonally aligned with the model's CF.

	local grid = 4.0
	local admissibleConfig = false
	local targetConfig = CFrame.new(0,0,0)

	local minBB, maxBB = getBoundingBox2(Data.Stamp.CurrentParts[1])
	local diagBB = maxBB - minBB

	local insertCFrame
	if Data.Stamp.CurrentParts[1]:IsA("Model") or Data.Stamp.CurrentParts[1]:IsA("Tool") then
		i = 1
		while (i < (#Data.Stamp.CurrentParts[1]:GetChildren()) and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("Part") and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("TrussPart") and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("WedgePart") and not Data.Stamp.CurrentParts[1]:GetChildren()[i]:IsA("CornerWedgePart")) do
			i = i + 1
		end
		insertCFrame = Data.Stamp.CurrentParts[1]:GetChildren()[i].CFrame
	else
		insertCFrame = Data.Stamp.CurrentParts[1].CFrame
	end

	if not isRestricted and Mouse then
		if Data.Stamp.CurrentParts[1]:IsA("Tool") then Mouse.TargetFilter = Data.Stamp.CurrentParts[1].Handle
		else Mouse.TargetFilter = Data.Stamp.CurrentParts[1] end
	end

	local targetPart = nil
	local success = pcall(function() targetPart = Mouse.Target end)

	if not success or targetPart == nil then
		return admissibleConfig, targetConfig
	end

	-- test mouse hit location
	local minBBTarget, maxBBTarget = getTargetPartBoundingBox(targetPart)
	local diagBBTarget = maxBBTarget - minBBTarget
	local targetCFrame = getMouseTargetCFrame(targetPart)
	local hitCFrame = CFrame.new(0,0,0)
	if Mouse then
		hitCFrame = Mouse.Hit
	end
	local mouseHitInWorld = hitCFrame.p

	-- find which axis of the insertion objects should match with the target surface
	-- this should use targetPart CFrame, not the model CFrame

	--[[ attempt at fixing Mouse.TargetSurface below...
	local targetModel = targetPart
	if not targetPart:FindFirstChild("RobloxModel") and targetPart.Parent and targetPart.Parent:FindFirstChild("RobloxModel") then targetModel = targetPart.Parent end
	local correctedTargetSurfaceVector = surfaceToVector(modelTargetSurface(targetModel, game.Workspace.CurrentCamera.CoordinateFrame.p, mouseHitInWorld))
	local targetVectorInWorld = targetPart.CFrame:vectorToWorldSpace(correctedTargetSurfaceVector)
	--]]

	if targetPart:IsA("Terrain") then
		if not cluster then cluster = game.Workspace.Terrain end

		cellID = cluster:WorldToCellPreferSolid(mouseHitInWorld)
		targetCFrame = CFrame.new(cluster:CellCenterToWorld(cellID.x, cellID.y, cellID.z))
	end
	
	local mouseHitInTarget = targetCFrame:pointToObjectSpace(mouseHitInWorld)
	local targetVectorInWorld = Vector3.new(0,0,0)
	if Mouse then
		targetVectorInWorld = targetCFrame:vectorToWorldSpace(Vector3.FromNormalId(Mouse.TargetSurface))
	end


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

	return admissibleConfig, targetConfig, getClosestAlignedWorldDirection(targetVectorInWorld)

end

function checkPartLimit()

	local numPoints = player.PointsUsed.Value
	local maxPoints = player.MaxPoints.Value

	if numPoints < maxPoints then
		return true
	else
		return false
	end

	return true
end

function setupDraggableClone()
	if eyeDropperConnection then eyeDropperConnection:disconnect() eyeDropperConnection = nil end

	--if not Mouse.Target then return end
	click.Value = false

	if Data.Stamp.CurrentParts then
		for i = 1, #Data.Stamp.CurrentParts do
			if Data.Stamp.CurrentParts[i].Parent ~= nil then
				Data.Stamp.CurrentParts[i].Parent = partModel
			end
		end
	end
	
	if Data.Stamp["Model"] == nil then return end

	local clone = Data.Stamp.Model:Clone()
	local scripts = {}
	local parts = {}
	local decals = {}
	
	collectParts(clone, parts, scripts, decals)

	if #parts > 0 then
		Data.Stamp.DisabledScripts = {}
		Data.Stamp.TransparencyTable = {}
		Data.Stamp.MaterialTable = {}
		Data.Stamp.CanCollideTable = {}
		Data.Stamp.AnchoredTable = {}
		Data.Stamp.DecalTransparencyTable = {}

		for index,script in pairs(scripts) do
			if not(script.Disabled) then
				script.Disabled = true
				Data.Stamp.DisabledScripts[#Data.Stamp.DisabledScripts +1] = script
			end
		end
		for index, part in pairs(parts) do
			Data.Stamp.TransparencyTable[part] = part.Transparency
			part.Transparency = gStaticTrans + (1-gStaticTrans)*part.Transparency
			Data.Stamp.MaterialTable[part] = part.Material
			part.Material = Enum.Material.Plastic
			Data.Stamp.CanCollideTable[part] = part.CanCollide
			part.CanCollide = false
			Data.Stamp.AnchoredTable[part] = part.Anchored
			part.Anchored = true
			part.archivable = false

			delay(0,function()
				local con = nil
				local exitLoop = false
				con = click.Changed:connect(function()
					if click.Value then
						con:disconnect()
						exitLoop = true
					end
				end)
				wait(fadeInDelayTime) -- give it some time to be completely transparent

				if exitLoop then return end -- if we already stamped, we don't need to do the rest of this
				
				local begTime = tick()
				local currTime = begTime
				while (currTime - begTime) < transFadeInTime and part and part:IsA("BasePart") and part.Transparency > gDesiredTrans and not exitLoop do
					local newTrans = 1 - (((currTime - begTime)/transFadeInTime) * (gStaticTrans - gDesiredTrans))
					if Data.Stamp.TransparencyTable[part] then part.Transparency = newTrans + (1-newTrans) * Data.Stamp.TransparencyTable[part] end
					wait(0.03)
					currTime = tick()
				end
				if part and part:IsA("BasePart") and not exitLoop then
					if Data.Stamp.TransparencyTable[part] then part.Transparency = gDesiredTrans + (1-gDesiredTrans)*Data.Stamp.TransparencyTable[part] end
				end
				if con then con:disconnect() end
			end)
		end

		for index, decal in pairs(decals) do
			Data.Stamp.DecalTransparencyTable[decal] = decal.Transparency
			decal.Transparency = gDesiredTrans + (1-gDesiredTrans)*decal.Transparency
		end
		
		clone.Parent = game.Workspace

		-- For Restricting Stamper Tool
		if(isRestricted) then

			-- mark a particular spot in BaseplateBumpers, so we can remove any stragglers later, when player leaves
			local cloneInsertionSpot = game.Workspace.BaseplateBumpers:FindFirstChild(player.Name)
			if cloneInsertionSpot == nil then
				cloneInsertionSpot = Instance.new("Model")
				cloneInsertionSpot.Name = player.Name
				cloneInsertionSpot.Parent = game.Workspace.BaseplateBumpers
			end

			clone.Parent = cloneInsertionSpot
		end

		-- disable all seats
		setSeatEnabledStatus(clone, true)
		setSeatEnabledStatus(clone, false)

		Data.Stamp.CurrentParts = clone:GetChildren()

		-- if auto-alignable, we enforce a pre-rotation to the canonical "0-frame"
		if autoAlignToFace() then
			if Data.Stamp.CurrentParts[1].PrimaryPart then modelInverse = Data.Stamp.CurrentParts[1].PrimaryPart.CFrame:inverse()
			else modelInverse = Data.Stamp.CurrentParts[1]:GetModelCFrame():inverse() end
			for i, object in pairs(Data.Stamp.CurrentParts[1]:GetChildren()) do
				if object:IsA("Flag") then object = object.Handle end
				if object:IsA("Part") or object:IsA("TrussPart") or object:IsA("WedgePart") or object:IsA("CornerWedgePart") or object:IsA("Seat") or object:IsA("VehicleSeat") then object.CFrame = modelInverse*object.CFrame end
			end
			gInitial90DegreeRotations = 0
		else

		-- pre-rotate if necessary
		local ry = gInitial90DegreeRotations * math.pi/2
		local rotCF = CFrame.fromEulerAnglesXYZ(0, ry, 0) 
		if Data.Stamp.CurrentParts[1]:IsA("Model") or Data.Stamp.CurrentParts[1]:IsA("Tool") then
			for i, object in pairs(Data.Stamp.CurrentParts[1]:GetChildren()) do
				if object:IsA("Flag") then object = object.Handle end
				if object:IsA("Part") or object:IsA("TrussPart") or object:IsA("WedgePart") or object:IsA("CornerWedgePart") or object:IsA("Seat") or object:IsA("VehicleSeat") then object.CFrame = rotCF * object.CFrame end
			end
		else
			Data.Stamp.CurrentParts[1].CFrame = rotCF * Data.Stamp.CurrentParts[1].CFrame
		end
		end

		-- After rotating, update the position
		configFound, targetCFrame = findConfigAtMouseTarget(Data.Stamp.TransparencyTable)
		if configFound then
			positionPartsAtCFrame3(Data.Stamp.TransparencyTable, targetCFrame)
		end
		-- to show joints during the mouse move
      game.JointsService:SetJoinAfterMoveInstance(Data.Stamp.CurrentParts[1])

		local mouseTarget = nil
		pcall(function() mouseTarget = Mouse.Target end)

      if mouseTarget and mouseTarget.Parent:FindFirstChild("RobloxModel") == nil then
			game.JointsService:SetJoinAfterMoveTarget(mouseTarget)
      else
			game.JointsService:SetJoinAfterMoveTarget(nil)
		end
      game.JointsService:ShowPermissibleJoints()

		for index, object in pairs(Data.Stamp.CurrentParts) do
			object.Parent = clone.Parent
		end

		clone:Remove()

		lastTargetCFrame = nil

	
		if billBoardOwnerGui then
			if #parts == 1 then
				billBoardOwnerGui.Parent = parts[1]
			else
				billBoardOwnerGui.Parent = parts[1].Parent
			end
		end

		HighScalabilityLine.NewHint = true -- show hint if they start dragging a high-scalability part

		Data.Stamp.Dragger = Instance.new("Dragger")
		--Begin a movement by faking a MouseDown signal
		Data.Stamp.Dragger:MouseDown(parts[1], Vector3.new(0,0,0), parts)
		Data.Stamp.Dragger:MouseUp()
	else
		--Nothing draggable in the Model
		Data.Stamp.Model:Remove()
		Data.Stamp.Model = nil
		Data.Stamp.TransparencyTable = nil
		Data.Stamp.MaterialTable = nil
		Data.Stamp.CanCollideTable = nil
		Data.Stamp.AnchoredTable = nil
		Data.Stamp.DisabledScripts = nil
	end

end


function noManualWelds(part)
	local partChildren = part:GetChildren()
	for i = 1, #partChildren do
		if partChildren[i]:IsA("ManualWeld") or partChildren[i]:IsA("Rotate") then
			return false
		end
	end
	return true
end

local debris = game:GetService("Debris")
function flashRedBox()
	errorBox.Parent = player.PlayerGui
	if Data.Stamp.CurrentParts[1]:IsA("Tool") then errorBox.Adornee = Data.Stamp.CurrentParts[1].Handle
	else errorBox.Adornee = Data.Stamp.CurrentParts[1] end

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

-- helper function to determine if a character can be pushed upwards by a certain amount
-- character is 5 studs tall, we'll check a 1.5 x 1.5 x 4.5 box around char, with center .5 studs below torsocenter
function spaceAboveCharacter(charTorso, newTorsoY)
	local partsAboveChar = game.Workspace:FindPartsInRegion3(Region3.new(Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) - Vector3.new(.75, 2.75, .75), Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) + Vector3.new(.75, 1.75, .75)), charTorso.Parent, 100)
	for j = 1, #partsAboveChar do
		if partsAboveChar[j].CanCollide and not partsAboveChar[j]:IsDescendantOf(Data.Stamp.CurrentParts[1]) then return false end
	end

	if clusterPartsInRegion(Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) - Vector3.new(.75, 2.75, .75), Vector3.new(charTorso.Position.X, newTorsoY, charTorso.Position.Z) + Vector3.new(.75, 1.75, .75)) then return false end

	return true
end


-- returns whether or not we want to cancel the stamp because we're blocked by this part
function isBlocker(part)
	if not part then return false end
	if not part.Parent then return false end
	if part:FindFirstChild("Humanoid") then return false end
	if part:FindFirstChild("RobloxStamper") or part:FindFirstChild("RobloxModel") then return true end
	if part:IsA("Part") and not part.CanCollide then return false end
	if part == game.Workspace then return true end
	if part == game.Lighting then return false end
	return isBlocker(part.Parent)
end

function onInsertMouseButton1Up()
	if guiScriptIsLoadingSomething or variables.InsertAsset.Updated.Value then return end -- don't try to stamp while we're loading!

	if eyeDropperConnection then 
		eyeDropperConnection:disconnect()
		eyeDropperConnection = nil
		return
	end

	if Data.Stamp.MouseDown then
		Data.Stamp.MouseDown = false
		if Data.Stamp.Dragger then

			--Place the object where the mouse is currently positioned
			-- For Restricting Stamper Tool

			while Data.Stamp.MouseLock do wait() end
			onInsertMouseMove()
			Data.Stamp.MouseLock = true

			if(isRestricted) then
				-- if player tries to stamp out of bounds, tell them they can't
				if not inBounds(Data.Stamp.TransparencyTable) then
					variables.ShowInvalidPlacement.Value = true
					Data.Stamp.MouseLock = false
					HighScalabilityLine.Start = nil
					HighScalabilityLine.Adorn.Parent = nil
					return
				end
			end

			-- if unstampable face, then don't let us stamp there!
			if unstampableSurface then
				Data.Stamp.MouseLock = false
				HighScalabilityLine.Start = nil
				HighScalabilityLine.Adorn.Parent = nil
				flashRedBox()
				return
			end

			-- Prevent part from being stamped on top of a player

			local minBB, maxBB = getBoundingBoxInWorldCoordinates(Data.Stamp.CurrentParts[1])
			local configFound, targetCFrame = findConfigAtMouseTarget(Data.Stamp.TransparencyTable)

			if configFound and not HighScalabilityLine.Adorn.Parent then
				if clusterPartsInRegion(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector) then Data.Stamp.MouseLock = false flashRedBox() return end

				local blockingParts = game.Workspace:FindPartsInRegion3(Region3.new(minBB+insertBoundingBoxOverlapVector, maxBB-insertBoundingBoxOverlapVector), Data.Stamp.CurrentParts[1], 100)
				for b = 1, #blockingParts do
					-- below if we only want to block stamping on self
					--if blockingParts[b].Parent == script.Parent.Parent then return end
					
					-- below if we want to block stamping on self and also stamping that intersects a model we've previously stamped on our baseplate
					--		  should work as soon as Region3 queries are fixed
					--      NOTE TO SELF:  See if partModel applies when isRestricted is false
					--if blockingParts[b]:IsDescendantOf(partModel) or blockingParts[b].Parent == script.Parent.Parent then Data.Stamp.MouseLock = false flashRedBox() break end --return end
					if isBlocker(blockingParts[b]) then Data.Stamp.MouseLock = false flashRedBox() return end-- still error if overlapping another model [should return here too!]
				end

				local alreadyPushedUp = {}
				-- if no blocking model below, then see if stamping on top of a character
				for b = 1, #blockingParts do
					--if blockingParts[b].Parent == script.Parent.Parent then
--						local blockingPersonTorso = script.Parent.Parent:FindFirstChild("Torso")
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
								Data.Stamp.MouseLock = false
								flashRedBox()
								return
								-- should return here too!
							end
						end
						
						--break
					end
				end
			elseif (not configFound) then
				HighScalabilityLine.Start = nil
				HighScalabilityLine.Adorn.Parent = nil
				Data.Stamp.MouseLock = false 
				return 
			end -- if no config then don't stamp!

			-- something will be stamped!  so set the "StampedSomething" toggle to true
			local localChar = game.Players.LocalPlayer.Character
			if localChar then
				local stampTracker = localChar:FindFirstChild("StampTracker")
				if stampTracker and not stampTracker.Value then stampTracker.Value = true end
			end

			-- also, show hints again if high scalability part
			HighScalabilityLine.NewHint = true

			if Data.Stamp.Model and Data.Stamp.Model:GetChildren()[1] and Data.Stamp.Model:GetChildren()[1].Name == "MegaClusterCube" then
					local line = HighScalabilityLine.InternalLine
					local cMax = game.Workspace.Terrain.MaxExtents.Max
					local cMin = game.Workspace.Terrain.MaxExtents.Min

					local clusterMaterial = 1 -- default is grass
					local clusterType = 0 -- default is brick
					local clusterOrientation = 0 -- default is 0 rotation

					local autoWedgeClusterParts = false
					if Data.Stamp.CurrentParts[1]:FindFirstChild("AutoWedge") then autoWedgeClusterParts = true end

					if Data.Stamp.CurrentParts[1]:FindFirstChild("ClusterMaterial") then
						clusterMaterial = Data.Stamp.CurrentParts[1].ClusterMaterial
						if (clusterMaterial:IsA("Vector3Value")) then
							-- extract all info from vector
							clusterType = clusterMaterial.Value.Y
							clusterOrientation = clusterMaterial.Value.Z
							clusterMaterial = clusterMaterial.Value.X
						else
							clusterMaterial = clusterMaterial.Value
						end
					end
		
					if HighScalabilityLine.Adorn.Parent and HighScalabilityLine.Start and ((HighScalabilityLine.Dimensions > 1) or (line and line.magnitude > 0)) then
						local startCell = game.Workspace.Terrain:WorldToCell(HighScalabilityLine.Start)

						local xInc = {0,0,0}
						local yInc = {0,0,0}
						local zInc = {0,0,0}
			
						local incrementVect = {nil, nil, nil}
						local stepVect = {Vector3.new(0, 0, 0), Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)}

						local worldAxes = {Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)}

						local lines = {}
						if HighScalabilityLine.Dimensions > 1 then table.insert(lines, HighScalabilityLine.MoreLines[1]) end
						if line and line.magnitude > 0 then table.insert(lines, line) end
						if HighScalabilityLine.Dimensions > 2 then table.insert(lines, HighScalabilityLine.MoreLines[2]) end

						for i = 1, #lines do
							lines[i] = Vector3.new(math.floor(lines[i].X+.5), math.floor(lines[i].Y+.5), math.floor(lines[i].Z+.5)) -- round to integers

							if lines[i].X > 0 then xInc[i] = 1 elseif lines[i].X < 0 then xInc[i] = -1 end
							if lines[i].Y > 0 then yInc[i] = 1 elseif lines[i].Y < 0 then yInc[i] = -1 end
							if lines[i].Z > 0 then zInc[i] = 1 elseif lines[i].Z < 0 then zInc[i] = -1 end

							incrementVect[i] = Vector3.new(xInc[i], yInc[i], zInc[i])
							if incrementVect[i].magnitude < .9 then incrementVect[i] = nil end
						end


						if not lines[2] then lines[2] = Vector3.new(0, 0, 0) end
						if not lines[3] then lines[3] = Vector3.new(0, 0, 0) end

						while (stepVect[3].magnitude*4 <= lines[3].magnitude) do
							local outerStepVectIndex = 1
							while outerStepVectIndex < 4 do
							stepVect[2] = Vector3.new(0, 0, 0)
						while (stepVect[2].magnitude*4 <= lines[2].magnitude) do
							local innerStepVectIndex = 1
							while innerStepVectIndex < 4 do
							stepVect[1] = Vector3.new(0, 0, 0)
						while (stepVect[1].magnitude*4 <= lines[1].magnitude) do
							local stepVectSum = stepVect[1] + stepVect[2] + stepVect[3]
							local cellPos = Vector3int16.new(startCell.X + stepVectSum.X, startCell.Y + stepVectSum.Y, startCell.Z + stepVectSum.Z)
							if cellPos.X >= cMin.X and cellPos.Y >= cMin.Y and cellPos.Z >= cMin.Z and cellPos.X < cMax.X and cellPos.Y < cMax.Y and cellPos.Z < cMax.Z then
								-- check if overlaps player or part:
								local cellCenter = game.Workspace.Terrain:CellCenterToWorld(cellPos.X, cellPos.Y, cellPos.Z)
								local cellBlockingParts = game.Workspace:FindPartsInRegion3(Region3.new(cellCenter - Vector3.new(2, 2, 2) + insertBoundingBoxOverlapVector, cellCenter + Vector3.new(2, 2, 2) - insertBoundingBoxOverlapVector), Data.Stamp.CurrentParts[1], 100)

								local skipThisCell = false
								for b = 1, #cellBlockingParts do
									if isBlocker(cellBlockingParts[b]) then skipThisCell = true break end
								end
								
								if not skipThisCell then
									-- pop players up above any set cells
									local alreadyPushedUp = {}
									-- if no blocking model below, then see if stamping on top of a character
									for b = 1, #cellBlockingParts do
										if cellBlockingParts[b].Parent and not alreadyPushedUp[cellBlockingParts[b].Parent] and cellBlockingParts[b].Parent:FindFirstChild("Humanoid") and cellBlockingParts[b].Parent:FindFirstChild("Humanoid"):IsA("Humanoid") then
											local blockingPersonTorso = cellBlockingParts[b].Parent:FindFirstChild("Torso")
											alreadyPushedUp[cellBlockingParts[b].Parent] = true

											if blockingPersonTorso then
												-- if so, let's push the person upwards so they pop on top of the stamped model/part (but only if there's space above them)
												local newY = cellCenter.Y + 5
												if spaceAboveCharacter(blockingPersonTorso, newY) then
													blockingPersonTorso.CFrame = blockingPersonTorso.CFrame + Vector3.new(0, newY - blockingPersonTorso.CFrame.p.Y, 0)
												else
													-- if no space, we just skip this one
													skipThisCell = true
													break
												end
											end
										end
									end
								end
						
								if not skipThisCell then  -- if we STILL aren't skipping...  then we're good to go!
									-- set it
									cluster:SetCell(cellPos.X, cellPos.Y, cellPos.Z, clusterMaterial, clusterType, clusterOrientation)
											
									-- auto-wedge it?
									if (autoWedgeClusterParts) then
										game.Workspace.Terrain:AutowedgeCells(Region3int16.new(Vector3int16.new(cellPos.x - 1, cellPos.y - 1, cellPos.z - 1), Vector3int16.new(cellPos.x + 1, cellPos.y + 1, cellPos.z + 1)))
									end
								end
							end

							stepVect[1] = stepVect[1] + incrementVect[1]
						end
							if incrementVect[2] then
								while innerStepVectIndex < 4 and worldAxes[innerStepVectIndex]:Dot(incrementVect[2]) == 0 do innerStepVectIndex = innerStepVectIndex + 1 end
								if innerStepVectIndex < 4 then 
									stepVect[2] = stepVect[2] + worldAxes[innerStepVectIndex]*worldAxes[innerStepVectIndex]:Dot(incrementVect[2])
								end
								innerStepVectIndex = innerStepVectIndex + 1
							else stepVect[2] = Vector3.new(1, 0, 0) innerStepVectIndex = 4 end -- skip all remaining loops
							if (stepVect[2].magnitude*4 > lines[2].magnitude) then innerStepVectIndex = 4 end
						end
						end
							wait()
							if incrementVect[3] then 
								while outerStepVectIndex < 4 and worldAxes[outerStepVectIndex]:Dot(incrementVect[3]) == 0 do outerStepVectIndex = outerStepVectIndex + 1 end
								if outerStepVectIndex < 4 then
									stepVect[3] = stepVect[3] + worldAxes[outerStepVectIndex]*worldAxes[outerStepVectIndex]:Dot(incrementVect[3]) 
								end
								outerStepVectIndex = outerStepVectIndex + 1
							else stepVect[3] = Vector3.new(1, 0, 0) outerStepVectIndex = 4 end -- skip all remaining loops
							if (stepVect[3].magnitude*4 > lines[3].magnitude) then outerStepVectIndex = 4 end
						end
						end

						-- and also get rid of any HighScalabilityLine stuff if it's there
						HighScalabilityLine.Start = nil
						HighScalabilityLine.Adorn.Parent = nil
						Data.Stamp.MouseLock = false
						return
					end

				-- not High-Scalability-Line-Based, so behave normally [and get rid of any HSL stuff]
				HighScalabilityLine.Start = nil
				HighScalabilityLine.Adorn.Parent = nil

				-- if target point is in cluster, just use cluster:SetCell
				if cluster then
					-- if targetCFrame is inside cluster, just set that cell to 1 and return
					local cellPos = cluster:WorldToCell(targetCFrame.p)

					if cellPos.X >= cMin.X and cellPos.Y >= cMin.Y and cellPos.Z >= cMin.Z and cellPos.X < cMax.X and cellPos.Y < cMax.Y and cellPos.Z < cMax.Z then
						cluster:SetCell(cellPos.X, cellPos.Y, cellPos.Z, clusterMaterial, clusterType, clusterOrientation)

						-- auto-wedge it
						if (autoWedgeClusterParts) then
							game.Workspace.Terrain:AutowedgeCells(Region3int16.new(Vector3int16.new(cellPos.x - 1, cellPos.y - 1, cellPos.z - 1), Vector3int16.new(cellPos.x + 1, cellPos.y + 1, cellPos.z + 1)))
						end

						Data.Stamp.MouseLock = false
						return
					end
				end
			end

			-- Post process: after positioning the part or model, restore transparency, material, anchored and collide states and create joints
			if Data.Stamp.CurrentParts[1]:IsA("Model") or Data.Stamp.CurrentParts[1]:IsA("Tool") then
				
				if Data.Stamp.CurrentParts[1]:IsA("Model") then
					-- Tyler's magical hack-code for allowing/preserving clones of both Surface and Manual Welds...  just don't ask X<
					manualWeldTable = {}
					manualWeldParentTable = {}
					saveTheWelds(Data.Stamp.CurrentParts[1])
					Data.Stamp.CurrentParts[1]:BreakJoints()
					Data.Stamp.CurrentParts[1]:MakeJoints()
					restoreTheWelds()
				end
				
				-- if it's a model, we also want to fill in the playerID and playerName tags, if it has those (e.g. for the friend-only door)
				playerIdTag = Data.Stamp.CurrentParts[1]:FindFirstChild("PlayerIdTag")
				playerNameTag = Data.Stamp.CurrentParts[1]:FindFirstChild("PlayerNameTag")
				if playerIdTag ~= nil then
					tempPlayerValue = getPlayer()
					if tempPlayerValue ~= nil then playerIdTag.Value = tempPlayerValue.userId end
				end
				if playerNameTag ~= nil then
					tempPlayerValue = getPlayer()
					if tempPlayerValue ~= nil then playerNameTag.Value = tempPlayerValue.Name end
				end
				-- ...and tag all inserted models for subsequent origin identification
				-- if no RobloxModel tag already exists, then add it.
				if Data.Stamp.CurrentParts[1]:FindFirstChild("RobloxModel") == nil then
					local stringTag = Instance.new("BoolValue", Data.Stamp.CurrentParts[1])
					stringTag.Name = "RobloxModel"

					if Data.Stamp.CurrentParts[1]:FindFirstChild("RobloxStamper") == nil then
						local stringTag2 = Instance.new("BoolValue", Data.Stamp.CurrentParts[1])
						stringTag2.Name = "RobloxStamper"
					end
				end

			else
				Data.Stamp.CurrentParts[1]:BreakJoints()
				if Data.Stamp.CurrentParts[1]:FindFirstChild("RobloxStamper") == nil then
					local stringTag2 = Instance.new("BoolValue", Data.Stamp.CurrentParts[1])
					stringTag2.Name = "RobloxStamper"
				end
			end
			
			-- make sure all the joints are activated before restoring anchor states
			if not createJoints then game.JointsService:CreateJoinAfterMoveJoints() end

			click.Value = true
			--Fix the transparency and material of all the parts
			for part, transparency in pairs(Data.Stamp.TransparencyTable) do
				part.Transparency = transparency
				part.archivable = true
			end
			for part, material in pairs(Data.Stamp.MaterialTable) do
				part.Material = material
			end
			for part, collide in pairs(Data.Stamp.CanCollideTable) do
				part.CanCollide = collide
			end
			for part, anchored in pairs(Data.Stamp.AnchoredTable) do
				part.Anchored = anchored
			end
			for decal, transparency in pairs(Data.Stamp.DecalTransparencyTable) do
				decal.Transparency = transparency
			end

			if (Data.Stamp.CurrentParts[1] and Data.Stamp.CurrentParts[1].Name == "MegaClusterCube") then
				Data.Stamp.CurrentParts[1].Transparency = 0
			end

			-- re-enable all seats
			setSeatEnabledStatus(Data.Stamp.CurrentParts[1], true)

			Data.Stamp.TransparencyTable = nil
			Data.Stamp.MaterialTable = nil
			Data.Stamp.CanCollideTable = nil
			Data.Stamp.AnchoredTable = nil

			-- ...and tag all inserted models for subsequent origin identification
			-- if no RobloxModel tag already exists, then add it.
			if Data.Stamp.CurrentParts[1]:FindFirstChild("RobloxModel") == nil then
				local stringTag = Instance.new("BoolValue", Data.Stamp.CurrentParts[1])
				stringTag.Name = "RobloxModel"
			end
						
			-- set our object back to the player's plate
			Data.Stamp.CurrentParts[1].Parent = partModel

			--Re-enable the scripts
			for index,script in pairs(Data.Stamp.DisabledScripts) do
				script.Disabled = false
			end
			--Now that they are all marked enabled, reinsert them into the world so they start running
			for index,script in pairs(Data.Stamp.DisabledScripts) do
				local oldParent = script.Parent
				script.Parent = nil
				script:Clone().Parent = oldParent
			end
			Data.Stamp.DisabledScripts = nil
			Data.Stamp.Dragger = nil
			Data.Stamp.CurrentParts.Parent = nil
			Data.Stamp.CurrentParts = nil

			Data.Stamp.MouseLock = false

			--Now set up a new instance of the object to allow a second copy to be stamped down
			variables.Stamped.Value = true
			variables.Stamped.Value = false
			if isRestricted then
				if checkPartLimit() then
					setupDraggableClone()
				else
					variables.ShowMaxedOut.Value = true
				end
			else
				setupDraggableClone()
			end

		end
	end
end


------------------------ EyeDropper Code -------------------------------------------

function onEyeDropperMouseButton1Down()
	if eyeDropperMoveConnection then 
		eyeDropperMoveConnection:disconnect()
	end
	clearSelection()
	if Mouse then
		Mouse.Icon = "http://www.roblox.com/asset?id=66887745"
	end

	-- deny any attempt to clone something that wasn't stamped using the Stamper tool
	if not Mouse or not Mouse.Target then
		startEyeDropperOperation()
		return
	end

	local isTerrainEyedroppering = false
	if Mouse.Target == game.Workspace.Terrain then
		-- want to eyedropper a terrain piece; gotta do a little extra footwork
		print("Eyedroppering Terrain Piece")
		local newTerrainPiece

		-- gotta make the fake part here
		local hitCell = game.Workspace.Terrain:WorldToCellPreferSolid(Mouse.Hit.p)
		local cellMat, cellType, cellOrient = game.Workspace.Terrain:GetCell(hitCell.x, hitCell.y, hitCell.z)

		if (cellType.Value == 1 or cellType.Value == 4) then newTerrainPiece = Instance.new("WedgePart") newTerrainPiece.formFactor = "Custom"
		elseif (cellType.Value == 2) then newTerrainPiece = Instance.new("CornerWedgePart")
		else newTerrainPiece = Instance.new("Part") newTerrainPiece.formFactor = "Custom" end
		newTerrainPiece.Name = "MegaClusterCube"
		newTerrainPiece.Size = Vector3.new(4, 4, 4)
		newTerrainPiece.BottomSurface = "Smooth"
		newTerrainPiece.TopSurface = "Smooth"

		-- can add decals or textures here if feeling particularly adventurous...  for now, can make a table of look-up colors
		newTerrainPiece.BrickColor = getClosestColorToTerrainMaterial(cellMat.Value)

		local sideways = 0
		local flipped = math.pi
		if cellType.Value == 4 then sideways = -math.pi/2 end
		if cellType.Value == 2 or cellType.Value == 3 then flipped = 0 end
		newTerrainPiece.CFrame = CFrame.Angles(0, math.pi/2*cellOrient.Value + flipped, sideways)

		if cellType.Value == 3 then
			local inverseCornerWedgeMesh = Instance.new("SpecialMesh")
			inverseCornerWedgeMesh.MeshType = "FileMesh"
			inverseCornerWedgeMesh.MeshId = "http://www.roblox.com/asset?id=66832495"
			inverseCornerWedgeMesh.Scale = Vector3.new(2, 2, 2)
			inverseCornerWedgeMesh.Parent = newTerrainPiece
		end

		local materialTag = Instance.new("Vector3Value")
		materialTag.Value = Vector3.new(cellMat.Value, cellType.Value, cellOrient.Value)
		materialTag.Name = "ClusterMaterial"
		materialTag.Parent = newTerrainPiece

		local tempModel = Instance.new("Model")
		newTerrainPiece.Parent = tempModel

		Data.Stamp.Model = tempModel
		Data.Stamp.Model:BreakJoints()

		isTerrainEyedroppering = true
	end

	local stamperTag = Mouse.Target.Parent:FindFirstChild("RobloxStamper")
	if stamperTag == nil then stamperTag = Mouse.Target:FindFirstChild("RobloxStamper") end
	if stamperTag == nil and not isTerrainEyedroppering then
		startEyeDropperOperation()
		return
	end

	local eyeDropperInstance
	-- find out if the target part is part of a Roblox Set Model
	local robloxModelTag = Mouse.Target.Parent:FindFirstChild("RobloxModel")
	if robloxModelTag ~= nil then
		eyeDropperInstance = Mouse.Target.Parent
	else
		eyeDropperInstance = Mouse.Target
	end
	
	-- do not allow certain objects to be captured with eye-dropper
	-- for now, locked parts
	if eyeDropperInstance:IsA("Part") and eyeDropperInstance.Locked and not isTerrainEyedroppering then
		startEyeDropperOperation()
	else
		if not isTerrainEyedroppering then
			local cloneInstance = eyeDropperInstance:clone()
			local tempModel = Instance.new("Model")
			cloneInstance.Parent = tempModel

			-- once more, we make sure it's on grid before eyedroppering
			if not isOnGrid(tempModel) then startEyeDropperOperation() return end

			Data.Stamp.Model = tempModel
			Data.Stamp.Model:BreakJoints()
		end

		-- will create and position clone without requiring user to move the mouse		

		if isRestricted then
			if checkPartLimit() then
				setupDraggableClone()
				if Mouse and not mouseButton1UpCon then mouseButton1UpCon = Mouse.Button1Up:connect(onInsertMouseButton1Up) end
			else
				variables.ShowMaxedOut.Value = true
			end
		else
			setupDraggableClone()
			if Mouse and not mouseButton1UpCon then mouseButton1UpCon = Mouse.Button1Up:connect(onInsertMouseButton1Up) end
		end

		variables.SwitchLoaderToDialog.AssetImage.Value = "0"
		variables.SwitchLoaderToDialog.DialogType.Value = "SideDialog"
		variables.SwitchLoaderToDialog.Value = true
	end
end

function onEyeDropperMouseMove() 
	if not(inGui) and not(inPalette) then
		if not Mouse or not Mouse.Target then clearSelection() return end
		local part = Mouse.Target
		if part:IsA("Terrain") and Mouse.Hit then
			selectionBox.Color = BrickColor.Green()
			setTerrainSelection(Mouse.Hit.p)
		elseif canEyeDropperObject(part) then
			local model = findModel(part)
			if model and isOnGrid(model) then 		
				selectionBox.Color = BrickColor.Green()
				setSelection(model)
			elseif (not model) and isOnGrid(part) then
				selectionBox.Color = BrickColor.Green()
				setSelection(part)
			else
				clearSelection()
			end
		else
			clearSelection()
		end
	end
end

function startEyeDropperOperation()

	cancelAssetPlacement()
	pressedEsc = false
	signalInsertComplete("EyeDropper")

	if mouseButton1UpCon then mouseButton1UpCon:disconnect() mouseButton1UpCon = nil end

	if eyeDropperConnection then
		eyeDropperConnection:disconnect()
		eyeDropperConnection = nil
	end
	if eyeDropperMoveConnection then eyeDropperMoveConnection:disconnect() end
	if Mouse then
		--Mouse.Icon ="rbxasset://textures//DropperCursor.png"
		Mouse.Icon = "http://www.roblox.com/asset?id=67163166"
		eyeDropperConnection = Mouse.Button1Up:connect(onEyeDropperMouseButton1Down)
		eyeDropperMoveConnection = Mouse.Move:connect(onEyeDropperMouseMove)
	end

end

function findModel(part)

	if isRestricted then
		while part ~= nil do
			if part.className == "Model" and part.Name ~= playerModel.Name and part.Name ~= "GarbageParts" then
				return part
			elseif part.Name == playerModel.Name or part.Name == "GarbageParts" then
				return nil
			end
			part = part.Parent
		end
		return nil

	else
		while part ~= game.Workspace do
			if part:FindFirstChild("RobloxModel") then
				return part
			end
			part = part.Parent
		end
		return nil
	end

end

------------------------ End EyeDropper Code ---------------------------------------




------------------------ Start Selection Highlighting Code --------------------------
function setTerrainSelection(point)
	if selectionBox then
		local cell = game.Workspace.Terrain:WorldToCellPreferSolid(point)
		local cellCenter = game.Workspace.Terrain:CellCenterToWorld(cell.X, cell.Y, cell.Z)
		terrainSelectionBox.CFrame = CFrame.new(cellCenter)
		selectionBox.Adornee = terrainSelectionBox
	end
end
	
function setSelection(partOrModel)
	if partOrModel ~= currentSelection then
		clearSelection()
		currentSelection = partOrModel
		selectionBox.Adornee = currentSelection
	end
end

function clearSelection()
	if currentSelection ~= nil then
		for part, color in pairs(currentSelectionColors) do
			part.BrickColor = color
		end
		selectionBox.Adornee = nil
	end
	currentSelectionColors = {}
	-- I put these inside if statements, because we can't assume these exist. (Jahr, 12-29-2010)
	if currentSelection then currentSelection = nil end
	if selectionBox then selectionBox.Adornee = nil end
end

------------------------ End Selection Highlighting Code --------------------------

function autoAlignToFace()
	local aatf = Data.Stamp.CurrentParts[1]:FindFirstChild("AutoAlignToFace")
	if aatf then return aatf.Value else return false end
end


function autoAlignHelper()
	local model = Data.Stamp.CurrentParts[1]
	local aatfTag = model:FindFirstChild("AutoAlignToFace")
	if not aatfTag then
		aatfTag = Instance.new("IntValue")
		aatfTag.Name = "AutoAlignToFace"
		aatfTag.Parent = Data.Stamp.CurrentParts[1]
		aatfTag.Value = 3
	end
	aatfTag.Value = aatfTag.Value + 1
	if aatfTag.Value > 3 then aatfTag.Value = 0 end
end

function unstampableFaceHelper()
	if not Mouse or not Mouse.Target then return end
	local model = Mouse.Target
	if not model then return end
	if not model:FindFirstChild("RobloxModel") then model = model.Parent end
	if not model then return end
	if not model:FindFirstChild("RobloxModel") then return end

	local ufhTag = model:FindFirstChild("UnstampableFaces")
	if not ufhTag then
		ufhTag = Instance.new("StringValue")
		ufhTag.Name = "UnstampableFaces"
		ufhTag.Parent = model
		ufhTag.Value = ""
	end
	
	local hitFace = modelTargetSurface(model, game.Workspace.CurrentCamera.CoordinateFrame.p, Mouse.Hit.p)

	-- put string list into table form
	breakingFaceList = {}
	for bf = -3, 3 do
		breakingFaceList[bf] = false
	end
	for bf in string.gmatch(ufhTag.Value, "[^,]+") do
		breakingFaceList[tonumber(bf)] = true
	end

	-- toggle value of hit face
	breakingFaceList[hitFace] = not breakingFaceList[hitFace]

	-- put table form back into string value
	ufhTag.Value = ""
	local seenAValueSoFar = false
	for bf = -3, 3 do
		if bf ~= 0 then -- ignore 0 face, since that doesn't exist
			if breakingFaceList[bf] then 
				if seenAValueSoFar then ufhTag.Value = ufhTag.Value .. "," .. tostring(bf)
				else ufhTag.Value = tostring(bf) seenAValueSoFar = true end
			end
		end
	end
end

function justificationHelper(whichAxis)
	local model = Data.Stamp.CurrentParts[1]
	local justTag = model:FindFirstChild("Justification")
	if not justTag then
		justTag = Instance.new("Vector3Value")
		justTag.Name = "Justification"
		justTag.Parent = Data.Stamp.CurrentParts[1]
		justTag.Value = Vector3.new(1, 1, 1)
	end
	local oldValue = justTag.Value
	if whichAxis == 1 then
		if oldValue.X == 2 then justTag.Value = Vector3.new(0, oldValue.Y, oldValue.Z)
		else justTag.Value = Vector3.new(oldValue.X+1, oldValue.Y, oldValue.Z) end
	elseif whichAxis == 2 then
		if oldValue.Y == 2 then justTag.Value = Vector3.new(oldValue.X, 0, oldValue.Z)
		else justTag.Value = Vector3.new(oldValue.X, oldValue.Y+1, oldValue.Z) end
	elseif whichAxis == 3 then
		if oldValue.Z == 2 then justTag.Value = Vector3.new(oldValue.X, oldValue.Y, 0)
		else justTag.Value = Vector3.new(oldValue.X, oldValue.Y, oldValue.Z+1) end
	end
end

function onInsertKeyDown(key)
	key = string.lower(key)
	if Data.Stamp.Dragger then
		if key == 'c' and Data.Stamp.CurrentParts[1].Name == "MegaClusterCube" and HighScalabilityLine.InternalLine and HighScalabilityLine.InternalLine.magnitude > 0 and HighScalabilityLine.Dimensions < 3 then
			HighScalabilityLine.MorePoints[HighScalabilityLine.Dimensions] = HighScalabilityLine.End
			HighScalabilityLine.MoreLines[HighScalabilityLine.Dimensions] = HighScalabilityLine.InternalLine
			HighScalabilityLine.Dimensions = HighScalabilityLine.Dimensions + 1
			HighScalabilityLine.NewHint = true
		end

		if key == 'r' and not autoAlignToFace() then
			-- Update orientation value if this is a fake terrain part
			if Data.Stamp.CurrentParts[1].Name == "MegaClusterCube" then
				local clusterValues = Data.Stamp.CurrentParts[1]:FindFirstChild("ClusterMaterial")
				if clusterValues and clusterValues:IsA("Vector3Value") then
					clusterValues.Value = Vector3.new(clusterValues.Value.X, clusterValues.Value.Y, (clusterValues.Value.Z+1)%4)
				end
			end

			-- Rotate the parts or all the parts in the model
			local ry = math.pi/2
			local rotCF = CFrame.fromEulerAnglesXYZ(0, ry, 0)
			gInitial90DegreeRotations = gInitial90DegreeRotations + 1
			if Data.Stamp.CurrentParts[1]:IsA("Model") or Data.Stamp.CurrentParts[1]:IsA("Tool") then
				for i, object in pairs(Data.Stamp.CurrentParts[1]:GetChildren()) do
					if object:IsA("Flag") then object = object.Handle end
					if object:IsA("Part") or object:IsA("TrussPart") or object:IsA("WedgePart") or object:IsA("CornerWedgePart") or object:IsA("Seat") or object:IsA("VehicleSeat") then
						object.CFrame = rotCF * object.CFrame
					end
				end
			else
				Data.Stamp.CurrentParts[1].CFrame = rotCF * Data.Stamp.CurrentParts[1].CFrame
			end
			-- After rotating, update the position
			configFound, targetCFrame = findConfigAtMouseTarget(Data.Stamp.TransparencyTable)
			if configFound then
				positionPartsAtCFrame3(Data.Stamp.CurrentParts[1], targetCFrame)
				
				-- update everything else in MouseMove
				onInsertMouseMove()
			end
		end
	end
	if key == 'e'  then
		startEyeDropperOperation()
	elseif key == 'q' then
		pressedEsc = true
		if eyeDropperConnection then
			eyeDropperConnection:disconnect()
			eyeDropperConnection = nil
		end
		if eyeDropperMoveConnection then eyeDropperMoveConnection:disconnect() end

		if Mouse and not mouseButton1UpCon then mouseButton1UpCon = Mouse.Button1Up:connect(onInsertMouseButton1Up) end

		clearSelection()
		cancelAssetPlacement()
		Data.Loading.Cancelled = true
		signalInsertComplete("Main")
	end
	
	-- admin-only tools: helpful functions for construction purposes
	if adminAccess then
		if key == 'L' or key == 'l' then
			-- autoalign helper
			if Data.Stamp.Dragger then autoAlignHelper() onInsertMouseMove() end
		elseif key == 'U' or key == 'u' then
			-- unstampable face helper
			unstampableFaceHelper()
		--elseif key == 'C' or key == 'c' then
--			if Data.Stamp.Dragger then justificationHelper() end -- the 'c' stands for "Centering" since "j" is already reserved by GuiScript
		--end
		elseif key == 'X' or key == 'x' then  -- change x justification
			if Data.Stamp.Dragger then justificationHelper(1) onInsertMouseMove() end
		elseif key == 'Y' or key == 'y' then  -- change y justification
			if Data.Stamp.Dragger then justificationHelper(2) onInsertMouseMove() end
		elseif key == 'Z' or key == 'z' then  -- change z justification
			if Data.Stamp.Dragger then justificationHelper(3) onInsertMouseMove() end
		end
	end
end


function onEquippedLocal(newMouse)
	Mouse = newMouse

	player = getPlayer()

	-- if equip goes through while in backpack (so getPlayer() returns nil), we don't want to process anything else
	if not player then return end

	--[[if game:FindFirstChild("NetworkClient") and game.CoreGui.Version >= 7 then  only show billboards in online mode
		if not billBoardOwnerGui then billBoardOwnerGui = generateOwnerGui(player.Name) end
	end]]

	if isRestricted then
		if game.Workspace:FindFirstChild("BuildingAreas") then
			local areas = game.Workspace.BuildingAreas:GetChildren()
			for i = 1, #areas do
				if areas[i]:FindFirstChild("Player") and areas[i].Player.Value == Tool.Parent.Name then
					playerModel = areas[i]:FindFirstChild("PlayerArea")
					break
				end
			end
		end
	else
		playerModel = game.Workspace

		-- give them a topHint gui too, if they don't have it since the place won't already have it	
		if not player.PlayerGui:FindFirstChild("topHint") then
			local topHintGui = script.Parent:FindFirstChild("topHint")
			if topHintGui then
				topHintGui:Clone().Parent = player.PlayerGui
			end
		end
	end

	if not playerModel then return end

	-- used to move object when walking
	cameraChangeCon = game.Players.LocalPlayer.Character.Humanoid.Running:connect(function(speed)
		if speed > 0 then
			walking = true
			while walking and cameraChangeCon do
				onInsertMouseMove()
				wait(1.0/30.0)
			end
		else
			walking = false
		end
	end)
	if Mouse then
		mouseMoveCon = newMouse.Move:connect(onInsertMouseMove)
		mouseButton1DownCon = newMouse.Button1Down:connect(onInsertMouseButton1Down)
		mouseButton1UpCon = newMouse.Button1Up:connect(onInsertMouseButton1Up)
		newMouse.KeyDown:connect(onInsertKeyDown)
	end

	if(isRestricted) then
		local takenAreas = game.Workspace.BuildingAreas:GetChildren()

		waitForChild(player, "playerNumber")

		if(player.playerNumber.Value == 0) then
			buildingPlate = nil
			partModel = nil
		else
			waitForChild(game.Workspace, "BuildingAreas")
			local buildingAreas = game.Workspace.BuildingAreas
			waitForChild(buildingAreas, "Area"..tostring(player.playerNumber.Value))
			local targetArea = buildingAreas:FindFirstChild("Area"..tostring(player.playerNumber.Value))
			
			waitForChild(targetArea, "PlayerArea")
			waitForChild(targetArea.PlayerArea, "BasePlate")

			buildingPlate = targetArea.PlayerArea.BasePlate
			partModel = targetArea.PlayerArea
		end
	else
		partModel = game.Workspace
	end

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "Model Delete Selection"
	selectionBox.Color = BrickColor.Red()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	alreadyMoving = false
end


function onUnequipped()
	Mouse = nil
	if mouseMoveCon then mouseMoveCon:disconnect() end
	if mouseButton1DownCon then mouseButton1DownCon:disconnect() end
	if mouseButton1UpCon then mouseButton1UpCon:disconnect() end
	if cameraChangeCon then cameraChangeCon:disconnect() cameraChangeCon = nil end
	if billBoardOwnerGui then billBoardOwnerGui:Remove() end

	cancelAssetPlacement()

	clearSelection()
	if selectionBox then selectionBox:Remove() end
end
----------------------------------------------------------------------------------------




-- Lua Start Script
Tool.Equipped:connect(function(newMouse) onEquippedLocal(newMouse) end)

waitForChild(variables,"InsertAsset")
waitForChild(variables.InsertAsset, "Updated")
variables.InsertAsset.Updated.Changed:connect(function(prop)
	if variables.InsertAsset.Updated.Value == true then
		pressedEsc = false
		beginInsertAssetStamp(variables.InsertAsset.AssetName.Value, variables.InsertAsset.AssetId.Value,
			variables.InsertAsset.Image.Value, variables.InsertAsset.StampMode.Value)
		variables.InsertAsset.Updated.Value = false
	end
end)

waitForChild(variables, "SwitchMode")
waitForChild(variables.SwitchMode, "Mode")
variables.SwitchMode.Changed:connect(function()
	if variables.SwitchMode.Value == true then
		if variables.SwitchMode.Mode.Value == "Clone" then
			startEyeDropperOperation()
		end
		variables.SwitchMode.Value = false
	end
end)

waitForChild(variables, "ReloadCurrentAsset")
variables.ReloadCurrentAsset.Changed:connect(function()
	if variables.ReloadCurrentAsset.Value == true then
		setupDraggableClone()
		variables.ReloadCurrentAsset.Value = false
	end
end)

Tool.Unequipped:connect(function() onUnequipped() end)
----------------------------------------------------------------------------------------


