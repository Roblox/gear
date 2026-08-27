-- basic functions
function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

function waitForProperty(instance, name)
	while not instance[name] do
		instance.Changed:wait()
	end
end

function getPlayer()
	waitForProperty(game.Players,"LocalPlayer")
	return game.Players.LocalPlayer
end

-- locals
local RbxStamper = LoadLibrary("RbxStamper")

if not RbxStamper then
	print("Error: RbxStamper Library Load Fail! Returning")
	return nil
end

local Tool = script.Parent
local stampControl = nil
local stampingCon = nil

local eyeDropperConnection = nil
local eyeDropperMoveConnection = nil
local keyCon = nil

local eyedropperOffGridTolerance = 0.01
local selectionBox = nil
local currentSelection = nil
local Mouse = nil
local currentSelectionColors = {}

local terrainSelectionBox = Instance.new("Part")
terrainSelectionBox.Parent = nil
terrainSelectionBox.formFactor = "Custom"
terrainSelectionBox.Size = Vector3.new(4, 4, 4)
terrainSelectionBox.Archivable = false
terrainSelectionBox.CFrame = CFrame.new()

local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = "CloneSelection"
selectionBox.Color = BrickColor.Green()
selectionBox.Adornee = nil
selectionBox.Archivable = false

waitForChild(script.Parent,"CloneHintGui")
waitForChild(script.Parent.CloneHintGui,"CloneHint")
local hintGui = script.Parent.CloneHintGui
local shortcutHint =  script.Parent.CloneHintGui.CloneHint

waitForProperty(game,"PlaceId")
local isRestricted = (game.PlaceId == 41324860 or game.PlaceId == 129686177)

local showBaseplateScript = nil
local hideBaseplateScript = nil
if isRestricted then
	waitForChild(getPlayer(), "PlayerGui")
	waitForChild(getPlayer().PlayerGui, "Waypoint")
	waitForChild(getPlayer().PlayerGui, "showBaseplateWaypoint")
	waitForChild(getPlayer().PlayerGui, "hideBaseplateWaypoint")
	showBaseplateScript = getPlayer().PlayerGui.showBaseplateWaypoint
	hideBaseplateScript = getPlayer().PlayerGui.hideBaseplateWaypoint
end

local modelToStampIn, stampRegion = nil

-- functions
function findModel(part)
	if isRestricted then
		while part ~= nil do
			if part.className == "Model" and part.Name ~= modelToStampIn.Name and part.Name ~= "GarbageParts" then
				return part
			elseif part.Name == modelToStampIn.Name or part.Name == "GarbageParts" then
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

function getClosestColorToTerrainMaterial(terrainValue)
	if terrainValue == 1 then
		return BrickColor.new("Bright green")
	elseif terrainValue == 2 then
		return BrickColor.new("Bright yellow")
	elseif terrainValue == 3 then
		return BrickColor.new("Bright red")
	elseif terrainValue == 4 then
		return BrickColor.new("Sand red")
	elseif terrainValue == 5 then
		return BrickColor.new("Black")
	elseif terrainValue == 6 then
		return BrickColor.new("Dark stone grey")
	elseif terrainValue == 7 then
		return BrickColor.new("Sand blue")
	elseif terrainValue == 8 then
		return BrickColor.new("Deep orange")
	elseif terrainValue == 9 then
		return BrickColor.new("Dark orange")
	elseif terrainValue == 10 then
		return BrickColor.new("Reddish brown")
	elseif terrainValue == 11 then
		return BrickColor.new("Light orange")
	elseif terrainValue == 12 then
		return BrickColor.new("Light stone grey")
	elseif terrainValue == 13 then
		return BrickColor.new("Sand green")
	elseif terrainValue == 14 then
		return BrickColor.new("Medium stone grey")
	elseif terrainValue == 15 then
		return BrickColor.new("Really red")
	elseif terrainValue == 16 then
		return BrickColor.new("Really blue")
	elseif terrainValue == 17 then
		return BrickColor.new("Bright blue")
	else
		return BrickColor.new("Bright green")
	end
end

function setTerrainSelection(point)
	if selectionBox then
		local cell = game.Workspace.Terrain:WorldToCellPreferSolid(point)
		local cellCenter = game.Workspace.Terrain:CellCenterToWorld(cell.X, cell.Y, cell.Z)
		terrainSelectionBox.CFrame = CFrame.new(cellCenter)
		selectionBox.Adornee = terrainSelectionBox
		currentSelection = game.Workspace.Terrain
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

	if currentSelection then currentSelection = nil end
	if selectionBox then selectionBox.Adornee = nil end
end

function canEyeDropperObject(part)
	local stamperTag = part.Parent:FindFirstChild("RobloxStamper")
	if stamperTag == nil then stamperTag = part:FindFirstChild("RobloxStamper") end

	if isRestricted then
		if not inRegion(part) then return false end
	end

	return part and not (part.Locked) and part:IsA("BasePart") and stamperTag ~= nil
end

function inRegion(partOrModel)
	if not stampRegion then return true end
	if not partOrModel then return true end

	return RbxStamper.CanEditRegion(partOrModel, stampRegion)
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

function setupFakeTerrainPart(cellMat, cellType, cellOrient, isWater, waterForce,waterDirection)
		local newTerrainPiece = nil
		if (cellType == 1 or cellType == 4) then 
			newTerrainPiece = Instance.new("WedgePart") 
			newTerrainPiece.formFactor = "Custom"
		elseif (cellType == 2) then 
			newTerrainPiece = Instance.new("CornerWedgePart")
		else 
			newTerrainPiece = Instance.new("Part")
			newTerrainPiece.formFactor = "Custom"
		end

		newTerrainPiece.Name = "MegaClusterCube"
		newTerrainPiece.Size = Vector3.new(4, 4, 4)
		newTerrainPiece.BottomSurface = "Smooth"
		newTerrainPiece.TopSurface = "Smooth"

		-- can add decals or textures here if feeling particularly adventurous...  for now, can make a table of look-up colors
		newTerrainPiece.BrickColor = getClosestColorToTerrainMaterial(cellMat)

		local sideways = 0
		local flipped = math.pi
		if cellType == 4 then sideways = -math.pi/2 end
		if cellType == 2 or cellType == 3 then flipped = 0 end
		newTerrainPiece.CFrame = CFrame.Angles(0, math.pi/2 * cellOrient + flipped, sideways)

		if cellType == 3 then
			local inverseCornerWedgeMesh = Instance.new("SpecialMesh")
			inverseCornerWedgeMesh.MeshType = "FileMesh"
			inverseCornerWedgeMesh.MeshId = "http://www.roblox.com/asset?id=66832495"
			inverseCornerWedgeMesh.Scale = Vector3.new(2, 2, 2)
			inverseCornerWedgeMesh.Parent = newTerrainPiece
		end

		local materialTag = Instance.new("Vector3Value")
		materialTag.Value = Vector3.new(cellMat, cellType, cellOrient)
		materialTag.Name = "ClusterMaterial"
		materialTag.Parent = newTerrainPiece

		if isWater then
			local waterForceTag = Instance.new("StringValue",newTerrainPiece)
			waterForceTag.Name = "WaterForceTag"
			waterForceTag.Value = string.sub(tostring(waterForce),17)

			local waterForceDirectionTag = Instance.new("StringValue",newTerrainPiece)
			waterForceDirectionTag.Name = "WaterForceDirectionTag"
			waterForceDirectionTag.Value = string.sub(tostring(waterDirection),21)
		end

		return newTerrainPiece
end

function hint(phrase, timeLength)
	waitForChild(game.Players.LocalPlayer.PlayerGui,"topHint")
	waitForChild(game.Players.LocalPlayer.PlayerGui.topHint, "Add")
	waitForChild(game.Players.LocalPlayer.PlayerGui.topHint.Add, "Label")
	waitForChild(game.Players.LocalPlayer.PlayerGui.topHint.Add, "Time")
	game.Players.LocalPlayer.PlayerGui.topHint.Add.Label.Value = tostring(phrase)
	game.Players.LocalPlayer.PlayerGui.topHint.Add.Time.Value = tonumber(timeLength)
	game.Players.LocalPlayer.PlayerGui.topHint.Add.Disabled = false
end

function showBaseplateWaypoint()
	if modelToStampIn and showBaseplateScript then
		local target = showBaseplateScript:FindFirstChild("target")
		if target then
			delay(0,function()
				target.Value = modelToStampIn.Parent:FindFirstChild("RegionBounds")
				showBaseplateScript.Disabled = false
				showBaseplateScript.Disabled = true
				wait(8)
				hideBaseplateScript.Disabled = false
				hideBaseplateScript.Disabled = true
			end)
		end
	end
end



function stampAttemptFailed()
	hint("You can only stamp in your baseplate", 5)
	showBaseplateWaypoint()
end

function hasPoints()
	waitForChild(game.Players.LocalPlayer, "MaxPoints")
	local maxPoints = game.Players.LocalPlayer.MaxPoints
	waitForChild(game.Players.LocalPlayer, "PointsUsed")
	local pointsUsed = game.Players.LocalPlayer.PointsUsed

	return ( (pointsUsed.Value/maxPoints.Value) < 1 )
end

function setupStamper(stampModel)
	if stampControl then stampControl.Destroy() end
	if stampingCon then
		stampingCon:disconnect()
		stampingCon = nil
	end

	if isRestricted then
		if not hasPoints() then
			hint("Too many parts stamped, delete some to stamp more", 5)
			return
		else
			stampControl = RbxStamper.SetupStamperDragger(stampModel, Mouse, modelToStampIn, stampRegion, stampAttemptFailed)
		end
	else
		stampControl = RbxStamper.SetupStamperDragger(stampModel, Mouse)
	end

	if stampControl then
		stampingCon = stampControl.Stamped.Changed:connect(function()
			if stampControl and stampControl.Stamped.Value then
				if isRestricted and not hasPoints() then
					hint("Too many parts stamped, delete some to stamp more", 5)
					if stampCon then stampCon:disconnect() end
					stampControl.Destroy()
				else
					stampControl.ReloadModel()
				end
			end
		end)
		shortcutHint.Visible = true
	end
end

function onEyeDropperMouseButton1Down()
	clearSelection()
	if Mouse then
		Mouse.Icon = "http://www.roblox.com/asset?id=66887745"
	end

	-- deny any attempt to clone something that wasn't stamped using the Stamper tool
	if not Mouse or not Mouse.Target then
		startEyeDropperOperation()
		return
	end

	local cloneInstance = nil
	local isTerrainEyedroppering = false
	if Mouse.Target == game.Workspace.Terrain and not isRestricted then -- want to eyedropper a terrain piece; do a little extra footwork
		-- make the fake part here
		local hitCell = game.Workspace.Terrain:WorldToCellPreferSolid(Mouse.Hit.p)
		local cellMat, cellType, cellOrient = game.Workspace.Terrain:GetCell(hitCell.x, hitCell.y, hitCell.z)
		local hasAnyWater, waterForce, waterDirection = game.Workspace.Terrain:GetWaterCell(hitCell.x, hitCell.y, hitCell.z)
		cloneInstance = setupFakeTerrainPart(cellMat.Value, cellType.Value, cellOrient.Value, hasAnyWater, waterForce, waterDirection)
		isTerrainEyedroppering = true
	end

	local stamperTag = Mouse.Target.Parent:FindFirstChild("RobloxStamper")
	if stamperTag == nil then stamperTag = Mouse.Target:FindFirstChild("RobloxStamper") end
	if stamperTag == nil and not isTerrainEyedroppering then
		startEyeDropperOperation()
		return
	end

	local eyeDropperInstance = nil
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
			cloneInstance = eyeDropperInstance:clone()
			-- once more, we make sure it's on grid before eyedroppering
			if not isOnGrid(cloneInstance) then
				if cloneInstance:IsA("Model") then cloneInstance:ResetOrientationToIdentity()
				else cloneInstance.CFrame = CFrame.new(cloneInstance.CFrame.p) end
			end

			cloneInstance:BreakJoints()
		end

		if eyeDropperConnection then
			eyeDropperConnection:disconnect()
			eyeDropperConnection = nil
		end
		if eyeDropperMoveConnection then
			eyeDropperMoveConnection:disconnect()
			eyeDropperMoveConnection = nil
		end

		setupStamper(cloneInstance)
	end
end

function onEyeDropperMouseMove() 
	if not Mouse or not Mouse.Target then 
		clearSelection()
		return
	end

	local part = Mouse.Target
	if part:IsA("Terrain") and Mouse.Hit and not isRestricted then
		selectionBox.Color = BrickColor.Green()
		setTerrainSelection(Mouse.Hit.p)
	elseif canEyeDropperObject(part) then
		local model = findModel(part)
		if model then 		
			selectionBox.Color = BrickColor.Green()
			setSelection(model)
		else 
			selectionBox.Color = BrickColor.Green()
			setSelection(part)
		end
	else
		clearSelection()
	end
end

function keyHandler(key)
	key = key:lower()
	if key == 'q' then
		startEyeDropperOperation()
	end
end

function startEyeDropperOperation()
	if stampControl then stampControl.Destroy() end

	if Mouse then
		Mouse.Icon = "http://www.roblox.com/asset?id=67163166"
		shortcutHint.Visible = false
		if not eyeDropperMoveConnection then
			eyeDropperConnection = Mouse.Button1Up:connect(onEyeDropperMouseButton1Down)
		end
		if not eyeDropperMoveConnection then
			eyeDropperMoveConnection = Mouse.Move:connect(onEyeDropperMouseMove)
		end
	end
end

function onEquipped(mouse)
	Mouse = mouse

	if game:FindFirstChild("Players") then
		if game.Players["LocalPlayer"] then
			selectionBox.Parent = game.Players.LocalPlayer.PlayerGui
			hintGui.Parent = game.Players.LocalPlayer.PlayerGui
		end
	end

	keyCon = Mouse.KeyDown:connect(keyHandler)
	startEyeDropperOperation()
end

function onUnequipped()
	if stampControl then
		stampControl.Destroy()
	end

	Mouse = nil
	selectionBox.Parent = nil

	if eyeDropperMoveConnection then
		eyeDropperMoveConnection:disconnect()
		eyeDropperMoveConnection = nil
	end
	if eyeDropperConnection then
		eyeDropperConnection:disconnect()
		eyeDropperConnection = nil
	end
	if keyCon then
		keyCon:disconnect()
		keyCon = nil
	end
	if hintGui then
		hintGui.Parent = nil
	end
end
------------------------------------------------------------------------------------------------
if isRestricted then -- setup our variables
	waitForChild(game,"Workspace")
	waitForChild(game.Workspace, "BuildingAreas")
	waitForChild(game.Workspace.BuildingAreas, "Area1")
	waitForChild(game.Workspace.BuildingAreas, "Area9") -- all areas loaded

	while not modelToStampIn do -- check for build area until we find one
		local buildAreas = game.Workspace.BuildingAreas:GetChildren()
		for i = 1, #buildAreas do
			if buildAreas[i]:IsA("Model") then
				waitForChild(buildAreas[i],"Player")
				if buildAreas[i].Player.Value == game.Players.LocalPlayer.Name then
					waitForChild(buildAreas[i],"PlayerArea")
					modelToStampIn = buildAreas[i].PlayerArea
					break
				end
			end
		end
		if not modelToStampIn then
			wait(0.5)
		end
	end


	local lowPos = modelToStampIn.Parent:FindFirstChild("LowPos")
	local highPos = modelToStampIn.Parent:FindFirstChild("HighPos")
	if not lowPos or highPos then
		wait(0.5)
		lowPos = modelToStampIn.Parent:FindFirstChild("LowPos")
		highPos = modelToStampIn.Parent:FindFirstChild("HighPos")
	end
	while lowPos.Value == Vector3.new(0,0,0) or highPos.Value == Vector3.new(0,0,0) do
		wait(0.5)
	end -- tool doesn't work until these are defined
		
	stampRegion = Region3.new(lowPos.Value, highPos.Value) -- this is where we can stamp
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

