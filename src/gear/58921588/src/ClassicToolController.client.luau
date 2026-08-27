local Tool = script.Parent

local keyUpCon = nil
local gui = nil

local connections = {}
local buttons = {}

local colorButton,SurfaceButton,MaterialButton,ResizeButton,draggerButton = nil

game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset?id=59103051")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset?id=59103080")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset?id=59103092")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset?id=59103119")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset?id=59103152")

function makeImageButton(buttonName, image, position, parent, hotKeyString)
	local button = Instance.new("ImageButton")
	button.Name = buttonName
	button.Style = Enum.ButtonStyle.RobloxButton
	button.Size = UDim2.new(0,45,0,45)
	if position then button.Position = position end
	button.Parent = parent

	local buttonImage = Instance.new("ImageLabel")
	buttonImage.Name = "ButtonImage"
	buttonImage.BackgroundTransparency = 1
	buttonImage.Size = UDim2.new(1,12,1,12)
	buttonImage.Position = UDim2.new(0,-6,0,-6)
	buttonImage.Image = image
	buttonImage.Parent = button

	if hotKeyString then
		local textShortcut = Instance.new("TextLabel")
		textShortcut.Text = hotKeyString
		textShortcut.Name = "TextShortcut"
		textShortcut.Font = Enum.Font.ArialBold
		textShortcut.BackgroundTransparency = 1
		textShortcut.FontSize = Enum.FontSize.Size14
		textShortcut.TextColor3 = Color3.new(1,1,1)
		textShortcut.Size = UDim2.new(0,textShortcut.TextBounds.X,0,textShortcut.TextBounds.X)
		textShortcut.Parent = button
	end

	return button
end

function deactivateTool(script)
	local enable = script:FindFirstChild("Active")
	if enable and enable:IsA("BoolValue") then
		enable.Value = false
	end
end

function deactivateAllTools()
	local toolChildren = Tool:GetChildren()
	for i = 1, #toolChildren do
		if toolChildren[i]:IsA("BaseScript") and toolChildren[i] ~= script then
			deactivateTool(toolChildren[i])
		end
	end
	for i = 1, #buttons do
		buttons[i].Selected = false
	end
end

function goToTool(toolName, button)
	deactivateAllTools()
	button.Selected = true

	wait() -- give scripts a heartbeat to get set straight

	local toolScript = Tool:FindFirstChild(toolName)
	if toolScript and toolScript:IsA("BaseScript") then
		local enable = toolScript:FindFirstChild("Active")
		if enable and enable:IsA("BoolValue") then
			enable.Value = true
		end
	end
end

function makeClassicControlGui()
	clearAllConnections()

	local classicGui = Instance.new("ScreenGui")
	classicGui.Name = "ClassicGui"
	
	local classicFrame = Instance.new("Frame")
	classicFrame.Name = "ClassicFrame"
	classicFrame.BackgroundTransparency = 1
	classicFrame.Size = UDim2.new(0,246,0,45)
	classicFrame.Position = UDim2.new(0.5, -113, 1, -130)
	classicFrame.Parent = classicGui

	colorButton = makeImageButton("ColorButton","http://www.roblox.com/asset?id=59103051",UDim2.new(0,0,0.5,-23), classicFrame, "F")
	local colorCon = colorButton.MouseButton1Click:connect(function() goToTool("Color", colorButton) end)
	table.insert(connections,colorCon)
	table.insert(buttons,colorButton)

	SurfaceButton = makeImageButton("SurfaceButton","http://www.roblox.com/asset?id=59103080",UDim2.new(0,90,0.5,-23), classicFrame, "H")
	local surfaceCon = SurfaceButton.MouseButton1Click:connect(function() goToTool("Surface", SurfaceButton) end)
	table.insert(connections,surfaceCon)
	table.insert(buttons,SurfaceButton)

	MaterialButton = makeImageButton("MaterialButton","http://www.roblox.com/asset?id=59103092",UDim2.new(0,45,0.5,-23), classicFrame, "G")
	local materialCon = MaterialButton.MouseButton1Click:connect(function() goToTool("Material", MaterialButton) end)
	table.insert(connections,materialCon)
	table.insert(buttons,MaterialButton)

	ResizeButton = makeImageButton("ResizeButton","http://www.roblox.com/asset?id=59103119",UDim2.new(0,180,0.5,-23), classicFrame, "K")
	local resizeCon = ResizeButton.MouseButton1Click:connect(function() goToTool("Resize", ResizeButton) end)
	table.insert(connections,resizeCon)
	table.insert(buttons,ResizeButton)

	draggerButton = makeImageButton("ResizeButton","http://www.roblox.com/asset?id=59103152",UDim2.new(0,135,0.5,-23), classicFrame, "J")
	local draggerCon = draggerButton.MouseButton1Click:connect(function() goToTool("Dragger", draggerButton) end)
	table.insert(connections,draggerCon)
	table.insert(buttons,draggerButton)

	return classicGui
end

function clearAllConnections()
	for i = 1, #connections do
		connections[i]:disconnect()
	end
	connections = {}
end


function hotKey(key)
	key = key:lower()

	if key == "f" then
		goToTool("Color", colorButton)
	elseif key == "g" then
		goToTool("Material", MaterialButton)
	elseif key == "h" then
		goToTool("Surface", SurfaceButton)
	elseif key == "j" then
		goToTool("Dragger", draggerButton)
	elseif key == "k" then
		goToTool("Resize", ResizeButton)
	end
end


function onEquippedLocal(mouse)
	Tool.Mouse.Value = mouse
	if not gui then
		gui = makeClassicControlGui()
	end
	gui.Parent = game.Players.LocalPlayer.PlayerGui

	keyUpCon = mouse.KeyUp:connect(function(key) hotKey(key) end)
end

function onUnequippedLocal()
	if keyUpCon then keyUpCon:disconnect() end
	deactivateAllTools()
	gui.Parent = nil	
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
