local Tool = script.Parent

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/delete_sel.png")

local selectionBox
local currentSelection
local currentSelectionColors = {}
local selectionLasso
local inGui = false
local inPalette = false
local lockTime = 0

function canSelectObject(part)
	return part and not (part.Locked) and (part.Position - script.Parent.Parent.Head.Position).Magnitude < 60
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

function cleanOrphanedModel(parent)
	if parent.className == "Model" then
		local children = parent:GetChildren()
		if #children == 0 then
			local oldParent = parent.Parent
			parent:Remove()
			cleanOrphanedModel(oldParent)
		end
	end
end

function on3dButton1Down(mouse) 
	local part = mouse.Target
	if canSelectObject(part) then
		local model = findModel(part)
		local oldParent
		if model then 
			if Instance.Lock(model) then
				if currentSelection == model then
					currentSelection = nil
					clearSelection()
				end
				oldParent = model.Parent
				model:Remove()
				--The lock will expire in 5 seconds, which is good enough since we deleted the model
			end
		else
			if Instance.Lock(part) then
				if currentSelection == part then
					currentSelection = nil
					clearSelection()
				end
				oldParent = part.Parent
				part:Remove()
				--The lock will expire in 5 seconds, which is good enough since we deleted the part
			end
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
		if Instance.Lock(partOrModel) then
			lockTime = time()
			currentSelection = partOrModel
			saveSelectionColor(currentSelection)
			selectionBox.Adornee = currentSelection
		end
	else
		if currentSelection ~= nil and time() - lockTime > 2 then
			--Maintain the lock
			if not(Instance.Lock(currentSelection)) then
				--we lost the lock
				clearSelection()
			else
				lockTime = time()
			end
		end
	end
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
	selectionLasso.Part = nil
	selectionBox.Adornee = nil
end

local alreadyMoving = false
function on3dMouseMove(mouse) 
	if alreadyMoving then 
		return 
	end
	alreadyMoving = true
	if not(inGui) and not(inPalette) then
		local part = mouse.Target
		if canSelectObject(part) then
			selectionLasso.Part = part
			local model = findModel(part)
			if model then 		
				setSelection(model)
			else
				setSelection(part)
			end
		else
			clearSelection()
		end
	end
	alreadyMoving = false
end

function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/delete_sel.png"
	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	guiMain = Instance.new("ScreenGui")
	guiMain.Parent = player.PlayerGui

	inGui = false
	inPalette = false

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

	alreadyMoving = false
	--buildGui(guiMain, mouse)
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	clearSelection()
	selectionBox:Remove()
	selectionLasso:Remove()
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
