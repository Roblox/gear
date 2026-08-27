local Tool = script.Parent

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/freemove_sel.png")

local selectionBox
local currentSelection
local currentSelectionColors = {}
local selectionLasso
local inGui = false
local inPalette = false
local lockTime = 0

function canSelectObject(part)
	return part and not (part.Locked) --and (part.Position - script.Parent.Parent.Head.Position).Magnitude < 60
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


function startDrag(mousePart, hitPoint, collection)
	dragger = Instance.new("Dragger")
	pcall(function() dragger:MouseDown(mousePart, hitPoint, collection) end)
end

function collectBaseParts(object, collection)
	if object == nil then return end
	if object:IsA("BasePart") then
		collection[#collection+1] = object
	end
	for index,child in pairs(object:GetChildren()) do
		collectBaseParts(child, collection)
	end
end

local touchCon = nil
local touched = false
local placing = false
function placePartSafe(part)

	if part == nil then return end

	touchCon = part.Touched:connect(function() touched = true end)
	part.Position = part.Position + Vector3.new(0,part.Size.Y,0)
	wait(0.1)
	if touched then
		touchCon:disconnect()
		touched = false
		placePartSafe(part)
	end
	
	part.Position = part.Position - Vector3.new(0,part.Size.Y,0)
	placing = false
	

end

local copyPart
local canCollide
local anchored

function onMouseDown(mouse) 
	mouse.Icon ="rbxasset://textures\\GrabRotateCursor.png"
	if(mouse.Target == nil) then mouse.Icon ="rbxasset://textures\\CloneCursor.png" copyPart = nil clearSelection() return end
	copyPart = mouse.Target:clone()

	canCollide = copyPart.CanCollide
	anchored = copyPart.Anchored

	copyPart.Anchored = true
	copyPart.CanCollide = false
	
	copyPart.Parent = game.Workspace
	

	if canSelectObject(copyPart) then
		local hitPoint = mouse.Hit:toObjectSpace(copyPart.CFrame).p
		if trySelection(copyPart) then
			local instances = {}
			collectBaseParts(currentSelection, instances)
			startDrag(mouse.Target, hitPoint, instances)
			return
		end
	else
		copyPart:remove()
	end
	

	--Clear the selection if we weren't able to lock succesfully
	onMouseUp(mouse)

	copyPart = nil
end



function onMouseUp(mouse)

	mouse.Icon ="rbxasset://textures\\CloneCursor.png"
	if copyPart == nil then return end
	while placing do wait() end
	placing = true
	placePartSafe(copyPart)

	if copyPart then
		copyPart.Anchored = anchored
		copyPart.CanCollide = canCollide
	end

	if dragger ~= nil then
		pcall(function() dragger:MouseUp() end)
		dragger = nil
	end
end

function trySelection(part)
	if canSelectObject(part) then
		selectionLasso.Part = part
		return setSelection(part)
	else
		clearSelection()
		return false
	end
end

function onKeyDown(key)
	if dragger ~= nil then
		if key == 'R' or key == 'r'  then
			dragger:AxisRotate(Enum.Axis.Y)
		elseif key == 'T' or key == 't' then
			dragger:AxisRotate(Enum.Axis.Z)
		end
	end
end
local alreadyMoving
function onMouseMove(mouse)
	if alreadyMoving then
		return
	end

	

	alreadyMoving = true
	if dragger ~= nil then

		--Maintain the lock
		if time() - lockTime > 3 then
			Instance.Lock(currentSelection)
			lockTime = time()
		end
		
		--Then drag
		pcall(function() dragger:MouseMove(mouse.UnitRay) end)
	else
		trySelection(mouse.Target)
	end
	alreadyMoving = false
end

	
function setSelection(partOrModel)
	if partOrModel ~= currentSelection then
		clearSelection()
		if Instance.Lock(partOrModel) then
			lockTime = time()
			currentSelection = partOrModel
			selectionBox.Adornee = currentSelection
			return true
		end
	else
		if currentSelection ~= nil then
			if time() - lockTime > 2 then
				--Maintain the lock
				if not(Instance.Lock(currentSelection)) then
					--we lost the lock
					clearSelection()
					return false
				else
					lockTime = time()
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

function clearSelection()
	if currentSelection ~= nil then
		for part, color in pairs(currentSelectionColors) do
			part.BrickColor = color
		end
		selectionBox.Adornee = nil
		Instance.Unlock(currentSelection)
	end
	currentSelectionColors = {}
	currentSelection = nil
	
	if(selectionLasso) then
		selectionLasso.Part = nil
	end
	if(selectionBox) then
		selectionBox.Adornee = nil
	end
end

function onEquippedLocal(mouse)
	wait(0.1)
	Tool.TextureId = "rbxasset://textures\\CloneCursor.png"

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	guiMain = Instance.new("ScreenGui")
	guiMain.Parent = player.PlayerGui

	inGui = false
	inPalette = false

	mouse.Icon ="rbxasset://textures\\CloneCursor.png"
	mouse.Button1Down:connect(function() onMouseDown(mouse) end)
	mouse.Button1Up:connect(function() onMouseUp(mouse) end)
	mouse.Move:connect(function() onMouseMove(mouse) end)
	mouse.KeyDown:connect(function(string) onKeyDown(string) end)

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "Model Delete Selection"
	selectionBox.Color = BrickColor.White()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Drag Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.archivable = false
	selectionLasso.Visible = true
	selectionLasso.Parent = game.workspace
	selectionLasso.Color = BrickColor.White()

	alreadyMoving = false
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	clearSelection()
	selectionBox:Remove()
	selectionLasso:Remove()
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)