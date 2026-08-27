-- This script is responsible for working the gui

-- basic functions
function waitForChild(instance, name)
	while not instance:findFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

function waitForProperty(instance, name)
	while not instance[name] do
		instance.Changed:wait()
	end
end


-- Locals
local Tool = script.Parent

waitForChild(Tool, "LuaGlobalVariables")
local variables = Tool.LuaGlobalVariables
waitForChild(variables, "InsertAsset")
local insertAsset = variables.InsertAsset
waitForChild(variables, "SwitchMode")
local switchMode = variables.SwitchMode
waitForChild(variables, "ShowAdminCategories")
local showAdminCategories = variables.ShowAdminCategories

waitForChild(variables, "ReloadCurrentAsset")
waitForChild(variables,"userIDs")

game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=42163425")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=42563487")

local BaseUrl = game:GetService("ContentProvider").BaseUrl

local buttonHeight = 64
local buttonWidth = buttonHeight

local waypointShowing = false
local showingPartPicker = true
local firstEquip = true

local Window
local Data
local loading = false

local startTime = 0

local SetCache = {}

local lastEnter = nil

-- For Restricting Stamper Tool
local buildingPlate
local partModel

-- wait for all of our set ids to load
local userIdsForStamperParts = variables.userIDs -- 7502714 This is UsabilityMan (on gametest)

function giveNewUserId(id)
	local newUserId = Instance.new("IntValue")
	newUserId.Name = "userID"
	newUserId.Value = id
	newUserId.Parent = userIdsForStamperParts
	userIdsForStamperParts.Value = userIdsForStamperParts.Value + 1
end

BaseUrl = BaseUrl:lower()

local isRestricted = Instance.new("BoolValue")
isRestricted.Name = "IsRestricted"
isRestricted.Value = false

function isLocalWTRB()
	waitForChild(game,"StarterGui")
	if game.StarterGui:FindFirstChild("VersionGui") then
		if game.StarterGui.VersionGui:FindFirstChild("VersionText", true) then
			return true
		end
	end
	return false
end

waitForProperty(game,"PlaceId")
if game.PlaceId == 41324860 or isLocalWTRB() then
	isRestricted.Value = true
end
isRestricted.Parent = variables

giveNewUserId(18881789)
giveNewUserId(18881808)
if not isRestricted.Value then
	giveNewUserId(18881829)
	giveNewUserId(18881853)
	giveNewUserId(18881866)
else
	giveNewUserId(2409156)
	giveNewUserId(19238067)
	giveNewUserId(19238114)
end

while #userIdsForStamperParts:GetChildren() < userIdsForStamperParts.Value do userIdsForStamperParts.ChildAdded:wait() end
userIdsForStamperParts = userIdsForStamperParts:GetChildren()

local useAssetVersionId = false
local LargeThumbnailUrl
local SmallThumbnailUrl

local InsertRows = 0
local InsertColumns = 0
local insertButtons = {}

local CancelDuringLoad

local prevPart = {AssetNameValue = "",AssetIdValue = 0 ,InsertFrameButtonImage = ""}
local recentPartStack = {}

-- Connection Managers
local guiChangedCon = nil
local cloneButtonCon = nil
local partListClickCon = nil
local itemFrameChangedCon = nil
local setsNextPageCon = nil
local setsPrevPageCon = nil
local insertPanelCloseCon = nil
local minimizeCon = nil
local restoreCon = nil
local setButtonCons = {}
local insertButtonCons = {}
local recentPartStackCons = {}

local Mouse = nil
local currSetPage = 1

local mode = 0 -- 0 = main dialog, 1 = stamper, 2 = eyedropper

waitForChild(script.Parent,"StampGUI")
local stamperGui = script.Parent.StampGUI
waitForChild(stamperGui,"InsertPanel")
waitForChild(stamperGui.InsertPanel, "CancelButton")
local currStampGui = nil

local maxRecentParts = 4
for i = 1, maxRecentParts do
	recentPartStack[i] = {AssetNameValue,AssetIdValue,InsertFrameButtonImage}
	recentPartStack[i].AssetNameValue = ""
	recentPartStack[i].AssetIdValue = ""
	recentPartStack[i].InsertFrameButtonImage = ""
end
----------------------------------------------------------------------------------------


-- functions
function showBaseplateGuideArrows()
	playerCharacter = Tool.Parent
	if playerCharacter:FindFirstChild("Humanoid") and not playerCharacter:FindFirstChild("BasePlateGuide") then
		newGuide = Tool.BasePlateGuide:Clone()
		newGuide.Parent = playerCharacter
		newGuide.Disabled = false
	end
end

function setAssetUrls()
	if useAssetVersionId then
		LargeThumbnailUrl = BaseUrl .. "Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&assetversionid="
		SmallThumbnailUrl = BaseUrl .. "Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=75&ht=75&assetversionid="
	else
		LargeThumbnailUrl = BaseUrl .. "Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid="
		SmallThumbnailUrl = BaseUrl .. "Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=75&ht=75&aid="
	end
end

function signalSwitchMode(mode)
	switchMode.Mode.Value = mode
	switchMode.Value = true
end

function goToClone()
	cancelLoadingWindow()
	closeInsertPanel()
	cancelAssetPlacement()

	mode = 2
	--signalStamperScript("",0,"","",false)
	signalSwitchMode("Clone")

	currStampGui.StamperPanel.StamperButtons.ClonePanel.Visible = true
	currStampGui.StamperPanel.StamperButtons.CloneButton.Selected = true
	if currStampGui.Parent ~= nil then
		currStampGui.StamperPanel.StamperButtons.ClonePanel:TweenPosition(UDim2.new(0, -88, 0, -8),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.35,true)
		delay(0.3,function() currStampGui.StamperPanel.StamperButtons.ClonePanel.ClonePanelText.Visible = true end)
	end
end

function goToStamp()
	mode = 1
	cancelLoadingWindow()
	closeInsertPanel()
	closeClonePanel()
end

function goToInsertPanel()
	cancelLoadingWindow()
	closeClonePanel()
	pcall(function() currStampGui.InsertPanel.CancelButton.Modal = true end)
	currStampGui.StamperPanel.StamperButtons.PartsButton.Selected = true

	if not showingPartPicker then
		showingPartPicker = true
		if currStampGui.Parent ~= nil then
			currStampGui.InsertPanel:TweenPosition(UDim2.new(0.2, 2, 0.1, 24),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.35,true)
		end
	else
		closeInsertPanel()
		reloadCurrentAsset()
	end
end

function closeInsertPanel()
	pcall(function() currStampGui.InsertPanel.CancelButton.Modal = false end)
	currStampGui.StamperPanel.StamperButtons.PartsButton.Selected = false

	showingPartPicker = false
	if currStampGui.Parent ~= nil then
		currStampGui.InsertPanel:TweenPosition(UDim2.new(0.2, 2, 1, 24),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.35,true)
	end
end

function closeClonePanel()
	currStampGui.StamperPanel.StamperButtons.ClonePanel.ClonePanelText.Visible = false
	currStampGui.StamperPanel.StamperButtons.CloneButton.Selected = false
	if currStampGui.Parent ~= nil then
		currStampGui.StamperPanel.StamperButtons.ClonePanel:TweenPosition(UDim2.new(0, 0, 0, -8),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.35,true)
		delay(0.3,function() currStampGui.StamperPanel.StamperButtons.ClonePanel.Visible = false end)
	end
end

function cancelAssetPlacement()
	gInitial90DegreeRotations = 0
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

	if Mouse then
		Mouse.Icon ="rbxasset://textures\\ArrowCursor.png"
	end
	game.JointsService:ClearJoinAfterMoveJoints()

end

function hint(label)

	-- Pass in a string, it shows a top hint.  (Replaces previous hint, if exists)
	_player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if(_player.PlayerGui:FindFirstChild("topHint")~=nil) then
		local topHint = _player.PlayerGui.topHint
		topHint.Add.Label.Value = label
		topHint.Add.Width.Value = 3 -- widest width
		topHint.Add.Time.Value = 5
		topHint.Add.Disabled = true
		topHint.Add.Disabled = false
	end

end

function getPlayer()
	return game.Players:GetPlayerFromCharacter(script.Parent.Parent)
end

function getHumanoid()
	local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	if player then
		waitForProperty(player,"Character")
		waitForChild(player.Character,"Humanoid")
		return player.Character.Humanoid
	else
		return nil
	end
end

function buildSetButton(name, setId, setImageId, i,  count)

	local button = currStampGui.InsertPanel.Sets.SetsLists.SetButtonExample:Clone()
	button.Text = name
	button.Name = "SetButton"
	button.Visible = true

	local setValue = Instance.new("IntValue")
	setValue.Name = "SetId"
	setValue.Value = setId
	setValue.Parent = button

	local setName = Instance.new("StringValue")
	setName.Name = "SetName"
	setName.Value = name
	setName.Parent = button

	return button
end


function previousSetPage()
	local newIndex = math.max(0, Data.Category[Data.CurrentCategory].Index - (InsertRows * InsertColumns))
	setSetIndex(newIndex)
end


function nextSetPage()
	local newIndex = math.max(0, Data.Category[Data.CurrentCategory].Index + (InsertRows * InsertColumns))
	setSetIndex(newIndex)
end

function setInsertButtonImageBehavior(insertFrame, visible, name, assetId)
	if visible then
		insertFrame.AssetName.Value = name
		insertFrame.AssetId.Value = assetId
		local newImageUrl = SmallThumbnailUrl  .. assetId
		if newImageUrl ~= insertFrame.Button.ButtonImage.Image then
			delay(0,function()
				game:GetService("ContentProvider"):Preload(SmallThumbnailUrl  .. assetId)
				insertFrame.Button.ButtonImage.Image = SmallThumbnailUrl  .. assetId
			end)
		end
		table.insert(insertButtonCons,
			insertFrame.Button.MouseButton1Click:connect(function()
				beginInsertAssetGui(insertFrame.AssetName.Value, insertFrame.AssetId.Value, insertFrame.Button.ButtonImage.Image, 1)
			end)
		)
		insertFrame.Visible = true
	else
		insertFrame.Visible = false
	end
end

function setSetIndex(dataOffset)

	Data.Category[Data.CurrentCategory].Index = dataOffset

	InsertRows = math.floor(currStampGui.InsertPanel.ItemsFrame.AbsoluteSize.Y/buttonHeight)
	InsertColumns = math.floor(currStampGui.InsertPanel.ItemsFrame.AbsoluteSize.X/buttonWidth)

	local PageSize = InsertRows * InsertColumns
	local contents = Data.Category[Data.CurrentCategory].Contents
	if contents then
		
		local numOfPages = math.ceil((#contents)/(PageSize))
		local currPage = math.ceil((dataOffset/PageSize) + 1)
		currStampGui.InsertPanel.PagingControls.PageText.Text = tostring(currPage) .. "/" .. tostring(numOfPages)
		currStampGui.InsertPanel.PagingControls.PageText.Visible = (numOfPages > 1)

      currStampGui.InsertPanel.PagingControls.PreviousPageButton.Visible = (numOfPages > 1) and dataOffset > 1
		currStampGui.InsertPanel.PagingControls.NextPageButton.Visible = (numOfPages > 1) and ((dataOffset - 1) + PageSize) < (#contents)

		-- remove our buttons and their connections
		for i = 1, #insertButtons do
			insertButtons[i]:remove()
		end
		for i = 1, #insertButtonCons do
			pcall(function() insertButtonCons[i]:disconnect() end)
		end

		insertButtonCons = {}
		insertButtons = {}
		local arrayPosition = 1
		for y = 1, InsertRows do
			for x = 1, InsertColumns do
				local buttonPosition = UDim2.new(0,(buttonWidth)*(x-1),0, (buttonHeight)*(y-1))

				local buttonCon
				insertButtons[arrayPosition], buttonCon = buildInsertButton(buttonPosition)
				table.insert(insertButtonCons,buttonCon)
				insertButtons[arrayPosition].Parent = currStampGui.InsertPanel.ItemsFrame
				arrayPosition = arrayPosition + 1
			end
		end

		Data.InsertButtons = insertButtons

		for index = 1, PageSize do
			if insertButtons[index] then
				if contents[index + dataOffset] then
					local assetId
					if useAssetVersionId then
						assetId = contents[index + dataOffset].AssetVersionId
					else
						assetId = contents[index + dataOffset].AssetId
					end
					setInsertButtonImageBehavior(insertButtons[index], true, contents[index + dataOffset].Name, assetId)
				else
					setInsertButtonImageBehavior(insertButtons[index], false)
				end
			end
		end
	else
		currStampGui.InsertPanel.PagingControls.PreviousPageButton.Visible = false
		currStampGui.InsertPanel.PagingControls.NextPageButton.Visible = false
	end

end

function moveLoadingLeft()
	if (tick() - startTime > 5) and (currStampGui.Parent ~= nil) then
		loading = false
		cancelAssetPlacement()
		goToInsertPanel()
	end
	if loading then
		currStampGui.LoadDialog.LoadLabel:TweenPosition(UDim2.new(0, 0, 0, -8),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.7,true,function() moveLoadingRight() end)
	end
end

function moveLoadingRight()
	if (tick() - startTime > 5) and (currStampGui.Parent ~= nil) then
		loading = false
		cancelAssetPlacement()
		goToInsertPanel()
	end
	if loading then
		currStampGui.LoadDialog.LoadLabel:TweenPosition(UDim2.new(0, 180, 0, -8),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.7,true,function() moveLoadingLeft() end)
	end
end

function moveLoadingWindow()
	startTime = tick()
	currStampGui.LoadDialog.Visible = true
	loading = true
	moveLoadingRight()
end

function cancelLoadingWindow()
	currStampGui.LoadDialog.Visible = false
	loading = false
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

function selectSet(button, setName, setId, setIndex)

	if button and Data.Category[Data.CurrentCategory] ~= nil then
		if button ~= Data.Category[Data.CurrentCategory].Button then
			Data.Category[Data.CurrentCategory].Button = button

			if SetCache[setId] == nil then
				SetCache[setId] = game:GetService("InsertService"):GetCollection(setId)
			end
			Data.Category[Data.CurrentCategory].Contents = SetCache[setId]

			Data.Category[Data.CurrentCategory].SetName = setName
			Data.Category[Data.CurrentCategory].SetId = setId
		end
		setSetIndex(setIndex)
	end

end


function selectCategory(button, category)
	selectCategoryPage(category, 0)
end


function processCategory(sets, setPanel)
	local setButtons = {}
	local numSkipped = 0
	for index, object in pairs(sets) do
		if not showAdminCategories.Value and object.Name == "Beta" then
			-- skip this if not an admin
			numSkipped = numSkipped + 1
		else
			setButtons[index - numSkipped] = buildSetButton(object.Name, object.CategoryId, object.ImageAssetId, index - numSkipped, #sets)
			setButtons[index - numSkipped].Parent = setPanel
		end
	end
	return setButtons
end


function setsNextPageClick(totalSetPages, gridSize)
	-- set our logic/gui correctly
	if currSetPage >= totalSetPages then return end

	currSetPage = currSetPage + 1
	currStampGui.InsertPanel.PagingControls.PageText.Text = tostring(currSetPage) .. "/" .. tostring(totalSetPages)
	if currSetPage == totalSetPages then
		currStampGui.InsertPanel.PagingControls.NextPageButton.Visible = false
		currStampGui.InsertPanel.PagingControls.PreviousPageButton.Visible = true
	else
		Window.Sets.PagingControls.NextPageButton.Visible = true
	end
	
	-- actually update the items
	makeCurrentSetsPageVisible(gridSize)
end

function setsPrevPageClick(totalSetPages, gridSize)
	-- set our logic/gui correctly
	if currSetPage <= 1 then return end

	currSetPage = currSetPage - 1
	currStampGui.InsertPanel.PagingControls.PageText.Text = tostring(currSetPage) .. "/" .. tostring(totalSetPages)
	if currSetPage == 1 then
		currStampGui.InsertPanel.PagingControls.NextPageButton.Visible = true
		currStampGui.InsertPanel.PagingControls.PreviousPageButton.Visible = false
	else
		currStampGui.InsertPanel.PagingControls.PreviousPageButton.Visible = true
	end

	-- actually update the items
	makeCurrentSetsPageVisible(gridSize)
end

function resetAllSetButtonSelection()
	local setButtons = Window.Sets.SetsLists:GetChildren()
	for i = 1, #setButtons do
		setButtons[i].Selected = false
		setButtons[i].BackgroundTransparency = 1
		setButtons[i].TextColor3 = Color3.new(1,1,1)
		setButtons[i].BackgroundColor3 = Color3.new(1,1,1)
	end
end

function populateSetsFrame()
	local categories = #Data.UserCategoryButtons
	local robloxMaxCat = categories
	
	-- don't do anything until window is visible (otherwise we won't layout anything!)
	while Window.Sets.SetsLists.AbsoluteSize.X <= 0 do
		Window.Sets.SetsLists.Changed:wait()
	end
	while Window.Sets.SetsLists.SetButtonExample.AbsoluteSize.X <= 0 do
		Window.Sets.SetsLists.SetButtonExample.Changed:wait()
	end

	local totalColumns = math.floor(Window.Sets.SetsLists.AbsoluteSize.X/Window.Sets.SetsLists.SetButtonExample.AbsoluteSize.X)
	local totalRows = math.floor(Window.Sets.SetsLists.AbsoluteSize.Y/Window.Sets.SetsLists.SetButtonExample.AbsoluteSize.Y)
	
	local currRow = 0
	local buttonVisible = true

	local masterCategory = 1
	for i = 1, categories do
		local userCategory = masterCategory -- needed to maintain local scope for categories in event listeners below
		local button = Window.Sets.SetsLists.SetButtonExample:clone()

		button.Name = "Set" .. tostring(Data.UserCategoryButtons[userCategory].SetName.Value) .. "Button"
		button.Parent = Window.Sets.SetsLists
		button.Position = UDim2.new(0,5,0,currRow * button.AbsoluteSize.Y)
		button.Visible = buttonVisible
		button.Text =  tostring(Data.UserCategoryButtons[userCategory].SetName.Value)

		if i == 1 then
			button.Selected = true
			button.BackgroundColor3 = Color3.new(0,204/255,0)
			button.TextColor3 = Color3.new(0,0,0)
			button.BackgroundTransparency = 0
		end

		button.MouseEnter:connect(function()
			if not button.Selected then
				button.BackgroundTransparency = 0
				button.TextColor3 = Color3.new(0,0,0)
			end
		end)
		button.MouseLeave:connect(function()
			if not button.Selected then
				button.BackgroundTransparency = 1
				button.TextColor3 = Color3.new(1,1,1)
			end
		end)
		setButtonCons[i] = button.MouseButton1Click:connect(function()
			resetAllSetButtonSelection()
			button.Selected = not button.Selected
			button.BackgroundColor3 = Color3.new(0,204/255,0)
			button.TextColor3 = Color3.new(0,0,0)
			button.BackgroundTransparency = 0

			selectSet(button, button.Text, Data.UserCategoryButtons[userCategory].SetId.Value, 0)
		end)
		
		masterCategory = masterCategory + 1

		currRow = currRow + 1
	end
	
	-- don't use example button as the first set!
	local example = currStampGui.InsertPanel.Sets.SetsLists.SetButtonExample
	currStampGui.InsertPanel.Sets.SetsLists.SetButtonExample.Parent = nil
	local buttons =  currStampGui.InsertPanel.Sets.SetsLists:GetChildren()
	example.Parent = currStampGui.InsertPanel.Sets.SetsLists

	-- set first category as loaded for default
	selectSet(buttons[1], buttons[1].Text, Data.UserCategoryButtons[1].SetId.Value, 0)
	selectCategory(buttons[1], Data.UserCategoryButtons)
end


function layoutSetButtons(frameHeight, setIndex)
	Data.Main.FrameHeight = frameHeight
	Data.Main.InsertSets = math.floor(frameHeight / (height*2))
	if #Data.CurrentCategory > Data.Main.InsertSets then
		--Steal one entry since we have too many things
		Data.Main.InsertSets = Data.Main.InsertSets - 1
	end

	Data.Category[Data.CurrentCategory].SetIndex = setIndex
end


function showLargePreview(insertButton)
	if insertButton:FindFirstChild("AssetId") then
		delay(0,function()
			game:GetService("ContentProvider"):Preload(LargeThumbnailUrl .. tostring(insertButton.AssetId.Value))
			currStampGui.InsertPanel.ItemPreview.LargePreview.Image = LargeThumbnailUrl .. tostring(insertButton.AssetId.Value)
		end)
	end
	if insertButton:FindFirstChild("AssetName") then
		currStampGui.InsertPanel.ItemPreview.TextPanel.RolloverText.Text = insertButton.AssetName.Value
	end
end


function buildInsertButton(buttonPosition)
	local insertButton = currStampGui.InsertPanel.ItemsFrame.InsertAssetButtonExample:clone()
	insertButton.Position = buttonPosition
	insertButton.Name = "InsertAssetButton"
	insertButton.Visible = true

	local mouseEnterCon = insertButton.MouseEnter:connect(function()
		lastEnter = insertButton
		delay(0.1,function()
			if lastEnter == insertButton then
				showLargePreview(insertButton)
			end
		end)
	end)
	return insertButton, mouseEnterCon
end

function minimizeStamperPanel()
	currStampGui.StamperPanel.StamperButtons.Visible = false
	currStampGui.StamperPanel.MinimizeButton.Visible = false
	if currStampGui.Parent ~= nil then
		currStampGui.StamperPanel:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,1,-92),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.5,true)
		delay(0.5,function()
			currStampGui.StamperPanel.RestoreButton.Visible = true
		end)
	end
end

function restoreStamperPanel()
	currStampGui.StamperPanel.RestoreButton.Visible = false
	if currStampGui.Parent ~= nil then
		currStampGui.StamperPanel:TweenSizeAndPosition(UDim2.new(0,350,0,48), UDim2.new(0.5,-175,1,-135), Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.5,true)
		delay(0.5,function()
			currStampGui.StamperPanel.StamperButtons.Visible = true
			currStampGui.StamperPanel.MinimizeButton.Visible = true
		end)
	end
end

function setUpStamperGui()
	pcall(function() currStampGui.InsertPanel.CancelButton.Modal = true end)
	Window.Sets = currStampGui.InsertPanel.Sets

	cloneButtonCon = currStampGui.StamperPanel.StamperButtons.CloneButton.MouseButton1Click:connect(goToClone)
	partListClickCon = currStampGui.StamperPanel.StamperButtons.PartsButton.MouseButton1Click:connect(goToInsertPanel)

	Data.Main = {}
	Data.Category = {}
	Data.Stamp = {}

	Data.BaseCategoryButtons = {}
	local userData = {}
	for id = 1, #userIdsForStamperParts do
		local newUserData = game:GetService("InsertService"):GetUserCategories(userIdsForStamperParts[id].Value)
		if newUserData and #newUserData > 2 then
			-- start at #3 to skip over My Decals and My Models for each account
			for category = 3, #newUserData do
				if newUserData[category].Name == "High Scalability" then
					table.insert(userData,1,newUserData[category])
				else
					table.insert(userData, newUserData[category])
				end
			end
		end
	end
	
	if userData then
		Data.UserCategoryButtons = processCategory(userData, setPanel)
	end

	guiChangedCon = currStampGui.Changed:connect(function(prop)
		if prop == "AbsoluteSize" then
			wait()
			setSetIndex(0)
		end
	end)

	InsertRows = math.floor(currStampGui.InsertPanel.ItemsFrame.AbsoluteSize.Y/buttonHeight)
	InsertColumns = math.floor(currStampGui.InsertPanel.ItemsFrame.AbsoluteSize.X/buttonWidth)

	populateSetsFrame()

	setsPrevPageCon = currStampGui.InsertPanel.PagingControls.PreviousPageButton.MouseButton1Click:connect(function() previousSetPage() end)
	setsNextPageCon = currStampGui.InsertPanel.PagingControls.NextPageButton.MouseButton1Click:connect(function() nextSetPage() end)

	insertPanelCloseCon = currStampGui.InsertPanel.CancelButton.MouseButton1Click:connect(function()
		closeInsertPanel()
		closeClonePanel()
		reloadCurrentAsset()
	end)

	minimizeCon = currStampGui.StamperPanel.MinimizeButton.MouseButton1Click:connect(function() minimizeStamperPanel() end)
	restoreCon = currStampGui.StamperPanel.RestoreButton.MouseButton1Click:connect(function() restoreStamperPanel() end)
end

-- signal to scripts we are ready to start manipulating objects
function signalStamperScript(assetName, assetId, image, stampMode)
	insertAsset.AssetName.Value = assetName
	insertAsset.AssetId.Value = assetId
	insertAsset.Image.Value = image
	insertAsset.StampMode.Value = stampMode
	insertAsset.Updated.Value = true
end

function reloadCurrentAsset()
	variables.ReloadCurrentAsset.Value = true
end


function beginInsertAssetGui(assetName, assetId, image, stampMode)
	Data.Stamp.StampMode = stampMode
	closeInsertPanel()
	signalStamperScript("",0,"","",false)
	moveLoadingWindow()
	cancelAssetPlacement()
	signalStamperScript(assetName, assetId, image, stampMode)
end


function cancelAssetLoad()
	Data.Loading.Cancelled = true
	insertComplete()
	gInitial90DegreeRotations = 0
end

function inBounds2(part)
	-- part must have a position property
	local xOne= buildingPlate.Position.x + buildingPlate.Size.x/2
	local xTwo = buildingPlate.Position.x - buildingPlate.Size.x/2
	local zOne = buildingPlate.Position.z + buildingPlate.Size.z/2
	local zTwo = buildingPlate.Position.z - buildingPlate.Size.z/2
	if part.Position.x > xOne or part.Position.x < xTwo then return false end
	if part.Position.z > zOne or part.Position.z < zTwo then return false end
	return true
end


-- For Restricting Stamper Tool (isRestricted)
function showHelp_pointToBuildingplate()

	if(buildingPlate==nil) then
		hint("All building areas are taken. If you want to build, leave and join again.")
	else
		-- only show one waypoint at a time (because kids will click a million times outside their plate)
		hint("Stamper Tool only works in your area.")
		if(not waypointShowing) then
			waypointShowing = true
			local _character = Tool.Parent
			waitForChild(_character, "Torso")
			_player = game.Players:GetPlayerFromCharacter(_character)
			_player.PlayerGui.showBaseplateWaypoint.target.Value = buildingPlate
			_player.PlayerGui.showBaseplateWaypoint.Disabled = true
			_player.PlayerGui.showBaseplateWaypoint.Disabled = false
			-- Wait until character moves in bounds (check every 2 seconds)
			while(not inBounds2(_character.Torso) and isEquipped) do	wait(2) end
			-- Then hide the waypoint
			hideHelp_pointToBuildingplate()
		end
	end

end


function showHelp_tooManyParts()
	hint("You have reached maximum number of parts! Delete some to put more down.")
end


function hideHelp_pointToBuildingplate()
	waypointShowing = false
	_player.PlayerGui.hideBaseplateWaypoint.Disabled = true
	_player.PlayerGui.hideBaseplateWaypoint.Disabled = false		
end


function setUpRestrictions()
	playerModel = game.Workspace.ActiveParts:FindFirstChild(player.Name .. "'s parts")

	local takenAreas = game.Workspace.BuildingAreas:GetChildren()

	waitForChild(player, "playerNumber")
		
	if(player.playerNumber.Value == 0) then
	  buildingPlate = nil
	  partModel = nil
	else
	  waitForChild(game.Workspace, "BuildingAreas")
	  local buildingAreas = game.Workspace.BuildingAreas
	  waitForChild(buildingAreas, "Area"..tostring(player.playerNumber.Value))
	  local targetArea = buildingAreas:FindFirstChild("Area"..tostring(player.playerNumber.Value))
	  waitForChild(targetArea, "PlayerArea")
	  waitForChild(targetArea.PlayerArea, "BasePlate")

	  buildingPlate = targetArea.PlayerArea.BasePlate
	  partModel = targetArea.PlayerArea
			
	end

	-- Check if player is standing in bounds, if not show error
	local _character = Tool.Parent
	waitForChild(_character, "Torso")
	_player = game.Players:GetPlayerFromCharacter(_character)
	if(buildingPlate~=nil) then
		if(not inBounds2(_character.Torso)) then
			showHelp_pointToBuildingplate()
		end
	else
		-- You have no building plate.
		hint("All building areas are taken. If you want to build, leave and join again.")
	end
end

function onInsertKeyDown(key)
	if loading then return end -- don't try to switch while we're loading

	key = string.lower(key)

	-- go to mru buttons
	if key == 'f' then
		mruButtonClick(1)
	elseif key == 'g' then
		mruButtonClick(2)
	elseif key == 'h' then
		mruButtonClick(3)
	elseif key == 'j' then
		mruButtonClick(4)
	end

end

function onEquippedLocal(mouse)
	player = getPlayer()
	if not player then 
		return 
	end
	if Tool.PlayerOwner.Value and Tool.PlayerOwner.Value ~= player then return end 

	-- For Restricting Stamper Tool
	if isRestricted.Value then
		setUpRestrictions()
	end

	Mouse = mouse
	if not firstEquip and currStampGui and Tool.SavedState.Value and Tool.PlayerOwner.Value == getPlayer() and Data and Data.FullyLoaded then

		currStampGui.Parent = getPlayer().PlayerGui

		if mode == 1 then -- if we were stamping, keep going
			-- if we signal a negative asset, then that means keep going using whatever was in recent memory [don't reload from insert service]
			signalStamperScript(insertAsset.AssetName.Value, -1, insertAsset.Image.Value, true)			
		elseif mode == 2 then -- time to clone
			goToClone()
		end

	else
		if firstEquip then
			Tool.PlayerOwner.Value = player
			firstEquip = false
		end
		CancelDuringLoad = false
		resetCons()

		Data = {}
		Data.FullyLoaded = false
				
		Window = {}
		Window.Sets = {}

		currStampGui = stamperGui:clone()
		currStampGui.Parent = getPlayer().PlayerGui
		wait()
		setUpStamperGui()

		if not(CancelDuringLoad) then
			currStampGui.Parent = getPlayer().PlayerGui
			Tool.SavedState.Value = currStampGui
		end

		Data.FullyLoaded = true
	end

	Mouse.KeyDown:connect(onInsertKeyDown)
end


function onUnequippedLocal()
	if currStampGui then
		Tool.SavedState.Value = currStampGui
		currStampGui.Parent = nil
	end
	
	pcall(function()
		cancelAssetPlacement()
		Data.Loading.Cancelled = true
	end)
	CancelDuringLoad = true
end


function killConnection(connection)
	if connection then connection:disconnect() end
end


function resetCons()
	killConnection(guiChangedCon)
	killConnection(cloneButtonCon)
	killConnection(partListClickCon)
	killConnection(itemFrameChangedCon)
	killConnection(setsPrevPageCon)
	killConnection(setsNextPageCon)
	killConnection(insertPanelCloseCon)
	killConnection(minimizeCon)
	killConnection(restoreCon)
end


function onAncestryChanged(child,parent)
	if Tool.PlayerOwner.Value and not Tool:IsDescendantOf(Tool.PlayerOwner.Value) and not Tool:IsDescendantOf(Tool.PlayerOwner.Value.Character) then
		--Tool was dropped in some way, so we need to nuke our external state
		Tool.SavedState.Value = nil
		resetCons()
	end
end


function getMaxNumOfRecentParts()
	return maxRecentParts
end


function pushRecentStackBack()
	for i = getMaxNumOfRecentParts() - 1, 1, -1 do
		recentPartStack[i + 1].AssetNameValue = recentPartStack[i].AssetNameValue
		recentPartStack[i + 1].AssetIdValue = recentPartStack[i].AssetIdValue
		recentPartStack[i + 1].InsertFrameButtonImage = recentPartStack[i].InsertFrameButtonImage
	end
end


function clearMRUList()
	local buttons = currStampGui.StamperPanel.StamperButtons.RecentFrame:GetChildren()
	for i = 1, #buttons do
		if recentPartStackCons[i] then recentPartStackCons[i]:disconnect() end
		buttons[i].Visible = false
	end
end


function mruButtonClick(position)
	if recentPartStack[position].AssetIdValue == insertAsset.AssetId.Value then return end -- already stamping part
	-- get rid of old part
	signalStamperScript("",0,"","",false)

	--Show the dialog window
	moveLoadingWindow()
	signalStamperScript(recentPartStack[position].AssetNameValue, recentPartStack[position].AssetIdValue, recentPartStack[position].InsertFrameButtonImage, true)
end


function insertMRUButton(position)
	local mruButton = currStampGui.StamperPanel.StamperButtons.RecentFrame:FindFirstChild("Button" .. tostring(position))
	mruButton.ButtonImage.Image = recentPartStack[position].InsertFrameButtonImage
	if mruButton.ButtonImage.Image == "" then
		mruButton.Text = recentPartStack[position].AssetNameValue
	end

	if recentPartStackCons[position] then pcall(function() recentPartStackCons[position]:Disconnect() end) end
	recentPartStackCons[position] = mruButton.MouseButton1Click:connect(function() mruButtonClick(position) end)
	mruButton.Visible = true
end


function refreshRecentParts()
	if insertAsset.Image.Value == "" then return end -- we don't have an asset, get out of here
	if not recentPartStack then return end -- if somehow not created yet (recentPartStack[i] calls below were nil somehow)
	
	local numOfRecentParts = getMaxNumOfRecentParts()

	for i = 1,numOfRecentParts do
		if insertAsset.AssetId and recentPartStack[i] and insertAsset.AssetId.Value == recentPartStack[i].AssetIdValue then -- already have part, don't push back
			return
		end
	end

	pushRecentStackBack()

	-- update our stack to show previously allocated part
	recentPartStack[1].AssetNameValue = insertAsset.AssetName.Value
	recentPartStack[1].AssetIdValue = insertAsset.AssetId.Value
	recentPartStack[1].InsertFrameButtonImage =  insertAsset.Image.Value

	clearMRUList()

	for i = 1, numOfRecentParts do
		if recentPartStack[i] and recentPartStack[i].AssetIdValue ~= "" then
			insertMRUButton(i)
		end
	end
end


function updateGui(type)
	if type == "Main" then
		goToInsertPanel()
	elseif type == "EyeDropper" then
		goToClone()
	elseif type == "SideDialog" then
		goToStamp()
	end
end
----------------------------------------------------------------------------------------



-- Lua Start Execution
setAssetUrls()

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.AncestryChanged:connect(onAncestryChanged)

waitForChild(variables, "SwitchLoaderToDialog")
variables.SwitchLoaderToDialog.Changed:connect(function(prop)
	if variables.SwitchLoaderToDialog.Value == true then
		updateGui(variables.SwitchLoaderToDialog.DialogType.Value)
		variables.SwitchLoaderToDialog.Value = false
	end

end)

waitForChild(variables, "ShowInvalidPlacement")
variables.ShowInvalidPlacement.Changed:connect(function(prop)
	if variables.ShowInvalidPlacement.Value == true then
		showHelp_pointToBuildingplate()
		showBaseplateGuideArrows()
		variables.ShowInvalidPlacement.Value = false
	end
end)

waitForChild(variables, "ShowMaxedOut")
variables.ShowMaxedOut.Changed:connect(function(prop)
	if variables.ShowMaxedOut.Value == true then
		showHelp_tooManyParts()
		variables.ShowMaxedOut.Value = false
	end
end)

waitForChild(variables, "Stamped")
variables.Stamped.Changed:connect(function()
	if variables.Stamped.Value == true then
		refreshRecentParts()
	end
end)
----------------------------------------------------------------------------------------