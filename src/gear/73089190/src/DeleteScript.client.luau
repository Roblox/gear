-- basic functions
function waitForChild(instance, name)
	while not instance:FindFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

function waitForProperty(instance, name)
	while not instance[name] do
		instance.Changed:wait()
	end
end

-- locals 
local RbxStamper = LoadLibrary("RbxStamper")

if not RbxStamper then
	print("Error: RbxStamper Library Load Fail! Returning")
	return nil
end

local Tool = script.Parent

enabled = true
game:GetService("ContentProvider"):Preload("rbxasset://icons/delete_sel.png")

local cluster = nil

local selectionBox
local currentSelection
local currentSelectionColors = {}
local selectionLasso

local player = nil

local highlight = false

local megaClusterSelectionBox = Instance.new("Part")
megaClusterSelectionBox.FormFactor = "Custom"
megaClusterSelectionBox.Size = Vector3.new(4, 4, 4) -- a little thicker than 4x4x4 unit clusterpart; just so selection box is more easily seen
megaClusterSelectionBox.Transparency = 1
megaClusterSelectionBox.Anchored = true
megaClusterSelectionBox.CanCollide = false
megaClusterSelectionBox.Parent = nil

waitForProperty(game,"PlaceId")
local isRestricted = (game.PlaceId == 41324860 or game.PlaceId == 129686177)
local stampRegion = nil
local modelToStampIn = nil

waitForChild(Tool, "AutoWedgeClusterParts")
local autoWedgeClusterParts = Tool.AutoWedgeClusterParts.Value

waitForChild(Tool, "PlayerOwner")
local playerOwner = Tool.PlayerOwner

-- functions

function canDeleteObject(part)
	-- let them delete anything that they created *or* anything on their baseplate
	return part and not (part.Locked) and part:IsA("BasePart") and (isChildOfMyModel(part) or inBounds(part))
end

-- For Restricting Stamper Tool (isRestricted)
function inBounds(partOrModel)
	if not stampRegion then return true end
	if not partOrModel then return true end
	
	return RbxStamper.CanEditRegion(partOrModel, stampRegion)
end

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
			if part:IsA("Model") then
				return part
			end
			part = part.Parent
		end
		return nil
	end
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
		if not modelToStampIn then return true end
		if modelToStampIn:IsAncestorOf(part) then
			return true
		else return false end
end

function on3dButton1Down(mouse)
	local part = mouse.Target

	if part == nil then 
		return
	elseif part:IsA("Terrain") and not isRestricted then
		if cluster ~= nil then
			local cellPos = cluster:WorldToCellPreferSolid(Vector3.new(mouse.Hit.x, mouse.Hit.y, mouse.Hit.z))
			local autoWedgeCell = cluster.AutowedgeCell
			local x = cellPos.x
			local y = cellPos.y
			local z = cellPos.z

			cluster:SetCell(x, y, z, 0, 0, 0)
			
			if (autoWedgeClusterParts) then

				for i = x - 1, x + 1 do
					for j = y - 1, y + 1 do
						for k = z - 1, z + 1 do
							autoWedgeCell(cluster,i,j,k)
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
		if isRestricted then
			if oldParent and oldParent ~= modelToStampIn then
				cleanOrphanedModel(oldParent)
			end
		else
			cleanOrphanedModel(oldParent)
		end
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
	local part = mouse.Target

	if not part then
		clearSelection() 
		return
	elseif part:IsA("Terrain") and not isRestricted then
		if not cluster then cluster = game.Workspace.Terrain end
		local hitCell = cluster:WorldToCellPreferSolid(mouse.Hit.p)
		if cluster:GetCell(hitCell.x, hitCell.y, hitCell.z).Value > 0 then
			megaClusterSelectionBox.CFrame = CFrame.new(cluster:CellCenterToWorld(hitCell.x, hitCell.y, hitCell.z))

			if isRestricted then
				megaClusterSelectionBox.Parent = game.Workspace.BaseplateBumpers
			else
				megaClusterSelectionBox.Parent = game.Workspace
			end

			selectionBox.Adornee = megaClusterSelectionBox
			currentSelection = nil  -- necessary so selection box can transition between terrain and non-terrain smoothly
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
function onEquippedLocal(mouse)
	equipCount = equipCount + 1
	local val = equipCount

	if isRestricted then
		waitForChild(game.Workspace, "BuildingAreas")
		if val ~= equipCount then
			return
		end
	end

	mouse.TargetFilter = megaClusterSelectionBox

	local character = script.Parent.Parent
	player = game.Players:GetPlayerFromCharacter(character)
	
	if not player then return end

	if playerOwner.Value and playerOwner.Value ~= player then return end
	playerOwner.Value = player

	guiMain = Instance.new("ScreenGui")
	guiMain.Parent = player.PlayerGui

	mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Icon = "http://www.roblox.com/asset?id=72539748"

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
----------------------------------------------------------------------------------------
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

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
