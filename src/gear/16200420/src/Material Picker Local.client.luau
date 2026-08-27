local Tool = script.Parent


enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/material_sel.png")

local selectionBox
local selectionLasso
local inGui
local inPalette

local selectedButton
local oldButton

function onMouseLeave(hoverSelection)
	if oldButton ~= nil then
		local notSelected = true
		local selectionText = ""
		if selectedButton ~= nil  then
			if oldButton == selectedButton then
				notSelected = false
			else
				selectionText = selectedButton.Name
			end
		end
		if notSelected then
			hoverSelection.Text = selectionText
			if oldButton.Parent then
				oldButton.Parent.BackgroundColor = BrickColor.Black()
			end
		end
	end
	oldButton = nil
end

function onMouseEnter(hoverSelection, guiButton)
	onMouseLeave(hoverSelection)
	hoverSelection.Text = guiButton.Name
	if guiButton ~= selectedButton then
		guiButton.Parent.BackgroundColor = BrickColor.White()
		oldButton = guiButton
	end
end

function onMouseUp(paletteFrame, guiButton)
	if selectedButton ~= nil then
		selectedButton.Parent.BackgroundColor = BrickColor.Black()
	end
	guiButton.Parent.BackgroundColor = BrickColor.Yellow()
	selectedButton = guiButton
	
	onMouseLeavePalette(paletteFrame)
	
	print("Selected Material: " .. guiButton.Name)
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
	
local MaterialEnum = {}
MaterialEnum["Plastic"] = Enum.Material.Plastic
MaterialEnum["Wood"] = Enum.Material.Wood
MaterialEnum["Slate"] = Enum.Material.Slate
MaterialEnum["Corroded Metal"] = Enum.Material.CorrodedMetal
MaterialEnum["Ice"] = Enum.Material.Ice
MaterialEnum["Grass"] = Enum.Material.Grass
MaterialEnum["Foil"] = Enum.Material.Foil
MaterialEnum["Diamond Plate"] = Enum.Material.DiamondPlate
MaterialEnum["Concrete"] = Enum.Material.Concrete


function buildGui(root, mouse)

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "Main Material Frame"
	mainFrame.Position = UDim2.new(0.0, 0, 1.0, -50)
	mainFrame.Size = UDim2.new(0.0, 50 * 12, 0.0, 50)
	mainFrame.Transparency = 1.0
	mainFrame.Parent = root
	

	local paletteFrame = Instance.new("Frame")
	paletteFrame.Position = UDim2.new(0.0, 0, 0.0, 0)
	paletteFrame.Size = UDim2.new(.75, 0, 1.0, 0)
	paletteFrame.BackgroundColor = BrickColor.Black()
	paletteFrame.Parent = mainFrame
	paletteFrame.MouseEnter:connect(function() onMouseEnterPalette(mouse) end)
	paletteFrame.MouseLeave:connect(function() onMouseLeavePalette(paletteFrame, mouse) end)

	local hoverSelection = Instance.new("TextLabel")
	hoverSelection.Position = UDim2.new(0.75, 0, 0, 0)
	hoverSelection.Size = UDim2.new(.25, 0, 1.0, 0)
	hoverSelection.BackgroundColor = BrickColor.Black()
	hoverSelection.TextColor = BrickColor.White()
	hoverSelection.Text = "Plastic"
	hoverSelection.Parent = mainFrame

	local materials= {}
	materials["Plastic"] = "http://www.roblox.com/Asset/?ID=16169981"
	materials["Wood"] = "http://www.roblox.com/Asset/?ID=16169971"
	materials["Slate"] = "http://www.roblox.com/Asset/?ID=16169975"
	materials["Corroded Metal"] = "http://www.roblox.com/Asset/?ID=16169978"
	materials["Ice"] = "http://www.roblox.com/Asset/?ID=16169985"
	materials["Grass"] = "http://www.roblox.com/Asset/?ID=16169988"
	materials["Foil"] = "http://www.roblox.com/Asset/?ID=16169991"
	materials["Diamond Plate"] = "http://www.roblox.com/Asset/?ID=16169998"
	materials["Concrete"] = "http://www.roblox.com/Asset/?ID=16170001"

	local order = {"Plastic", "Wood", "Slate", "Corroded Metal", "Ice", "Grass", "Foil", "Diamond Plate", "Concrete"}

	local x 
	for x=1, #order do
		local key = order[x]
		local value = materials[key]

		local guiFrame = Instance.new("Frame")
		guiFrame.Position = UDim2.new(1.0/9 * (x-1), 0, 0.0, 0)
		guiFrame.Size = UDim2.new(1.0/9, 0, 1.0, 0)
		guiFrame.BackgroundColor = BrickColor.Black()
		--guiFrame.BorderSizePixel = 0
		guiFrame.Parent = paletteFrame

		local guiButton = Instance.new("ImageButton")
		guiButton.Position = UDim2.new(0.0, 2, 0.0, 2)
		guiButton.Size = UDim2.new(1.0, -4, 1.0, -4)
		guiButton.Image = value
		guiButton.Name = key
		--guiButton.BorderSizePixel = 0
		guiButton.AutoButtonColor = false
		guiButton.MouseEnter:connect(function() onMouseEnter(hoverSelection, guiButton) end)
		guiButton.MouseButton1Up:connect(function() onMouseUp(paletteFrame, guiButton) end)
		guiButton.Parent = guiFrame

		if hoverSelection.Text == guiButton.Name then
			selectedButton = guiButton
			guiFrame.BackgroundColor = BrickColor.Yellow()
		end
	end

	mainFrame.MouseLeave:connect(function() onMouseLeave(hoverSelection) end)

end

function on3dButton1Down(mouse) 
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
	if not(inGui) and not(inPalette) then
		mouse.Icon ="rbxasset://textures\\MaterialCursor.png"
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
	Tool.TextureId = "rbxasset://icons/material_sel.png"

	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	guiMain = Instance.new("ScreenGui")
	guiMain.Parent = player.PlayerGui

	inGui = false
	inPalette = false
	oldButton = nil
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

	buildGui(guiMain, mouse)
end

function onUnequippedLocal()
	Tool.TextureId = origTexture
	guiMain:Remove()
	selectionBox:Remove()
	selectionLasso:Remove()
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
