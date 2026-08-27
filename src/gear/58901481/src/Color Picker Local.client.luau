local Tool = script.Parent

enabled = true
local menu
local origTexture = 	Tool.TextureId
local localAssetBase = "rbxasset://textures/ui/"
game:GetService("ContentProvider"):Preload("rbxasset://icons/color_sel.png")

local buttonDownCon, mouseMoveCon
local clickCons = {}

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
			color =  script.Parent.CurrentColor.Value
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

function makeColorMenu()
	local paintGui = Instance.new("ScreenGui")
	paintGui.Name = "PaintGui"

	local paintMenu = Instance.new("ImageLabel")
	paintMenu.Name = "PaintMenu"
	paintMenu.Position = UDim2.new(0,0,1,-600)
	paintMenu.Size = UDim2.new(0,120,0,500)
	paintMenu.BackgroundTransparency = 1
	paintMenu.ZIndex = 2
	paintMenu.Image = localAssetBase .. "PaintMenu.png"
	paintMenu.Parent = paintGui

	local paintColorButton = Instance.new("ImageButton")
	paintColorButton.BorderSizePixel = 0
	paintColorButton.ZIndex = 2
	paintColorButton.Size = UDim2.new(0.200000003, 0,0.0500000007, 0)

	local selection = Instance.new("Frame")
	selection.BorderSizePixel = 0
	selection.BackgroundColor3 = Color3.new(1,1,1)
	selection.BackgroundTransparency = 1
	selection.ZIndex = 2
	selection.Size = UDim2.new(1.1,0,1.1,0)
	selection.Position = UDim2.new(-0.05,0,-0.05,0)
	selection.Parent = paintColorButton

	local header  = 0.08
	local spacing = 18

	local count = 1

	local function findNextColor()
		colorName = tostring(BrickColor.new(count))
		while colorName == "Medium stone grey" do
			count = count + 1
			colorName = tostring(BrickColor.new(count))
		end
		return count
	end

	for i = 0,15 do
		for j = 1, 4 do
			newButton = paintColorButton:clone()
			newButton.BackgroundColor3 = BrickColor.new(findNextColor()).Color
			newButton.Name = tostring(BrickColor.new(count))
			count = count + 1
			if j == 1 then newButton.Position = UDim2.new(0.08,0,i/spacing + header,0)
			elseif j == 2 then newButton.Position = UDim2.new(0.29,0,i/spacing + header,0)
			elseif j == 3 then newButton.Position = UDim2.new(0.5,0,i/spacing + header,0)
			elseif j == 4 then newButton.Position = UDim2.new(0.71,0,i/spacing + header,0) end
			newButton.Parent = paintMenu
		end
	end

	local paintButtons = paintMenu:GetChildren()
	for i = 1, #paintButtons do
		local newCon = paintButtons[i].MouseButton1Click:connect(function()
			script.Parent.CurrentColor.Value = BrickColor.new(paintButtons[i].Name)
		end)
		table.insert(clickCons,newCon)
	end

	return paintGui
end

function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/color_sel.png"

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	buttonDownCon = mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	mouseMoveCon  = mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Icon ="rbxasset://textures\\FillCursor.png"

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Color = Tool.CurrentColor.Value
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Delete Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = Tool.CurrentColor.Value
	selectionLasso.Parent = game.workspace

	menu = makeColorMenu()
	menu.Parent = game.Players.LocalPlayer.PlayerGui
end

function onUnequippedLocal()
	if menu then menu:remove() end
	Tool.TextureId = origTexture

	for i = 1, #clickCons do
		clickCons[i]:disconnect()
	end
	clickCons = {}

	if selectionBox then selectionBox:Remove() end
	if selectionLasso then selectionLasso:Remove() end
	if mouseMoveCon then mouseMoveCon:disconnect() end
	if buttonDownCon then buttonDownCon:disconnect() end
end

Tool.CurrentColor.Changed:connect(function()
	if selectionBox then selectionBox.Color = Tool.CurrentColor.Value end
	if selectionLasso then selectionLasso.Color = Tool.CurrentColor.Value end
end)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
