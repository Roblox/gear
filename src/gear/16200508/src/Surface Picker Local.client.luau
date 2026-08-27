local Tool = script.Parent


enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/surface_sel.png")

local selectionSurface
local selectionLasso
local inGui = false
local inPalette = false

local selectedButton = nil
local oldButton = nil
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
	
	print("Selected SurfaceType : " .. guiButton.Name)
end

function setSelectionSurface(part, surface) 
	unsetSelectionSurface()
	selectionSurface.Adornee = part
	selectionSurface.TargetSurface = surface
	selectionLasso.Part = part
end
function unsetSelectionSurface() 
	selectionSurface.Adornee = nil
	selectionLasso.Part = nil
end

function onMouseEnterGui(mouse)
	mouse.Icon ="rbxasset://textures\\ArrowCursor.png"
	unsetSelectionSurface()
	inGui = true
end
function onMouseLeaveGui(mouse)
	inGui = false
end

function onMouseEnterPalette(mouse)
	mouse.Icon ="rbxasset://textures\\ArrowCursor.png"
	unsetSelectionSurface()
	inPalette = true
end
function onMouseLeavePalette(paletteFrame, mouse)
	inPalette = false
end
	
local SurfaceEnum = {}
SurfaceEnum["Smooth"] = Enum.SurfaceType.Smooth
SurfaceEnum["Studs"] = Enum.SurfaceType.Studs
SurfaceEnum["Inlets"] = Enum.SurfaceType.Inlet
SurfaceEnum["Universal"] = Enum.SurfaceType.Universal
SurfaceEnum["Glue"] = Enum.SurfaceType.Glue
SurfaceEnum["Weld"] = Enum.SurfaceType.Weld
SurfaceEnum["Hinge"] = Enum.SurfaceType.Hinge
SurfaceEnum["Motor"] = Enum.SurfaceType.Motor



function buildGui(root, mouse)

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "Main Surface Frame"
	mainFrame.Position = UDim2.new(0.0, 0, 1.0, -50)
	mainFrame.Size = UDim2.new(0.0, 50 * 10, 0.00, 50)
	mainFrame.Transparency = 1.0
	mainFrame.Parent = root
	
	local paletteFrame = Instance.new("Frame")
	paletteFrame.Name = "Palette"
	paletteFrame.Position = UDim2.new(0.0, 0, 0.0, 0)
	paletteFrame.Size = UDim2.new(.8, 0, 1.0, 0)
	paletteFrame.BackgroundColor = BrickColor.Black()
	paletteFrame.MouseEnter:connect(function() onMouseEnterPalette(mouse) end)
	paletteFrame.MouseLeave:connect(function() onMouseLeavePalette(paletteFrame, mouse) end)
	paletteFrame.Parent = mainFrame
	
	local hoverSelection = Instance.new("TextLabel")
	hoverSelection.Position = UDim2.new(0.8, 0, 0.0, 0)
	hoverSelection.Size = UDim2.new(.2, 0, 1.0, 0)
	hoverSelection.BackgroundColor = BrickColor.Black()
	hoverSelection.TextColor = BrickColor.White()
	hoverSelection.Text = "Studs"
	hoverSelection.Parent = mainFrame

	local surfaces = {}
	surfaces["Smooth"] = "http://www.roblox.com/Asset/?ID=16171076"
	surfaces["Studs"] = "http://www.roblox.com/Asset/?ID=16171077"
	surfaces["Inlets"] = "http://www.roblox.com/Asset/?ID=16171066"
	surfaces["Universal"] = "http://www.roblox.com/Asset/?ID=16171136"
	surfaces["Glue"] = "http://www.roblox.com/Asset/?ID=16171062"
	surfaces["Weld"] = "http://www.roblox.com/Asset/?ID=16171080"
	surfaces["Hinge"] = "http://www.roblox.com/Asset/?ID=16171065"
	surfaces["Motor"] = "http://www.roblox.com/Asset/?ID=16171070"
	
	local order = {"Smooth", "Studs", "Inlets", "Universal", "Glue", "Weld", "Hinge", "Motor"}

	local x 
	for x=1, #order do
		local key = order[x]
		local value = surfaces[key]
		local guiFrame = Instance.new("Frame")
		guiFrame.Position = UDim2.new(1.0/8 * (x-1), 0, 0.0, 0)
		guiFrame.Size = UDim2.new(1.0/8, 0, 1.0, 0)
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


function canSelectObject(part, surface)
	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60 and 
		(not(part:IsA("WedgePart")) or surface ~= Enum.NormalId.Front)
end


function on3dMouseMove(mouse)
	local part = mouse.Target
	local surface = mouse.TargetSurface
	if canSelectObject(part, surface) then
		setSelectionSurface(part, surface)
	else
		unsetSelectionSurface()
	end

end
function on3dButton1Down(mouse) 
	local part = selectionSurface.Adornee
	if part then
		local normalId = selectionSurface.TargetSurface
		local surface = SurfaceEnum[selectedButton.Name]
		--Apply the selected surface to the current parts
		if normalId == Enum.NormalId.Top then
			part.TopSurface = surface
		elseif normalId == Enum.NormalId.Bottom then  
			part.BottomSurface = surface
		elseif normalId == Enum.NormalId.Front then  
			part.FrontSurface = surface
		elseif normalId == Enum.NormalId.Back then  
			part.BackSurface = surface
		elseif normalId == Enum.NormalId.Left then  
			part.LeftSurface = surface
		elseif normalId == Enum.NormalId.Right then  
			part.RightSurface = surface
		end
	end
end

local guiMain
function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/surface_sel.png"
	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	guiMain = Instance.new("ScreenGui")
	guiMain.Parent = player.PlayerGui

	inGui = false
	inPalette = false

	mouse.Move:connect(function() on3dMouseMove(mouse) end)
	mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)
	--mouse.Icon ="rbxasset://textures\\MaterialCursor.png"

	selectionSurface = Instance.new("SurfaceSelection")
	selectionSurface.Color = BrickColor.Red()
	selectionSurface.Adornee = nil
	selectionSurface.Parent = player.PlayerGui

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
	selectionSurface:Remove()
	selectionLasso:Remove()
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
