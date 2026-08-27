local Tool = script.Parent;

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/configure_sel.png")

local selectionLasso
local selectionBox
local guiMain

local selectionGui
local hintGui

local valueConnections = {}

local objectValueSelect = {}

local colorPaletteSelectMode = false

local textSize = 1

--Constants
local width = UDim.new(3, 0)
local height = 20 
local transparency = 0.5
local buttonColor = BrickColor.new("Mid gray")
local frameColor = BrickColor.new("Pastel yellow")


function sharedProcess(name, parentFrame)
	local subFrame = Instance.new("Frame")
	subFrame.Name = name
	subFrame.Size = UDim2.new(1.0, 0, 0, height)
	subFrame.BackgroundTransparency = 1.0
	subFrame.BorderSizePixel = 0
	
	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0.0, 0, 0.0, 0)
	label.Size = UDim2.new(0.5, 0, 1.0, 0)
	label.FontSize = textSize
	label.TextColor = BrickColor.White()
	label.Text = name
	label.Parent = subFrame
	label.BackgroundTransparency = 1.0
	label.BorderSizePixel = 0

	return subFrame
end

function createTextBox(size, text)
	local textBox = Instance.new("TextBox")
	textBox.Position = UDim2.new(0.5, 1, 0.0, 1)
	textBox.Size = size
	textBox.BackgroundColor = BrickColor.White()
	textBox.FontSize = textSize
	textBox.TextColor = BrickColor.Black()
	textBox.Text = text	
	return textBox;
end

function setCheckBoxValue(checkBox, value)
	if value then
		checkBox.Text = "X"
	else
		checkBox.Text = ""
	end
end
function createCheckBox(value)
	local checkBox = Instance.new("TextButton")
	checkBox.Position = UDim2.new(0.75, -(height-4)/2, 0.0, 2)
	checkBox.Size = UDim2.new(0.0, height-4, 0.0, height-4)
	checkBox.BackgroundColor = BrickColor.White()
	checkBox.TextColor = BrickColor.Black()
	checkBox.FontSize = textSize
	setCheckBoxValue(checkBox, value)
	return checkBox
end



function processBoolValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local checkBox = createCheckBox(value.Value)
	
	--Tie the two values together... we'll need to break these connections later
	checkBox.MouseButton1Down:connect(function() value.Value = not(value.Value) end)
	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) setCheckBoxValue(checkBox, newValue) end)	
	checkBox.Parent = subFrame
	return subFrame
end

function processIntValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), value.Value, function(textBox) value.Value = textBox.Text end)
	textBox.Name = value.Name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop) if prop == 'Text' then if textBox.Text ~= '' then pcall(function() value.Value = textBox.Text end) end textBox.Text = value.Value end end)
	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) textBox.Text = newValue end)
	
	textBox.Parent = subFrame
	return subFrame;
end

function processPropertyValue(object, name, field, guiFrame)
	local subFrame = sharedProcess(name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), object[field], function(textBox) object[field] = textBox.Text end)
	textBox.Name = name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop) if prop == 'Text' then if textBox.Text ~= '' then pcall(function() object[field] = textBox.Text end) end textBox.Text = object[field] end end)
	valueConnections[#valueConnections+1] = object.Changed:connect(function(property) if property == field then textBox.Text = object[field] end end)
	
	textBox.Parent = subFrame
	return subFrame
end


function processNumberValue(value, guiFrame)
	return processIntValue(value, guiFrame)
end


function processStringValue(value, guiFrame)
	return processIntValue(value, guiFrame)
end



function onMouseLeave(hoverSelection, selectedButtonTable, oldButton)
	if oldButton[0] then
		local notSelected = true;
		local selectionText = "";
		for key, value in pairs(selectedButtonTable) do
			if oldButton[0] == value then
				notSelected = false
			else
				selectionText = value.BackgroundColor.Name;
			end
		end
		if notSelected then
			hoverSelection.Text = selectionText;
			oldButton[0].Parent.BackgroundColor = BrickColor.Black();
		end
	end
	oldButton[0] = nil
end

function onMouseEnter(hoverSelection, guiButton, selectedButtonTable, oldButton)
	onMouseLeave(hoverSelection, selectedButtonTable, oldButton)
	hoverSelection.Text = guiButton.BackgroundColor.Name
	if guiButton ~= selectedButton then
		guiButton.Parent.BackgroundColor = BrickColor.White();
		oldButton[0] = guiButton
	end
end

function changeColorSelection(colorHolder, paletteFrame, guiButton, selectedButtonTable)
	if selectedButtonTable[colorHolder] ~= nil then
		selectedButtonTable[colorHolder].Parent.BackgroundColor = BrickColor.Black();
	end

	guiButton.Parent.BackgroundColor = BrickColor.Yellow();
	colorHolder.BackgroundColor = guiButton.BackgroundColor
	selectedButtonTable[colorHolder] = guiButton
end

function onMouseUp(colorHolder, paletteFrame, guiButton, selectedButtonTable)
	changeColorSelection(colorHolder, paletteFrame, guiButton, selectedButtonTable)

	onMouseLeavePalette(paletteFrame)
end

function onShowColorDialog(paletteFrame)
	paletteFrame.Visible = not(paletteFrame.Visible)
	colorPaletteSelectMode = true
end


function onMouseEnterPalette(mouse)
	--mouse.Icon ="rbxasset://textures\\ArrowCursor.png"
	colorPaletteSelectMode = true
end
function onMouseLeavePalette(paletteFrame)
	colorPaletteSelectMode = false
	paletteFrame.Visible = false
end

function processBrickColorValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)

	local sideBar = Instance.new("Frame")
	sideBar.Position = UDim2.new(0.5, 0, 0.0, 0)
	sideBar.Size = UDim2.new(0.5, 0, 1.0, 0)
	sideBar.BackgroundTransparency = 1.0
	sideBar.Parent = subFrame
	sideBar.BorderSizePixel = 0
	--sideBar.MouseEnter:connect(function() onMouseEnterGui(mouse) end)
	--sideBar.MouseLeave:connect(function() onMouseLeaveGui(mouse) end)

	local primaryColor = Instance.new("TextButton")
	primaryColor.Position = UDim2.new(0.0, 1, 0.0, 1)
	primaryColor.Size = UDim2.new(0.0, height-2, 0, height-2)
	primaryColor.Text  = ""	
	primaryColor.FontSize = textSize
	primaryColor.BackgroundColor = value.Value
	primaryColor.BorderColor = BrickColor.Black()
	--primaryColor.BorderSizePixel = 1
	primaryColor.Parent = sideBar

	local hoverSelection = Instance.new("TextLabel")
	hoverSelection.Position = UDim2.new(0.0, height+2, 0.0, 0)
	hoverSelection.Size = UDim2.new(1.0, -height - 4, 1.0, 0)
	hoverSelection.Text = ""
	hoverSelection.FontSize = textSize
	hoverSelection.BackgroundTransparency = 1.0
	hoverSelection.BorderSizePixel = 0
	hoverSelection.TextColor = BrickColor.White()
	hoverSelection.Text = primaryColor.BackgroundColor.Name;
	hoverSelection.Parent = sideBar

	local paletteFrame = Instance.new("Frame")
	paletteFrame.Position = UDim2.new(primaryColor.Position.X.Scale, primaryColor.Position.X.Offset + height, primaryColor.Position.Y.Scale, primaryColor.Position.Y.Offset - height*7)
	paletteFrame.Size = UDim2.new(0, height*8, 0, height*8)
	paletteFrame.BackgroundColor = BrickColor.White()
	paletteFrame.BorderColor = BrickColor.White()
	paletteFrame.Visible = false;
	paletteFrame.Parent = sideBar
	paletteFrame.ZIndex = 2
	paletteFrame.MouseEnter:connect(function() onMouseEnterPalette(mouse) end)
	paletteFrame.MouseLeave:connect(function() onMouseLeavePalette(paletteFrame, mouse) end)

	primaryColor.MouseButton1Down:connect(function() onShowColorDialog(paletteFrame) end)

	local selectedButtonTable = {}
	local colorButtonTable = {}
	local oldButton = {}
	for xOffset = 0, 7 do
		for yOffset = 0,7 do
			local guiFrame = Instance.new("Frame")
			guiFrame.Position = UDim2.new(1.0/8 * xOffset, 0, 1.0/8*yOffset, 0)
			guiFrame.Size = UDim2.new(1.0/8, 0, 1.0/8, 0)
			guiFrame.BackgroundColor = BrickColor.White();
			guiFrame.BorderSizePixel = 0
			guiFrame.Parent = paletteFrame;
			guiFrame.ZIndex = 2
		
			local guiButton = Instance.new("TextButton")
			guiButton.FontSize = textSize
			guiButton.Position = UDim2.new(0.0, 1, 0.0, 1)
			guiButton.Size = UDim2.new(1.0, -2, 1.0, -2)
			guiButton.Text = ""
			guiButton.BorderSizePixel = 0
			guiButton.AutoButtonColor = false
			local color = BrickColor.palette(xOffset + yOffset*8)
			colorButtonTable[color.Number] = guiButton
			guiButton.BackgroundColor = color
			guiButton.MouseEnter:connect(function() onMouseEnter(hoverSelection, guiButton, selectedButtonTable, oldButton) end)
			guiButton.MouseButton1Up:connect(function() onMouseUp(primaryColor, paletteFrame, guiButton, selectedButtonTable, oldButton) end)
			guiButton.MouseButton1Up:connect(function() value.Value = guiButton.BackgroundColor end)
			guiButton.Parent = guiFrame
			guiButton.ZIndex = 2

			if guiButton.BackgroundColor == primaryColor.BackgroundColor then
				guiFrame.BackgroundColor = BrickColor.White()
				selectedButtonTable[primaryColor] = guiButton
			end
		end
	end

	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) print(newValue) changeColorSelection(primaryColor, paletteFrame, colorButtonTable[newValue.Number], selectedButtonTable) end)	
	return subFrame
end


function onObjectValueMouseClick(guiFrame, value, objectButton)
	objectValueSelect["CancelFrame"].Visible = true
	--guiFrame.Visible = false
	objectValueSelect["CancelFrame"].Parent = guiFrame
	objectValueSelect["Value"] = value
	objectValueSelect["Frame"] = guiFrame
	objectValueSelect["Enabled"] = true


	onObjectValueMouseLeave(value, objectButton)
end

function createObjectSelectCancelFrame(guiMain)
	local cancelFrame = Instance.new("ImageLabel")
	cancelFrame.Name = "ObjectValueSelectCancel"
	cancelFrame.Image = "http://www.roblox.com/asset/?id=36269485"
	cancelFrame.Size = UDim2.new(width.Scale/3, width.Offset, 0.0, height)
	cancelFrame.Position = UDim2.new(1, 0,0,0) --1.0, -height)
	cancelFrame.BackgroundTransparency = 1
	cancelFrame.Visible = false
	cancelFrame.Parent = guiMain

	local objectSelectHint = Instance.new("TextLabel")
	objectSelectHint.FontSize = textSize
	objectSelectHint.Size = UDim2.new(0.75, 0, 1.0, 0)
	objectSelectHint.Position = UDim2.new(0, 0, 0.0, 0)
	objectSelectHint.BackgroundTransparency = 1.0
	objectSelectHint.Text = "Please select a Part"
	objectSelectHint.TextColor = BrickColor.White()
	objectSelectHint.Parent = cancelFrame

	local objectSelectCancelButton = Instance.new("TextButton")
	objectSelectCancelButton.FontSize = textSize
	objectSelectCancelButton.Size = UDim2.new(0.25, -4, 1.0, -4)
	objectSelectCancelButton.Position = UDim2.new(0.75, 2, 0.0, 2)
	objectSelectCancelButton.BackgroundColor = BrickColor.White()
	objectSelectCancelButton.TextColor = BrickColor.Black()
	objectSelectCancelButton.Text = "Cancel";
	objectSelectCancelButton.MouseButton1Click:connect(function() onObjectValueCancel() end)
	objectSelectCancelButton.Parent = cancelFrame

	objectValueSelect["CancelFrame"]  = cancelFrame
end

function onObjectValueMouseEnter(value, objectButton)
	objectValueSelect["HoverBox"].Adornee = value.Value
	objectValueSelect["HoverValue"] = value
	if value.Value then
		objectButton.BackgroundColor = BrickColor.Blue()
	else
		objectButton.BackgroundColor = BrickColor.White()
	end
end
	
function onObjectValueMouseLeave(value, objectButton)
	if objectValueSelect["HoverValue"] == value then
		objectValueSelect["HoverBox"].Adornee = nil
		objectValueSelect["HoverValue"] = nil
	end
	objectButton.BackgroundColor = buttonColor
end

function onObjectValueCancel()
	if objectValueSelect["Enabled"] then
		objectValueSelect["Enabled"] = false

		objectValueSelect["Box"].Adornee = nil
		objectValueSelect["Frame"].Visible = true
		objectValueSelect["CancelFrame"].Visible = false
		objectValueSelect["Frame"] = nil
		objectValueSelect["Value"] = nil
	end
end

function on3dObjectValueButton1Up(mouse, guiMain)
	local part = mouse.Target
	if part ~= nil then
		objectValueSelect["Value"].Value = part

		objectValueSelect["Enabled"] = false

		objectValueSelect["Box"].Adornee = nil
		objectValueSelect["Frame"].Visible = true
		objectValueSelect["CancelFrame"].Visible = false

		objectValueSelect["Frame"] = nil
		objectValueSelect["Value"] = nil
	end
end

function on3dObjectValueMouseMove(mouse, guiMain)
	local part = mouse.Target
	if part and part ~= objectValueSelect["Box"].Adornee then
		objectValueSelect["Box"].Adornee = part
	end
end

function setObjectButtonText(guiFrame, objectButton, objectValue)
	if objectValueSelect["Enabled"] and objectValue == objectValueSelect["Value"] then
		guiFrame.Visible = true
		objectValueSelect["Enabled"] = false
		objectValueSelect["Value"] = nil
	end

	if  objectValue.Value ~= nil then
		objectButton.Text = objectValue.Value.Name
	else
		objectButton.Text = "[nil]"
	end
	objectButton.BackgroundColor = buttonColor
end

function processObjectValue(value, playerGui, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local objectButton = Instance.new("TextButton")
	objectButton.FontSize = textSize
	objectButton.Position = UDim2.new(0.5, 2, 0.0, 2)
	objectButton.Size = UDim2.new(0.5, -4, 1.0, -4)
	objectButton.BackgroundColor = BrickColor.White()
	objectButton.TextColor = BrickColor.Black()
	objectButton.Parent = subFrame
	objectButton.AutoButtonColor = false

	objectButton.MouseButton1Click:connect(function() onObjectValueMouseClick(guiFrame, value, objectButton) end)
	objectButton.MouseEnter:connect(function() onObjectValueMouseEnter(value, objectButton) end)
	objectButton.MouseLeave:connect(function() onObjectValueMouseLeave(value, objectButton) end)

	valueConnections[#valueConnections+1] = value.Changed:connect(function(newObjectValue) setObjectButtonText(guiFrame, objectButton, value) end)	

	setObjectButtonText(guiFrame, objectButton, value)
	return subFrame
end


function processValue(value, playerGui, guiFrame)
	if value.className == "BoolValue" then
		return processBoolValue(value, guiFrame)
	elseif value.className == "IntValue" then
		return processIntValue(value, guiFrame)
	elseif value.className == "NumberValue" then
		return processNumberValue(value, guiFrame)
	elseif value.className == "StringValue" then
		return processStringValue(value, guiFrame)
	elseif value.className == "ObjectValue" then
		return processObjectValue(value, playerGui, guiFrame)
	elseif value.className == "BrickColorValue" then
		return processBrickColorValue(value, guiFrame)
	else
		return nil
	end
end

function sharedMain(name, playerGui)
	local parentFrame = Instance.new("ImageLabel")
	parentFrame.Image = "http://www.roblox.com/asset/?id=36269485"
	parentFrame.Name = "MainFrame"
	parentFrame.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel")
	titleLabel.FontSize = textSize + 2
	titleLabel.Size = UDim2.new(1.0, 0.0, 0.0, height)
	titleLabel.TextColor = BrickColor.White()
	titleLabel.BackgroundColor = BrickColor.new("Cool yellow")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = name
	titleLabel.Parent = parentFrame
	titleLabel:clone().Parent = parentFrame

	return parentFrame
end

function sharedButtons(parentFrame, valueChildren)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "Buttons"
	buttonFrame.BackgroundTransparency = 1.0
	buttonFrame.Size = UDim2.new(1.0, 0.0, 0.0, height)
	buttonFrame.Position = UDim2.new(0.0, 0, 0.0, valueChildren*height)
	buttonFrame.Parent = parentFrame
	valueChildren = valueChildren + 1

	local okButton = Instance.new("TextButton")
	okButton.FontSize = textSize
	okButton.Text = "Ok"
	okButton.Size = UDim2.new(.25, -4, 0.0, height-4)
	okButton.Position = UDim2.new(0.5-.25/2, 2, 0.0, 2)
	okButton.BackgroundColor = buttonColor
	okButton.MouseButton1Click:connect(function() removeSelectionGui() end)
	okButton.Parent = buttonFrame

	parentFrame.Size = UDim2.new(width.Scale, width.Offset, 0.0, valueChildren*height)
	parentFrame.Position = UDim2.new(1, 0, 0.5, -(valueChildren*height)/2)
	
end

function processVehicleSeat(vehicleSeat, playerGui, valueChildren)
	print("Building Vehicle Seat")
	local parentFrame = sharedMain(vehicleSeat.Name, playerGui)

	local valueChildren = 1
	local fields = {"MaxSpeed", "Steer", "Torque", "TurnSpeed"}
	for pos, field in pairs(fields) do
		print("Creating " .. field)
		local newFrame = processPropertyValue(vehicleSeat, field, field, guiFrame)
		if newFrame then
			print("Got the frame")
			newFrame.Position = UDim2.new(0.0, 0, 0.0, valueChildren*height)
			newFrame.Parent = parentFrame
			valueChildren = valueChildren + 1
		end

	end

	sharedButtons(parentFrame, valueChildren)
	return parentFrame
end

function processConfiguration(config, playerGui)
	local parentFrame = sharedMain(config.Name, playerGui)

	local valueChildren = 1
	local children = config:GetChildren() 
	if children then
		for pos, child in pairs(children) do
			local newFrame = processValue(child, playerGui, parentFrame);
			if newFrame then
				newFrame.Position = UDim2.new(0.0, 0, 0.0, valueChildren*height)
				newFrame.Parent = parentFrame
				valueChildren = valueChildren + 1
			end
		end
	end
	
	sharedButtons(parentFrame, valueChildren)
	return parentFrame
end

function on3dMouseMove(mouse, guiMain)
	if objectValueSelect["Enabled"] then
		on3dObjectValueMouseMove(mouse, guiMain)
	end
end

function removeSelectionGui()
	if selectionGui ~= nil then
		selectionGui:Remove()
		selectionGui = nil
		for pos, connection in pairs(valueConnections) do
			connection:disconnect()
		end
		valueConnections = {}
	end

	selectionBox.Adornee = nil
	selectionLasso.Part = nil
	objectValueSelect["Box"].Adornee = nil
	objectValueSelect["HoverBox"].Adornee = nil
	hintGui.Visible = true

	showConfigurationAnnotations()
end



function canSelectObject(part)
	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end


function on3dButton1Up(mouse, guiMain, playerGui)
	if objectValueSelect["Enabled"] then
		on3dObjectValueButton1Up(mouse, guiMain)
		return
	elseif canSelectObject(mouse.Target) then
		local part = mouse.Target
		local foundPart = nil

		if part:IsA("VehicleSeat") then
			foundPart = part
		else
			local children = part:GetChildren() 		
			if children then
				for pos, child in pairs(children) do
					if child:IsA("Configuration") then
						foundPart = child
						break
					end
				end
			end
		end
	
		if foundPart then
			if selectionGui then
				removeSelectionGui()
			end

			hideConfigurationAnnotations()

			if foundPart:IsA("Configuration") then
				selectionGui = processConfiguration(foundPart, playerGui)
			else
				selectionGui = processVehicleSeat(foundPart, playerGui)	
			end
			selectionGui.Parent = guiMain
			print(selectionGui.Parent.Parent)
			selectionBox.Adornee = part
			selectionLasso.Part = part

			hintGui.Visible = false
			return
		end
	end
	
	print("3D Button Mouse Up")
	removeSelectionGui()
end
function on3dButton1Down(mouse, guiMain, playerGui)
	print("3D Button Mouse Down")
end

function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/configure_sel.png"
	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	if script.Parent:FindFirstChild("SelectedButton") then
		guiMain = Instance.new("Frame")
		guiMain.BackgroundTransparency = 1
		guiMain.Size = UDim2.new(1,0,1,0)
		guiMain.Position = UDim2.new(0,0,0,0)
		guiMain.Parent = script.Parent.SelectedButton.Value.Parent.Parent
	else
		guiMain = Instance.new("Frame")
		guiMain.BackgroundTransparency = 1
		guiMain.Size = UDim2.new(1,0,1,0)
		guiMain.Position = UDim2.new(0,0,0,0)
		guiMain.Parent = player.PlayerGui.GameGui.BuildTools.Frame
	end

	setUpConfigurationService(guiMain)
	showConfigurationAnnotations()

	createObjectSelectCancelFrame(guiMain)

	hintGui = Instance.new("ImageLabel")
	hintGui.Image = "http://www.roblox.com/asset/?id=36312091"
	hintGui.Position = UDim2.new(1, 0, 0.6, 0)
	hintGui.Size = UDim2.new(1.2, 0, 0.2,0)
	hintGui.BackgroundTransparency = 1
	hintGui.Parent = guiMain

	mouse.Icon ="rbxasset://textures\\DragCursor.png"
	mouse.Button1Down:connect(function() on3dButton1Down(mouse, guiMain, player.PlayerGui) end)
	mouse.Button1Up:connect(function() on3dButton1Up(mouse, guiMain, player.PlayerGui) end)
	mouse.Move:connect(function() on3dMouseMove(mouse, guiMain) end)
	
	selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "MainSelectionBox"
	selectionBox.Color = BrickColor.Red()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui;

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Delete Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = BrickColor.Red()
	selectionLasso.Parent = game.workspace

	objectValueSelect.HoverBox = Instance.new("SelectionBox")
	objectValueSelect.HoverBox.Name = "HoverBox"
	objectValueSelect.HoverBox.Color = BrickColor.Blue()
	objectValueSelect.HoverBox.Adornee = nil
	objectValueSelect.HoverBox.Parent = player.PlayerGui;

	objectValueSelect.Box = Instance.new("SelectionBox")
	objectValueSelect.Box.Name = "Box"
	objectValueSelect.Box.Color = BrickColor.Blue()
	objectValueSelect.Box.Adornee = nil
	objectValueSelect.Box.Parent = player.PlayerGui;


end

function onUnequippedLocal()
	Tool.TextureId = origTexture

	destroyConfigurationService()

	removeSelectionGui()

	selectionBox:Remove()
	selectionLasso:Remove()
	objectValueSelect.Box:Remove()
	objectValueSelect.HoverBox:Remove()
	objectValueSelect.CancelFrame:Remove()

	guiMain:Remove()

	objectValueSelect = {}
end


local configTable = {}

function createVisualAnnotation(config, guiMain)
	local selection = Instance.new("SelectionBox")
	selection.Name = "Annotation"
	selection.Color = BrickColor.Red()
	selection.Parent = guiMain.Parent
	return selection
end

function configurationParentChanged(data, part)
	if part and not(part:IsA("BasePart")) then
		--Not a legit part, get rid of it
		part = nil
	end

	data["VisualAnnotation"].Adornee = part
end

function showConfigurationAnnotations()
	for config, data in pairs(configTable) do
		data["VisualAnnotation"].Visible = true
	end
end


function hideConfigurationAnnotations()
	for config, data in pairs(configTable) do
		data["VisualAnnotation"].Visible = false
	end
end

function configurationAdded(config, guiMain)
	if configTable[config] then
		return
	end
	
	local data = {}
	data.Configuration = config
	data.VisualAnnotation = createVisualAnnotation(config, guiMain)
	if config:IsA("Configuration") then
		data.Connection = config.AncestryChanged:connect(function(child, newParent) if child == config then configurationParentChanged(data, newParent) end end)
		configurationParentChanged(data, config.Parent)
	else
		configurationParentChanged(data, config)
	end

	configTable[config] = data
end

function configurationRemoved(config)
	local data = configTable[config]	
	if not(data) then
		--I have no opinion about this
		return
	end

	if data.Connection then
		data.Connection:disconnect()
	end

	data.VisualAnnotation:Remove()
	
	configTable[config] = nil
end

local ServiceConnections

function findVehicleSeats(object, guiMain)
	if object:IsA("VehicleSeat") then
		configurationAdded(object, guiMain)
	end
	for index,child in pairs(object:GetChildren()) do
		findVehicleSeats(child, guiMain)
	end
end

function setUpConfigurationService(guiMain)
	ServiceConnections = {}
	local collectionService = game:GetService("CollectionService")

	ServiceConnections[#ServiceConnections+1] = collectionService.ItemAdded:connect(function(instance) if instance:IsA("Configuration") then configurationAdded(instance, guiMain) end end)
	ServiceConnections[#ServiceConnections+1] = collectionService.ItemRemoved:connect(function(instance) if instance:IsA("Configuration") then configurationRemoved(instance) end end)

	local configs = collectionService:GetCollection("Configuration")
	if configs then
		for pos, config in pairs(configs) do
			configurationAdded(config, guiMain)
		end
	end

	ServiceConnections[#ServiceConnections+1] = game.workspace.DescendantAdded:connect(function(instance) if instance:IsA("VehicleSeat") then configurationAdded(instance, guiMain) end end)
	ServiceConnections[#ServiceConnections+1] = game.workspace.DescendantRemoving:connect(function(instance) if instance:IsA("VehicleSeat") then configurationRemoved(instance) end end)
	findVehicleSeats(game.workspace, guiMain)

end

function destroyConfigurationService()
	for config, data in pairs(configTable) do
		configurationRemoved(config)
	end
	for index, connection in pairs(ServiceConnections) do
		connection:disconnect()
	end
	ServiceConnections = {}
end



Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)