-- basic functions
function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

local Tool = script.Parent

waitForChild(Tool.Dragger, "Active")


local gui = nil

local connections = {}

function deactivateTool(script)
	local enable = script:FindFirstChild("Active")
	if enable and enable:IsA("BoolValue") then
		enable.Value = false
	end
end

function deactivateAllTools()
	local toolChildren = script:GetChildren()
	for i = 1, #toolChildren do
		if toolChildren[i]:IsA("BaseScript") and toolChildren[i] ~= script then
			deactivateTool(toolChildren[i])
		end
	end
end

function switchGrid(type)
	deactivateAllTools()

	wait()

	if type == "1" then
		script.OldDragger.Active.Value = true
		gui.DraggerButton.Selected = true
		gui.Dragger4xButton.Selected = false
	else
		script.NewDragger.Active.Value = true
		gui.DraggerButton.Selected = false
		gui.Dragger4xButton.Selected = true
	end
end

function makeTextButton(buttonName, text, position, parent)
	local button = Instance.new("TextButton")
	button.Name = buttonName
	button.Style = Enum.ButtonStyle.RobloxButton
	button.Size = UDim2.new(0,100,0,40)
	if position then button.Position = position end
	button.Parent = parent

	button.Text = text
	button.Font = Enum.Font.ArialBold
	button.FontSize = Enum.FontSize.Size18
	button.TextColor3 = Color3.new(1,1,1)

	return button
end

function makeDraggerGui()
	local draggerGui = Instance.new("ScreenGui")
	draggerGui.Name = "DraggerGui"

	local draggerButton = makeTextButton("DraggerButton","1x1 Grid",UDim2.new(0.5,-100,0,0),draggerGui)
	local dragger4xButton = makeTextButton("Dragger4xButton","4x4 Grid",UDim2.new(0.5,0,0,0),draggerGui)

	local con = draggerButton.MouseButton1Click:connect(function() switchGrid("1") end)
	local con2 = dragger4xButton.MouseButton1Click:connect(function() switchGrid("4") end)
	table.insert(connections,con)
	table.insert(connections,con2)

	return draggerGui
end


function onEquippedLocal(mouse)
	Tool.Mouse.Value = mouse
	if not gui then
		gui = makeDraggerGui()
	end
	gui.Parent = game.Players.LocalPlayer.PlayerGui
	script.NewDragger.Active.Value = true
	gui.Dragger4xButton.Selected = true
end

function onUnequippedLocal()
	for i = 1, #connections do
		connections[i]:disconnect()
	end
	connections = {}

	gui:remove()
	gui = nil
	deactivateAllTools()
end

script.Active.Changed:connect(function(prop)
	if script.Active.Value == true then
		onEquippedLocal(Tool.Mouse.Value)
	else
		onUnequippedLocal()
	end
end)

