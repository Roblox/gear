local Tool = script.Parent
local frame = nil

--game:GetService("InsertService"):SetCollectionUrl("http://test.roblox.com/Game/Tools/insertasset.ashx?sid=%d")
--game:GetService("InsertService"):SetBaseCategoryUrl("http://test.roblox.com/Game/Tools/insertasset.ashx?nsets=10")
--game:GetService("InsertService"):SetAssetUrl("http://test.roblox.com/Asset/?id=%d")
 
enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/insert_sel.png")

local height = 20
local width = UDim.new(0.25, 0)
local height = 20
local buttonTransparency = 0.1
local insertButtonTransparency = 0.25
local transparency = 0.25

local selectedButtonColor = Color3.new(.1255, .4078, .1961)
local selectedButtonTextColor = Color3.new(1.0,1.0,1.0)

local buttonColor = Color3.new(0.0898, 0.2148, .2344)
local buttonTextColor = Color3.new(1.0,1.0,1.0)

local frameColor = Color3.new(.1255, .4078, .1961)
local frameTextColor = Color3.new(1.0,1.0,1.0)

local titleColor = Color3.new(0.6289, 0.8398, 0)
local titleTextColor = Color3.new(0.0,0.0,0.0)

local Window
local Data
local Mouse

local SetCache = {}

local soloGame = game:FindFirstChild("NetworkClient") == nil

--Constants
local useAssetVersionId = true
local BaseUrl = game:GetService("ContentProvider").BaseUrl
local ThumbnailUrl;
if useAssetVersionId then
	ThumbnailUrl = BaseUrl .. "Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=110&ht=110&assetversionid="
else
	ThumbnailUrl = BaseUrl .. "Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=110&ht=110&aid="
end

local InsertRows = 4
local InsertColumns = 8

--Static variables used for creating sizes
function getPlayer()
	local character = script.Parent.Parent
	return game.Players:GetPlayerFromCharacter(character)
end

function minimize()
	if Window.Stamp.Frame.Visible then
		cancelAssetPlacement()
	elseif Window.Main.Frame.Visible then
		Window.Main.Frame.Visible = false
		Window.Minimized.Frame.Visible = true
	end
end

function buildImageButton(image)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.BackgroundTransparency = 1.0

	local button = Instance.new("ImageButton")
	button.Name = "Button"
	button.Parent  = buttonFrame
	button.Image = image
	button.Size = UDim2.new(1.0, 0, 1.0, 0)
	button.Position = UDim2.new(0.0, 0, 0.0, 0)
	button.BorderSizePixel = 1
	button.Parent  = buttonFrame
	button.BackgroundTransparency = 0
	
	return buttonFrame

end
function buildTextButton(text)

	local buttonFrame = Instance.new("Frame")
	buttonFrame.BackgroundTransparency = 1.0
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Parent  = buttonFrame
	button.Text = text
	button.Size = UDim2.new(1.0, 0, 1.0, 0)
	button.TextWrap = true
	button.Position = UDim2.new(0.0, 0, 0.0, 0)
	button.BorderSizePixel = 1
	button.BackgroundTransparency = buttonTransparency
	button.Parent  = buttonFrame
	
	return buttonFrame
end

function mouseEnterInsertButton(insertFrame)
	if insertFrame ~= Data.CurrentRolloverInsertButton then
		insertFrame.Button.Transparency = 0.0
		Data.CurrentRolloverInsertButton = insertFrame
		Window.Main.RolloverText.Text = Data.CurrentRolloverInsertButton.AssetName.Value
	end
end

function mouseLeaveInsertButton(insertFrame)
	if insertFrame == Data.CurrentRolloverInsertButton then
		Window.Main.RolloverText.Text = ""
		Data.CurrentRolloverInsertButton = nil
		
	end
	insertFrame.Button.Transparency = insertButtonTransparency
end

function buildInsertButton(position, size)
	local insertFrame = buildImageButton("")
	insertFrame.Name = "InsertAssetButton"
	insertFrame.Position = position
	insertFrame.Size = size
	insertFrame.Button.BackgroundColor3 = Color3.new(1.0,1.0,1.0)
	insertFrame.Button.Transparency = insertButtonTransparency
	insertFrame.Visible = false

	local assetId = Instance.new("IntValue")
	assetId.Name = "AssetId"
	assetId.Value = -1
	assetId.Parent = insertFrame

	local assetName = Instance.new("StringValue")
	assetName.Name = "AssetName"
	assetName.Value = ""
	assetName.Parent = insertFrame

	insertFrame.Button.MouseButton1Click:connect(function() mouseLeaveInsertButton(insertFrame) beginInsertAsset(insertFrame.AssetName.Value, insertFrame.AssetId.Value, insertFrame.Button.Image, false) end)
	insertFrame.Button.MouseButton2Click:connect(function() mouseLeaveInsertButton(insertFrame) beginInsertAsset(insertFrame.AssetName.Value, insertFrame.AssetId.Value, insertFrame.Button.Image, true) end)
	insertFrame.Button.MouseEnter:connect(function() mouseEnterInsertButton(insertFrame) end)
	insertFrame.Button.MouseLeave:connect(function() mouseLeaveInsertButton(insertFrame) end)

	return insertFrame
end

function setInsertButtonImageBehavior(insertFrame, visible, name, assetId)
	if visible then
		insertFrame.AssetName.Value = name
		insertFrame.AssetId.Value = assetId
		insertFrame.Button.Image = ThumbnailUrl  .. assetId
		insertFrame.Button.BackgroundColor3 = Color3.new(1.0,1.0,1.0)
		insertFrame.Visible = true
	else
		insertFrame.Visible = false
	end		
end

function mouseEnterSetButton(setFrame)
	if setFrame.Button.AutoButtonColor then
		setFrame.Button.Icon.Transparency = 0.0
	end
end
function mouseLeaveSetButton(setFrame)
	if setFrame.Button.AutoButtonColor then
		setFrame.Button.Icon.Transparency = insertButtonTransparency
	end
end

function buildSetButton(name, setId, setImageId, i,  count)
	local buttonFrame = buildTextButton("")
	buttonFrame.Name = "SetButton"
	buttonFrame.Size = UDim2.new(1.0, 0, 0.0, height*2)
	buttonFrame.Position = UDim2.new(0.0, 0, 0.0, (i-1)*height*2)
	buttonFrame.Button.BackgroundColor3 = buttonColor
	buttonFrame.Button.TextColor3 = buttonTextColor
	buttonFrame.Visible = false

	local setNameLabel = Instance.new("TextLabel")
	setNameLabel.Name = "Name"
	setNameLabel.Text = name
	setNameLabel.TextColor3 = buttonTextColor
	setNameLabel.BackgroundTransparency = 1.0
	setNameLabel.Size = UDim2.new(1.0, -height*2, 1.0, 0.0)
	setNameLabel.Position = UDim2.new(0.0, height*2, 0.0, 0)
	setNameLabel.TextWrap = true
	setNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	setNameLabel.Parent = buttonFrame.Button
	
	local iconLabel = Instance.new("ImageLabel")
	iconLabel.Name = "Icon"
	iconLabel.Image = BaseUrl .. "asset/?id=" .. setImageId
	iconLabel.Size = UDim2.new(0.0, height*2 - 4, 0.0, height*2 -4)
	iconLabel.Position = UDim2.new(0.0, 2, 0.0, 2)
	iconLabel.Transparency = insertButtonTransparency
	iconLabel.Parent = buttonFrame.Button
	
	local setValue = Instance.new("IntValue")
	setValue.Name = "SetId"
	setValue.Value = setId
	setValue.Parent = buttonFrame

	local setName = Instance.new("StringValue")
	setName.Name = "SetName"
	setName.Value = name
	setName.Parent = buttonFrame
	
	buttonFrame.Button.MouseButton1Click:connect(function() selectSet(buttonFrame, buttonFrame.SetName.Value, buttonFrame.SetId.Value, 0) end)
	buttonFrame.Button.MouseEnter:connect(function() mouseEnterSetButton(buttonFrame) end)
	buttonFrame.Button.MouseLeave:connect(function() mouseLeaveSetButton(buttonFrame) end)

	--print("Built button " .. i .. " SetId=" .. setId .. " SetName=" .. name)

	return buttonFrame
end

function previousSetPage() 
	local newIndex = math.max(1, Data.Category[Data.CurrentCategory].Index - (Data.Main.InsertRows * Data.Main.InsertColumns))
	setSetIndex(newIndex) 
end

function nextSetPage()
	local newIndex = math.max(0, Data.Category[Data.CurrentCategory].Index + (Data.Main.InsertRows * Data.Main.InsertColumns))
	setSetIndex(newIndex)
end

function setSetIndex(dataOffset)
	Data.Category[Data.CurrentCategory].Index = dataOffset

	local PageSize = Data.Main.InsertRows*Data.Main.InsertColumns 
	local contents = Data.Category[Data.CurrentCategory].Contents
	if contents then
		for index = 1, PageSize do
			if Data.InsertButtons[index] then
				if contents[index + dataOffset] then
					--for key, value in pairs(contents[index+dataOffset]) do
					--	print("key=" .. key .. ", value=" .. value)
					--end

					local assetId
					if useAssetVersionId then
						assetId = contents[index + dataOffset].AssetVersionId 
					else 
						assetId = contents[index + dataOffset].AssetId
					end
					setInsertButtonImageBehavior(Data.InsertButtons[index], true, contents[index + dataOffset].Name, assetId)
				else
					setInsertButtonImageBehavior(Data.InsertButtons[index], false)
				end
			end
		end
		Window.Main.PreviousPageButton.Visible = dataOffset > 0
		Window.Main.NextPageButton.Visible = (dataOffset + PageSize) < (#contents)
	else
		Window.Main.PreviousPageButton.Visible = false
		Window.Main.NextPageButton.Visible = false
	end
end

function previousCategoryPage() 
	local newIndex = math.max(0, Data.Category[Data.CurrentCategory].SetIndex - Data.Main.InsertSets)
	setCategoryIndex(newIndex) 
end

function nextCategoryPage()
	local newIndex = math.max(0, Data.Category[Data.CurrentCategory].SetIndex + Data.Main.InsertSets)
	setCategoryIndex(newIndex)
end

function setCategoryIndex(setIndex)
	Data.Category[Data.CurrentCategory].SetIndex = setIndex
	--This is how many vertical items we can display

	--Layout all buttons in this setoh
	if #Data.CurrentCategory > Data.Main.InsertSets then
		--Steal one for use by the layout buttons, when it rains it pours

		--We can't fit all the buttons
		local heightUsed = 0

		local index = 1
		if index < setIndex then
			heightUsed = height
			Window.Main.PreviousSetButton.Visible = true
			while index < setIndex do
				Data.CurrentCategory[index].Visible = false
				index = index + 1
			end
		else
			Window.Main.PreviousSetButton.Visible = false
		end

		local offset = 0
		while offset < Data.Main.InsertSets and index + offset <= #Data.CurrentCategory do
			Data.CurrentCategory[index + offset].Size = UDim2.new(1.0, 0, 0.0, height*2)
			Data.CurrentCategory[index + offset].Position = UDim2.new(0.0, 0, 0.0, height*2*offset + heightUsed)
			Data.CurrentCategory[index + offset].Visible = true
			offset = offset + 1
		end
		index = index + offset
		heightUsed = heightUsed + Data.Main.InsertSets*height*2

		if index <= #Data.CurrentCategory then
			Window.Main.NextSetButton.Position = UDim2.new(0.0, 0, 0.0, heightUsed)
			Window.Main.NextSetButton.Size = UDim2.new(1.0, 0, 1.0, -heightUsed)
			Window.Main.NextSetButton.Visible = true
			while index <=  #Data.CurrentCategory do
				Data.CurrentCategory[index].Visible = false
				index = index + 1
			end		
		else
			Window.Main.NextSetButton.Visible = false
		end
		--Window.Main.Frame.SetTab.SetFiller.Size = UDim2.new(0.0, 0, 0.0, 0)
	else
		Window.Main.PreviousSetButton.Visible = false
		Window.Main.NextSetButton.Visible = false

		for key, buttonFrame in pairs(Data.CurrentCategory) do
			buttonFrame.Size = UDim2.new(1.0, 0, 0.0, height*2)
			buttonFrame.Position = UDim2.new(0.0, 0, 0.0, height*2*(key-1))
			buttonFrame.Visible = true
		end

		--Then expand this to fill the remaining space at the bottom
		--Window.Main.Frame.SetTab.SetFiller.Position = UDim2.new(0.0, 0, 0.0, height*2*#Data.CurrentCategory)
		--Window.Main.Frame.SetTab.SetFiller.Size = UDim2.new(1.0, 0, 0.0, frameHeight - height*2*#Data.CurrentCategory)
	end
end

function selectCategoryPage(buttons, page)
	if buttons ~= Data.CurrentCategory then		
		if Data.CurrentCategory then
			for key, button in pairs(Data.CurrentCategory) do
				button.Visible = false
			end
		end

		Data.CurrentCategory = buttons		
		if Data.Category[Data.CurrentCategory] == nil then
			Data.Category[Data.CurrentCategory] = {}
			if #buttons > 0 then
				selectSet(buttons[1], buttons[1].SetName.Value, buttons[1].SetId.Value, 0)
			end
		else
			Data.Category[Data.CurrentCategory].Button = nil
			selectSet(Data.Category[Data.CurrentCategory].ButtonFrame, Data.Category[Data.CurrentCategory].SetName, Data.Category[Data.CurrentCategory].SetId, Data.Category[Data.CurrentCategory].Index)
		end
		if Data.Main.FrameHeight then
			if Data.Category[Data.CurrentCategory].SetIndex then
				layoutSetButtons(Data.Main.FrameHeight, Data.Category[Data.CurrentCategory].SetIndex)
			else
				layoutSetButtons(Data.Main.FrameHeight, 1)
			end
		end


	end
end
function filterSet(set)
	if soloGame then
		return set
	end

	local result = {}
	for pos, object in pairs(set) do
		if object.IsTrusted then
			result[#result+1] = object
		end
	end
	return result
end
function selectSet(buttonFrame, setName, setId, setIndex)
	if buttonFrame then
		if buttonFrame.Button ~= Data.Category[Data.CurrentCategory].Button then
			if Data.Category[Data.CurrentCategory].Button ~= nil then
				Data.Category[Data.CurrentCategory].Button.BackgroundColor3 = buttonColor
				Data.Category[Data.CurrentCategory].Button.TextColor3 = buttonTextColor
				Data.Category[Data.CurrentCategory].Button.Icon.Transparency = insertButtonTransparency
				Data.Category[Data.CurrentCategory].Button.AutoButtonColor = true
			end
			
			Data.Category[Data.CurrentCategory].Button = buttonFrame.Button
			Data.Category[Data.CurrentCategory].Button.BackgroundColor3 = selectedButtonColor
			Data.Category[Data.CurrentCategory].Button.TextColor3 = selectedButtonTextColor
			Data.Category[Data.CurrentCategory].Button.Icon.Transparency = 0.0
			Data.Category[Data.CurrentCategory].Button.AutoButtonColor = false
		
			if SetCache[setId] == nil then
				SetCache[setId] = filterSet(game:GetService("InsertService"):GetCollection(setId))
			end
			Data.Category[Data.CurrentCategory].Contents = SetCache[setId]
			Window.Main.Title.Text = setName

			Data.Category[Data.CurrentCategory].SetName = setName
			Data.Category[Data.CurrentCategory].SetId = setId
			Data.Category[Data.CurrentCategory].ButtonFrame = buttonFrame
		end

		setSetIndex (setIndex)
	end
end

function selectCategory(button, category)
	if Data.CurrentCategory ~= category then
		if Data.CurrentCategoryButton then
			Data.CurrentCategoryButton.BackgroundColor3 = buttonColor
			Data.CurrentCategoryButton.TextColor3 = buttonTextColor
			Data.CurrentCategoryButton.AutoButtonColor = true
		end
	end
	selectCategoryPage(category, 0)

	Data.CurrentCategoryButton = button
	Data.CurrentCategoryButton.BackgroundColor3 = selectedButtonColor
	Data.CurrentCategoryButton.TextColor3 = selectedButtonTextColor
	Data.CurrentCategoryButton.AutoButtonColor = false
end

function processCategory(sets, setPanel)
	local setButtons = {}
	for index, object in pairs(sets) do
		--for key, value in pairs(object) do
		--	print("key=" .. key .. ", value=" .. value)
		--end
		setButtons[index] = buildSetButton(object.Name, object.CategoryId, object.ImageAssetId, index, #sets)
		setButtons[index].Parent = setPanel	
	end
	return setButtons
end

local speed = 25
function pushInFrame()
	while frame.Position.X.Offset < 100 do
		frame.Position = UDim2.new(0, frame.Position.X.Offset + speed,0,-100)
		wait()
	end
end

function pushOutFrame()
	while frame.Position.X.Offset > -119 do
		frame.Position = UDim2.new(0, frame.Position.X.Offset - speed,0,-100)
		wait()
	end
end

function buildMainGui(root, userId)
	root.Image = "http://www.roblox.com/asset/?id=35267965"
	root.Size = UDim2.new(0,119,0,375)
	root.BackgroundTransparency = 1
	root.Parent = getPlayer().PlayerGui.NewGuiDemo.BuildTools.Frame.AddDeleteTools.InsertObject
	root.Position = UDim2.new(0,-119,0,-100)
--[[	Window.Main = {}
	Data.Main = {}
	Data.Category = {}
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "InsertMainDialog"
	mainFrame.Position = UDim2.new(0.0, 0, 0.25, 0)
	mainFrame.Size = UDim2.new(0.75, 0, 0.75, 0)
	mainFrame.Transparency = 1.0
	mainFrame.Active = true
	mainFrame.Parent = root
	Window.Main.Frame = mainFrame

	local setTab = Instance.new("Frame")
	setTab.Position = UDim2.new(0.0, 0, 0.0, 0)
	setTab.Size = UDim2.new(0.15, 0, 1.0, 0)
	setTab.BackgroundTransparency = 1.0
	setTab.Name = "SetTab"
	setTab.Parent = mainFrame

	local setPanel = Instance.new("Frame")
	setPanel.Position = UDim2.new(0.0, 0, 0.0, 0)
	setPanel.Size = UDim2.new(1.0, 0, 1.0, 0)
	setPanel.BackgroundTransparency = 1.0
	setPanel.Name = "SetPanel"
	setPanel.Parent = setTab

	local setFiller = Instance.new("Frame")
	setFiller.Name = "SetFiller"
	setFiller.Size = UDim2.new(0.0, 0, 0.0, 0)
	setFiller.Position = UDim2.new(0.0, 0, 0.0, 0)
	setFiller.BackgroundColor3 = frameColor
	setFiller.BackgroundTransparency = transparency*.5
	setFiller.Parent = setTab
	
	local previousSetButton = Instance.new("TextButton")
	previousSetButton.Name = "PreviousSetButton"
	previousSetButton.Size = UDim2.new(1.0, 0, 0, height)
	previousSetButton.Position = UDim2.new(0.0, 0, 0.0, 0)
	previousSetButton.BackgroundColor3 = buttonColor
	previousSetButton.TextColor3 = buttonTextColor
	previousSetButton.BackgroundTransparency = transparency
	previousSetButton.Text = "..."
	previousSetButton.MouseButton1Click:connect(previousCategoryPage)
	previousSetButton.Parent = setTab
	previousSetButton.Visible = false
	Window.Main.PreviousSetButton = previousSetButton

	local nextSetButton = Instance.new("TextButton")
	nextSetButton.Name = "NextSetButton"
	nextSetButton.Size = UDim2.new(1.0, 0, 0.0, height)
	nextSetButton.Position = UDim2.new(0.0, 0, 1.0, -height)
	nextSetButton.BackgroundColor3 = buttonColor
	nextSetButton.TextColor3 = buttonTextColor
	nextSetButton.BackgroundTransparency = transparency
	nextSetButton.Text = "..."
	nextSetButton.MouseButton1Click:connect(nextCategoryPage)
	nextSetButton.Parent = setTab
	nextSetButton.Visible = false
	Window.Main.NextSetButton = nextSetButton

	local insertTab = Instance.new("Frame")
	insertTab.Name = "InsertTab"
	insertTab.Position = UDim2.new(0.15, 0, 0.0, 0)
	insertTab.Size = UDim2.new(0.85, 0, 1.0, 0)
	insertTab.BackgroundTransparency = 1.0
	insertTab.Parent = mainFrame
	
	Data.BaseCategoryButtons = processCategory(game:GetService("InsertService"):GetBaseCategories(), setPanel)	
	local userData = game:GetService("InsertService"):GetUserCategories(userId)
	if userData then
		Data.UserCategoryButtons = processCategory(userData, setPanel)

		local userCategoryButton = Instance.new("TextButton")
		userCategoryButton.Name = "UserCategoryButton"
		userCategoryButton.Size = UDim2.new(0.25, 0, 0, height)
		userCategoryButton.Position = UDim2.new(0.25, 0, 0.0, -height)
		userCategoryButton.BackgroundColor3 = buttonColor
		userCategoryButton.TextColor3 = buttonTextColor
		userCategoryButton.BackgroundTransparency = transparency*.5
		userCategoryButton.Text = "User Sets"
		userCategoryButton.MouseButton1Click:connect(function() selectCategory(userCategoryButton, Data.UserCategoryButtons) end)
		userCategoryButton.Parent = insertTab
	end
	--Data.UserCategoryButtons =  processCategory(game:GetService("InsertService"):GetBaseCategories(), setPanel)

	local baseCategoryButton = Instance.new("TextButton")
	baseCategoryButton.Name = "RobloxCategoryButton"
	baseCategoryButton.Size = UDim2.new(0.25, 0, 0, height)
	baseCategoryButton.Position = UDim2.new(0.0, 0, 0.0, -height)
	baseCategoryButton.BackgroundColor3 = buttonColor
	baseCategoryButton.TextColor3 = buttonTextColor
	baseCategoryButton.BackgroundTransparency = transparency *.5
	baseCategoryButton.Text = "Roblox Sets"
	baseCategoryButton.MouseButton1Click:connect(function() selectCategory(baseCategoryButton, Data.BaseCategoryButtons) end)
	baseCategoryButton.Parent = insertTab

	local titleFrame = Instance.new("TextLabel")
	titleFrame.Name = "Title"
	titleFrame.Position = UDim2.new(0.0, 0, 0.0, 0)
	titleFrame.Size = UDim2.new(1.0, 0, 0.0, height)
	titleFrame.TextWrap = true
	titleFrame.BackgroundColor3 = titleColor
	titleFrame.TextColor3 = titleTextColor
	titleFrame.BackgroundTransparency = .1
	titleFrame.Text = "Set Foo"
	titleFrame.Parent = insertTab
	Window.Main.Title = titleFrame

	local minimizeButton = Instance.new("ImageButton")
	minimizeButton.Name = "Minimize"
	minimizeButton.Position = UDim2.new(1.0, -height + 1, 0.0, 1)
	minimizeButton.Size = UDim2.new(0.0, height-2, 0.0, height-2)
	minimizeButton.Image = BaseUrl .. "asset?id=20889725"
	minimizeButton.MouseButton1Click:connect(minimize)
	minimizeButton.Parent = titleFrame

	local insertPanel = Instance.new("Frame")
	insertPanel.Name = "InsertPanel"
	insertPanel.Position = UDim2.new(0.0, 0, 0.0, height)
	insertPanel.Size = UDim2.new(1.0, 0, 1.0, -2*height)
	insertPanel.BackgroundColor3 = frameColor
	insertPanel.BackgroundTransparency = transparency
	insertPanel.Parent = insertTab

	local footerPanel = Instance.new("Frame")
	footerPanel.Name = "Footer"
	footerPanel.Size = UDim2.new(1.0, 0, 0, height)
	footerPanel.Position = UDim2.new(0.0, 0, 1.0, -height)
	footerPanel.BackgroundTransparency = transparency
	footerPanel.BackgroundColor3 = frameColor
	footerPanel.Parent = insertTab
	
	local rolloverText = Instance.new("TextLabel")
	rolloverText.Name = "RolloverText"
	rolloverText.Size = UDim2.new(0.8, 0, 1.0, 0)
	rolloverText.Position = UDim2.new(0.1, 0, 0.0, 0)
	rolloverText.TextColor3 = frameTextColor
	rolloverText.BackgroundColor3 = frameColor
	rolloverText.BackgroundTransparency = transparency
	rolloverText.Text = ""
	rolloverText.TextWrap = true
	rolloverText.Parent = footerPanel
	Window.Main.RolloverText = rolloverText

	local previousButton = Instance.new("TextButton")
	previousButton.Name = "PreviousPageButton"
	previousButton.Size = UDim2.new(0.1, 0, 1.0, 0)
	previousButton.Position = UDim2.new(0.0, 0, 0.0, 0)
	previousButton.BackgroundColor3 = buttonColor
	previousButton.TextColor3 = buttonTextColor
	previousButton.BackgroundTransparency = transparency
	previousButton.Text = "<--"
	previousButton.MouseButton1Click:connect(previousSetPage)
	previousButton.Parent = footerPanel
	previousButton.Visible = false
	Window.Main.PreviousPageButton = previousButton

	local nextButton = Instance.new("TextButton")
	nextButton.Name = "NextPageButton"
	nextButton.Size = UDim2.new(0.1, 0, 1.0, 0)
	nextButton.Position = UDim2.new(0.9, 0, 0.0, 0)
	nextButton.BackgroundColor3 = buttonColor
	nextButton.TextColor3 = buttonTextColor
	nextButton.BackgroundTransparency = transparency
	nextButton.Text = "-->"
	nextButton.MouseButton1Click:connect(nextSetPage)
	nextButton.Parent = footerPanel
	nextButton.Visible = false
	Window.Main.NextPageButton = nextButton

	local insertButtons = {}
	for y = 1, InsertRows do
		for x = 1, InsertColumns do
			insertButtons[x  + (y - 1) * InsertColumns] = buildInsertButton(UDim2.new(.125*(x-1), 2, 0.25*(y-1), 2), UDim2.new(.125, -4, .25, -4))
			insertButtons[x  + (y - 1) * InsertColumns].Parent = insertPanel
		end
	end	
	Data.InsertButtons = insertButtons
	Data.Main.InsertRows = InsertRows
	Data.Main.InsertColumns = InsertColumns
	
	selectCategory(baseCategoryButton, Data.BaseCategoryButtons)]]
	pushInFrame()
end

function layoutInsertButtons(guiMain)
	local size = guiMain.AbsoluteSize
	
	local frameSize = 0.75 * size
	local frameSizeUsed = Vector2.new(0, height*2)

	--We want 15% or 100 pixels, which ever is smaller
	if frameSize.x * .15 < 100 then
		local oldSize = Window.Main.Frame.SetTab.Size
		Window.Main.Frame.SetTab.Size = UDim2.new(0.0, 100, oldSize.Y.Scale, oldSize.Y.Offset)
		Window.Main.Frame.InsertTab.Position = UDim2.new(0.0, 100, 0.0, 0)
		frameSizeUsed = Vector2.new(frameSizeUsed.x + 100, frameSizeUsed.y)
	else
		local oldSize = Window.Main.Frame.SetTab.Size
		Window.Main.Frame.SetTab.Size = UDim2.new(0.15, 0, oldSize.Y.Scale, oldSize.Y.Offset)
		Window.Main.Frame.InsertTab.Position = UDim2.new(0.15, 0, 0.0, 0)
		frameSizeUsed = Vector2.new(frameSizeUsed.x + .15*frameSize.x, frameSizeUsed.y)
	end

	--Decide how many buttons we can fit, and what size to make the insert buttons
	--2 sizes of insert buttons, 50x50 and 100x100

	local buttonSize = 110
	while buttonSize > 70 and math.floor((frameSize - frameSizeUsed).x/buttonSize) * math.floor((frameSize - frameSizeUsed).y/buttonSize) < 32 do
		buttonSize = buttonSize - 10
	end
	
	Data.Main.InsertColumns = math.min(math.max(1, math.floor((frameSize - frameSizeUsed).x/buttonSize)), InsertColumns)
	Data.Main.InsertRows = math.min(math.max(1, math.floor((frameSize - frameSizeUsed).y/buttonSize)), InsertRows)
	
	for index, button in pairs(Data.InsertButtons) do
		if index <= Data.Main.InsertRows * Data.Main.InsertColumns then
			button.Visible = true
			button.Size = UDim2.new(0, buttonSize-4, 0, buttonSize-4)
			button.Position = UDim2.new(0, buttonSize * ((index-1)%Data.Main.InsertColumns) + 2 + 2,
								       0, buttonSize * math.floor((index-1)/Data.Main.InsertColumns) + 2 + 2)
		else
			button.Visible = false
		end
	end
	Window.Main.Frame.InsertTab.Size = UDim2.new(0.0, buttonSize * Data.Main.InsertColumns + 4, 0.0, buttonSize * Data.Main.InsertRows + height*2 + 4)

	if Data.Category[Data.CurrentCategory].Index == nil then
		setSetIndex(0)
	else
		setSetIndex(Data.Category[Data.CurrentCategory].Index)
	end
	
	local finalFrameHeight = frameSizeUsed.y + Data.Main.InsertRows*buttonSize + 4
	Window.Main.Frame.Size = UDim2.new(0, frameSizeUsed.x + Data.Main.InsertColumns*buttonSize + 4, 0, finalFrameHeight)
	Window.Main.Frame.Position = UDim2.new(0.0, 0, 1.0, -Window.Main.Frame.Size.Y.Offset)

	if Data.Category[Data.CurrentCategory].SetIndex == nil then
		layoutSetButtons(finalFrameHeight, 1)
	else
		layoutSetButtons(finalFrameHeight, Data.Category[Data.CurrentCategory].SetIndex)
	end
end

function layoutSetButtons(frameHeight, setIndex)
	Data.Main.FrameHeight = frameHeight
	Data.Main.InsertSets = math.floor(frameHeight / (height*2))
	if #Data.CurrentCategory > Data.Main.InsertSets then
		--Steal one entry since we have two many things
		Data.Main.InsertSets = Data.Main.InsertSets - 1 
	end

	print("Layout Set Buttons index=" .. setIndex .. ", InsertSets="..Data.Main.InsertSets)
	
	setCategoryIndex(setIndex)
end


function insertComplete()
	Window.Loading.Frame.Visible = false
	Window.Stamp.Frame.Visible = false
	Window.Main.Frame.Visible = true
end

function UnlockInstances(object)
	if object:IsA("BasePart") then
		object.Locked = false
	end
	for index,child in pairs(object:GetChildren()) do
		UnlockInstances(child)
	end
end

function beginInsertDecal(decal)

	Data.Stamp.DecalSelection = Instance.new("SurfaceSelection")
	Data.Stamp.DecalSelection.Color = BrickColor.new("Bright orange")
	Data.Stamp.DecalSelection.archivable = false
	Data.Stamp.DecalSelection.Parent = getPlayer().PlayerGui
	
	--Save the decal in our Lua code for later use
	Data.Stamp.Decal = decal
	Data.Stamp.Decal.Parent = nil
end

function beginInsertAsset(assetName, assetId, image, stampMode)
	--Copy over details into dialog window
	Window.Loading.AssetThumbLabel.Image = image
	Window.Loading.AssetNameLabel.Text = assetName
	
	Window.Stamp.AssetThumbLabel.Image = image
	Window.Stamp.AssetNameLabel.Text = assetName
	Data.Stamp.StampMode = stampMode

	--Hide the main window
	Window.Main.Frame.Visible = false
	--Show the dialog window
	Window.Loading.Frame.Visible = true
	Data.Loading.Cancelled = false

	--This call will cause a "wait" until the data comes back
	local root
	if useAssetVersionId then
		root = game:GetService("InsertService"):LoadAssetVersion(assetId)
	else
		root = game:GetService("InsertService"):LoadAsset(assetId)
	end

	if Data.Loading.Cancelled then
		--The user got bored and wandered off

		--Just delete the model from the world... a shame we loaded it when they got bored
		root:Remove()
	else
		Window.Loading.Frame.Visible = false
		
		local instances = root:GetChildren()
		if #instances == 0 then
			root:Remove()
			insertComplete()
			return
		end

		--Unlock all parts that are inserted, to make sure they are editable
		UnlockInstances(root)

		--Continue the insert process
		root.Name = "InsertedObject" .. assetId

		--Examine the contents and decide what it looks like
		for pos, instance in pairs(instances) do
			--Single instance objects might be treated special, decals/skyboxes
			if instance:IsA("Decal") then
				--Current system here stops after finding one Decal (and gives you Decal tool)
				--We should do the same (probably)
				beginInsertDecal(instance)
				root:Remove()
				
				Window.Stamp.Frame.Visible = true
				return
			elseif instance:IsA("Team") then
				instance.Parent = game:GetService("Teams")
			elseif instance:IsA("SpawnLocation") then
				
			elseif instance:IsA("HopperBin") then
				-- Must go into the starterPack, prompt user?
			elseif instance:IsA("Tool") then
				-- Ask them if it should go in StarterPack? 
			elseif instance:IsA("Sky") then
				local lightingService = game:GetService("Lighting")
				for index,child in pairs(lightingService:GetChildren()) do
					if child:IsA("Sky") then
						child:Remove();
					end
				end
				instance.Parent = lightingService
				return
			else
				
			end
		end

		if #root:GetChildren() == 0 then
			root:Remove()
			insertComplete()
			return
		end

		Window.Stamp.Frame.Visible = true
		Data.Stamp.Model = root
	end
end

function cancelAssetLoad()
	Data.Loading.Cancelled = true
	insertComplete()
end

function buildLoadingDialogGui(root)
	Window.Loading = {}
	Data.Loading = {}

	local dialogFrame = Instance.new("Frame")
	dialogFrame.Name = "InsertLoadingDialog"
	dialogFrame.Size = UDim2.new(0.0, height*10, 0, height*5)
	dialogFrame.Position = UDim2.new(0.5, -height*5, 0.5, -height*2.5)
	dialogFrame.BackgroundColor3 = frameColor
	dialogFrame.Active = true
	dialogFrame.Parent = root
	dialogFrame.Visible = false
	Window.Loading.Frame = dialogFrame

	local assetThumb = Instance.new("ImageLabel")
	assetThumb.Position = UDim2.new(0.0, 2, 0.0, 2)
	assetThumb.Size = UDim2.new(0.5, -4, 1.0, -4)
	assetThumb.Parent = dialogFrame
	Window.Loading.AssetThumbLabel = assetThumb

	local descriptionFrame = Instance.new("Frame")
	descriptionFrame.Name = "Description"
	descriptionFrame.Size = UDim2.new(0.5, 0, 1.0, 0)
	descriptionFrame.Position = UDim2.new(0.5, 0, 0.0, 0)
	descriptionFrame.Transparency = 1
	descriptionFrame.Parent = dialogFrame

	local label = Instance.new("TextLabel")
	label.Text = "Loading..."
	label.Position = UDim2.new(0.5, 0, 0, 0);
	label.Size = UDim2.new(0.0, 0, 0.0, height)
	label.BorderSizePixel = 0
	label.TextColor3 = frameTextColor
	label.Parent = descriptionFrame
	
	local assetLabel = Instance.new("TextLabel")
	assetLabel.Text = "Your Asset Here"
	assetLabel.Position = UDim2.new(0.0, 0, 0.0, height)
	assetLabel.Size = UDim2.new(1.0, 0, 1.0, -2*height)
	assetLabel.BorderSizePixel = 0
	assetLabel.BackgroundTransparency = 1.0
	assetLabel.Parent = descriptionFrame
	assetLabel.TextColor3 = frameTextColor
	assetLabel.TextWrap = true
	Window.Loading.AssetNameLabel = assetLabel	

	local cancelButton = Instance.new("TextButton")
	cancelButton.Name = "PreviousPageButton"
	cancelButton.Size = UDim2.new(0, height*3, 0, height)
	cancelButton.Position = UDim2.new(0.5, -height*1.5, 1.0, -height*1.2)
	cancelButton.BackgroundColor3 = buttonColor
	cancelButton.TextColor3 = buttonTextColor
	cancelButton.Text = "Cancel"
	cancelButton.MouseButton1Click:connect(cancelAssetLoad)
	cancelButton.Parent = descriptionFrame
end



function cancelAssetPlacement()
	Data.Stamp.Cancelled = true
	Data.Stamp.Dragger = nil
	if Data.Stamp.Model then
		Data.Stamp.Model:Remove()
		Data.Stamp.Model = nil
	end
	if Data.Stamp.CurrentParts then
		for index, object in pairs(Data.Stamp.CurrentParts) do
			object:Remove()
		end
		Data.Stamp.CurrentParts = nil
	end

	if Data.Stamp.DecalSelection then
		Data.Stamp.DecalSelection:Remove()
		Data.Stamp.DecalSelection = nil
	end
	if Data.Stamp.Decal then
		Data.Stamp.Decal:Remove()
		Data.Stamp.Decal = nil
	end

	if Mouse then
		Mouse.Icon ="rbxasset://textures\\ArrowCursor.png"
	end	
	insertComplete()
end

function onInsertKeyDown(key)
	if Data.Stamp.Dragger then
		if key == 'R' or key == 'r'  then
			Data.Stamp.Dragger:AxisRotate(Enum.Axis.Y)
		elseif key == 'T' or key == 't' then
			Data.Stamp.Dragger:AxisRotate(Enum.Axis.Z)
		end
	end
	if key == '' then
		minimize()
	end
end


function canSelectObject(part)
	return part and not (part.Locked) and part:IsA("BasePart") and (part.Position - Tool.Parent.Head.Position).Magnitude < 60
end

function setSelectionSurface(part, surface) 
	if Data.Stamp.DecalSelection.Adornee == part and Data.Stamp.DecalSelection.TargetSurface == surface then
		return
	end
	unsetSelectionSurface()
	Data.Stamp.DecalSelection.Adornee = part
	Data.Stamp.DecalSelection.TargetSurface = surface
	--selectionLasso.Part = part

	local decalFound = false
	for index,child in pairs(part:GetChildren()) do
		if child:IsA("Decal") and child.Face == surface then
			decalFound = true
			break
		end
	end

	if not(decalFound) then
		Data.Stamp.Decal.Parent = part
		Data.Stamp.Decal.Face = surface
	end
end

function unsetSelectionSurface() 
	Data.Stamp.DecalSelection.Adornee = nil
	--selectionLasso.Part = nil
	Data.Stamp.Decal.Parent = nil
end

function onInsertMouseMove() 
	if Data.Stamp.MovingLock then
		return
	end

	local newCursor = "rbxasset://textures\\ArrowCursor.png"
	Data.Stamp.MovingLock = true
	if Data.Stamp.Decal then
		local part = Mouse.Target
		if canSelectObject(part) then
			setSelectionSurface(part, Mouse.TargetSurface)
		else
			unsetSelectionSurface()
			newCursor = BaseUrl .. "asset?id=20715642"
		end
	elseif Data.Stamp.Dragger == nil then
		if Data.Stamp.Model ~= nil then
			Mouse.Icon ="rbxasset://textures//GrabRotateCursor.png"
			setupDraggableClone()
		end
	else
		Data.Stamp.Dragger:MouseMove(Mouse.UnitRay)
	end
	Mouse.Icon = newCursor

	Data.Stamp.MovingLock = false
end

function onInsertMouseButton1Down()
	if Data.Stamp.Dragger or Data.Stamp.Decal then
		Data.Stamp.MouseDown = true
	end
end

function onInsertMouseButton1Up()
	if Data.Stamp.MouseDown then
		Data.Stamp.MouseDown = false
		if Data.Stamp.Decal then
			local part = Mouse.Target
			if canSelectObject(part) and Instance.Lock(part) then
				local surface = Mouse.TargetSurface 
				for index,child in pairs(part:GetChildren()) do
					if child:IsA("Decal") and child.Face == surface then
						child:Remove()
					end
				end

				local newDecal  = Data.Stamp.Decal:Clone()
				newDecal.Face = surface
				newDecal.Parent = part
					Instance.Unlock(part)
				
				if Data.Stamp.StampMode then
				else 
					Instance.Unlock(part)
					cancelAssetPlacement()
				end
			end
		elseif Data.Stamp.Dragger then
			--Place the object where the mouse is currently positioned
			Data.Stamp.Dragger:MouseUp()
		
			--Fix the transparency of all the parts
			for part, transparency in pairs(Data.Stamp.TransparencyTable) do
				part.Transparency = transparency
			end
			Data.Stamp.TransparencyTable = nil

			--Re-enable the scripts
			for index,script in pairs(Data.Stamp.DisabledScripts) do
				script.Disabled = false
			end
			--Now that they are all marked enabled, reinsert them into the world so they start running
			for index,script in pairs(Data.Stamp.DisabledScripts) do
				local oldParent = script.Parent
				script.Parent = nil
				script:Clone().Parent = oldParent
			end
			Data.Stamp.DisabledScripts = nil

			Data.Stamp.Dragger = nil
			Data.Stamp.CurrentParts = nil
			
			if Data.Stamp.StampMode then
				--Now set up a new instance of the object to allow a second copy to be stamped down
				setupDraggableClone()
			else
				cancelAssetPlacement()
			end
		end
	end
end


function collectParts(object, baseParts, scripts)
	if object:IsA("BasePart") then
		baseParts[#baseParts+1] = object
	elseif object:IsA("Script") then
		scripts[#scripts+1] = object
	end

	for index,child in pairs(object:GetChildren()) do
		collectParts(child, baseParts, scripts)
	end
end



function setupDraggableClone()
	local clone = Data.Stamp.Model:Clone()
	local scripts = {}
	local parts = {}

	collectParts(clone, parts, scripts)

	if #parts > 0 then
		Data.Stamp.DisabledScripts = {}
		Data.Stamp.TransparencyTable = {}

		for index,script in pairs(scripts) do
			if not(script.Disabled) then
				script.Disabled = true
				Data.Stamp.DisabledScripts[#Data.Stamp.DisabledScripts +1] = script
			end
		end
		for index, part in pairs(parts) do
			Data.Stamp.TransparencyTable[part] = part.Transparency
			part.Transparency = 0.5
		end

		game:GetService("InsertService"):Insert(clone)
		
		Data.Stamp.CurrentParts = clone:GetChildren();
		for index, object in pairs(Data.Stamp.CurrentParts) do
			object.Parent = clone.Parent
		end
		clone:Remove();
		
		Data.Stamp.Dragger = Instance.new("Dragger")
		--Begin a movement by faking a MouseDown signal
		Data.Stamp.Dragger:MouseDown(parts[1], Vector3.new(0,0,0), parts)
		Data.Stamp.Dragger:MouseMove(Mouse.UnitRay)
	else
		--Nothing draggable in the Model
		Data.Stamp.Model:Remove()
		Data.Stamp.Model = nil
		Data.Stamp.TransparencyTable = nil
		Data.Stamp.DisabledScripts = nil
	end
end
function buildStampDialogGui(root)
	Window.Stamp = {}
	Data.Stamp = {}

	local dialogFrame = Instance.new("Frame")
	dialogFrame.Name = "InsertStampDialog"
	dialogFrame.Size = UDim2.new(0.0, height*10, 0, height*5)
	dialogFrame.Position = UDim2.new(0.0, 0, 1.0, -height*5)
	dialogFrame.BackgroundColor3 = frameColor
	dialogFrame.Active = true
	dialogFrame.Parent = root
	dialogFrame.Visible = false
	Window.Stamp.Frame = dialogFrame

	local assetThumb = Instance.new("ImageLabel")
	assetThumb.Position = UDim2.new(0.0, 2, 0.0, 2)
	assetThumb.Size = UDim2.new(0.5, -4, 1.0, -4)
	assetThumb.Parent = dialogFrame
	Window.Stamp.AssetThumbLabel = assetThumb

	local descriptionFrame = Instance.new("Frame")
	descriptionFrame.Name = "Description"
	descriptionFrame.Size = UDim2.new(0.5, 0, 1.0, 0)
	descriptionFrame.Position = UDim2.new(0.5, 0, 0.0, 0)
	descriptionFrame.Transparency = 1
	descriptionFrame.Parent = dialogFrame

	local assetLabel = Instance.new("TextLabel")
	assetLabel.Text = "Your Asset Here"
	assetLabel.Position = UDim2.new(0.0, 0, 0.0, 0)
	assetLabel.Size = UDim2.new(1.0, 0, 1.0, -height)
	assetLabel.BorderSizePixel = 0
	assetLabel.BackgroundTransparency = 1.0
	assetLabel.Parent = descriptionFrame
	assetLabel.TextColor3 = frameTextColor
	assetLabel.TextWrap = true
	Window.Stamp.AssetNameLabel = assetLabel	

	local cancelButton = Instance.new("TextButton")
	cancelButton.Name = "CancelButton"
	cancelButton.Size = UDim2.new(0, height*4.5, 0, height)
	cancelButton.Position = UDim2.new(0.5, -height*2.25, 1.0, -height*1.2)
	cancelButton.BackgroundColor3 = buttonColor
	cancelButton.TextColor3 = buttonTextColor
	cancelButton.Text = "Back to Toolbox"
	cancelButton.MouseButton1Click:connect(cancelAssetPlacement)
	cancelButton.Parent = descriptionFrame

	Data.Stamp.MovingLock = false	
end

function buildInitialLoadScreen(root)
	local dialogFrame = Instance.new("Frame")
	dialogFrame.Name = "InsertLoadingScreen"
	dialogFrame.Size = UDim2.new(0.0, height*10, 0, height*5)
	dialogFrame.Position = UDim2.new(0.5, -height*5, 0.5, -height*2.5)
	dialogFrame.BackgroundColor3 = frameColor
	dialogFrame.Active = true
	dialogFrame.Visible = true
	dialogFrame.Parent = root

	local label = Instance.new("TextLabel")
	label.Text = "Loading"
	label.Position = UDim2.new(0.0, 0, 0, 0)
	label.Size = UDim2.new(1.0, 0, 0.0, height)
	label.BorderSizePixel = 1
	label.TextColor3 = titleTextColor
	label.BackgroundColor3 = titleColor
	label.Parent = dialogFrame
	
	local assetLabel = Instance.new("TextLabel")
	assetLabel.Text = "Please Wait"
	assetLabel.Position = UDim2.new(0.0, 0, 0.0, height)
	assetLabel.Size = UDim2.new(1.0, 0, 1.0, -2*height)
	assetLabel.BorderSizePixel = 1
	assetLabel.BackgroundTransparency = 1.0
	assetLabel.TextColor3 = frameTextColor
	assetLabel.TextWrap = true
	assetLabel.Parent = dialogFrame
end

function buildMinimizedGui(root)
	Window.Minimized = {}
	Data.Minimized = {}
	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Size = UDim2.new(0, height*4.5, 0, height)
	minimizeButton.Position = UDim2.new(0.0, 0, 1.0, -height)
	minimizeButton.BackgroundColor3 = buttonColor
	minimizeButton.TextColor3 = buttonTextColor
	minimizeButton.Text = "Toolbox"
	minimizeButton.MouseButton1Click:connect(function() Window.Minimized.Frame.Visible = false Window.Main.Frame.Visible = true end)
	minimizeButton.Visible = false
	minimizeButton.Parent = root

	Window.Minimized.Frame = minimizeButton
end


local CancelDuringLoad
local LoadScreen 
function onEquippedLocal(mouse)
	Tool.TextureId = "rbxasset://icons/insert_sel.png"

	Mouse = mouse
	if Tool.SavedState.Value and Tool.PlayerOwner.Value == getPlayer() and Data and Data.FullyLoaded then
		guiMain = Tool.SavedState.Value
		guiMain.Parent = getPlayer().PlayerGui

		Window.Stamp.Frame.Visible = false
		Window.Minimized.Frame.Visible = false
		Window.Loading.Frame.Visible = false
		Window.Main.Frame.Visible = true
		
		--Window = Tool.SavedState.Value.Window
		--Data = Tool.SavedState.Value.Window
	else
		CancelDuringLoad = false

		--[[LoadScreen = Instance.new("ScreenGui")
		LoadScreen.Name = "InsertToolLoading"
		buildInitialLoadScreen(LoadScreen)
		LoadScreen.Parent = getPlayer().PlayerGui]]
		
		--guiMain = Instance.new("ScreenGui")
	--	guiMain.Name = "InsertToolboxMain"
		Window = {}
		Data = {}
		Data.FullyLoaded = false
		frame = Instance.new("ImageLabel")
		--buildMainGui(frame, getPlayer().userId)
		--buildLoadingDialogGui(guiMain)
	--	buildStampDialogGui(guiMain)
		--buildMinimizedGui(guiMain)

		LoadScreen:Remove()
		LoadScreen = nil
		
		if not(CancelDuringLoad) then
			guiMain.Changed:connect(function(property) if property == "AbsoluteSize" then layoutInsertButtons(guiMain) end end)
			guiMain.Parent = getPlayer().PlayerGui

			Tool.SavedState.Value = guiMain
			Tool.PlayerOwner.Value = getPlayer()
		end

		Data.FullyLoaded = true
	end

	Mouse.Move:connect(onInsertMouseMove)
	Mouse.Button1Down:connect(onInsertMouseButton1Down)
	Mouse.Button1Up:connect(onInsertMouseButton1Up)
	Mouse.KeyDown:connect(onInsertKeyDown)

end

function onUnequippedLocal()
	Tool.TextureId = origTexture

	pushOutFrame()
	frame:remove()

	pcall(function()
		cancelAssetPlacement()
		cancelAssetLoad()
		guiMain.Parent = nil
		end)
	
	CancelDuringLoad = true

	if LoadScreen then
		LoadScreen:Remove()
	end
end

function onAncestryChanged(child,parent)
	if Tool.PlayerOwner.Value and not Tool:IsDescendantOf(Tool.PlayerOwner.Value) and not Tool:IsDescendantOf(Tool.PlayerOwner.Value.Character) then
		--Tool was dropped in some way, so we need to nuke our external state
		Tool.SavedState.Value = nil
		Tool.PlayerOwner.Value = nil
	end
	
	pcall(cancelAssetPlacement)
	pcall(cancelAssetLoad)
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.AncestryChanged:connect(onAncestryChanged)