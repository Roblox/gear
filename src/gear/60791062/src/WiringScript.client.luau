function waitForChild(parent, child)
	while not parent:FindFirstChild(child) do
		parent.ChildAdded:wait()
	end
end

local Tool = script.Parent
local mouseMoveCon, mouseButtonDownCon = nil

local eventTable = {}
local receiverTable = {}
local ServiceConnections = {}
local adornmentTable = {}

local eventBadgeCount = {}
local receiverBadgeCount = {}

local root = nil

local isRestricted = false
if tostring(game.PlaceId) == "41324860" then
	isRestricted = true
end

local CONNECT_BILLBOARD_GUI = "ConnectBillboardGui"
local WIRE_LASSO = "WireLasso"
local WIRE_TEXTURE = "http://www.roblox.com/asset?id=56954045"
--local WIRE_TEXTURE = "rbxasset://Textures/ui/playerlist_small_hide_dn.png"
local KILL_WIRE_TEXTURE = "rbxasset://Textures/ui/CloseButton_dn.png"
local STATIC_PLAYER_GUI = nil
local STATIC_BASE_PLATE = nil
local SELECTED_SOURCE = nil
local SELECTED_SINK = nil
local WIRE_LASSO_MAP = {}
local WIRING_PANEL_MAP = {}
local LAST_HOVERED_PART = nil
local SCREEN_MESSAGE = nil
local ANNOTATIONS = {}
local KNOWN_SOURCE_PARTS = {}
local KNOWN_SINK_PARTS = {}
local BASE_ANNOTATION_TRANSPARENCY = 0.5
local BASE_WIRE_TRANSPARENCY = 0.5
local BASE_WIRE_RADIUS = .06
local ENHANCED_WIRE_RADIUS = .12
local SOURCE_BUTTON_TEXT_COLOR = Color3.new(1, .5, 0)
local SOURCE_BUTTON_ICON_TEXTURE = "http://www.roblox.com/asset?id=61334830"
local SOURCE_BUTTON_ICON_HOVER_TEXTURE = "http://www.roblox.com/asset?id=61335012"
local SINK_BUTTON_TEXT_COLOR = Color3.new(0, 1, 0)
local SINK_BUTTON_ICON_TEXTURE = "http://www.roblox.com/asset?id=60730993"
local SINK_BUTTON_ICON_HOVER_TEXTURE = "http://www.roblox.com/asset?id=61335025"
local BUTTON_HOVER_TEXT_COLOR = Color3.new(1, 1, 1)
local BUTTON_ICON_WIDTH = 50
local DISCONNECT_ICON_HOVER_TEXTURE = "http://www.roblox.com/asset?id=55130256"
local DISCONNECT_SOURCE_ICON_TEXTURE = "http://www.roblox.com/asset?id=55130237"
local DISCONNECT_SINK_ICON_TEXTURE = "http://www.roblox.com/asset?id=55130219"
local TAIL_TEXTURE = "http://www.roblox.com/asset?id=55134078"
local USE_BILLBOARD_GUI = true
local LAST_CLICK_TIME = 0
local CLICK_HELP_TIME_DELTA = .8
local SOURCE_BADGE_TEXTURE = "http://www.roblox.com/asset?id=60730993"
local SINK_BADGE_TEXTURE = "http://www.roblox.com/asset?id=61334830"

local ALL_TEXTURES = { SOURCE_BUTTON_ICON_TEXTURE, SOURCE_BUTTON_ICON_HOVER_TEXTURE,
		SINK_BUTTON_ICON_TEXTURE, SINK_BUTTON_ICON_HOVER_TEXTURE,
		DISCONNECT_ICON_HOVER_TEXTURE, DISCONNECT_SOURCE_ICON_TEXTURE,
		DISCONNECT_SINK_ICON_TEXTURE, TAIL_TEXTURE, WIRE_TEXTURE, SOURCE_BADGE_TEXTURE, SINK_BADGE_TEXTURE}

for idx, asset in ipairs(ALL_TEXTURES) do
	game:GetService("ContentProvider"):Preload(asset)
end

function clearSelection()
	SELECTED_SOURCE = nil
	SELECTED_SINK = nil
	getLocalLasso().From = nil
	getLocalLasso().To = nil
end

function clearScreenMessage()
	if SCREEN_MESSAGE ~= nil then
		SCREEN_MESSAGE:Remove()
		SCREEN_MESSAGE = nil
	end
end

function clearHover()
	if LAST_HOVERED_PART ~= nil then
		local lastHover = LAST_HOVERED_PART
		if not ANNOTATIONS[lastHover] then
			lastHover = findModel(lastHover)
		end

		ANNOTATIONS[lastHover].Transparency = BASE_ANNOTATION_TRANSPARENCY
		if WIRING_PANEL_MAP[lastHover] ~= nil then
			WIRING_PANEL_MAP[lastHover]:Remove()
			WIRING_PANEL_MAP[lastHover] = nil
		end
		setPartWireTransparency(LAST_HOVERED_PART, BASE_WIRE_TRANSPARENCY, BASE_WIRE_RADIUS, "")
	end
end

function getPlayerGui()
	if STATIC_PLAYER_GUI == nil then
		STATIC_PLAYER_GUI = game.Players:GetPlayerFromCharacter(Tool.Parent).PlayerGui
	end
	return STATIC_PLAYER_GUI
end

function findMyBasePlate()
	if isRestricted then
		if STATIC_BASE_PLATE == nil then
			local buildingAreas = game.Workspace.BuildingAreas:GetChildren()
			for i = 1, #buildingAreas do
				if buildingAreas[i].Player.Value == script.Parent.Parent.Name then
					waitForChild(buildingAreas[i],"PlayerArea")
					STATIC_BASE_PLATE = buildingAreas[i].PlayerArea
				end
			end
		end
		return STATIC_BASE_PLATE
	end

	return nil
end

function getLocalLasso()
	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("lasso") then
		local lasso = Instance.new("FloorWire")
		lasso.Name = "lasso"
		lasso.Parent = game.Players.LocalPlayer.PlayerGui
		lasso.Color = BrickColor.new("Really black")
	end

	return game.Players.LocalPlayer.PlayerGui.lasso
end

function findModel(part)
	if isRestricted then
		local basePlate = findMyBasePlate()
		while part ~= nil do
			if part.className == "Model" and part.Name ~= basePlate.Name and part.Name ~= "GarbageParts" then
				return part
			elseif part.Name == basePlate.Name or part.Name == "GarbageParts" then
				return nil
			end
			part = part.Parent
		end
	else
		local origPart = part
		while part ~= nil do
			if part.className == "Model" then
				return part
			elseif part.Name == "Workspace" or part.Name == "game" then
				return origPart
			end
			part = part.Parent
		end
	end

	return nil
end

function createVisualAnnotation(part, guiMain)
	local selection = Instance.new("SelectionBox", guiMain)
	selection.Name = "Annotation"
	selection.Color = BrickColor.new("Lime green")
	selection.Transparency = BASE_ANNOTATION_TRANSPARENCY
	selection.Adornee = part
	return selection
end

function isInteractivePart(obj)
	if obj == nil then return false end
	if obj:IsA("Part") then
		for idx, child in ipairs(obj:GetChildren()) do
			if child:IsA("CustomEvent") or child:IsA("CustomEventReceiver") then
				return true
			end
		end
	end
	return false
end

function applyToConnectorsWires(sourceOrSink, fn)
	if sourceOrSink:IsA("CustomEvent") then
		for idx, recv in ipairs(sourceOrSink:GetAttachedReceivers()) do
			fn(WIRE_LASSO_MAP[sourceOrSink][recv])
		end
	else
		local source = sourceOrSink.Source
		if source ~= nil then
			fn(WIRE_LASSO_MAP[source][sourceOrSink])
		end
	end
end

function warnNoWireableParts()
	local topHint = nil
	pcall(function() topHint = getPlayerGui().Gui.Hints.CenterHint end)
	
	if topHint then
		topHint.Add.Label.Value = "No Wiring Parts!  Add Wiring Parts using the Stamper Tool."
		topHint.Add.Width.Value = 580
		topHint.Add.Time.Value = 10
		topHint.Add.Disabled = true  -- flip it off then on, in case it's currently running.
		topHint.Add.Disabled = false
	end
end

function warnNotClickingWireablePart()
	if getPlayerGui():FindFirstChild("CenterHint", true) then
		local topHint = getPlayerGui().Gui.Hints.CenterHint
		topHint.Add.Label.Value = "This part isn't wireable :("
		topHint.Add.Width.Value = 580
		topHint.Add.Time.Value = 2
		topHint.Add.Disabled = true  -- flip it off then on, in case it's currently running.
		topHint.Add.Disabled = false
	end
end

--------------------------------------------------------------------------------
-- Screen messages (when source/sink is selected)

function stylizeScreenMessageLabel(label, text)
	label.Text = text
	label.FontSize = Enum.FontSize.Size24
	label.Font = Enum.Font.ArialBold
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Size = UDim2.new(0, label.TextBounds.x, 0, label.TextBounds.y)
	label.TextColor3 = Color3.new(1, 1, 1)
end

function createSourceIcon(parent, precedingText)
	local sourceIcon = Instance.new("ImageLabel", frame)
	sourceIcon.Archivable = false
	sourceIcon.Image = SOURCE_BUTTON_ICON_TEXTURE
	sourceIcon.Size = UDim2.new(0, 30, 0, 30)
	sourceIcon.BackgroundTransparency = 1
	sourceIcon.BorderSizePixel = 0
	sourceIcon.Position = UDim2.new(0,
			precedingText.Position.X.Offset + precedingText.TextBounds.x + 5,
			0, precedingText.Position.Y.Offset +
				((precedingText.Size.Y.Offset - sourceIcon.Size.Y.Offset) / 2))
	return sourceIcon
end

function createSinkIcon(parent, precedingText)
	local sinkIcon = Instance.new("ImageLabel", frame)
	sinkIcon.Archivable = false
	sinkIcon.Image = SINK_BUTTON_ICON_TEXTURE
	sinkIcon.Size = UDim2.new(0, 30, 0, 30)
	sinkIcon.BackgroundTransparency = 1
	sinkIcon.BorderSizePixel = 0
	sinkIcon.Position = UDim2.new(0,
			precedingText.Position.X.Offset + precedingText.TextBounds.x + 5,
			0, precedingText.Position.Y.Offset +
				((precedingText.Size.Y.Offset - sinkIcon.Size.Y.Offset) / 2))
	return sinkIcon
end

function addToAllXPositions(objs, offset)
	for idx, obj in ipairs(objs) do
		pos = obj.Position
		obj.Position = UDim2.new(0, pos.X.Offset + offset, 0, pos.Y.Offset)
	end
end

function showSourceScreenMessage(source)
	gui = Instance.new("ScreenGui", getPlayerGui())
	gui.Archivable = false
	frame = Instance.new("Frame", gui)
	frame.Archivable = false
	frame.Style = Enum.FrameStyle.RobloxRound

	local line1part1 = Instance.new("TextLabel", frame)
	line1part1.Archivable = false
	stylizeScreenMessageLabel(line1part1, "Choose a")

	sinkIcon = createSinkIcon(frame, line1part1)
	
	line1part2 = Instance.new("TextLabel", frame)
	line1part2.Archivable = false
	stylizeScreenMessageLabel(line1part2, "receiver to trigger when")
	line1part2.Position = UDim2.new(0,
		sinkIcon.Position.X.Offset + sinkIcon.Size.X.Offset + 5, 0, 0)

	line1height = math.max(sinkIcon.Size.Y.Offset, line1part1.Size.Y.Offset)

	line2part1 = Instance.new("TextLabel", frame)
	line2part1.Archivable = false
	stylizeScreenMessageLabel(line2part1, source.Parent.Name)
	line2part1.Position = UDim2.new(0, 0, 0, line1height)
	
	sourceIcon = createSourceIcon(frame, line2part1)

	line2part2 = Instance.new("TextLabel", frame)
	stylizeScreenMessageLabel(line2part2, "signals ")
	line2part2.Position = UDim2.new(0,
		sourceIcon.Position.X.Offset + sourceIcon.Size.X.Offset + 5,
		0, line2part1.Position.Y.Offset)

	line2part3 = Instance.new("TextLabel", frame)
	stylizeScreenMessageLabel(line2part3, source.Name)
	line2part3.TextColor3 = SOURCE_BUTTON_TEXT_COLOR
	line2part3.Position = UDim2.new(0,
		line2part2.Position.X.Offset + line2part2.Size.X.Offset,
		0, line2part1.Position.Y.Offset)

	-- re-center
	line1width = line1part2.Position.X.Offset + line1part2.Size.X.Offset
	line2width = line2part3.Position.X.Offset + line2part3.Size.X.Offset

	if line1width > line2width then
		local halfDelta = (line1width - line2width) / 2
		addToAllXPositions({line2part1, sourceIcon, line2part2, line2part3}, halfDelta)
	else
		local halfDelta = (line2width - line1width) / 2
		addToAllXPositions({line1part1, sinkIcon, line1part2}, halfDelta)
	end

	frame.Size = UDim2.new(0, math.max(line1width, line2width) + 15,
			0, 2 * line1height + 5)
	frame.Position = UDim2.new(.5, -frame.Size.X.Offset/2, 0, 0)

	clearScreenMessage()
	SCREEN_MESSAGE = gui
end

function showSinkScreenMessage(sink)
	gui = Instance.new("ScreenGui", getPlayerGui())
	frame = Instance.new("Frame", gui)
	frame.Style = Enum.FrameStyle.RobloxRound

	local line1part1 = Instance.new("TextLabel", frame)
	stylizeScreenMessageLabel(line1part1, "Choose which")

	local sourceIcon = createSourceIcon(frame, line1part1)
	
	line1part2 = Instance.new("TextLabel", frame)
	stylizeScreenMessageLabel(line1part2, "signal will cause")
	line1part2.Position = UDim2.new(0,
		sourceIcon.Position.X.Offset + sourceIcon.Size.X.Offset + 5, 0, 0)

	local line1height = math.max(sourceIcon.Size.Y.Offset, line1part1.Size.Y.Offset)

	line2part1 = Instance.new("TextLabel", frame)
	stylizeScreenMessageLabel(line2part1, sink.Parent.Name .. " to")
	line2part1.Position = UDim2.new(0, 0, 0, line1height)
	
	local sinkIcon = createSinkIcon(frame, line2part1)

	line2part2 = Instance.new("TextLabel", frame)
	stylizeScreenMessageLabel(line2part2, sink.Name)
	line2part2.TextColor3 = SINK_BUTTON_TEXT_COLOR
	line2part2.Position = UDim2.new(0,
		sinkIcon.Position.X.Offset + sinkIcon.Size.X.Offset,
		0, line2part1.Position.Y.Offset)

	-- re-center
	line1width = line1part2.Position.X.Offset + line1part2.Size.X.Offset
	line2width = line2part2.Position.X.Offset + line2part2.Size.X.Offset

	if line1width > line2width then
		local halfDelta = (line1width - line2width) / 2
		addToAllXPositions({line2part1, sinkIcon, line2part2}, halfDelta)
	else
		local halfDelta = (line2width - line1width) / 2
		addToAllXPositions({line1part1, sourceIcon, line1part2}, halfDelta)
	end

	frame.Size = UDim2.new(0, math.max(line1width, line2width) + 15,
			0, 2 * line1height + 5)
	frame.Position = UDim2.new(.5, -frame.Size.X.Offset/2, 0, 0)

	clearScreenMessage()
	SCREEN_MESSAGE = gui
end

--------------------------------------------------------------------------------
-- Hover

function setPartWireTransparency(part, transparency, wireRadius, texture)
	for idx, child in ipairs(part:GetChildren()) do
		if child:IsA("CustomEvent") then
			for idx2, recv in ipairs(child:GetAttachedReceivers()) do
				addWireUiIfNotAlreadyThere(child, recv)
				WIRE_LASSO_MAP[child][recv].Transparency = transparency
				WIRE_LASSO_MAP[child][recv].WireRadius = wireRadius
				WIRE_LASSO_MAP[child][recv].Texture = texture
				WIRE_LASSO_MAP[child][recv].Color = BrickColor.new("Really black")
			end
		elseif child:IsA("CustomEventReceiver") then
			local source = child.Source
			if source ~= nil then
				addWireUiIfNotAlreadyThere(source, child)
				WIRE_LASSO_MAP[source][child].Transparency = transparency
				WIRE_LASSO_MAP[source][child].WireRadius = wireRadius
				WIRE_LASSO_MAP[source][child].Texture = texture
				WIRE_LASSO_MAP[source][child].Color = BrickColor.new("Really black")
			end
		end
	end
end

function canHighlight(part,model)
	if (KNOWN_SOURCE_PARTS[part] and SELECTED_SOURCE == nil) or (KNOWN_SINK_PARTS[part] and SELECTED_SINK == nil) then
		return true, part
	elseif (KNOWN_SOURCE_PARTS[model] and SELECTED_SOURCE == nil) or (KNOWN_SINK_PARTS[model] and SELECTED_SINK == nil) then
		return true, model
	end

	return false, nil
end

function hoverListener(mouse)
	if mouse.Target == nil then return end

	local part = mouse.Target
	local model = findModel(part)
	if LAST_HOVERED_PART ~= part and findModel(LAST_HOVERED_PART) ~= model then
		clearHover()
		local highlight, instance = canHighlight(part,model)
		if highlight then
			LAST_HOVERED_PART = part
			ANNOTATIONS[model].Transparency = 0
			buildScreenPanel(model, mouse.X, mouse.Y)
			setPartWireTransparency(part, 0, ENHANCED_WIRE_RADIUS, "")
		else
			LAST_HOVERED_PART = nil
		end

		-- Point the temporary wire to the LAST_HOVERED_PART if not nil,
		-- otherwise point it at the character
		local otherEndOfWire = game.Players.LocalPlayer.Character.Humanoid.Torso
		if LAST_HOVERED_PART ~= nil then
			otherEndOfWire = LAST_HOVERED_PART
		end
		if SELECTED_SOURCE ~= nil then
			getLocalLasso().To = otherEndOfWire
		end
		if SELECTED_SINK ~= nil then
			getLocalLasso().From = otherEndOfWire
		end
	end
end

--------------------------------------------------------------------------------
-- Connect / Disconnect dialog

function addWireUiIfNotAlreadyThere(source, sink)
	if WIRE_LASSO_MAP[source] == nil then
		WIRE_LASSO_MAP[source] = {}
	end
	if WIRE_LASSO_MAP[source][sink] ~= nil then
		return
	end

	pairLasso = Instance.new("FloorWire", getPlayerGui())
	pairLasso.From = source.Parent
	pairLasso.To = sink.Parent
	pairLasso.Transparency = BASE_WIRE_TRANSPARENCY
	pairLasso.Texture = ""
	pairLasso.Name = WIRE_LASSO
	pairLasso.Color = BrickColor.new("Really black")
	WIRE_LASSO_MAP[source][sink] = pairLasso
end

function connectHelper(source, sink)
	-- clear wires coming to sink
	local old_source = sink.Source
	if old_source ~= nil then
		wire = WIRE_LASSO_MAP[old_source][sink]
		if wire ~= nil then
			wire:Remove()
			WIRE_LASSO_MAP[old_source][sink] = nil
		end
		sink.Source = nil
	end

	sink.Source = source
	addWireUiIfNotAlreadyThere(source, sink)
end

function makeSourceConnectCallback(source)
	return function()
		clearHover()
		if SELECTED_SINK ~= nil then
			connectHelper(source, SELECTED_SINK)
			clearSelection()
			clearScreenMessage()
			for part, val in pairs(KNOWN_SINK_PARTS) do
				local model = findModel(part)
				ANNOTATIONS[model].Transparency = BASE_ANNOTATION_TRANSPARENCY
			end
		else
			SELECTED_SOURCE = source
			getLocalLasso().From = source.Parent
			getLocalLasso().To = game.Players.LocalPlayer.Character.Humanoid.Torso
			showSourceScreenMessage(SELECTED_SOURCE)
			for part, val in pairs(KNOWN_SOURCE_PARTS) do
				if not KNOWN_SINK_PARTS[part] then
					local model = findModel(part)
					ANNOTATIONS[model].Transparency = 1
				end
			end
		end
	end
end

function makeSinkConnectCallback(sink)
	return function()
		clearHover()
		if SELECTED_SOURCE ~= nil then
			connectHelper(SELECTED_SOURCE, sink)
			clearSelection()
			clearScreenMessage()
			for part, val in pairs(KNOWN_SOURCE_PARTS) do
				local model = findModel(part)
				ANNOTATIONS[model].Transparency = BASE_ANNOTATION_TRANSPARENCY
			end
		else
			SELECTED_SINK = sink
			getLocalLasso().From = game.Players.LocalPlayer.Character.Humanoid.Torso
			getLocalLasso().To = sink.Parent
			showSinkScreenMessage(SELECTED_SINK)
			for part, val in pairs(KNOWN_SINK_PARTS) do
				if not KNOWN_SOURCE_PARTS[part] then
					local model = findModel(part)
					ANNOTATIONS[model].Transparency = 1
				end
			end
		end
	end
end

function makeControlButton(y_position, frame, sourceOrSink, textColor, iconImage, iconHoverImage, callbackBuilder)
	local button = Instance.new("TextButton", frame)
	button.Position = UDim2.new(.025, 0, 0, y_position)
	button.Text = sourceOrSink.Name
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Style = Enum.ButtonStyle.Custom
	button.BorderSizePixel = 0
	button.BackgroundTransparency = 1
	button.BackgroundColor3 = Color3.new(0, 0 ,0)
	button.TextColor3 = textColor
	button.Font = Enum.Font.ArialBold
	button.FontSize = Enum.FontSize.Size18
	button.ZIndex = 2
	button.Size = UDim2.new(.95, 0, 0, button.TextBounds.y)
	
	local icon = Instance.new("ImageLabel", button)
	icon.Image = iconImage
	icon.ZIndex = 2
	icon.Position = UDim2.new(0, button.TextBounds.x + 10, 0, -8)
	icon.Size = UDim2.new(0, 30, 0 , 30)
	icon.BackgroundTransparency = 1

	button.MouseEnter:connect(function()
		applyToConnectorsWires(sourceOrSink, function(wire)
			wire.Texture = WIRE_TEXTURE
			wire.Velocity = 2
		end)
		button.BackgroundTransparency = 0
		button.TextColor3 = BUTTON_HOVER_TEXT_COLOR
		icon.Image = iconHoverImage
	end)
	local leaveCallback = function()
		applyToConnectorsWires(sourceOrSink, function(wire)
			wire.Texture = ""
		end)
		button.BackgroundTransparency = 1
		button.TextColor3 = textColor
		icon.Image = iconImage
	end
	button.MouseLeave:connect(leaveCallback)
	button.MouseButton1Click:connect(function()
		callbackBuilder(sourceOrSink)()
		leaveCallback()
	end)
	return button
end

function makeDisconnectCallback(source, sink)
	clearHover()
	sink.Source = nil
	if WIRE_LASSO_MAP[source] ~= nil then
		lassoUi = WIRE_LASSO_MAP[source][sink]
		if lassoUi ~= nil then
			lassoUi:Remove()
			WIRE_LASSO_MAP[source][sink] = nil
		end
	end
end

function makeDisconnectButton(y_position, frame, localConnector, foreignConnector, textColor, iconImage)
	local source = nil
	local sink = nil
	if localConnector:IsA("CustomEvent") then
		source = localConnector
		sink = foreignConnector
	else
		source = foreignConnector
		sink = localConnector
	end

	local button = Instance.new("TextButton", frame)
	button.Position = UDim2.new(0, 17, 0, y_position)
	button.Text = foreignConnector.Name .. " (" .. foreignConnector.Parent.Name .. ")" 
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Style = Enum.ButtonStyle.Custom
	button.BackgroundTransparency = 1
	button.BackgroundColor3 = Color3.new(0, 0 ,0)
	button.TextColor3 = textColor
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Arial
	button.FontSize = Enum.FontSize.Size18
	button.ZIndex = 3
	button.Size = UDim2.new(.95, -10, 0, button.TextBounds.y + 2)
	
	local icon = Instance.new("ImageLabel", button)
	icon.Image = iconImage
	icon.Parent = button
	icon.Position = UDim2.new(0, button.TextBounds.x + 10, 0, 2)
	icon.Size = UDim2.new(0, 15, 0 , 15)
	icon.BackgroundTransparency = 1

	local buttonCons = {}

	table.insert(buttonCons,
		button.MouseButton1Click:connect(function() 
			makeDisconnectCallback(source, sink)
		end)
	)
	table.insert(buttonCons,
		button.MouseEnter:connect(function()
			button.BackgroundTransparency = 0
			button.TextColor3 = BUTTON_HOVER_TEXT_COLOR
			icon.Image = DISCONNECT_ICON_HOVER_TEXTURE
			WIRE_LASSO_MAP[source][sink].Color = BrickColor.new("Really red")
		end)
	)
	table.insert(buttonCons,
		button.MouseLeave:connect(function()
		button.BackgroundTransparency = 1
		button.TextColor3 = textColor
		icon.Image = iconImage
		WIRE_LASSO_MAP[source][sink].Color = BrickColor.new("Really black")
	end)
	)

	table.insert(buttonCons,
		button.AncestryChanged:connect(function(child,parent)
			if parent == nil then
				for i = 1, #buttonCons do
					buttonCons[i]:disconnect()
				end
			end
		end)
	)

	return button
end

function getPartSourcesAndSinks(part, sources,sinks)
	for idx, child in ipairs(part:GetChildren()) do
		if child:IsA("CustomEvent") then
			table.insert(sources, child)
		elseif child:IsA("CustomEventReceiver") then
			table.insert(sinks, child)
		end
	end
end

function getSourcesAndSinks(instance,sources,sinks)
	if instance:IsA("BasePart") then
		getPartSourcesAndSinks(instance, sources,sinks)
	elseif instance:IsA("Model") then
		local modelChildren = instance:GetChildren()
		for i = 1, #modelChildren do
			if modelChildren[i]:IsA("BasePart") then
				getPartSourcesAndSinks(modelChildren[i],sources,sinks)
			elseif modelChildren[i]:IsA("Model") then
				getSourcesAndSinks(modelChildren[i],sources,sinks)
			end
		end
	end
end

local function findFirstConnector(node)
	if node:IsA("BasePart") then
		for idx, child in ipairs(node:GetChildren()) do
			if connector == nil and (child:IsA("CustomEvent") or child:IsA("CustomEventReceiver")) then
				return child
			end
		end
	else
		local children = node:GetChildren()
		if #children == 0 then
			return nil
		end
		for i = 1, #children do
			local subConnector = findFirstConnector(children[i])
			if subConnector then return subConnector end
		end
	end
end

function buildScreenPanel(part, x, y)
	sources = {}
	sinks = {}
	getSourcesAndSinks(part,sources,sinks)

	local gui = nil
	local mouseFrame = nil
	if USE_BILLBOARD_GUI then
		gui = Instance.new("BillboardGui", getPlayerGui())
		gui.Name = "WiringGui"
		gui.StudsOffset = Vector3.new(0, 1.5, 0)
		gui.ExtentsOffset = Vector3.new(0,0, 0)
		gui.Adornee = part
		gui.Active = true
		gui.AlwaysOnTop = true
	else 
		gui = Instance.new("ScreenGui", getPlayerGui())
	end

	frame = Instance.new("Frame", gui)
	frame.Style = Enum.FrameStyle.RobloxRound
	frame.ZIndex = 1
	frame.Active = true

	local maxWidth = 0
	local y_position = 5

	if SELECTED_SOURCE == nil then
		for idx, source in ipairs(sources) do
			local button = makeControlButton(y_position, frame, source, SOURCE_BUTTON_TEXT_COLOR,
					SOURCE_BUTTON_ICON_TEXTURE, SOURCE_BUTTON_ICON_HOVER_TEXTURE,
					makeSourceConnectCallback)
			maxWidth = math.max(1.25 * (button.TextBounds.x + BUTTON_ICON_WIDTH), maxWidth)
			y_position = y_position + button.TextBounds.y

			receivers = source:GetAttachedReceivers()
			for sub_idx, receiver in ipairs(receivers) do
				y_position = y_position + 2
				addWireUiIfNotAlreadyThere(source, receiver)
				local button = makeDisconnectButton(y_position, frame, source, receiver,
					SOURCE_BUTTON_TEXT_COLOR, DISCONNECT_SOURCE_ICON_TEXTURE)
				y_position = y_position + button.TextBounds.y
				maxWidth = math.max(1.15 * (button.TextBounds.x + 17 + 25), maxWidth)
			end
			y_position = y_position + 5
		end
	end

	if SELECTED_SINK == nil then
		for idx, sink in ipairs(sinks) do
			local button = makeControlButton(y_position, frame, sink, SINK_BUTTON_TEXT_COLOR,
					SINK_BUTTON_ICON_TEXTURE, SINK_BUTTON_ICON_HOVER_TEXTURE,
					makeSinkConnectCallback)
			maxWidth = math.max(1.25 * (button.TextBounds.x + BUTTON_ICON_WIDTH), maxWidth)
			y_position = y_position + button.TextBounds.y

			local sender = sink.Source
			if sender ~= nil then
				y_position = y_position + 2
				-- addWire takes source first
				addWireUiIfNotAlreadyThere(sender, sink)
				local button = makeDisconnectButton(y_position, frame, sink, sender,
					SINK_BUTTON_TEXT_COLOR, DISCONNECT_SINK_ICON_TEXTURE)
				y_position = y_position + button.TextBounds.y
				maxWidth = math.max(1.15 * (button.TextBounds.x + 17 + 25), maxWidth)
			end
			y_position = y_position + 5
		end
	end

	-- set size and position
	if not getPlayerGui():FindFirstChild("ScreenGui") then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Parent = getPlayerGui()
	end

	local screenSize = getPlayerGui().ScreenGui.AbsoluteSize
	local menuWidth = maxWidth
	local menuHeight = y_position + 17.5
	if USE_BILLBOARD_GUI then

		
		local size = Vector3.new(0,0,0)
		if gui.Adornee:IsA("BasePart") then
			size = gui.Adornee.Size
		elseif gui.Adornee:IsA("Model") then
			size = gui.Adornee:GetModelSize()
		end

		local xSize= size.X
		if size.Y > xSize then
			xSize = size.Y
		end

		gui.Size = UDim2.new(0, menuWidth,0,menuHeight + 150)
		gui.SizeOffset = Vector2.new(0, -50.0 / (menuHeight + 150));
		
		local tail = Instance.new("ImageLabel", frame)
		tail.Size = UDim2.new(0, 32, 0, 32)
		tail.Position = UDim2.new(.5, -16, 1, 8)
		tail.Image = TAIL_TEXTURE
		tail.BackgroundTransparency = 1
		tail.Visible = true

		f = Instance.new("Frame", gui)
		f.Size = UDim2.new(1, 0, 1, 0)
		f.BackgroundTransparency = 1
		f.ZIndex = 1
		f.Active = true
		b = Instance.new("TextButton", f)
		b.ZIndex = 1
		b.BackgroundTransparency = 1
		b.Text = ""
		b.BorderSizePixel = 0
		b.Size = UDim2.new(1, 0, 1, 0)
		b.MouseButton1Click:connect(function ()
			print("Clicker")
			local foundConnector = findFirstConnector(findModel(LAST_HOVERED_PART))
			if foundConnector ~= nil and foundConnector:IsA("CustomEvent") then
				makeSourceConnectCallback(foundConnector)()
			elseif foundConnector ~= nil and foundConnector:IsA("CustomEventReceiver") then
				makeSinkConnectCallback(foundConnector)()
			end
		end)
	else
		x = math.min(x - 9, screenSize.x - menuWidth) 
		y = math.min(y - 9, screenSize.y - menuHeight)
		frame.Position = UDim2.new(0, x, 0, y)
	end

	frame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
	frame.Position = UDim2.new(0.5,-menuWidth/2,0.05,0)
	WIRING_PANEL_MAP[part] = gui
end

function inBaseplate(instance)
	if instance == STATIC_BASE_PLATE then return true end

	local instanceCopy = instance
	print("instanceCopy init =",instanceCopy)

	while instanceCopy and (instanceCopy.Parent ~= nil or instanceCopy.Parent ~= game.Workspace) do
		if instanceCopy.Parent == STATIC_BASE_PLATE then
			print("in baseplate")
			return true
		end
		print("instanceCopy =",instanceCopy)
		instanceCopy = instanceCopy.Parent
	end

	return false
end

--------------------------------------------------------------------------------
-- Tool.Equipped/Unequipped

Tool.Equipped:connect(function(mouse)
	playerGui = getPlayerGui()
	LAST_HOVERED_PART = nil

	if isRestricted then
		root = findMyBasePlate()
	else
		root = game.Workspace
	end

	local interactiveCount = setUpConfigurationService()

	if not interactiveCount or interactiveCount == 0 then
		warnNoWireableParts()
	end

	getLocalLasso().Texture = WIRE_TEXTURE
	getLocalLasso().WireRadius = ENHANCED_WIRE_RADIUS
	clearSelection()

	if isRestricted then
		mouse.TargetFilter = game.Workspace.BaseplateBumpers
	end

	mouseMoveCon = mouse.Move:connect(function() hoverListener(mouse) end)
	mouseButtonDownCon = mouse.Button1Down:connect(function()
		if LAST_HOVERED_PART ~= nil then return end

		clearSelection()
		clearScreenMessage()
		clearHover()
		local annotationCount = 0
		for part, annotation in pairs(ANNOTATIONS) do
			annotation.Transparency = BASE_ANNOTATION_TRANSPARENCY
			annotationCount = annotationCount + 1
		end
		if annotationCount == 0 then
			warnNoWireableParts()
		elseif time() - LAST_CLICK_TIME < CLICK_HELP_TIME_DELTA then
			warnNotClickingWireablePart()
		end
		LAST_CLICK_TIME = time()
	end)
	-- TODO: onkeydown/onmouse2down, prevent hover from triggering
	-- until the up event comes
end)

Tool.Unequipped:connect(function()
	playerGui = getPlayerGui()

	destroyConfigurationService()

	if mouseMoveCon then mouseMoveCon:disconnect() end
	if mouseButtonDownCon then mouseButtonDownCon:disconnect() end

	if playerGui:FindFirstChild("CenterHint", true) then
		local centerHint = getPlayerGui().Gui.Hints.CenterHint
		centerHint.Delete.Disabled = false
	end

	-- TODO: simplify these side effects
	-- call clearHover before removing annotations, because
	-- clear hover resets annotation boxes. Also before clearing
	-- lassos because this may create lassos
	clearHover()

	for part, gui in pairs(WIRING_PANEL_MAP) do
		if gui then gui:Remove() end
	end
	WIRING_PANEL_MAP = {}

	for source, submap in pairs(WIRE_LASSO_MAP) do
		for sink, wire in pairs(submap) do
			wire:Remove()
		end
	end
	WIRE_LASSO_MAP = {}

	for k,box in pairs(ANNOTATIONS) do
		box:Remove()
	end
	ANNOTATIONS = {}

	KNOWN_SOURCE_PARTS = {}
	KNOWN_SINK_PARTS = {}

	clearSelection()
	clearScreenMessage()
	LAST_HOVERED_PART = nil
end)

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

		if not adornmentTable[guiKey] then return end
		table.insert(adornmentTable[guiKey],screen)

		local badgeFrame = Instance.new("Frame")
		badgeFrame.Name = "BadgeFrame"
		badgeFrame.Size = UDim2.new(2,0,1,0)
		badgeFrame.Position = UDim2.new(-0.5,0,0,0)
		badgeFrame.BackgroundTransparency = 1
		badgeFrame.Parent = screen

		return screen
	end

	return billboard
end

function repositionBadges(badgeFrame)
	local badges = badgeFrame:GetChildren()
	if #badges == 1 then
		badges[1].Position = UDim2.new(0.25,0,0,0)
	elseif #badges == 2 then
		badges[1].Position = UDim2.new(0,0,0,0)
		badges[2].Position = UDim2.new(0.5,0,0)
	end
end

function hasBadge(adornee, type)
	local screen = getBillboard(adornee)
	return screen:FindFirstChild(type .. "Badge",true)
end

function removeBadge(adornee, type)
	local screen = getBillboard(adornee)
	local badge = screen:FindFirstChild(type .. "Badge",true)
	if badge then badge:remove() end
end

function createBadge(adornee,type)
	local screen = getBillboard(adornee)

	local wiringBadge = Instance.new("ImageLabel")
	wiringBadge.Name = type .. "Badge"
	wiringBadge.BackgroundTransparency = 1
	if type == "Receiver" then
		wiringBadge.Image = SOURCE_BADGE_TEXTURE
	else
		wiringBadge.Image = SINK_BADGE_TEXTURE
	end

	wiringBadge.Position = UDim2.new(0.25,0,0,0)
	wiringBadge.Size = UDim2.new(0.5,0,1,0)
	wiringBadge.Parent = screen.BadgeFrame
	wiringBadge.Changed:connect(function(prop)
		if prop == "AbsoluteSize" then
			if wiringBadge.AbsoluteSize.X < 10 then
				wiringBadge.Visible = false
			else
				wiringBadge.Visible = true
			end
		end
	end)

	repositionBadges(screen.BadgeFrame)
end

function upAdorneeCount(adornee,type)
	local typeLower = string.lower(type)
	if typeLower == "receiver" then
		if not receiverBadgeCount[adornee] then
			receiverBadgeCount[adornee] = 1
		else
			receiverBadgeCount[adornee] = receiverBadgeCount[adornee] + 1
		end
	elseif typeLower == "event" then
		if not eventBadgeCount[adornee] then
			eventBadgeCount[adornee] = 1
		else
			eventBadgeCount[adornee] = eventBadgeCount[adornee] + 1
		end
	end
end

function downAdorneeCount(adornee,type)
	local typeLower = string.lower(type)
	if typeLower == "receiver" then
		if receiverBadgeCount[adornee] then
			receiverBadgeCount[adornee] = receiverBadgeCount[adornee] - 1
			if receiverBadgeCount[adornee] < 1 then
				receiverBadgeCount[adornee] = nil
			end
		end
	elseif typeLower == "event" then
		if eventBadgeCount[adornee] then
			eventBadgeCount[adornee] = eventBadgeCount[adornee] - 1
			if eventBadgeCount[adornee] < 1 then
				eventBadgeCount[adornee] = nil
			end
		end
	end
end

function createAdornment(adornee,adornColor,type)
	upAdorneeCount(adornee,type)

	if receiverBadgeCount[adornee] == 1 or eventBadgeCount[adornee] == 1 then
		local box = Instance.new("SelectionBox")
		box.Color = adornColor
		box.Name = adornee.Name .. "Selection" .. tostring(type)
		box.Adornee = adornee
		box.Transparency = 0.5
		box.Parent = game.Players.LocalPlayer.PlayerGui
		if not adornmentTable[adornee] then
			adornmentTable[adornee] = {}
		end

		ANNOTATIONS[adornee] = box
		table.insert(adornmentTable[adornee],box)

		if not hasBadge(adornee,type) then
			createBadge(adornee,type)
		end
	end
end

function doRemoveAdornment(adornee, type)
	local key = adornee
	if not adornmentTable[key] then return end
	for i = 1, #adornmentTable[key] do
		if adornmentTable[key] and adornmentTable[key][i] then
			if string.find(adornmentTable[key][i].Name,type) then
				adornmentTable[key][i]:remove()
				adornmentTable[key][i] = nil
			end
		end
	end
end

function removeAdornment(adornee, type)
	downAdorneeCount(adornee,type)

	if type == "Receiver" then
		if not receiverBadgeCount[adornee]then
			removeBadge(adornee, type)
			doRemoveAdornment(adornee, type)
		end
	elseif type == "Event" then
		if not eventBadgeCount[adornee] then
			removeBadge(adornee, type)
			doRemoveAdornment(adornee, type)
		end
	end
end

function eventReceiverAdded(receiver,wirePartCount)
	if isRestricted then
		if not inBaseplate(receiver) then return wirePartCount end
	end
	receiverTable[receiver] = findModel(receiver.Parent)
	createAdornment(receiverTable[receiver], BrickColor.new("Lime green"), "Receiver")
	setPartWireTransparency(receiver.Parent, BASE_WIRE_TRANSPARENCY, BASE_WIRE_RADIUS, "")

	KNOWN_SINK_PARTS[receiver.Parent] = true
	KNOWN_SINK_PARTS[receiverTable[receiver]]= true

	if wirePartCount then
		return wirePartCount + 1
	else
		return 0
	end

end

function eventAdded(event,wirePartCount)
	if isRestricted then
		if not inBaseplate(event) then return wirePartCount end
	end
	eventTable[event] = findModel(event.Parent)
	createAdornment(eventTable[event], BrickColor.new("Bright orange"), "Event")
	setPartWireTransparency(event.Parent, BASE_WIRE_TRANSPARENCY, BASE_WIRE_RADIUS, "")

	KNOWN_SOURCE_PARTS[event.Parent] = true
	KNOWN_SOURCE_PARTS[eventTable[event]]= true

	if wirePartCount then
		return wirePartCount + 1
	else
		return 0
	end
end

function eventReceiverRemoved(receiver)
	if not receiverTable[receiver] then return end

	KNOWN_SINK_PARTS[receiver.Parent] = false
	KNOWN_SINK_PARTS[receiverTable[receiver]]= false

	removeAdornment(receiverTable[receiver],"Receiver")
	receiverTable[receiver] = nil
end

function eventRemoved(event)
	if not eventTable[event] then return end

	KNOWN_SOURCE_PARTS[event.Parent] = false
	KNOWN_SOURCE_PARTS[eventTable[event]]= false

	removeAdornment(eventTable[event], "Event")
	eventTable[event] = nil
end

function setUpConfigurationService()
	local wirePartCount = 0
	ServiceConnections = {}
	local collectionService = game:GetService("CollectionService")

	-- first lets check if anything already exists
	local receivers = collectionService:GetCollection("CustomEventReceiver")
	if receivers then
		for pos, receiver in pairs(receivers) do
			wirePartCount = eventReceiverAdded(receiver, wirePartCount)
		end
	end

	local events = collectionService:GetCollection("CustomEvent")
	if events then
		for pos, event in pairs(events) do
			wirePartCount = eventAdded(event, wirePartCount)
		end
	end

	-- Now lets listen for any future additions/removals
	ServiceConnections[#ServiceConnections+1] = collectionService.ItemAdded:connect(function(instance)
		if instance:IsA("CustomEventReceiver") then
			eventReceiverAdded(instance)
		elseif instance:IsA("CustomEvent") then
			eventAdded(instance)
		end 
	end)
	ServiceConnections[#ServiceConnections+1] = collectionService.ItemRemoved:connect(function(instance)
		if instance:IsA("CustomEventReceiver") then
			eventReceiverRemoved(instance)
		elseif instance:IsA("CustomEvent") then
			eventRemoved(instance)
		end
	end)

	return wirePartCount
end

function destroyConfigurationService()
	-- first lets destroy the collection service
	for index, connection in pairs(ServiceConnections) do
		connection:disconnect()
	end
	ServiceConnections = {}

	-- now lets remove all of our collection service objects that were generated
	for event, object in pairs(eventTable) do
		eventRemoved(event)
	end
	for eventReceiver, object in pairs(receiverTable) do
		eventReceiverRemoved(eventReceiver)
	end
end

