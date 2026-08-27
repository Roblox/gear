-- basic functions
function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

local Tool = script.Parent.Parent


waitForChild(Tool.Dragger.OldDragger, "Active")

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/freemove_sel.png")

local selectionBox
local currentSelection
local currentSelectionColors = {}
local selectionLasso
local inGui = false
local inPalette = false

local connections = {}

function canSelectObject(part)
	return part and not (part.Locked) and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end

function findModel(part)
	while part ~= nil do
		if part:IsA("Model") and part ~= game.Workspace then
			return part
		elseif part == game.Workspace then
			return nil
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

function onMouseDown(mouse) 
	mouse.Icon ="rbxasset://textures\\GrabRotateCursor.png"
	local part = mouse.Target
	if canSelectObject(part) then
		local hitPoint = mouse.Hit:toObjectSpace(part.CFrame).p
		if trySelection(part) then
			local instances = {}
			collectBaseParts(currentSelection, instances)
			startDrag(part, hitPoint, instances)
			return
		end
	end
	onMouseUp(mouse)
end



function onMouseUp(mouse)
	mouse.Icon ="rbxasset://textures\\GrabCursor.png"
	if dragger ~= nil then
		pcall(function() dragger:MouseUp() end)
		dragger = nil
	end
end

function trySelection(part)
	if canSelectObject(part) then
		selectionLasso.Part = part
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
		pcall(function() dragger:MouseMove(mouse.UnitRay) end)
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
	else
		if currentSelection ~= nil then
			return true
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
	Tool.TextureId = "rbxasset://icons/freemove_sel.png"

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	guiMain = Instance.new("ScreenGui")
	guiMain.Parent = game.Players.LocalPlayer.PlayerGui

	inGui = false
	inPalette = false

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
	selectionBox.Parent = game.Players.LocalPlayer.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Drag Lasso"
	selectionLasso.Humanoid = game.Players.LocalPlayer.Character.Humanoid
	selectionLasso.archivable = false
	selectionLasso.Visible = true
	selectionLasso.Parent = game.workspace
	selectionLasso.Color = BrickColor.Blue()

	alreadyMoving = false
end

function onUnequippedLocal()
	for i = 1, #connections do
		connections[i]:disconnect()
	end
	connections = {}

	Tool.TextureId = origTexture
	clearSelection()
	selectionBox:Remove()
	selectionLasso:Remove()
end


script.Active.Changed:connect(function()
	if script.Active.Value then
		onEquippedLocal(Tool.Mouse.Value)
	else
		onUnequippedLocal()
	end
end)
