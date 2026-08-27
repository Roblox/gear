print("start recent parts")

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

function getPlayer()
	waitForProperty(game.Players,"LocalPlayer")
	return game.Players.LocalPlayer
end

-- locals
local Tool = script.Parent
local RbxStamper = LoadLibrary("RbxStamper")
local RbxGui = LoadLibrary("RbxGui")
local stamperControl = nil
local lastStampModel = nil
local currStampId = nil

local recentPartsGui = nil
local loadingGui = nil
local waterGui, waterChangedEvent, waterForceAndDirection = nil, nil, {"None","NegX"}

local mouse = nil
local keyCon = nil

local waterMaterial = 17
local maxNumOfButtons = 20
local xSpacing = 90
local ySpacing = xSpacing
local yPos = 10
local xPos = 10

local recentButtons = {}

local BaseUrl = game:GetService("ContentProvider").BaseUrl:lower()
local thumbUrl = BaseUrl .. "game/tools/thumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid="

waitForChild(script.Parent,"RecentHintGui")
waitForChild(script.Parent.RecentHintGui,"RecentHint")
local hintGui = script.Parent.RecentHintGui
local shortcutHint = script.Parent.RecentHintGui.RecentHint

waitForProperty(game,"PlaceId")
local isRestricted = (game.PlaceId == 41324860 or game.PlaceId == 129686177)
local modelToStampIn, stampRegion = nil

local showBaseplateScript = nil
local hideBaseplateScript = nil
if isRestricted then
	waitForChild(getPlayer(), "PlayerGui")
	waitForChild(getPlayer().PlayerGui, "Waypoint")
	waitForChild(getPlayer().PlayerGui, "showBaseplateWaypoint")
	waitForChild(getPlayer().PlayerGui, "hideBaseplateWaypoint")
	showBaseplateScript = getPlayer().PlayerGui.showBaseplateWaypoint
	hideBaseplateScript = getPlayer().PlayerGui.hideBaseplateWaypoint
end

print("recent past waits")

-- functions
function stampAttemptFailed()
	hint("You can only stamp in your baseplate", 5)
	showBaseplateWaypoint()
end

function hasPoints()
	waitForChild(game.Players.LocalPlayer, "MaxPoints")
	local maxPoints = game.Players.LocalPlayer.MaxPoints
	waitForChild(game.Players.LocalPlayer, "PointsUsed")
	local pointsUsed = game.Players.LocalPlayer.PointsUsed

	return ( (pointsUsed.Value/maxPoints.Value) < 1 )
end

function hint(phrase, timeLength)
	waitForChild(game.Players.LocalPlayer.PlayerGui,"topHint")
	waitForChild(game.Players.LocalPlayer.PlayerGui.topHint, "Add")
	waitForChild(game.Players.LocalPlayer.PlayerGui.topHint.Add, "Label")
	waitForChild(game.Players.LocalPlayer.PlayerGui.topHint.Add, "Time")
	game.Players.LocalPlayer.PlayerGui.topHint.Add.Label.Value = tostring(phrase)
	game.Players.LocalPlayer.PlayerGui.topHint.Add.Time.Value = tonumber(timeLength)
	game.Players.LocalPlayer.PlayerGui.topHint.Add.Disabled = false
end

function showBaseplateWaypoint()
	if modelToStampIn and showBaseplateScript then
		local target = showBaseplateScript:FindFirstChild("target")
		if target then
			delay(0,function()
				target.Value = modelToStampIn.Parent:FindFirstChild("RegionBounds")
				showBaseplateScript.Disabled = false
				showBaseplateScript.Disabled = true
				wait(8)
				hideBaseplateScript.Disabled = false
				hideBaseplateScript.Disabled = true
			end)
		end
	end
end


function setupStamper(model, mouse)
	if model then
		if isRestricted then
			if not hasPoints() then
				hint("Too many parts stamped, delete some to stamp more", 5)
				return
			else
				stampControl = RbxStamper.SetupStamperDragger(model,mouse, modelToStampIn, stampRegion, stampAttemptFailed)
			end
		else
			stampControl = RbxStamper.SetupStamperDragger(model,mouse)
		end

		if stampControl then
			stampCon = stampControl.Stamped.Changed:connect(function()
					if stampControl.Stamped.Value then
						if isRestricted and not hasPoints() then
							hint("Too many parts stamped, delete some to stamp more", 5)
							if stampCon then stampCon:disconnect() end
							stampControl.Destroy()
						else
							stampControl.ReloadModel()
						end
					end
			end)
		end
	end
end

function makeLoadingGui(parent)
	local newLoadingFrame = Instance.new("Frame")
	newLoadingFrame.Name = "LoadingFrame"
	newLoadingFrame.Style = Enum.FrameStyle.RobloxRound
	newLoadingFrame.Size = UDim2.new(0,350,0,60)
	newLoadingFrame.Visible = false
	newLoadingFrame.Position = UDim2.new(0.5,-175,0.5,-30)

	local loadingText = Instance.new("TextLabel")
	loadingText.Name = "LoadingText"
	loadingText.BackgroundTransparency = 1
	loadingText.Size = UDim2.new(0,155,1,0)
	loadingText.Font = Enum.Font.ArialBold
	loadingText.FontSize = Enum.FontSize.Size36
	loadingText.Text = "Loading..."
	loadingText.TextColor3 = Color3.new(1,1,1)
	loadingText.TextStrokeTransparency = 0
	loadingText.Parent = newLoadingFrame

	loadingGui = newLoadingFrame

	newLoadingFrame.Parent = parent
end

function showLoadingDialog()
	loadingGui.LoadingText:TweenPosition(UDim2.new(0,150,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 2, true)
	recentPartsGui.RecentFrame.Visible = false
	shortcutHint.Visible = true
	loadingGui.Visible = true
end

function hideLoadingDialog()
	loadingGui.LoadingText:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
	loadingGui.Visible = false
end


function buildRecentButton(assetId, initTerrainShape)
	local recentButton = Instance.new("ImageButton")
	recentButton.Name = "RecentButton"
	recentButton.Position = UDim2.new(0,10,0,10)
	recentButton.Size = UDim2.new(0,85,0,85)
	recentButton.Style = Enum.ButtonStyle.RobloxButton
	if assetId then
		recentButton.Image = thumbUrl .. assetId
	end
	recentButton.ZIndex = 6

	local terrainShape = Instance.new("IntValue")
	terrainShape.Name = "TerrainShape"
	if initTerrainShape ~= nil then
		terrainShape.Value = initTerrainShape
	else
		terrainShape.Value = -1
	end
	terrainShape.Parent = recentButton

	recentButton.MouseButton1Click:connect(function()
		if stampControl then 
			stampControl.Destroy()
		end
		recentPartsGui.RecentFrame.Visible = false
		shortcutHint.Visible = true
		showLoadingDialog()
			local sStart, sEnd = string.find(recentButton.Image, "aid")
			local assetIdToStamp = string.sub(recentButton.Image, sEnd + 2)
			if recentButton.TerrainShape.Value >= 0 then
				lastStampModel = RbxStamper.GetStampModel(tonumber(assetIdToStamp), recentButton.TerrainShape.Value)
			else
				lastStampModel = RbxStamper.GetStampModel(tonumber(assetIdToStamp))
			end
			local clusterMaterial = lastStampModel:FindFirstChild("ClusterMaterial",true)
			if clusterMaterial and clusterMaterial:IsA("Vector3Value") then
				waterGui.Visible = (clusterMaterial.Value.X == waterMaterial)
			end

			currStampId = assetIdToStamp

			setupStamper(lastStampModel, mouse)
			if waterGui.Visible then
				updateWaterInfo()
			end
		hideLoadingDialog()
	end)

	return recentButton
end

function updateWaterInfo()
	if stampControl then
		stampControl.Destroy()
	end
	if stampCon then
		stampCon:disconnect()
		stampCon = nil
	end

	showLoadingDialog()
		lastStampModel = RbxStamper.GetStampModel(tonumber(currStampId))
	hideLoadingDialog()

	if lastStampModel.Name == "MegaClusterCube" then
		local clusterTag = lastStampModel:FindFirstChild("ClusterMaterial")
		-- we are going to stamp water, send info to stamper about this
		if clusterTag and clusterTag.Value.X == 17 then
			local waterForceTag = Instance.new("StringValue",lastStampModel)
			waterForceTag.Name = "WaterForceTag"
			waterForceTag.Value = waterForceAndDirection[1]

			local waterForceDirectionTag = Instance.new("StringValue",lastStampModel)
			waterForceDirectionTag.Name = "WaterForceDirectionTag"
			waterForceDirectionTag.Value = waterForceAndDirection[2]
		end
	end

	setupStamper(lastStampModel, mouse)
end

function createWaterGui()
	local waterForceDirections = {"NegX","X","NegY","Y","NegZ","Z"}
	local waterForces = {"None", "Small", "Medium", "Strong", "Max"}

	local waterForceDirection = "NegX"
	local waterForce = "None"

	local waterFrame = Instance.new("Frame")
	waterFrame.Name = "WaterFrame"
	waterFrame.Style = Enum.FrameStyle.RobloxSquare
	waterFrame.Size = UDim2.new(0,150,0,110)
	waterFrame.Visible = false

	local waterForceLabel = Instance.new("TextLabel")
	waterForceLabel.Name = "WaterForceLabel"
	waterForceLabel.BackgroundTransparency = 1
	waterForceLabel.Size = UDim2.new(1,0,0,12)
	waterForceLabel.Font = Enum.Font.ArialBold
	waterForceLabel.FontSize = Enum.FontSize.Size12
	waterForceLabel.TextColor3 = Color3.new(1,1,1)
	waterForceLabel.TextXAlignment = Enum.TextXAlignment.Left
	waterForceLabel.Text = "Water Force"
	waterForceLabel.Parent = waterFrame

	local waterForceDirLabel = waterForceLabel:Clone()
	waterForceDirLabel.Name = "WaterForceDirectionLabel"
	waterForceDirLabel.Text = "Water Force Direction"
	waterForceDirLabel.Position = UDim2.new(0,0,0,50)
	waterForceDirLabel.Parent = waterFrame

	local waterTypeChangedEvent = Instance.new("BindableEvent",waterFrame)
	waterTypeChangedEvent.Name = "WaterTypeChangedEvent"

	local waterForceDirectionSelectedFunc = function(newForceDirection)
		waterForceDirection = newForceDirection
		waterTypeChangedEvent:Fire({waterForce, waterForceDirection})
	end
	local waterForceSelectedFunc = function(newForce)
		waterForce = newForce
		waterTypeChangedEvent:Fire({waterForce, waterForceDirection})
	end

	local waterForceDirectionDropDown, forceWaterDirectionSelection = RbxGui.CreateDropDownMenu(waterForceDirections, waterForceDirectionSelectedFunc)
	waterForceDirectionDropDown.Size = UDim2.new(1,0,0,25)
	waterForceDirectionDropDown.Position = UDim2.new(0,0,1,3)
	forceWaterDirectionSelection("NegX")
	waterForceDirectionDropDown.Parent = waterForceDirLabel

	local waterForceDropDown, forceWaterForceSelection = RbxGui.CreateDropDownMenu(waterForces, waterForceSelectedFunc)
	forceWaterForceSelection("None")
	waterForceDropDown.Size = UDim2.new(1,0,0,25)
	waterForceDropDown.Position = UDim2.new(0,0,1,3)
	waterForceDropDown.Parent = waterForceLabel

	return waterFrame, waterTypeChangedEvent
end

function buildGui()
	recentPartsGui = Instance.new("ScreenGui")
	recentPartsGui.Name = "RecentPartsGui"

	local recentFrame = Instance.new("Frame")
	recentFrame.Name = "RecentFrame"
	recentFrame.BackgroundColor3 = Color3.new(0,0,0)
	recentFrame.BackgroundTransparency = 0.5
	recentFrame.Size = UDim2.new(0,465,0,375)
	recentFrame.Position = UDim2.new(0.5,-238,0.5,-180)
	recentFrame.ZIndex = 5
	recentFrame.Parent = recentPartsGui
	
	makeLoadingGui(recentPartsGui)

	waterGui, waterChangedEvent = createWaterGui()
	waterGui.Parent = recentPartsGui

	waterChangedEvent.Event:connect(function(waterTable)
		waterForceAndDirection = waterTable
		updateWaterInfo()
	end)
end

function appendButton(button)
	if xPos >= 370 then -- we need to start a new row
		yPos = yPos + ySpacing
		xPos = 10
		button.Position = UDim2.new(0, xPos, 0, yPos)
	else
		xPos = xPos + xSpacing
		button.Position = UDim2.new(0, xPos, 0, yPos)
	end
	button.Parent = recentPartsGui.RecentFrame 
	table.insert(recentButtons,button)
end

function pushButtonsBack()
	if #recentButtons == 1 then return end

	for i = #recentButtons - 1, 1, -1 do
		recentButtons[i + 1].Image = recentButtons[i].Image
		recentButtons[i + 1].TerrainShape.Value = recentButtons[i].TerrainShape.Value
	end
end

function pushToTop(buttonPos)
	if #recentButtons == 1 then return end

	local imageToTop = recentButtons[buttonPos].Image
	local terrainShapeTop = recentButtons[buttonPos].TerrainShape.Value
	for i = buttonPos - 1, 1, -1 do
		recentButtons[i + 1].Image = recentButtons[i].Image
		recentButtons[i + 1].TerrainShape.Value = recentButtons[i].TerrainShape.Value
	end
	recentButtons[1].Image = imageToTop
	recentButtons[1].TerrainShape.Value = terrainShapeTop
end

function addRecentPart(assetId, terrainShape)
	if not recentPartsGui then
		buildGui()
	end

	assetId = tostring(assetId)

	-- first check to see if we have this asset, and if so put it at the top
	for i = 1, #recentButtons do
		local sStart, sEnd = string.find(recentButtons[i].Image, "aid")
		local recentAssetId = string.sub(recentButtons[i].Image, sEnd + 2)
		if recentAssetId == assetId then
			pushToTop(i)
			return
		end
	end

	if #recentButtons >= maxNumOfButtons then --have as many buttons as we can, need to remove some stuff
		pushButtonsBack()
		recentButtons[1].Image = thumbUrl .. assetId
		recentButtons[1].TerrainShape.Value = terrainShape
		return
	end

	local button = buildRecentButton(assetId, terrainShape)
	if #recentButtons < 1 then -- first button
		table.insert(recentButtons,button)
		button.Parent = recentPartsGui.RecentFrame
		return
	end

	-- adding new button to front
	appendButton(button) 
	pushButtonsBack()
	recentButtons[1].Image = thumbUrl .. assetId
	recentButtons[1].TerrainShape.Value = terrainShape
end

function keyHandler(key)
	if not key then return end

	key = string.lower(key)

	if key == 'q' then
		if recentPartsGui then
			hideLoadingDialog()
			recentPartsGui.RecentFrame.Visible = true
			shortcutHint.Visible = false
			if stampControl then
				stampControl.Destroy() -- need to remove our stamping object
			end
		end
	end
end


function onEquipped(newMouse)
	print("recent onEquipped newMouse is", newMouse)
	if not newMouse then return end

	mouse = newMouse
	mouse.Icon = "http://www.roblox.com/asset?id=66887745"

print("recent recentPartsGui is", recentPartsGui)
	if not recentPartsGui then
		buildGui()
	end
	waterGui.Visible = false
	recentPartsGui.Parent = game.Players.LocalPlayer.PlayerGui
	hintGui.Parent = game.Players.LocalPlayer.PlayerGui

	keyCon = mouse.KeyDown:connect(function(key) keyHandler(key) end)
	
	print("recent onequipped End")
end

function onUnequipped()	
	hideLoadingDialog()
	recentPartsGui.Parent = nil
	hintGui.Parent = nil
	recentPartsGui.RecentFrame.Visible = true
	shortcutHint.Visible = false

	if stampControl then
		stampControl.Destroy()
	end

	mouse.Icon = ""
	mouse = nil

	if keyCon then
		keyCon:disconnect()
		keyCon = nil
	end
end

print("recent isRestricted is",isRestricted)
------------------------------------------------------------------------------------------------
if isRestricted then -- setup our variables
	waitForChild(game,"Workspace")
	waitForChild(game.Workspace, "BuildingAreas")
	waitForChild(game.Workspace.BuildingAreas, "Area1")
	waitForChild(game.Workspace.BuildingAreas, "Area9") -- all areas loaded

	while not modelToStampIn do -- check for build area until we find one
		local buildAreas = game.Workspace.BuildingAreas:GetChildren()
		for i = 1, #buildAreas do
			if buildAreas[i]:IsA("Model") then
				waitForChild(buildAreas[i],"Player")
				if buildAreas[i].Player.Value == game.Players.LocalPlayer.Name then
					waitForChild(buildAreas[i],"PlayerArea")
					modelToStampIn = buildAreas[i].PlayerArea
					break
				end
			end
		end
		if not modelToStampIn then
			wait(0.5)
		end
	end


	local lowPos = modelToStampIn.Parent:FindFirstChild("LowPos")
	local highPos = modelToStampIn.Parent:FindFirstChild("HighPos")
	if not lowPos or highPos then
		wait(0.5)
		lowPos = modelToStampIn.Parent:FindFirstChild("LowPos")
		highPos = modelToStampIn.Parent:FindFirstChild("HighPos")
	end
	while lowPos.Value == Vector3.new(0,0,0) or highPos.Value == Vector3.new(0,0,0) do
		wait(0.5)
	end -- tool doesn't work until these are defined
		
	stampRegion = Region3.new(lowPos.Value, highPos.Value) -- this is where we can stamp
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

script.AddRecentPart.OnInvoke = function(assetId, terrainShape)
	print("script.AddRecentPart.OnInvoke", assetId, terrainShape)
	addRecentPart(assetId, terrainShape)
	print("script.AddRecentPart.OnInvoke finished")
end

print("recent made it thru whole script")
