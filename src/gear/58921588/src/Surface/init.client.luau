-- basic functions
function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

local Tool = script.Parent
local menu


waitForChild(Tool.Surface,"Active")
waitForChild(Tool.Surface,"CurrentSurface")

enabled = true
local origTexture = 	Tool.TextureId
local localAssetBase = "rbxasset://textures/ui/"
game:GetService("ContentProvider"):Preload("rbxasset://icons/surface_sel.png")

local selectionSurface
local selectionLasso

local currentSurfaceButton = nil

local mouseMoveCon, button1DownCon
local conArray = {}

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

local SurfaceEnum = {}
SurfaceEnum["Smooth"] = Enum.SurfaceType.Smooth
SurfaceEnum["Studs"] = Enum.SurfaceType.Studs
SurfaceEnum["Inlet"] = Enum.SurfaceType.Inlet
SurfaceEnum["Universal"] = Enum.SurfaceType.Universal
SurfaceEnum["Glue"] = Enum.SurfaceType.Glue
SurfaceEnum["Weld"] = Enum.SurfaceType.Weld
SurfaceEnum["Hinge"] = Enum.SurfaceType.Hinge
SurfaceEnum["Motor"] = Enum.SurfaceType.Motor


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
		local surface = Tool.Surface.CurrentSurface.Value
		if surface == nil then return end
		--Apply the selected surface to the current parts
		if normalId == Enum.NormalId.Top then
			part.TopSurface = surface
		elseif normalId == Enum.NormalId.Bottom then  
		elseif normalId == Enum.NormalId.Front then  
			part.BottomSurface = surface
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

function createSurfaceMenu()

	local surfaceGui = Instance.new("ScreenGui")
	surfaceGui.Name = "SurfaceGui"

	local surfaceMenu = Instance.new("ImageLabel")
	surfaceMenu.Name = "SurfaceMenu"
	surfaceMenu.Position = UDim2.new(0,0,1,-400)
	surfaceMenu.Size = UDim2.new(0,150,0,300)
	surfaceMenu.BackgroundTransparency = 1
	surfaceMenu.ZIndex = 2
	surfaceMenu.Image = localAssetBase .. "SurfaceMenu.png"
	surfaceMenu.Parent = surfaceGui

	textures = {"Smooth", "Studs", "Inlets", "Universal", "Glue", "Weld", "Hinge", "Motor"}
	current = 1

	local surfaceButtons = {}

	local surfaceButton = Instance.new("ImageButton")
	surfaceButton.BackgroundTransparency = 1
	surfaceButton.Size = UDim2.new(0.400000003, 0,0.19, 0)
	surfaceButton.ZIndex = 4
	
	local selection = Instance.new("Frame")
	selection.Name = "Selection"
	selection.BorderSizePixel = 0
	selection.BackgroundColor3 = Color3.new(1,1,1)
	selection.BackgroundTransparency = 1
	selection.ZIndex = 3
	selection.Size = UDim2.new(1.1,0,1.1,0)
	selection.Position = UDim2.new(-0.05,0,-0.05,0)
	selection.Parent = surfaceButton

	local function getTextureAndName(button)
		if current > #textures then
			button:remove()
			return false
		end
		button.Image = localAssetBase .. textures[current] .. ".png"

		if textures[current] == "Inlets" then --nice hack to adjust for inconsistent namings
			button.Name = "Inlet"
		else
			button.Name = textures[current]
		end

		current = current + 1
		return true
	end

	local ySpacing = 0.14
	local xSpacing  = 0.07
	for i = 1,4 do
		for j = 1,2 do
			local button = surfaceButton:clone()
			button.Position = UDim2.new((j -1)/2.2 + xSpacing,0,ySpacing + (i - 1)/4.6,0)
			getTextureAndName(button)
			button.Parent = surfaceMenu
			table.insert(surfaceButtons,button)
		end
	end

	for i = 1, #surfaceButtons do
		local newCon = surfaceButtons[i].MouseButton1Click:connect(function()
			Tool.Surface.CurrentSurface.Value = surfaceButtons[i].Name

			if currentSurfaceButton then 
				if currentSurfaceButton:FindFirstChild("Selection") then
					currentSurfaceButton.Selection.BackgroundTransparency = 1
				end
			end

			currentSurfaceButton = surfaceButtons[i]
			surfaceButtons[i].Selection.BackgroundTransparency = 0
		end)
		local enterCon = surfaceButtons[i].MouseEnter:connect(function()
			surfaceButtons[i].Selection.BackgroundTransparency = 0
		end)
		local leaveCon = surfaceButtons[i].MouseLeave:connect(function()
			if surfaceButtons[i] ~= currentSurfaceButton then surfaceButtons[i].Selection.BackgroundTransparency = 1 end
		end)
		table.insert(conArray,newCon)
		table.insert(conArray,enterCon)
		table.insert(conArray,leaveCon)
	end

	return surfaceGui
end



function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/surface_sel.png"
	local character = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	mouseMoveCon = mouse.Move:connect(function() on3dMouseMove(mouse) end)
	button1DownCon = mouse.Button1Down:connect(function() on3dButton1Down(mouse) end)

	selectionSurface = Instance.new("SurfaceSelection")
	selectionSurface.Color = BrickColor.Red()
	selectionSurface.Adornee = nil
	selectionSurface.Parent = player.PlayerGui

	selectionLasso = Instance.new("SelectionPartLasso")
	selectionLasso.Name = "Model Surface Lasso"
	selectionLasso.Humanoid = character.Humanoid
	selectionLasso.Parent = game.workspace
	selectionLasso.Part = nil
	selectionLasso.Visible = true
	selectionLasso.archivable = false
	selectionLasso.Color = BrickColor.Yellow()

	menu = createSurfaceMenu()
	menu.Parent = game.Players.LocalPlayer.PlayerGui
end

function onUnequippedLocal()
	if mouseMoveCon then mouseMoveCon:disconnect() end
	if button1DownCon then button1DownCon:disconnect() end

	for i = 1, #conArray do
		if conArray[i] then conArray[i]:disconnect() end
	end
	conArray = {}

	menu:remove()
	Tool.TextureId = origTexture
	if selectionBox then selectionBox:Remove() end
	if selectionLasso then selectionLasso:Remove() end
	if selectionSurface then selectionSurface:Remove() end
end

script.Active.Changed:connect(function(prop)
	if script.Active.Value == true then
		onEquippedLocal(Tool.Mouse.Value)
	else
		onUnequippedLocal()
	end
end)
