function waitForChild(instance, name)
	while not instance:FindFirstChild(name) do
		instance.ChildAdded:wait()
	end
end


local Tool = script.Parent

enabled = true
game:GetService("ContentProvider"):Preload("rbxasset://icons/delete_sel.png")

local cluster = nil

local selectionBox
local currentSelection
local currentSelectionColors = {}
local selectionLasso

local deleteDistance = 100
local player = nil
--local playerModel = nil
local playerModel = game.Workspace
local buildingPlate = nil

local highlight = false

local megaClusterSelectionBox = Instance.new("Part")
megaClusterSelectionBox.FormFactor = "Custom"
megaClusterSelectionBox.Size = Vector3.new(4, 4, 4) -- a little thicker than 4x4x4 unit clusterpart; just so selection box is more easily seen
megaClusterSelectionBox.Transparency = 1
megaClusterSelectionBox.Anchored = true
megaClusterSelectionBox.CanCollide = false
megaClusterSelectionBox.Parent = nil

waitForChild(Tool, "IsRestricted")
local isRestricted = Tool.IsRestricted.Value

waitForChild(Tool, "AutoWedgeClusterParts")
local autoWedgeClusterParts = Tool.AutoWedgeClusterParts.Value

function hint(label)

	-- Pass in a string, it shows a top hint.  (Replaces previous hint, if exists)
	_player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if(_player ~= nil and _player.PlayerGui:FindFirstChild("topHint")~=nil) then
		local topHint = _player.PlayerGui.topHint
		topHint.Add.Label.Value = label
		topHint.Add.Width.Value = 3 -- widest width
		topHint.Add.Time.Value = 5
		topHint.Add.Disabled = true
		topHint.Add.Disabled = false
	end

end

function canDeleteObject(part)
	-- let them delete anything that they created *or* anything on their baseplate
	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < deleteDistance and (isChildOfMyModel(part) or partInBounds(part))
end

-- For Restricting Stamper Tool (isRestricted)
function inBounds(part)

	if part == nil then return false end

	if part:IsA("Part") or part:IsA("WedgePart") or part:IsA("TrussPart") then
		if not partInBounds(part) then return false end
	elseif part:IsA("Model") then
		local primPart = object.PrimaryPart
		if not partInBounds(primPart) then return false end
	end

	return true

end

function partInBounds(part)

	local xOne = buildingPlate.Position.x + buildingPlate.Size.x/2
	local xTwo = buildingPlate.Position.x - buildingPlate.Size.x/2
	local zOne = buildingPlate.Position.z + buildingPlate.Size.z/2
	local zTwo = buildingPlate.Position.z - buildingPlate.Size.z/2

	if part.Position.x > xOne or part.Position.x < xTwo then return false end
	if part.Position.z > zOne or part.Position.z < zTwo then return false end

	return true

end


function findModel(part)
	while part ~= nil do
		if part.className == "Model" and part.Name ~= playerModel.Name and part.Name ~= "GarbageParts" then
			return part
		elseif part.Name == playerModel.Name or part.Name == "GarbageParts" then
			return nil
		end
		part = part.Parent
	end

	return nil
end

function cleanOrphanedModel(parent)
	if not parent then return end
	if parent.className == "Model" then
		local children = parent:GetChildren()
		if #children == 0 and parent.Name ~= "GarbageParts" then
			local oldParent = parent.Parent
			parent:Remove()
			cleanOrphanedModel(oldParent)
		end
	end
end

function isChildOfMyModel(part)
		if not playerModel then return true end
		if playerModel:IsAncestorOf(part) then
			return true
		else return false end
end


-- Cyrion's auto-wedge fcn:
--sets cell x, y, z to default material if parameter is provided, if not sets cell x, y, z to be whatever material it previously was
--returns true if made a wedge, false if the cell remains a block
function MakeWedge(x, y, z, defaultmaterial)
	local c = game.Workspace.Terrain
	--gather info about all the cells around x, y, z
	surroundings = {} --surroundings is a 3 x 3 x 3 array of the material of the cells adjacent to x, y, z
	for i = x - 1, x + 1 do
		surroundings[i] = {}
		for j = y - 1, y + 1 do
			surroundings[i][j] = {}
			for k = z - 1, z + 1 do
				local material, wedge, rotation = c:GetCell(i, j, k)
				surroundings[i][j][k] = material.Value
			end
		end
	end
	--make some useful arrays and counters
	local sides = {} --sides is an array of the material of the 4 adjacent sides
	sides[0] = surroundings[x - 1][y][z]
	sides[1] = surroundings[x][y][z + 1]
	sides[2] = surroundings[x + 1][y][z]
	sides[3] = surroundings[x][y][z - 1]
	local adjacentSides = 0
	for n = 0, 3 do
		if sides[n] > 0 then
			adjacentSides = adjacentSides + 1
		end
	end
	local sidesAbove = {} --sides is an array of the material of the 4 adjacent sides 1 height above
	sidesAbove[0] = surroundings[x - 1][y + 1][z]
	sidesAbove[1] = surroundings[x][y + 1][z + 1]
	sidesAbove[2] = surroundings[x + 1][y + 1][z]
	sidesAbove[3] = surroundings[x][y + 1][z - 1]
	local adjacentSidesAbove = 0
	for n = 0, 3 do
		if sidesAbove[n] > 0 then
			adjacentSidesAbove = adjacentSidesAbove + 1
		end
	end
	local corners = {} --corners is an array of the material of the 4 adjacent corners
	corners[0] = surroundings[x - 1][y][z - 1]
	corners[1] = surroundings[x - 1][y][z + 1]
	corners[2] = surroundings[x + 1][y][z + 1]
	corners[3] = surroundings[x + 1][y][z - 1]
	local adjacentCorners = 0
	for n = 0, 3 do
		if corners[n] > 0 then
			adjacentCorners = adjacentCorners + 1
		end
	end
	local cornersAbove = {} --corners is an array of the material of the 4 adjacent corners 1 height above
	cornersAbove[0] = surroundings[x - 1][y + 1][z - 1]
	cornersAbove[1] = surroundings[x - 1][y + 1][z + 1]
	cornersAbove[2] = surroundings[x + 1][y + 1][z + 1]
	cornersAbove[3] = surroundings[x + 1][y + 1][z - 1]
	local adjacentCornersAbove = 0
	for n = 0, 3 do
		if cornersAbove[n] > 0 then
			adjacentCornersAbove = adjacentCornersAbove + 1
		end
	end
	--determine what type of wedge to make
	local material = nil
	local wedge = nil
	local rotation = nil 
	if defaultmaterial then
		material = defaultmaterial
	else
		material, wedge, rotation = c:GetCell(x, y, z) --start with the existing material, wedge, and rotation
	end
	wedge = 0 --default wedge is a block
	rotation = 0 --default rotation is 0
	--type 1: 45 degree ramp //must not have a block on top and must have a block under, and be surrounded by 1 side; or 3 sides and the 2 corners between them
	if surroundings[x][y + 1][z] == 0 and surroundings[x][y - 1][z] > 0 then
		if adjacentSides == 1 then
			for n = 0, 3 do
				if sides[n] > 0 then
					wedge = 1
					rotation = (n + 1) % 4
					c:SetCell(x, y, z, material, wedge, rotation)
					return true
				end
			end
		elseif  adjacentSides == 3 then
			for n = 0, 3 do
				if sides[n] > 0 and corners[(n + 1) % 4] > 0 and sides[(n + 1) % 4] > 0 and corners[(n + 2) % 4] > 0 and sides[(n + 2) % 4] > 0 then
					wedge = 1
					rotation = (n + 2) % 4
					c:SetCell(x, y, z, material, wedge, rotation)
					return true
				end
			end
		end
	end
	--type 2: 45 degree corner //must not have a block on top and must have a block under, and be surrounded by 2 sides and the 1 corner between them; or 3 sides and 1 corner between 2 of them (facing towards that corner)
	if surroundings[x][y + 1][z] == 0 and surroundings[x][y - 1][z] > 0 then
		for n = 0, 3 do
			if sides[n] > 0 and corners[(n + 1) % 4] > 0 and sides[(n + 1) % 4] > 0 and (adjacentSides == 2 or (adjacentSides == 3 and (corners[(n + 3) % 4] > 0 or (sides[(n + 2) % 4] > 0 and corners[(n + 2) % 4] > 0) or (sides[(n + 3) % 4] > 0 and corners[n] > 0)))) then
				wedge = 2
				rotation = (n + 2) % 4
				c:SetCell(x, y, z, material, wedge, rotation)
				return true
			end
		end
	end
	--type 3: 45 degree inverse corner //surrounded by three sides or 4 sides and 3 corners, with nothing above or else a block on top surrounded on 2 sides and the corner between them
	if adjacentSides == 3 and surroundings[x][y + 1][z] > 0 then
		if adjacentCorners > 1 then
			for n = 0, 3 do
				if (corners[n] == 0 or cornersAbove[n] == 0) and (sides[(n - 1) % 4] == 0 or sides[n] == 0) and (sidesAbove[n] == 0 and sidesAbove[(n + 1) % 4] > 0 and sidesAbove[(n + 2) % 4] > 0 and sidesAbove[(n + 3) % 4] == 0) then 
					wedge = 3
					rotation = (n + 3) % 4
					c:SetCell(x, y, z, material, wedge, rotation)
					return true
				end
			end
		end
	elseif adjacentSides == 4 and adjacentCorners == 3 then
		for n = 0, 3 do
			if corners[n] == 0 and (surroundings[x][y + 1][z] == 0 or (sidesAbove[n] == 0 and sidesAbove[(n + 1) % 4] > 0 and cornersAbove[(n + 2) % 4] > 0 and sidesAbove[(n + 2) % 4] > 0 and sidesAbove[(n + 3) % 4] == 0)) then
				wedge = 3
				rotation = (n + 3) % 4
				c:SetCell(x, y, z, material, wedge, rotation)
				return true
			end
		end
	end
	--type 4: half a cube, as if it were cut diagonally from front to back //surrounded by 2 sides
	if adjacentSides == 2 and adjacentCorners < 4 then
		for n = 0, 3 do
			if sides[n] == 0 and sides[(n + 1) % 4] == 0 and (surroundings[x][y + 1][z] == 0 or (sidesAbove[n] == 0 and sidesAbove[(n + 1) % 4] == 0 and sidesAbove[(n + 2) % 4] > 0 and sidesAbove[(n + 3) % 4] > 0)) then
				wedge = 4
				rotation = n
				c:SetCell(x, y, z, material, wedge, rotation)
				return true
			end
		end
	end
	c:SetCell(x, y, z, material, wedge, rotation)
	return false
end

function on3dButton1Down(mouse)
	local part = mouse.Target

	if part == nil then 
		return
	elseif part:IsA("Terrain") then
		if cluster ~= nil then
			local cellPos = cluster:WorldToCellPreferSolid(Vector3.new(mouse.Hit.x, mouse.Hit.y, mouse.Hit.z))
			local x = cellPos.x
			local y = cellPos.y
			local z = cellPos.z

			cluster:SetCell(x, y, z, 0, 0, 0)
			
			if (autoWedgeClusterParts) then

				for i = x - 1, x + 1 do
					for j = y - 1, y + 1 do
						for k = z - 1, z + 1 do
							MakeWedge(i, j, k)
						end
					end
				end

			end

			clearSelection()
			on3dMouseMove(mouse)

		end
	elseif canDeleteObject(part) then
		local model = findModel(part)
		local oldParent
		if model then 
			if currentSelection == model then
				currentSelection = nil
				clearSelection()
			end
			oldParent = model.Parent
			model:Remove()
		else
			if currentSelection == part then
				currentSelection = nil
				clearSelection()
			end
			oldParent = part.Parent
			part:Remove()
		end
		cleanOrphanedModel(oldParent)
	end
end

function saveSelectionColor(instance)
	if instance:IsA("BasePart") then
		currentSelectionColors[instance] = instance.BrickColor
		if instance.BrickColor == BrickColor.Red() then
			instance.BrickColor = BrickColor.new("Really red")
		else
			instance.BrickColor = BrickColor.Red()
		end
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
	megaClusterSelectionBox.Parent = nil
end


function on3dMouseMove(mouse) 
	if isRestricted then
		mouse.TargetFilter = game.Workspace.BaseplateBumpers
	else
		mouse.TargetFilter = megaClusterSelectionBox
	end
	local part = mouse.Target

	if not part then
		clearSelection() 
		return
	elseif part:IsA("Terrain") then
		if not cluster then cluster = game.Workspace.Terrain end
		local hitCell = cluster:WorldToCellPreferSolid(mouse.Hit.p)
		if cluster:GetCell(hitCell.x, hitCell.y, hitCell.z).Value > 0 then
			megaClusterSelectionBox.CFrame = CFrame.new(cluster:CellCenterToWorld(hitCell.x, hitCell.y, hitCell.z))

			if isRestricted then megaClusterSelectionBox.Parent = game.Workspace.BaseplateBumpers else megaClusterSelectionBox.Parent = game.Workspace end
			selectionBox.Adornee = megaClusterSelectionBox
		else
			clearSelection()
			return
		end
	elseif canDeleteObject(part) then
		local model = findModel(part)
		if model then 		
			selectionBox.Color = BrickColor.Red()
			setSelection(model)
		else
			selectionBox.Color = BrickColor.Red()
			setSelection(part)
		end
	else
		clearSelection()
	end
end

local equipCount = 0
function onEquippedLocal(mouse) --Fix implemented by Luckymaxer
	equipCount = equipCount + 1
	local val = equipCount
	
	if isRestricted then
		mouse.TargetFilter = game.Workspace.BaseplateBumpers
	else
		mouse.TargetFilter = megaClusterSelectionBox
	end

	if isRestricted then
		waitForChild(game.Workspace, "BuildingAreas")
		if val ~= equipCount then
			return
		end
	end

	local character = script.Parent.Parent
	player = game.Players:GetPlayerFromCharacter(character)
	
	if not player then return end

	if isRestricted then
		local takenAreas = game.Workspace.BuildingAreas:GetChildren()
		for i = 1, #takenAreas do
				if takenAreas[i]:FindFirstChild("Player") ~= nil then  -- Test if child exists (to fix current bug: "Player" child is omitted from 1 baseplate at random, when played online.)
					if takenAreas[i].Player.Value == Tool.Parent.Name then
						buildingPlate = takenAreas[i].PlayerArea.BasePlate
						break
					end
				end
		end
	end

   if buildingPlate then
		playerModel  = buildingPlate.Parent
	else
		--playerModel  = nil
		playerModel = game.Workspace
	end

	mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Icon ="rbxasset://textures\\HammerCursor.png"

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "Model Delete Selection"
	selectionBox.Color = BrickColor.Red()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Delete Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.archivable = false
	selectionLasso.Visible = true
	selectionLasso.Parent = game.workspace
	selectionLasso.Color = BrickColor.Red()

	highlight = true
end

function onUnequippedLocal()
	highlight = false
	if selectionBox then
		clearSelection()
		selectionBox:Remove()
	end
	if selectionLasso then selectionLasso:Remove() end
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
