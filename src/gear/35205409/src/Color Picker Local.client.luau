local Tool = script.Parent

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/color_sel.png")

function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	wait(.5)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	enabled = true

end


local selectionBox
local selectionLasso

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

function canSelectObject(part)
	return part and not (part.Locked) and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end

function on3dButton1Down(mouse) 
	local part = mouse.Target
	if canSelectObject(part) then
		if Instance.Lock(part) then
			color =  BrickColor.new(tostring(selectedButton))
			if color == nil then
				Instance.Unlock(part)
				return
			end
			part.BrickColor = color
			Instance.Unlock(part)
		end
	end
end

function on3dMouseMove(mouse) 
	mouse.Icon ="rbxasset://textures\\FillCursor.png"
	local part = mouse.Target
	if canSelectObject(part) then
		setSelectionBox(part)
	else
		unsetSelectionBox()
	end
end

function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/color_sel.png"

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Icon ="rbxasset://textures\\FillCursor.png"

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Color = Tool.Value.Value
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Delete Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = Tool.Value.Value
	selectionLasso.Parent = game.workspace
	
	Tool.SelectedButton.Changed:connect(function(property)

		if value == Tool.SelectedButton.Value then return end
		value = Tool.SelectedButton.Value

		selectedButton = Tool.SelectedButton.Value

	end)
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	value = nil
	selectedButton = nil
	if selectionBox then selectionBox:Remove() end
	if selectionLasso then selectionLasso:Remove() end
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
