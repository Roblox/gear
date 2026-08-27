-- general functions
function waitForProperty(instance, name)
	while not instance[name] do
		instance.Changed:wait()
	end
end
function waitForChild(instance, name)
	while not instance:FindFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

local RbxGui
if LoadLibrary then
	RbxGui = LoadLibrary("RbxGui")
else
	return
end

local isRestricted = false
print(game.PlaceId)
if game.PlaceId == 41324860 then
	isRestricted = true
end
print(isRestricted)

local Tool = script.Parent

enabled = true
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=59785529")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=61423967")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=61427382")

local configIconImage = "http://www.roblox.com/asset/?id=59785529"
local configIconOverImage = "http://www.roblox.com/asset/?id=61423967"
local configIconHoverImage = "http://www.roblox.com/asset/?id=61427382"
local highlightedImage = nil

local STATIC_BASE_PLATE = nil

local ServiceConnections

local guiMain
local screen

local selectionGui

local player
local playerArea

local canTween = true
local gridRecalc
local lastPart

local lastConfig = nil
local lastVehicleSeat = nil
local origValueMap = {}

local valueConnections = {}

local objectValueSelect = {}

local adornmentTable = {}

local colorPaletteSelectMode = false

local needsIconReset = false

local textSize = 5

--Constants
local width = UDim.new(3, 0)
local height = 20 
local transparency = 0.5
local buttonColor = BrickColor.new("Mid gray")
local frameColor = BrickColor.new("Pastel yellow")


local function isInModel(part)
	if part == game.Workspace then
		return false, nil
	elseif part:IsA("Model") then
		return true, part
	else
		return isInModel(part.Parent)
	end
end


function constrained(valueObject)
	return (valueObject:IsA("IntConstrainedValue") or valueObject:IsA("DoubleConstrainedValue"))
end

function sharedProcess(name, parentFrame)
	local subFrame = Instance.new("Frame")
	subFrame.Name = name
	subFrame.Size = UDim2.new(1.0, 0, 0, height)
	subFrame.BackgroundTransparency = 1.0
	subFrame.BorderSizePixel = 0
	
	local label = Instance.new("TextLabel")
	label.Font = Enum.Font.ArialBold
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
	textBox.BackgroundTransparency = 1
	textBox.FontSize = textSize - 3
	textBox.TextColor3 = Color3.new(1,1,1)
	textBox.Text = text	
	textBox.ZIndex = 2

	local textBoxBacking = Instance.new("TextButton")
	textBoxBacking.Text = ""
	textBoxBacking.Style = Enum.ButtonStyle.RobloxButtonDefault
	textBoxBacking.Size = UDim2.new(1,0,1,0)
	textBoxBacking.Parent = textBox

	return textBox
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
	checkBox.Style = Enum.ButtonStyle.RobloxButtonDefault
	checkBox.TextColor3 = Color3.new(1,1,1)
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

function processConstrainedNumberValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), value.ConstrainedValue, function(textBox) value.ConstrainedValue = textBox.Text end)
	textBox.Name = value.Name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop)
		if prop == "Text" then
			local prevValue = value.ConstrainedValue
			if textBox.Text ~= "" then
				pcall(function() value.ConstrainedValue = textBox.Text end)
			end
			textBox.Text = value.ConstrainedValue
		end
	end)
	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) textBox.Text = newValue end)
	
	textBox.Parent = subFrame
	return subFrame;
end

function processIntValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), value.Value, function(textBox) value.Value = textBox.Text end)
	textBox.Name = value.Name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop)
		if prop == "Text" then
			local prevValue = value.Value
			if textBox.Text ~= "" then
				pcall(function() value.Value = textBox.Text end)
			end
			textBox.Text = value.Value
		end
	end)
	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) textBox.Text = newValue end)
	
	textBox.Parent = subFrame
	return subFrame;
end

function processPropertyValue(object, name, field, guiFrame)
	origValueMap[name] = object[field]

	local subFrame = sharedProcess(name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), object[field], function(textBox) object[field] = textBox.Text end)
	textBox.Name = name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop) 
		if prop == "Text" then
			if textBox.Text ~= "" then
				local success = pcall(function() object[field] = textBox.Text end)
			end
			textBox.Text = object[field]
		end
	end)

	valueConnections[#valueConnections+1] = object.Changed:connect(function(property) if property == field then textBox.Text = object[field] end end)
	
	textBox.Parent = subFrame
	return subFrame
end


function processEnumValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)

	local valueChildren = value:GetChildren()
	local enumNames = {}
	for i = 1, #valueChildren do
		if valueChildren[i]:IsA("BoolValue") and valueChildren[i].Value == true then
			table.insert(enumNames,valueChildren[i].Name)
		end
	end

	local valueToChange = value
	local enumSelect = function(item)
		valueToChange.Value = tostring(item)
	end

	local dropDownEnumMenu, updateEnumSelection = RbxGui.CreateDropDownMenu(enumNames, enumSelect)
	dropDownEnumMenu.Position = UDim2.new(0.5,0,0,0)
	dropDownEnumMenu.Size = UDim2.new(0.5,0,0,20)
	dropDownEnumMenu.Parent = subFrame

	for i = 1, #valueChildren do
		if value.Value == valueChildren[i].Name then
			dropDownEnumMenu.DropDownMenuButton.Text = valueChildren[i].Name
			break
		end
	end

	return subFrame
end



function processNumberValue(value, guiFrame)
	return processIntValue(value, guiFrame)
end


function processStringValue(value, guiFrame)
	return processIntValue(value, guiFrame)
end

function inBaseplate(instance)
	if instance == STATIC_BASE_PLATE then return true end

	local instanceCopy = instance

	while instanceCopy and (instanceCopy.Parent ~= nil or instanceCopy.Parent ~= game.Workspace) do
		if instanceCopy.Parent == STATIC_BASE_PLATE then
			return true
		end
		instanceCopy = instanceCopy.Parent
	end

	return false
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

	local primaryColor = Instance.new("TextButton")
	primaryColor.Position = UDim2.new(0.0, 1, 0.0, 1)
	primaryColor.Size = UDim2.new(0.0, height-2, 0, height-2)
	primaryColor.Text  = ""	
	primaryColor.FontSize = textSize
	primaryColor.BackgroundColor = value.Value
	primaryColor.BorderColor = BrickColor.Black()
	primaryColor.Parent = sideBar

	local hoverSelection = Instance.new("TextLabel")
	hoverSelection.Position = UDim2.new(0.0, height+2, 0.0, 0)
	hoverSelection.Size = UDim2.new(1.0, -height - 4, 1.0, 0)
	hoverSelection.Text = ""
	hoverSelection.Font = Enum.Font.ArialBold
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

	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) changeColorSelection(primaryColor, paletteFrame, colorButtonTable[newValue.Number], selectedButtonTable) end)	
	return subFrame
end


function onObjectValueMouseClick(guiFrame, value, objectButton)
	objectValueSelect["Value"] = value
	objectValueSelect["Frame"] = guiFrame
	objectValueSelect["Enabled"] = true

	onObjectValueMouseLeave(value, objectButton)
end

function onObjectValueMouseEnter(value, objectButton)
	objectValueSelect["HoverValue"] = value
	if value.Value then
		objectButton.BackgroundColor = BrickColor.Blue()
	else
		objectButton.BackgroundColor = BrickColor.White()
	end
end
	
function onObjectValueMouseLeave(value, objectButton)
	if objectValueSelect["HoverValue"] == value then
		objectValueSelect["HoverValue"] = nil
	end
	objectButton.BackgroundColor = buttonColor
end

function onObjectValueCancel()
	if objectValueSelect["Enabled"] then
		objectValueSelect["Enabled"] = false

		objectValueSelect["Frame"].Visible = true
		objectValueSelect["Frame"] = nil
		objectValueSelect["Value"] = nil
	end
end

function on3dObjectValueButton1Up(mouse, guiMain)
	local part = mouse.Target
	if part ~= nil then
		objectValueSelect["Value"].Value = part

		objectValueSelect["Enabled"] = false

		objectValueSelect["Frame"].Visible = true

		objectValueSelect["Frame"] = nil
		objectValueSelect["Value"] = nil
	end
end

function on3dObjectValueMouseMove(mouse, guiMain)
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
	if constrained(value) then origValueMap[value.Name] = value.ConstrainedValue
	else origValueMap[value.Name] = value.Value end

	if #value:GetChildren() > 0 and value:IsA("StringValue") then
		return processEnumValue(value, guiFrame)
	else
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
		elseif value.className == "IntConstrainedValue" or value.className == "DoubleConstrainedValue" then
			return processConstrainedNumberValue(value, guiFrame)
		else
			return nil
		end
	end
end

function killFrame(frame)
	screen.Enabled = false
	frame:remove()
end

function closeFrame(frame)
	lastPart = nil
	if frame.Parent == nil then return end
	frame:TweenSizeAndPosition(UDim2.new(0,0,0,0),UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5, true, function() killFrame(frame) end)
end

function allowTween()
	canTween = true
end

function openFrame(frame,size)
	if not canTween then return end
	canTween = false
	screen.Enabled = true
	frame.Size = UDim2.new(0,0,0,0)
	frame.Position = UDim2.new(0.5,0,0.5,0)
	frame:TweenSizeAndPosition(size,UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5,true, function() allowTween() end)
end

function sharedMain(name, playerGui)
	local parentFrame = Instance.new("Frame")
	parentFrame.Style = Enum.FrameStyle.RobloxRound
	parentFrame.Active = true
	parentFrame.Name = "MainFrame"
	parentFrame.Size = UDim2.new(1, 0, 1, 0)
	parentFrame.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Font = Enum.Font.ArialBold
	titleLabel.FontSize = textSize + 2
	titleLabel.Size = UDim2.new(1.0, 0.0, 0.0, height)
	titleLabel.TextColor = BrickColor.White()
	titleLabel.BackgroundColor = BrickColor.new("Cool yellow")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = name
	titleLabel.Parent = parentFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Style = Enum.ButtonStyle.RobloxButtonDefault
	closeButton.Size = UDim2.new(0,20,0,20)
	closeButton.Position = UDim2.new(1,-16,0,-5)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.new(1,1,1)
	closeButton.Font = Enum.Font.ArialBold
	closeButton.FontSize = Enum.FontSize.Size18
	closeButton.Parent = parentFrame

	local closeCon = nil
	closeCon = closeButton.MouseButton1Click:connect(function()
		closeCon:disconnect()
		removeBillboards()
		screen.Enabled = false
		cancelSelectionGui()
	end)

	local scrollFrame, scrollUpButton, scrollDownButton, recalculateFunction = RbxGui.CreateScrollingFrame()
	gridRecalc = recalculateFunction
	scrollFrame.Name = "ValueContainer"
	scrollFrame.Size = UDim2.new(1,-17,1,-50)
	scrollFrame.Position = UDim2.new(0,0,0,25)
	scrollFrame.Parent = parentFrame

	local changerCon = nil
	delay(1,function()
		if scrollFrame and scrollFrame.Parent then
			changerCon = scrollFrame.Changed:connect(function(prop)
				if prop == "AbsoluteSize" then
					if scrollFrame.AbsoluteSize.Y < 38 then
						changerCon:disconnect()
						closeFrame(parentFrame)
					else
						gridRecalc()
					end
				end
			end)
		end
	end)

	local dieCon
	dieCon = scrollFrame.AncestryChanged:connect(function(child,parent)
		if parent == nil then
			dieCon:disconnect()
			if changerCon then changerCon:disconnect() end
		end
	end)

	local scrollButtonFrame = Instance.new("Frame")
	scrollButtonFrame.Name = "ScrollButtonFrame"
	scrollButtonFrame.Position = UDim2.new(1,-17,0,25)
	scrollButtonFrame.Size = UDim2.new(0,17,1,-50)
	scrollButtonFrame.BackgroundTransparency = 1
	scrollButtonFrame.Parent = parentFrame

	scrollUpButton.Parent = scrollButtonFrame
	scrollDownButton.Parent = scrollButtonFrame
	scrollDownButton.Position = UDim2.new(0,0,1,-17)
	

	return parentFrame
end

function sharedButtons(parentFrame, valueChildren)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "Buttons"
	buttonFrame.BackgroundTransparency = 1.0
	buttonFrame.Size = UDim2.new(1.0, 0.0, 0.0, height)
	buttonFrame.Position = UDim2.new(0.0, 0, 1, -25)
	buttonFrame.Parent = parentFrame
	valueChildren = valueChildren + 1

	local okButton = Instance.new("TextButton")
	okButton.FontSize = textSize
	okButton.Name = "OkButton"
	okButton.Font = Enum.Font.ArialBold
	okButton.TextColor = BrickColor.White()
	okButton.Style = Enum.ButtonStyle.RobloxButton
	okButton.Text = "Ok"
	okButton.Size = UDim2.new(.25, -4, 0.0, height + 5)
	okButton.Position = UDim2.new(0.55, 2, 0.0, 2)
	okButton.BackgroundColor = buttonColor
	okButton.MouseButton1Click:connect(function() removeSelectionGui() end)
	okButton.Parent = buttonFrame

	local cancelButton = okButton:clone()
	cancelButton.Name = "cancelButton"
	cancelButton.Text  = "Cancel"
	cancelButton.Position = UDim2.new(0.200000003, 2, 0, 2)
	cancelButton.MouseButton1Click:connect(function() cancelSelectionGui() end)
	cancelButton.Parent = buttonFrame
end

function processVehicleSeat(vehicleSeat, playerGui, valueChildren)
	local parentFrame = sharedMain(vehicleSeat.Name, playerGui)
	lastVehicleSeat = vehicleSeat

	local valueChildren = 1
	local fields = {"MaxSpeed", "Steer", "Torque", "TurnSpeed"}
	for pos, field in pairs(fields) do
		local newFrame = processPropertyValue(vehicleSeat, field, field, guiFrame)
		if newFrame then
			newFrame.Position = UDim2.new(0.0, 0, 0.0, (valueChildren*height) - height)
			newFrame.Parent = parentFrame.ValueContainer
			valueChildren = valueChildren + 1
		end

	end

	sharedButtons(parentFrame, valueChildren)
	return parentFrame
end

function processConfiguration(config, playerGui)
	local parentFrame = sharedMain(config.Name, playerGui)
	lastConfig = config

	local valueChildren = 1
	local children = config:GetChildren() 
	if children then
		for pos, child in pairs(children) do
			local newFrame = processValue(child, playerGui, parentFrame)
			if newFrame then
				newFrame.Position = UDim2.new(0.0, 0, 0.0, (valueChildren*height) - height)
				newFrame.Parent = parentFrame.ValueContainer
				valueChildren = valueChildren + 1
			end
		end
	end
	
	sharedButtons(parentFrame, valueChildren)
	return parentFrame
end

function on3dMouseMove(mouse, guiMain)
	if mouse.Target and canSelectObject(mouse.Target) then

		local part = mouse.Target
		if part:IsA("VehicleSeat") then
			foundPart = part
		else
			foundPart = findConfiguration(part)
		end

		if foundPart then
			mouse.Icon = "rbxasset://textures\\DragCursor.png"
			if objectValueSelect["HoverBox"] then 
				local isModel, model = isInModel(part)
				local adornee = part
				if isModel then
					adornee = model
				end

				objectValueSelect["HoverBox"].Adornee = adornee
				local billboard = getBillboard(adornee)

				local configBadge = billboard:FindFirstChild("ConfigBadge",true)
				if configBadge then
					configBadge.Image = configIconOverImage
					highlightedImage = configBadge
				end
			end
			needsIconReset = true
		else
			if needsIconReset then
				mouse.Icon = ""
				if objectValueSelect["HoverBox"] then objectValueSelect["HoverBox"].Adornee = nil end
				needsIconReset = false

				if highlightedImage then 
					highlightedImage.Image = configIconImage
				end
			end
		end
	else
		if needsIconReset then
			mouse.Icon = ""
			if objectValueSelect["HoverBox"] then objectValueSelect["HoverBox"].Adornee = nil end
			needsIconReset = false

			if highlightedImage then 
				highlightedImage.Image = configIconImage
			end
		end
	end

	if objectValueSelect["Enabled"] then
		on3dObjectValueMouseMove(mouse, guiMain)
	end
end

function cancelSelectionGui()
	lastPart = nil

	if selectionGui ~= nil then
		closeFrame(selectionGui)
		selectionGui = nil
		for pos, connection in pairs(valueConnections) do
			connection:disconnect()
		end
		valueConnections = {}
	end

	showConfigurationAnnotations()

	if lastConfig then
		local configValues = lastConfig:GetChildren()
		for i = 1, #configValues do
			if origValueMap[configValues[i].Name] ~= nil then
				if constrained(configValues[i]) then configValues[i].ConstrainedValue = origValueMap[configValues[i].Name]
				else configValues[i].Value = origValueMap[configValues[i].Name] end

				origValueMap[configValues[i].Name] = nil
			end
		end
	elseif lastVehicleSeat then
		lastVehicleSeat.MaxSpeed = origValueMap["MaxSpeed"]
		origValueMap["MaxSpeed"] = nil
		lastVehicleSeat.Steer = origValueMap["Steer"]
		origValueMap["Steer"] = nil
		lastVehicleSeat.Torque = origValueMap["Torque"]
		origValueMap["Torque"] = nil
		lastVehicleSeat.TurnSpeed = origValueMap["TurnSpeed"]
		origValueMap["TurnSpeed"] = nil
	end
end

function removeSelectionGui()
	if selectionGui ~= nil then
		closeFrame(selectionGui)
		for pos, connection in pairs(valueConnections) do
			connection:disconnect()
		end
		valueConnections = {}
	end

	if objectValueSelect["HoverBox"] then objectValueSelect["HoverBox"].Adornee = nil end

	showConfigurationAnnotations()

	if lastConfig then
		local configValues = lastConfig:GetChildren()
		for i = 1, #configValues do
			if origValueMap[configValues[i].Name] ~= nil then
				origValueMap[configValues[i].Name] = nil
			end
		end
	end
end

function canSelectObject(part)
	if isRestricted then
		waitForChild(playerArea,"PlayerArea")
		if isRestricted and playerArea:FindFirstChild("PlayerArea") and part:IsDescendantOf(playerArea.PlayerArea) then
			return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
		else
			return false
		end
	end

	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end

local function findConfigInModel(model)
	local children = model:GetChildren()
	for i = 1, #children do
		if children[i]:IsA("Configuration") or children[i]:IsA("VehicleSeat") then
			return children[i]
		end
	end
	for i = 1, #children do
		if #children[i]:GetChildren() > 0 then
			local returnValue = findConfigInModel(children[i])
			if returnValue ~= nil then
				return returnValue
			end
		end
	end

	return nil
end

function findConfiguration(part)
	print("findConfiguration on",part)
	local partInModel, model = isInModel(part)
	if partInModel then
		local isModelConfig = findConfigInModel(model)
		return isModelConfig
	else
		local children = part:GetChildren() 		
		if children then
			for pos, child in pairs(children) do
				if child:IsA("Configuration") or child:IsA("VehicleSeat") then
					return child
				end
			end
		end
	end
	return nil
end

function removeBillboards()
	local guis = guiMain:GetChildren()
	for i = 1, #guis do
		if guis[i]:IsA("Frame") then
			guis[i]:remove()
		end
	end
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
			foundPart = findConfiguration(part)
		end
	
		if foundPart then
			
			if foundPart == lastPart then
				return
			end
			lastPart = foundPart

			removeBillboards()
			screen.Enabled = true

			if foundPart:IsA("Configuration") then
				selectionGui = processConfiguration(foundPart, playerGui)
			else
				selectionGui = processVehicleSeat(foundPart, playerGui)	
			end
			selectionGui.Parent = guiMain
			openFrame(selectionGui, selectionGui.Size)

			local hasModel, model = isInModel(part)
			if hasModel then
				screen.Adornee = model
			else
				screen.Adornee = part
			end

			if highlightedImage then 
				highlightedImage.Image = configIconImage
			end
		end
	else
		cancelSelectionGui()
	end
end

function onEquippedLocal(mouse)
	local character = script.Parent.Parent
	player = game.Players:GetPlayerFromCharacter(character)

	if player == nil then return end

	print("isRestricted = ",isRestricted)
	if isRestricted then
		waitForChild(game.Workspace,"BuildingAreas")
		waitForChild(game.Workspace.BuildingAreas,"Area1")
		waitForChild(game.Workspace.BuildingAreas.Area1,"Player")
		local areas = game.Workspace.BuildingAreas:GetChildren()
		for i = 1, #areas do
			if areas[i]:FindFirstChild("Player") and areas[i].Player.Value == player.Name then
				playerArea = areas[i]
				break
			end
		end
		print("player area is",playerArea)
		STATIC_BASE_PLATE = playerArea
	end

	if not screen then
		screen = Instance.new("BillboardGui")
		screen.Name = "ConfigGui"
		screen.Size = UDim2.new(0,360,0,180)
		screen.Enabled = false
		screen.Active = true
		screen.Parent = player.PlayerGui
		screen.AlwaysOnTop = true

		guiMain = Instance.new("Frame")
		guiMain.BackgroundTransparency = 1
		guiMain.Size = UDim2.new(1,0,1,0)
		guiMain.Parent = screen
	else
		removeBillboards()
		lastPart = nil
		screen.Parent = player.PlayerGui
	end

	setUpConfigurationService(guiMain)
	showConfigurationAnnotations()

	mouse.Button1Up:connect(function() on3dButton1Up(mouse, guiMain, player.PlayerGui) end)
	mouse.Move:connect(function() on3dMouseMove(mouse, guiMain) end)

	objectValueSelect.HoverBox = Instance.new("SelectionBox")
	objectValueSelect.HoverBox.Name = "HoverBox"
	objectValueSelect.HoverBox.Color = BrickColor.new("Really blue")
	objectValueSelect.HoverBox.Transparency = 0.5
	objectValueSelect.HoverBox.Adornee = nil
	objectValueSelect.HoverBox.Parent = player.PlayerGui;
end

function onUnequippedLocal()

	local guiChildren = game.Players.LocalPlayer.PlayerGui:GetChildren()
	for i = 1, #guiChildren do
		if guiChildren[i]:IsA("BillboardGui") then
			guiChildren[i].Parent = nil
		end
	end

	destroyConfigurationService()

	objectValueSelect.HoverBox:Remove()

	if screen then
		screen.Parent = nil
	end

	player = nil

	hideConfigurationAnnotations()

	objectValueSelect = {}
end


local configTable = {}

function createVisualAnnotation(config, guiMain)
	local selection = Instance.new("SelectionBox")
	selection.Name = "Annotation"
	selection.Color = BrickColor.new("Really blue")
	selection.Transparency = 0.5
	selection.Parent = guiMain.Parent
	return selection
end

function configurationParentChanged(data, part)
	local isModel, model = isInModel(part)
	if not isModel then
		data["VisualAnnotation"].Adornee = part
	else
		data["VisualAnnotation"].Adornee = model
	end
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

local function isInMyArea(part)
	if part.Parent == nil then return false end
	if part.Parent:FindFirstChild("Player") and part.Parent.Player:IsA("StringValue") then
		if part.Parent.Player.Value == player.Name then
			return true
		else
			return false
		end
	elseif part.Parent == game.Workspace.BuildingAreas or part.Parent == game.Workspace then
		return false
	else
		return isInMyArea(part.Parent)
	end
end

function findBillboard(guiTable)
	if not guiTable then return end

	for i = 1, #guiTable do
		if guiTable[i] and guiTable[i]:IsA("BillboardGui") then
			return guiTable[i]
		end
	end
end

function getBillboard(adornee)
	local guiKey = adornee
	
	local billboard = findBillboard(adornmentTable[guiKey])
	if not billboard then
		local screen = Instance.new("BillboardGui")
		screen.Name = adornee.Name .. "BadgeGUI"
		screen.Size = UDim2.new(1.5,0,1.5,0)
		screen.Enabled = true
		screen.Active = true
		screen.AlwaysOnTop = true
		screen.ExtentsOffset = Vector3.new(0,0,0)
		screen.Adornee = adornee
		screen.Parent = game.Players.LocalPlayer.PlayerGui

		if not adornmentTable[guiKey] then 
			adornmentTable[guiKey] = {}
		end
		table.insert(adornmentTable[guiKey],screen)

		return screen
	end

	return billboard
end

function hasBadge(adornee)
	local screen = getBillboard(adornee)
	if not screen then return false end
	return screen:FindFirstChild("Badge",true)
end

function removeBadge(adornee)
	local screen = getBillboard(adornee)
	local badge = screen:FindFirstChild("ConfigBadge",true)
	if badge then badge:remove() end
end

function giveConfigBadge(adornee)
	local billboard = getBillboard(adornee)

	local configBadge = Instance.new("ImageLabel")
	configBadge.Name = "ConfigBadge"
	configBadge.BackgroundTransparency = 1
	configBadge.Image = configIconImage
	configBadge.Size = UDim2.new(1,0,1,0)
	configBadge.Parent = billboard

	billboard.Parent =  game.Players.LocalPlayer.PlayerGui

	local badgeCon = configBadge.Changed:connect(function(prop)
		if prop == "AbsoluteSize" then
			configBadge.Visible = (configBadge.AbsoluteSize.X > 10)
		end
	end)

	local enterCon = configBadge.MouseEnter:connect(function()
		configBadge.Image = configIconHoverImage
	end)

	local leaveCon = configBadge.MouseLeave:connect(function()
		configBadge.Image = configIconImage
	end)

	local killCon = nil
	killCon = configBadge.AncestryChanged:connect(function(child,parent)
		if parent == nil then
			killCon:disconnect()
			badgeCon:disconnect()
			enterCon:disconnect()
			leaveCon:disconnect()
		end
	end)
end

function configurationAdded(config, guiMain)
	if configTable[config] then
		return
	end

	if isRestricted and not inBaseplate(config) then return end
	
	local data = {}
	data.Configuration = config
	data.VisualAnnotation = createVisualAnnotation(config, guiMain)
	if config:IsA("Configuration") then
		data.Connection = config.AncestryChanged:connect(function(child, newParent)
			if child == config then
				configurationParentChanged(data, newParent)
			end
		end)
		configurationParentChanged(data, config.Parent)
	else
		configurationParentChanged(data, config)
	end

	local partInModel, model = isInModel(config.Parent)
	if partInModel then
		if not hasBadge(model) then
			giveConfigBadge(model)
		end
	else
		if not hasBadge(config.Parent) then
			giveConfigBadge(config.Parent)
		end
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
	removeBadge(config.Parent)
	
	configTable[config] = nil
end

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