local Tool = script.Parent

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/color_sel.png")

local mainFrame = nil

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
local inGui = false
local inPalette = false

local selectedButtonTable = {}
local oldButton = nil
function onMouseLeave(hoverSelection)
	if oldButton ~= nil then
		local notSelected = true
		local selectionText = ""
		for key, value in pairs(selectedButtonTable) do
			if oldButton == value then
				notSelected = false
			else
				selectionText = value.BackgroundColor.Name
			end
		end
		if notSelected then
			hoverSelection.Text = selectionText
			oldButton.Parent.BackgroundColor = BrickColor.Black()
		end
	end
	oldButton = nil
end

function onMouseEnter(hoverSelection, guiButton)
	onMouseLeave(hoverSelection)
	hoverSelection.Text = guiButton.BackgroundColor.Name
	if guiButton ~= selectedButton then
		guiButton.Parent.BackgroundColor = BrickColor.White()
		oldButton = guiButton
	end
end

function onMouseUp(colorHolder, paletteFrame, guiButton)
	if selectedButtonTable[colorHolder] ~= nil then
		selectedButtonTable[colorHolder].Parent.BackgroundColor = BrickColor.Black()
	end
	guiButton.Parent.BackgroundColor = BrickColor.Yellow()
	colorHolder.BackgroundColor = guiButton.BackgroundColor
	selectionBox.Color = guiButton.BackgroundColor
	selectionLasso.Color = guiButton.BackgroundColor
	Tool.Value.Value = guiButton.BackgroundColor
	selectedButtonTable[colorHolder] = guiButton
	
	onMouseLeavePalette(paletteFrame)
	
	print("Selected Color: " .. guiButton.BackgroundColor.Name)
end

function onShowColorDialog(paletteFrame)
	paletteFrame.Visible = true
end

function setSelectionBox(part) 
	unsetSelectionBox()
	selectionBox.Adornee = part
	selectionLasso.Part = part
end
function unsetSelectionBox() 
	selectionBox.Adornee = nil
	selectionLasso.Part = nil
end

function onMouseEnterGui(mouse)
	mouse.Icon ="rbxasset://textures\\ArrowCursor.png"
	unsetSelectionBox()
	inGui = true
end
function onMouseLeaveGui(mouse)
	inGui = false
end

function onMouseEnterPalette(mouse)
	mouse.Icon ="rbxasset://textures\\ArrowCursor.png"
	unsetSelectionBox()
	inPalette = true
end
function onMouseLeavePalette(paletteFrame, mouse)
	inPalette = false
end
	
local moveSpeed = 10
function pushOutFrame(mainFrame)
	while mainFrame.Position.X.Offset < 100 do
		mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale,mainFrame.Position.X.Offset + moveSpeed,mainFrame.Position.Y.Scale,mainFrame.Position.Y.Offset)
		wait()
	end
end

function pushInFrame(mainFrame)
	while mainFrame.Position.X.Offset > -210 do
		mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale,mainFrame.Position.X.Offset - moveSpeed,mainFrame.Position.Y.Scale,mainFrame.Position.Y.Offset)
		wait()
	end
end


local primaryColor = nil
function buildGui(player, mouse)

	pushOutFrame(mainFrame)

	--[[local mainFrame = Instance.new("Frame")
	mainFrame.Position = UDim2.new(0.0, 0, 1.0, -250)
	mainFrame.Size = UDim2.new(0.0, 200, 0.0, 250)
	mainFrame.Transparency = 1.0]]
	--mainFrame.Parent = player.PlayerGui.NewGuiDemo.BuildTools.PropertyTools.PaintTool
	

	--[[local paletteFrame = Instance.new("Frame")
	paletteFrame.Position = UDim2.new(0.0, 0, 0.0, 0)
	paletteFrame.Size = UDim2.new(1.0, 0, 4.0/5, 0)
	paletteFrame.BackgroundColor = BrickColor.Black()
	paletteFrame.Visible = false
	paletteFrame.Parent = mainFrame]]


	--[[local sideBar = Instance.new("Frame")
	sideBar.Position = UDim2.new(0.0, 0, 4.0/5, 0)
	sideBar.Size = UDim2.new(1.0, 0, 1.0/5, 0)
	sideBar.BackgroundColor = BrickColor.Black()
	sideBar.Parent = mainFrame]]
	mainFrame.sideBar.MouseEnter:connect(function() onMouseEnterGui(mouse) end)
	mainFrame.sideBar.MouseLeave:connect(function() onMouseLeaveGui(mouse) end)

	--[[primaryColor = Instance.new("TextButton")
	primaryColor.Position = UDim2.new(0.75, 1, 0.0, 1)
	primaryColor.Size = UDim2.new(0.25, -2, 1.0, -2)
	primaryColor.Text  = ""	
	primaryColor.BackgroundColor = Tool.Value.Value
	primaryColor.BorderColor = BrickColor.Black()
	primaryColor.BorderSizePixel = 1
	primaryColor.Parent = sideBar]]
	mainFrame.sideBar.primaryColor.MouseButton1Down:connect(function() print("Showdialog") onShowColorDialog(paletteFrame) end)


	local hoverSelection = Instance.new("TextLabel")
	hoverSelection.Position = UDim2.new(0.0, 0, 0.0, 0)
	hoverSelection.Size = UDim2.new(0.75, 0, 1.0, 0)
	hoverSelection.Text = ""
	hoverSelection.BackgroundColor = BrickColor.Black()
	hoverSelection.TextColor = BrickColor.White()
	hoverSelection.Text = mainFrame.sideBar.primaryColor.BackgroundColor.Name
	hoverSelection.Parent = mainFrame.sideBar

	--local secondaryColor = Instance.new("TextButton")
	--secondaryColor.Position = UDim2.new(0.75, 0, 0.0, 0)
	--secondaryColor.Size = UDim2.new(0.25, 0, 1.0, 0)
	--secondaryColor.Text = ""
	--secondaryColor.BackgroundColor = BrickColor.Black()
	--secondaryColor.Parent = sideBar

	local colors = mainFrame.paletteFrame:GetChildren()
	for i = 1, #colors do
		local button = colors[i]:GetChildren()
		button[1].MouseEnter:connect(function() onMouseEnter(hoverSelection, button[1]) end)
		button[1].MouseButton1Up:connect(function() onMouseUp(mainFrame.sideBar.primaryColor, mainFrame.paletteFrame, button[1]) end)
	end
	
	--[[for xOffset = 0, 7 do
		for yOffset = 0,7 do
			local guiFrame = Instance.new("Frame")
			guiFrame.Position = UDim2.new(1.0/8 * xOffset, 0, 1.0/8*yOffset, 0)
			guiFrame.Size = UDim2.new(1.0/8, 0, 1.0/8, 0)
			guiFrame.BackgroundColor = BrickColor.Black()
			guiFrame.BorderSizePixel = 0
			guiFrame.Parent = paletteFrame
		
			local guiButton = Instance.new("TextButton")
			guiButton.Position = UDim2.new(0.0, 2, 0.0, 2)
			guiButton.Size = UDim2.new(1.0, -4, 1.0, -4)
			guiButton.Text = ""
			guiButton.BorderSizePixel = 0
			guiButton.AutoButtonColor = false
			guiButton.BackgroundColor = BrickColor.palette(xOffset + yOffset*8)
			guiButton.MouseEnter:connect(function() onMouseEnter(hoverSelection, guiButton) end)
			guiButton.MouseButton1Up:connect(function() onMouseUp(primaryColor, paletteFrame, guiButton) end)
			--guiButton.MouseButton2Down:connect(function() onMouseClick(secondaryColor, guiButton) end)
			guiButton.Parent = guiFrame

			if guiButton.BackgroundColor == primaryColor.BackgroundColor then
				guiFrame.BackgroundColor = BrickColor.White()
				selectedButtonTable[primaryColor] = guiButton
			end
		end
	end]]
	mainFrame.MouseLeave:connect(function() onMouseLeave(hoverSelection) end)

end
function canSelectObject(part)
	return part and not (part.Locked) and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end

function on3dButton1Down(mouse) 
	local part = mouse.Target
	if canSelectObject(part) then
		if Instance.Lock(part) then
			part.BrickColor = mainFrame.sideBar.primaryColor.BackgroundColor
			Instance.Unlock(part)
		end
	end
end

function on3dMouseMove(mouse) 
	if not(inGui) and not(inPalette) then
		mouse.Icon ="rbxasset://textures\\FillCursor.png"
		local part = mouse.Target
		if canSelectObject(part) then
			setSelectionBox(part)
		else
			unsetSelectionBox()
		end
	end
end

local guiMain
function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/color_sel.png"

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	guiMain = Instance.new("ScreenGui")
	guiMain.Parent = player.PlayerGui

	inGui = false
	inPalette = false

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
	
	mainFrame = player.PlayerGui.NewGuiDemo.BuildTools.Frame.PropertyTools.PaintTool.Frame

	mainFrame.paletteFrame.MouseEnter:connect(function() print("EnterPalette") onMouseEnterPalette(mouse) end)
	mainFrame.paletteFrame.MouseLeave:connect(function() print("LeavePalette")  onMouseLeavePalette(paletteFrame, mouse) end)

	buildGui(player, mouse)
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	pushInFrame(mainFrame)
	--guiMain:Remove()
	selectionBox:Remove()
	selectionLasso:Remove()
end


--local part2 = Instance.new("Part")
--if Instance.Lock(part2) then
--	Instance.Unlock(part2)
--end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
