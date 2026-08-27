local Tool = script.Parent


enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/material_sel.png")

local selectionBox
local selectionLasso

local selectedButton

local value = nil

function setSelectionBox(part) 
	unsetSelectionBox()
	selectionBox.Adornee = part
	selectionLasso.Part = part
end
function unsetSelectionBox() 
	selectionBox.Adornee = nil
	selectionLasso.Part = nil
end

local MaterialEnum = {}
MaterialEnum["Plastic"] = Enum.Material.Plastic
MaterialEnum["Wood"] = Enum.Material.Wood
MaterialEnum["Slate"] = Enum.Material.Slate
MaterialEnum["CorrodedMetal"] = Enum.Material.CorrodedMetal
MaterialEnum["Ice"] = Enum.Material.Ice
MaterialEnum["Grass"] = Enum.Material.Grass
MaterialEnum["Foil"] = Enum.Material.Foil
MaterialEnum["DiamondPlate"] = Enum.Material.DiamondPlate
MaterialEnum["Concrete"] = Enum.Material.Concrete

function on3dButton1Down(mouse) 
	if selectedButton == nil then return end
	local part = mouse.Target
	if part and not (part.Locked) then
		if Instance.Lock(part) then
			part.Material = MaterialEnum[selectedButton.Name]
			Instance.Unlock(part)
		end
	end
end

function canSelectObject(part)
	return part and not (part.Locked) and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end


function on3dMouseMove(mouse) 
	mouse.Icon ="rbxasset://textures\\MaterialCursor.png"
	local part = mouse.Target
	if canSelectObject(part) then
		setSelectionBox(part)
	else
		unsetSelectionBox()
	end
end

function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/material_sel.png"
	value = nil
	selectedButton = nil

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	selectedButton = nil

	mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Icon ="rbxasset://textures\\MaterialCursor.png"

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Color = BrickColor.Yellow()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Delete Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Parent = game.workspace
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = BrickColor.Red()

	Tool.SelectedButton.Changed:connect(function(property)

		if value == Tool.SelectedButton.Value then return end
		value = Tool.SelectedButton.Value

		selectedButton = Tool.SelectedButton.Value
	end)
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	if selectionBox then selectionBox:Remove() end
	if selectionLasso then selectionLasso:Remove() end
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
