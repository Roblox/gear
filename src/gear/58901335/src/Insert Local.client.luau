local Tool = script.Parent

enabled = true
local origTexture = 	Tool.TextureId
game:GetService("ContentProvider"):Preload("rbxasset://icons/insert_sel.png")

local insertGui

local height = 20
local width = UDim.new(0.25, 0)
local height = 20
local buttonTransparency = 0.1
local insertButtonTransparency = 0.25
local transparency = 0.25

local freeIndex = 1
local freeViewing = false
local viewingModels = false
local currentSearchText = ""
local freeModels
local freeSets

local loading = false

local dropDownSelected = false

local selectedButtonColor = Color3.new(.1255, .4078, .1961)
local selectedButtonTextColor = Color3.new(1.0,1.0,1.0)

local buttonColor = Color3.new(0.0898, 0.2148, .2344)
local buttonTextColor = Color3.new(1.0,1.0,1.0)

local frameColor = Color3.new(.1255, .4078, .1961)
local frameTextColor = Color3.new(1.0,1.0,1.0)

local titleColor = Color3.new(0.6289, 0.8398, 0)
local titleTextColor = Color3.new(0,0,0)

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

local InsertRows = 7
local InsertColumns = 3
local highlight = true
local minYSize = 8

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
	buttonFrame.BackgroundColor = BrickColor.White()
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.BorderSizePixel = 0

	local button = Instance.new("ImageButton")
	button.Name = "Button"
	button.Parent  = buttonFrame
	button.Image = image
	button.Size = UDim2.new(.9, 0, .9, 0)
	button.Position = UDim2.new(0.05, 0, 0.05, 0)
	button.BorderSizePixel = 0
	button.Parent  = buttonFrame
	button.AutoButtonColor = false
	button.BackgroundTransparency = 0

	local latest = Instance.new("StringValue")
	latest.Name = "Latest"
	latest.Value = "nil"
	latest.Parent = button

	local fadeSpeed = 0.1
	button.MouseEnter:connect(function()
		button.Latest.Value = "Enter"
		while button.Parent.BackgroundTransparency > 0 and button.Latest.Value == "Enter" do
			button.Parent.BackgroundTransparency = button.Parent.BackgroundTransparency - fadeSpeed
			wait()
		end
	end)

	button.MouseLeave:connect(function()
		imageButtonMouseLeave(button, fadeSpeed)
	end)

	button.MouseButton1Click:connect(function()
		imageButtonMouseLeave(button, fadeSpeed)
	end)
	
	return buttonFrame

end


function imageButtonMouseLeave(button, fadeSpeed)
	button.Latest.Value = "Leave"
	while button.Parent.BackgroundTransparency < 1 and button.Latest.Value == "Leave" do
		button.Parent.BackgroundTransparency = button.Parent.BackgroundTransparency + fadeSpeed
		wait()
	end
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
		if highlight then
			Window.Main.RolloverText.Text = Data.CurrentRolloverInsertButton.AssetName.Value
		else 
			Window.Main.RolloverText.Text = ""
		end
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
	if freeViewing == false then
		local newIndex = math.max(1, Data.Category[Data.CurrentCategory].Index - (Data.Main.InsertRows * Data.Main.InsertColumns))
		setSetIndex(newIndex)
	else
		freeIndex = math.max(freeIndex - 1,1)
		if viewingModels then
			loadFreeSets(freeModels,"Models",currentSearchText)
		else
			loadFreeSets(freeDecals,"Decals",currentSearchText)
		end
		Window.Main.NextPageButton.Visible = true
		Window.Main.PreviousPageButton.Visible = true
		if freeIndex == 1 then
			Window.Main.PreviousPageButton.Visible = false
		end
	end
end

function nextSetPage()
	if freeViewing == false then
		local newIndex = math.max(0, Data.Category[Data.CurrentCategory].Index + (Data.Main.InsertRows * Data.Main.InsertColumns))
		setSetIndex(newIndex)
	else
		freeIndex = freeIndex + 1
		local models
		if viewingModels then
			loadFreeSets(freeModels,"Models",currentSearchText)
			models = game:GetService("InsertService"):GetFreeModels(currentSearchText,freeIndex)
		else
			loadFreeSets(freeDecals,"Decals",currentSearchText)
			models = game:GetService("InsertService"):GetFreeDecals(currentSearchText,freeIndex)
		end
		local totalCount = 21

		for ndx,catinfo in ipairs( models ) do 
			for k,v in pairs(catinfo) do 
				if k == "TotalCount" then totalCount = v end
			end 
		end

		-- we've reach the end if true
		if tonumber(totalCount) < 21 then
			Window.Main.NextPageButton.Visible = false
		end

		Window.Main.PreviousPageButton.Visible = true
	end
end

function setSetIndex(dataOffset)
	Data.Category[Data.CurrentCategory].Index = dataOffset

	local PageSize = Data.Main.InsertRows*Data.Main.InsertColumns 
	local contents = Data.Category[Data.CurrentCategory].Contents
	if contents then
		for index = 1, PageSize do
			if Data.InsertButtons[index] then
				if contents[index + dataOffset] then

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
		Window.Main.PreviousPageButton.Visible = dataOffset > 1
		Window.Main.NextPageButton.Visible = ((dataOffset - 1) + PageSize) < (#contents)
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
	else
		Window.Main.PreviousSetButton.Visible = false
		Window.Main.NextSetButton.Visible = false

		for key, buttonFrame in pairs(Data.CurrentCategory) do
			buttonFrame.Size = UDim2.new(1.0, 0, 0.0, height*2)
			buttonFrame.Position = UDim2.new(0.0, 0, 0.0, height*2*(key-1))
			buttonFrame.Visible = true
		end

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
	if buttonFrame and Data.Category[Data.CurrentCategory] ~= nil then
		if buttonFrame.Button ~= Data.Category[Data.CurrentCategory].Button or type(setId) ~= "number"  then
			
			Data.Category[Data.CurrentCategory].Button = buttonFrame.Button
		
			Data.Category[Data.CurrentCategory].Contents = setId

			if type(setId) == "number" then
				SetCache[setId] = filterSet(game:GetService("InsertService"):GetCollection(setId))
				Data.Category[Data.CurrentCategory].Contents = SetCache[setId]
			end
			
			Window.Main.Title.Text = setName
			print(setName)

			Data.Category[Data.CurrentCategory].SetName = setName
			Data.Category[Data.CurrentCategory].SetId = setId
			Data.Category[Data.CurrentCategory].ButtonFrame = buttonFrame
		end

		setSetIndex (setIndex)
	end
end

function selectCategory(button, category)

	selectCategoryPage(category, 0)

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

function loadFreeSets(button,type,search)
	
	local stuff
	if type == "Models" then
		stuff = game:GetService("InsertService"):GetFreeModels(search,freeIndex)
	elseif type == "Decals" then
		stuff = game:GetService("InsertService"):GetFreeDecals(search,freeIndex)
	end

	for ndx,catinfo in ipairs( stuff ) do 
		for k,v in pairs(catinfo) do 
			if k == "Results" then
				selectSet(button, button.Button.Text, v, 0)
				return
			end
		end 
	end

end

function createDropDownMenu(parent, Window)

	local width = 1.1
	local xPos = 0.055

	local dropDownMenu = Instance.new("ImageButton")
	dropDownMenu.Name = "DropDownMenu"
	dropDownMenu.Image = "http://www.roblox.com/asset/?id=36361347"
	dropDownMenu.BackgroundTransparency = 1
	dropDownMenu.AutoButtonColor = false
	dropDownMenu.Size = UDim2.new(width,0,0.06,0)
	dropDownMenu.Position = UDim2.new(xPos,0,0.09,0)
	dropDownMenu.Parent = parent
	dropDownMenu.ZIndex = 2
	
	local droppedDownMenu = Instance.new("ImageLabel")
	droppedDownMenu.Name = "List"
	droppedDownMenu.Image = "http://www.roblox.com/asset/?id=36361705"
	droppedDownMenu.BackgroundTransparency = 1
	droppedDownMenu.Visible = false
	droppedDownMenu.Active = false
	droppedDownMenu.Position = UDim2.new(xPos,0,0.085,0)
	droppedDownMenu.Size = UDim2.new(width,0,1,0)
	droppedDownMenu.Parent = dropDownMenu.Parent
	droppedDownMenu.ZIndex = 3
	
	local titleFrame = Instance.new("TextLabel")
	titleFrame.Name = "Title"
	titleFrame.Position = UDim2.new(0.05, 0, 0, 0)
	titleFrame.Size = UDim2.new(0.86, 0, 1, 0)
	titleFrame.TextWrap = true
	titleFrame.BackgroundColor3 = titleColor
	titleFrame.TextColor3 = titleTextColor
	titleFrame.BackgroundTransparency = 1
	titleFrame.Text = "Change me"
	titleFrame.ZIndex = 3
	titleFrame.TextXAlignment = 0
	titleFrame.Parent = dropDownMenu
	Window.Main.Title = titleFrame

	local textButton = Instance.new("TextButton")
	textButton.Name = "Button"
	textButton.BackgroundTransparency = 1
	textButton.BorderSizePixel = 0
	textButton.Text = "Test"
	textButton.Size = UDim2.new(1,0,1,0)
	textButton.TextXAlignment = 2
	textButton.TextWrap = true
	textButton.ZIndex = 5

	local buttonFrame = Instance.new("ImageLabel")
	buttonFrame.Image = "http://www.roblox.com/asset/?id=36361705"
	buttonFrame.ZIndex = 4
	buttonFrame.BackgroundTransparency = 1
	
	textButton.Parent = buttonFrame

	local categories =  #Data.BaseCategoryButtons
	local robloxMaxCat = categories
	categories = categories + #Data.UserCategoryButtons

	local spacing = 0.1
	buttonFrame.Size = UDim2.new(0.9,0,(1 -  spacing)/(categories + 2),0) 


	-- make sure buttons are big enough
	local testButton = buttonFrame:clone()
	testButton.Parent = droppedDownMenu
--[[	local tryCount = 0
	while testButton.AbsoluteSize.Y < minYSize and tryCount < 100 do
		droppedDownMenu.Size = UDim2.new(width,0,droppedDownMenu.Size.Y.Scale + 0.01,0)
		tryCount = tryCount + 1
	end]]
	testButton:remove()
	testButton = nil


	local masterCategory = 1
	print(categories)
	for i = 1, categories do
		-- needed to maintain local scope for categories in event listeners below
		local userCategory = masterCategory
		local button = buttonFrame:clone()
		button.Position = UDim2.new(0.05,0,(i - 1)/(categories + 2),0)
		button.Parent = droppedDownMenu
		if i <= robloxMaxCat then
			button.Button.Text = "Roblox Set: " .. tostring(Data.BaseCategoryButtons[i].SetName.Value)
		else
			button.Button.Text =  tostring(Data.UserCategoryButtons[userCategory].SetName.Value)
		end


		button.Button.MouseButton1Click:connect(function()
			freeViewing = false
			titleFrame.Text = button.Button.Text
			parent.InsertTab.SearchFrame.Visible = false
			if i <= robloxMaxCat then
				selectSet(button, button.Button.Text, Data.BaseCategoryButtons[i].SetId.Value, 0)
			else
				selectSet(button, button.Button.Text, Data.UserCategoryButtons[userCategory].SetId.Value, 0)
			end
			dropDownSelected = not dropDownSelected
			if not dropDownSelected then
				dropDownMenu.Image = "http://www.roblox.com/asset/?id=36361347"
			else
				dropDownMenu.Image = "http://www.roblox.com/asset/?id=36701740"
			end
			droppedDownMenu.Visible = not droppedDownMenu.Visible
			droppedDownMenu.Active = not droppedDownMenu.Active
			highlight = true
		end)
		if i > robloxMaxCat then masterCategory = masterCategory + 1 end
	end

	freeModels = buttonFrame:clone()
	freeModels.Position = UDim2.new(0.05,0,categories/(categories +2),0)
	freeModels.Button.Text = "Free Models"
	freeModels.Parent = droppedDownMenu
	freeModels.Button.MouseButton1Click:connect(function()
		freeViewing = true
		viewingModels = true
		freeIndex = 1
		titleFrame.Text = freeModels.Button.Text
		loadFreeSets(freeModels,"Models","")
		parent.InsertTab.SearchFrame.Visible = true
		--dropDownMenu.Visible = not dropDownMenu.Visible
		dropDownSelected = not dropDownSelected
		if not dropDownSelected then
			dropDownMenu.Image = "http://www.roblox.com/asset/?id=36361347"
		else
			dropDownMenu.Image = "http://www.roblox.com/asset/?id=36701740"
		end
		droppedDownMenu.Visible = not droppedDownMenu.Visible
		droppedDownMenu.Active = not droppedDownMenu.Active
		highlight = true
	end)

	freeDecals = buttonFrame:clone()
	freeDecals.Position = UDim2.new(0.05,0,(categories + 1)/(categories +2),0)
	freeDecals.Button.Text = "Free Decals"
	freeDecals.Parent = droppedDownMenu
	freeDecals.Button.MouseButton1Click:connect(function()
		freeViewing = true
		viewingModels = false
		freeIndex = 1
		titleFrame.Text = freeDecals.Button.Text
		loadFreeSets(freeDecals,"Decals","")
		parent.InsertTab.SearchFrame.Visible = true
		--dropDownMenu.Visible = not dropDownMenu.Visible
		dropDownSelected = not dropDownSelected
		if not dropDownSelected then
			dropDownMenu.Image = "http://www.roblox.com/asset/?id=36361347"
		else
			dropDownMenu.Image = "http://www.roblox.com/asset/?id=36701740"
		end

		droppedDownMenu.Visible = not droppedDownMenu.Visible
		droppedDownMenu.Active = not droppedDownMenu.Active
		highlight = true
	end)
	

	dropDownMenu.MouseButton1Click:connect(function()
		Window.Main.RolloverText.Text = ""
		--dropDownMenu.Visible = not dropDownMenu.Visible
		dropDownSelected = not dropDownSelected
		if not dropDownSelected then
			dropDownMenu.Image = "http://www.roblox.com/asset/?id=36361347"
		else
			dropDownMenu.Image = "http://www.roblox.com/asset/?id=36701740"
		end

		droppedDownMenu.Visible = not droppedDownMenu.Visible
		droppedDownMenu.Active = not droppedDownMenu.Active
		highlight = false
	end)

	-- set first category as loaded for default
	print("got here")
	local buttons = droppedDownMenu:GetChildren()
	selectSet(buttons[1], buttons[1].Button.Text, Data.BaseCategoryButtons[1].SetId.Value, 0)
	selectCategory(buttons[1], Data.BaseCategoryButtons)
	Window.Main.Title.Text = "Roblox Set: " ..  tostring(Data.BaseCategoryButtons[1].SetName.Value)

end

function buildMainGui(root, userId)
	Window.Main = {}
	Data.Main = {}
	Data.Category = {}
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "InsertMainDialog"
	mainFrame.Position = UDim2.new(0.0, 0, 0, 0)
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Transparency = 1.0
	mainFrame.Active = true
	mainFrame.Parent = root
	Window.Main.Frame = mainFrame

	local insertTab = Instance.new("Frame")
	insertTab.Name = "InsertTab"
	insertTab.Position = UDim2.new(0, 0, 0.0, 0)
	insertTab.Size = UDim2.new(1, 0, 1.0, 0)
	insertTab.BackgroundTransparency = 1.0
	insertTab.Parent = mainFrame

	local searchFrame = Instance.new("Frame")
	searchFrame.Name = "SearchFrame"
	searchFrame.Size = UDim2.new(1,0,0.1,0)
	searchFrame.Position = UDim2.new(0.12,0,1.11,0)
	searchFrame.BackgroundTransparency = 1
	searchFrame.Visible = false
	searchFrame.Parent = insertTab
	
	local searchGraphicBox = Instance.new("ImageLabel")
	searchGraphicBox.Image = "http://www.roblox.com/asset/?id=36337274"
	searchGraphicBox.Name = "SearchGraphicBox"
	searchGraphicBox.BackgroundTransparency = 1
	searchGraphicBox.Size = UDim2.new(0.7,0,1,0)
	searchGraphicBox.Parent = searchFrame

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Text = "Enter Text Here"
	searchBox.TextWrap = true
	searchBox.TextColor = BrickColor.White()
	searchBox.BackgroundTransparency = 1
	searchBox.Size = UDim2.new(1,0,1,0)
	searchBox.Parent = searchGraphicBox

	local searchButton = Instance.new("ImageButton")
	searchButton.Name = "SearchButton"
	searchButton.Image = "http://www.roblox.com/asset/?id=37272267"
	searchButton.BackgroundTransparency = 1
	searchButton.AutoButtonColor = false
	searchButton.Size = UDim2.new(0.4,0,1,0)
	searchButton.Position = UDim2.new(0.71,0,0)
	searchButton.Parent = searchFrame

	searchButton.MouseButton1Down:connect(function() 
		currentSearchText = searchBox.Text
		freeIndex = 1
		if viewingModels then
			loadFreeSets(freeModels,"Models",searchBox.Text)
		else
			loadFreeSets(freeDecals,"Decals",searchBox.Text)
		end
	end)

	
	Data.BaseCategoryButtons = processCategory(game:GetService("InsertService"):GetBaseCategories(), setPanel)
	local userData = game:GetService("InsertService"):GetUserCategories(userId)
	if userData then
		Data.UserCategoryButtons = processCategory(userData, setPanel)
	end

	local insertPanel = Instance.new("ImageLabel")
	insertPanel.Name = "InsertPanel"
	insertPanel.Image = "http://www.roblox.com/asset/?id=36337274"
	insertPanel.Position = UDim2.new(0.0, 0, 0.0, 0)
	insertPanel.Size = UDim2.new(1.2, 0, 1.1, 0)
	insertPanel.BackgroundTransparency = 1
	insertPanel.Parent = insertTab

	local insertButtons = {}
	for y = 1, InsertRows do
		for x = 1, InsertColumns do
			insertButtons[x  + (y - 1) * InsertColumns] = buildInsertButton(UDim2.new(.3*(x-1) + 0.05, 0, 0.11*(y-1) + 0.15, 0), UDim2.new(.32, -4, .12, -4))
			insertButtons[x  + (y - 1) * InsertColumns].Parent = insertPanel
		end
	end	

	Data.InsertButtons = insertButtons
	Data.Main.InsertRows = InsertRows
	Data.Main.InsertColumns = InsertColumns

	local footerPanel = Instance.new("Frame")
	footerPanel.Name = "Footer"
	footerPanel.Size = UDim2.new(1.0, 0, 0.06, 0)
	footerPanel.Position = UDim2.new(0.0, 0, 1.03, 0)
	footerPanel.BackgroundTransparency = 1
	footerPanel.BackgroundColor3 = frameColor
	footerPanel.Parent = insertTab
	
	local rolloverText = Instance.new("TextLabel")
	rolloverText.Name = "RolloverText"
	rolloverText.Size = UDim2.new(0.8, 0, 1.0, 0)
	rolloverText.Position = UDim2.new(0.2, 0, 0.0, 0)
	rolloverText.TextColor = BrickColor.White()
	rolloverText.BackgroundColor3 = frameColor
	rolloverText.BackgroundTransparency = 1
	rolloverText.Text = ""
	rolloverText.TextWrap = true
	rolloverTextXAlignment = 2
	rolloverText.Parent = footerPanel
	Window.Main.RolloverText = rolloverText

	local previousButton = Instance.new("ImageButton")
	previousButton.Image = "http://www.roblox.com/asset/?id=36340011"
	previousButton.Name = "PreviousPageButton"
	previousButton.Size = UDim2.new(0.1, 0, 1.0, 0)
	previousButton.Position = UDim2.new(0.1, 0, 0.0, 0)
	previousButton.BackgroundColor3 = buttonColor
	previousButton.AutoButtonColor = false
	previousButton.BackgroundTransparency = 1

	previousButton.MouseButton1Click:connect(previousSetPage)
	previousButton.Parent = footerPanel
	previousButton.Visible = false
	Window.Main.PreviousPageButton = previousButton

	local nextButton = Instance.new("ImageButton")
	nextButton.Image = "http://www.roblox.com/asset/?id=36339978"
	nextButton.Name = "NextPageButton"
	nextButton.Size = UDim2.new(0.1, 0, 1.0, 0)
	nextButton.Position = UDim2.new(1, 0, 0.0, 0)
	nextButton.AutoButtonColor = false
	nextButton.BackgroundTransparency = 1

	nextButton.MouseButton1Click:connect(nextSetPage)
	nextButton.Parent = footerPanel
	nextButton.Visible = false
	Window.Main.NextPageButton = nextButton

	createDropDownMenu(mainFrame, Window)

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

function moveLoadingWindow()
	local speed = 0.005
	while Window.Loading.Frame.Visible do
		while Window.Loading.Frame.Visible and Window.Loading.Frame.Position.Y.Scale < (1 - Window.Loading.Frame.Size.Y.Scale) do
			Window.Loading.Frame.Position = UDim2.new(Window.Loading.Frame.Position.X.Scale,Window.Loading.Frame.Position.X.Offset,Window.Loading.Frame.Position.Y.Scale + speed,Window.Loading.Frame.Position.Y.Offset)
			wait()
		end
		while Window.Loading.Frame.Visible and Window.Loading.Frame.Position.Y.Scale > 0 do
			Window.Loading.Frame.Position = UDim2.new(Window.Loading.Frame.Position.X.Scale,Window.Loading.Frame.Position.X.Offset,Window.Loading.Frame.Position.Y.Scale - speed,Window.Loading.Frame.Position.Y.Offset)
			wait()
		end
	end
end

function resetLoadingWindow()
	Window.Loading.Frame.Visible = false
	Window.Loading.Frame.Position = UDim2.new(0,0,0,0)
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
	local mover = coroutine.create(moveLoadingWindow)
	Window.Loading.Frame.Visible = true
	coroutine.resume(mover)
	Data.Loading.Cancelled = false

	--This call will cause a "wait" until the data comes back
	local id = math.random(5,500)
	print("loading id = " .. tostring(id))
	local root
	local loader
	loading = true
	if useAssetVersionId then
		loader = coroutine.create(function()	
			root = game:GetService("InsertService"):LoadAssetVersion(assetId)
			loading = false
		end)
		coroutine.resume(loader)
		--root = game:GetService("InsertService"):LoadAssetVersion(assetId)
	else
		loader = coroutine.create(function()	
			root = game:GetService("InsertService"):LoadAsset(assetId)
			loading = false
		end)
		coroutine.resume(loader)
		--root = game:GetService("InsertService"):LoadAsset(assetId)
	end
	local count = 0
	while loading and count < 5 do
		count = count + 1
		wait(1)
	end
	loading = false

	if count >= 5 then
		print("failed loading id = " .. tostring(id))
	else
		print("finished loading id = " .. tostring(id))
	end

	if Data.Loading.Cancelled or count >=5 then
		--The user got bored and wandered off

		--Just delete the model from the world... a shame we loaded it when they got bored
		if root then
			root:Remove()
		end
		Window.Loading.Frame.Visible = false
		Window.Main.Frame.Visible = true
		return

	else		
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
				Window.Loading.Frame.Visible = false
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

		resetLoadingWindow()
		print("done loading?")

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

	local dialogFrame = Instance.new("ImageLabel")
	dialogFrame.Image = "http://www.roblox.com/asset/?id=36269485"
	dialogFrame.Name = "InsertLoadingDialog"
	dialogFrame.Size = UDim2.new(1.6, 0, 0.3, 0)
	dialogFrame.Position = UDim2.new(0.0, 0, 0, 0)
	dialogFrame.BackgroundTransparency = 1
	dialogFrame.Active = true
	dialogFrame.Parent = root
	dialogFrame.Visible = false
	Window.Loading.Frame = dialogFrame

	local assetBacking = Instance.new("ImageLabel")
	assetBacking.Image = "http://www.roblox.com/asset/?id=36426105"
	assetBacking.BackgroundTransparency = 1
	assetBacking.ZIndex = 1
	assetBacking.Size = UDim2.new(1,0,1,0)

	local assetThumb = Instance.new("ImageLabel")
	assetThumb.Position = UDim2.new(0.0, 2, 0.0, 2)
	assetThumb.Size = UDim2.new(0.5, -4, 1.0, -4)
	assetThumb.Parent = dialogFrame
	assetThumb.BackgroundTransparency = 1
	assetThumb.ZIndex = 2
	Window.Loading.AssetThumbLabel = assetThumb
	assetBacking.Parent = assetThumb

	local descriptionFrame = Instance.new("Frame")
	descriptionFrame.Name = "Description"
	descriptionFrame.Size = UDim2.new(0.5, 0, 1.0, 0)
	descriptionFrame.Position = UDim2.new(0.5, 0, 0.0, 0)
	descriptionFrame.Transparency = 1
	descriptionFrame.Parent = dialogFrame

	local label = Instance.new("TextLabel")
	label.Text = "Loading..."
	label.FontSize = 2
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
	cancelButton.Size = UDim2.new(1, 0, 0.180000007, 0)
	cancelButton.Position = UDim2.new(-0.0500000007, 0, 0.699999988, 0)
	cancelButton.BackgroundColor3 = Color3.new(1,0.2,0.2)
	cancelButton.TextColor = BrickColor.White()
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

function buildStampDialogGui(root)

	Window.Stamp = {}
	Data.Stamp = {}

	local dialogFrame = Instance.new("ImageLabel")
	dialogFrame.Image = "http://www.roblox.com/asset/?id=36269485"
	dialogFrame.Name = "InsertStampDialog"
	dialogFrame.Size = UDim2.new(1.6, 0, 0.3, 0)
	dialogFrame.Position = UDim2.new(0.0, 0, 0.7, 0)
	dialogFrame.BackgroundTransparency = 1
	dialogFrame.Active = true
	dialogFrame.Parent = root
	dialogFrame.Visible = false
	Window.Stamp.Frame = dialogFrame

	local assetBacking = Instance.new("ImageLabel")
	assetBacking.Image = "http://www.roblox.com/asset/?id=36426105"
	assetBacking.BackgroundTransparency = 1
	assetBacking.ZIndex = 1
	assetBacking.Size = UDim2.new(1,0,1,0)

	local assetThumb = Instance.new("ImageLabel")
	assetThumb.Position = UDim2.new(0.0, 2, 0.0, 2)
	assetThumb.Size = UDim2.new(0.5, -4, 1.0, -4)
	assetThumb.Parent = dialogFrame
	assetThumb.BackgroundTransparency = 1
	assetThumb.ZIndex = 2
	Window.Stamp.AssetThumbLabel = assetThumb

	assetBacking.Parent = assetThumb

	local descriptionFrame = Instance.new("Frame")
	descriptionFrame.Name = "Description"
	descriptionFrame.Size = UDim2.new(0.5, 0, 1.0, 0)
	descriptionFrame.Position = UDim2.new(0.5, 0, 0.0, 0)
	descriptionFrame.Transparency = 1
	descriptionFrame.Parent = dialogFrame

	local assetLabel = Instance.new("TextLabel")
	assetLabel.Text = "Your Asset Here"
	assetLabel.Position = UDim2.new(-0.05, 0, 0.25, 0)
	assetLabel.Size = UDim2.new(1.0, 0, 0.4, 0)
	assetLabel.BorderSizePixel = 0
	assetLabel.BackgroundTransparency = 1.0
	assetLabel.Parent = descriptionFrame
	assetLabel.TextColor3 = frameTextColor
	assetLabel.TextWrap = true
	Window.Stamp.AssetNameLabel = assetLabel

	local readyFrame = Instance.new("Frame")
	readyFrame.Name = "ReadyDialogue"
	readyFrame.Size = UDim2.new(0.47, 0, 0.2, 0)
	readyFrame.Position = UDim2.new(0.5, 0, 0.05, 0)
	readyFrame.Transparency = 1
	readyFrame.Parent = dialogFrame

	local label = Instance.new("TextLabel")
	label.Text = "Ready to Place"
	label.FontSize = 2
	label.TextWrap = true
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor = BrickColor.White()
	label.Parent = readyFrame

	local cancelButton = Instance.new("TextButton")
	cancelButton.Name = "CancelButton"
	cancelButton.Size = UDim2.new(1, 0, 0.180000007, 0)
	cancelButton.Position = UDim2.new(-0.0500000007, 0, 0.699999988, 0)
	cancelButton.BackgroundColor3 = Color3.new(1,0.1,0.1)
	cancelButton.TextColor = BrickColor.White()
	cancelButton.TextWrap = true
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
		guiMain.Parent = insertGui

		Window.Stamp.Frame.Visible = false
		Window.Loading.Frame.Visible = false
		Window.Main.Frame.Visible = true

	else
		CancelDuringLoad = false

		insertGui = Instance.new("ScreenGui")
		insertGui.Name = "InsertGui"

		guiMain = Instance.new("Frame")
		guiMain.Size = UDim2.new(0,150,0,400)
		guiMain.Position = UDim2.new(0,0,1,-550)
		guiMain.BackgroundTransparency = 1
		guiMain.Name = "InsertToolboxMain"

		Window = {}
		Data = {}
		Data.FullyLoaded = false

		buildMainGui(guiMain, getPlayer().userId)
		buildLoadingDialogGui(guiMain)
		buildStampDialogGui(guiMain)

		if not(CancelDuringLoad) then
			insertGui.Parent = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
			guiMain.Parent = insertGui

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
	Mouse:remove()

	Tool.TextureId = origTexture

	guiMain.Parent = nil

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