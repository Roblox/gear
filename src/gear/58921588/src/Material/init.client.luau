-- basic functions
function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

local Tool = script.Parent
waitForChild(Tool.Material,"Active")
waitForChild(Tool.Material,"CurrentMaterial")

enabled = true
local origTexture = 	Tool.TextureId
local localAssetBase = "rbxasset://textures/ui/"
game:GetService("ContentProvider"):Preload("rbxasset://icons/material_sel.png")

local menu

local selectionBox
local selectionLasso

local selectedButton

local value = nil

local downCons = {}

local currentMaterialButton = nil

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
	local part = mouse.Target
	if part and not (part.Locked) then
		if Instance.Lock(part) then
			part.Material = MaterialEnum[Tool.Material.CurrentMaterial.Value]
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

function createMaterialMenu()
	local materialGui = Instance.new("ScreenGui")
	materialGui.Name = "MaterialGui"

	local materialMenu = Instance.new("ImageLabel")
	materialMenu.Name = "MaterialMenu"
	materialMenu.Position = UDim2.new(0,0,1,-350)
	materialMenu.Size = UDim2.new(0,100,0,250)
	materialMenu.BackgroundTransparency = 1
	materialMenu.ZIndex = 2
	materialMenu.Image = localAssetBase .. "MaterialMenu.png"
	materialMenu.Parent = materialGui

	local textures = {"Plastic","Wood","Slate","CorrodedMetal","Ice","Grass","Foil","DiamondPlate","Concrete"}

	local materialButtons = {}

	local materialButton = Instance.new("ImageButton")
	materialButton.BackgroundTransparency = 1
	materialButton.Size = UDim2.new(0.400000003, 0,0.16, 0)
	materialButton.ZIndex = 4

	local selection = Instance.new("Frame")
	selection.Name = "Selection"
	selection.BorderSizePixel = 0
	selection.BackgroundColor3 = Color3.new(1,1,1)
	selection.BackgroundTransparency = 1
	selection.ZIndex = 3
	selection.Size = UDim2.new(1.1,0,1.1,0)
	selection.Position = UDim2.new(-0.05,0,-0.05,0)
	selection.Parent = materialButton

	local current = 1
	local function getTextureAndName(button)

		if current > #textures then
			button:remove()
			return false
		end
		button.Image = localAssetBase .. textures[current] .. ".png"
		button.Name = textures[current]
		current = current + 1
		return true

	end

	local ySpacing = 0.10
	local xSpacing  = 0.07
	for i = 1,5 do
		for j = 1,2 do
			local button = materialButton:clone()
			button.Position = UDim2.new((j -1)/2.2 + xSpacing,0,ySpacing + (i - 1)/5.5,0)
			if getTextureAndName(button) then button.Parent = materialMenu else button:remove() end
			table.insert(materialButtons,button)
		end
	end


	for i = 1, #materialButtons do
		local newCon = materialButtons[i].MouseButton1Click:connect(function()
			Tool.Material.CurrentMaterial.Value = materialButtons[i].Name

			if currentMaterialButton then
				if currentMaterialButton:FindFirstChild("Selection") then
					currentMaterialButton.Selection.BackgroundTransparency = 1
				end
			end

			currentMaterialButton = materialButtons[i]
			materialButtons[i].Selection.BackgroundTransparency = 0
		end)
		local enterCon = materialButtons[i].MouseEnter:connect(function()
			materialButtons[i].Selection.BackgroundTransparency = 0
		end)
		local leaveCon = materialButtons[i].MouseLeave:connect(function()
			if materialButtons[i] ~= currentMaterialButton then materialButtons[i].Selection.BackgroundTransparency = 1 end
		end)
		table.insert(downCons, newCon)
		table.insert(downCons, enterCon)
		table.insert(downCons, leaveCon)
	end

	return materialGui
end

function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/material_sel.png"
	value = nil
	selectedButton = nil

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	selectedButton = nil

	button1DownCon = mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	mouseMoveCon = mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Icon ="rbxasset://textures\\MaterialCursor.png"

	selectionBox = Instance.new("SelectionBox")
	selectionBox.Color = BrickColor.Yellow()
	selectionBox.Adornee = nil
	selectionBox.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Material Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Parent = game.workspace
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = BrickColor.Green()

	menu = createMaterialMenu()
	menu.Parent = game.Players.LocalPlayer.PlayerGui
end

function onUnequippedLocal()
	if button1DownCon then button1DownCon:disconnect() end
	if mouseMoveCon then mouseMoveCon:disconnect() end

	for i = 1, #downCons do
		downCons[i]:disconnect()
	end
	downCons = {}

	menu:remove()
	Tool.TextureId = origTexture
	if selectionBox then selectionBox:Remove() end
	if selectionLasso then selectionLasso:Remove() end
end

script.Active.Changed:connect(function(prop)
	if script.Active.Value == true then
		onEquippedLocal(Tool.Mouse.Value)
	else
		onUnequippedLocal()
	end
end)
