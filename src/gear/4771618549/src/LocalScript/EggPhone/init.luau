
--Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local UserInput = game:GetService("UserInputService")
local Marketplace = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

--References
local screen = script:WaitForChild("EggPhone")
local ui = screen["EggPhone"]
local background = ui["Plain"]
local loadingBackground = ui["Loading"]
local glowingBackground = ui["LoadingGlow"]
local topScreen =ui["TopBar"]
local CloseButton = ui["Close"]
local TotalEggs = topScreen["EggCount"]

--Main Screen Top Layer
local mainScreen = ui["MainFrame"]
local titleLayer = mainScreen["1Frame"]
local eggLayer = mainScreen["2Frame"]
local gameLayer = mainScreen["3Frame"]
local buttonLayer = mainScreen["4Frame"]

--Main Screen References
local eggTitle = titleLayer["TextLabel"]
local eggViewport = eggLayer["2Frame"]["ViewportFrame"]
local eggLocked = eggViewport["isLocked"]
local leftArrow = eggLayer["1Frame"]["2Frame"]["ImageButton"]
local leftHotKey = eggLayer["1Frame"]["1Frame"]["ImageButton"]
local rightArrow = eggLayer["3Frame"]["2Frame"]["ImageButton"]
local rightHotKey = eggLayer["3Frame"]["1Frame"]["ImageButton"]
local gameTitle = gameLayer["1TextLabel"]
local hintTitle = gameLayer["2TextLabel"]
local allEggsButton = buttonLayer["ImageButton"]

--All Screen Top Layer
local allScreen = ui["AllFrame"]
local eggLayer = allScreen["EggFrame"]
local arrowLayer = allScreen["ArrowFrame"]

--All Screen References
local previousPage = arrowLayer["1Frame"]["1ImageButton"]
local previousHotKey = arrowLayer["1Frame"]["2ImageButton"]
local nextPage = arrowLayer["2Frame"]["1ImageButton"]
local nextHotKey = arrowLayer["2Frame"]["2ImageButton"]

--Random Data
local Data = require(script.EggData)
local EggFolder = game:GetService("ReplicatedStorage"):WaitForChild("EggFolder")
local Eggs, Games = Data(0), Data(1)
local startLoaded = false
local isLoaded = false
local player = game.Players.LocalPlayer

--Local functions
local function openLoadingScreen(EggPhone)
	
	loadingBackground.Visible = true
	glowingBackground.Visible = true
	background.Visible = false
	
	loadingBackground.ImageTransparency = 0
	glowingBackground.ImageTransparency = 1
	
	spawn(function()
		
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local tween = TweenService:Create(
			glowingBackground,
			tweenInfo,
			{ImageTransparency = 0}
		)
		local tween2 = TweenService:Create(
			glowingBackground,
			tweenInfo,
			{ImageTransparency = 1}
		)
		local hold
		
		repeat
			
			tween:Play()
			tween.Completed:Wait()
			--This swamps the tweens
			hold = tween 
			tween = tween2 
			tween2 = hold 
			hold = nil
			
		until EggPhone.Page ~= 0 or ui.Visible == false
		
	end)
	
end

local function openMainScreen(EggPhone, toInit)
	
	loadingBackground.Visible = false
	glowingBackground.Visible = false
	background.Visible = true
	
	mainScreen.Visible = true
	allScreen.Visible = false
	
	local Num = EggPhone.DisplayEgg
	local Max = #EggPhone.DisplayEggs
	
	local function setEgg()
		local DisplayEgg = EggPhone.DisplayEggs[Num]
		
		if not DisplayEgg then
			warn("[EGGPHONE] Could not fetch Egg List, Display Egg #1 is not existing")
		end
		
		eggTitle.Text = DisplayEgg.EggName
		gameTitle.Text = DisplayEgg.GameName or ""
		hintTitle.Text = DisplayEgg.EggMission or ""
		
		local eggs = eggViewport:GetChildren()
		for _,egg in pairs(eggs) do
			if egg:IsA("BasePart") then
				egg.Parent = EggFolder
			end
		end
		
		DisplayEgg.EggModel.Parent = eggViewport
		DisplayEgg.EggModel.Mesh.TextureId = not DisplayEgg.Unlocked and "" or DisplayEgg.TextureId
		eggLocked.Visible = not DisplayEgg.Unlocked

		DisplayEgg.EggModel.Position = Vector3.new()
		
		local camera = eggViewport:FindFirstChild("Camera") or nil
		if not camera then
			camera = camera or workspace.Camera:Clone()
			camera.Parent = eggViewport
			eggViewport.CurrentCamera = camera
			camera.CFrame = CFrame.new(Vector3.new(3,0,0), Vector3.new(0,0,0)) 
		end
		camera.FieldOfView = 70
		
		local particle = DisplayEgg.EggModel:FindFirstChild("Particle")
		if particle then
			particle:Destroy()
		end
	
		leftArrow.Visible = true
		leftHotKey.Visible = true
		rightArrow.Visible = true
		rightHotKey.Visible = true
		
		if Num == Max and Num == 1 then
			
			rightArrow.Visible = false
			leftArrow.Visible = false
			leftHotKey.Visible = false
			rightHotKey.Visible = false
			
		elseif Num == 1 then
			
			leftArrow.Visible = false
			leftHotKey.Visible = false
			
		elseif Num == Max then
			
			rightArrow.Visible = false
			rightHotKey.Visible = false
		
		end
	end
	
	if toInit then
	
		local function scrollLeft()
			
			if Num > 1 then
				
				Num = Num - 1
				setEgg()
				
			end
			
		end
		
		local function scrollRight()
			
			if Num < Max then
				
				Num = Num + 1
				setEgg()
				
			end
			
		end
		
		table.insert(EggPhone.tempConnections, UserInput.InputEnded:Connect(function(inputObject)
			
			if inputObject.KeyCode == Enum.KeyCode.ButtonX or inputObject.KeyCode == Enum.KeyCode.Q then
				
				scrollLeft()
				
			elseif inputObject.KeyCode == Enum.KeyCode.ButtonY or inputObject.KeyCode == Enum.KeyCode.E then
				
				scrollRight()
				
			end
			
		end))
			
		table.insert(EggPhone.tempConnections, leftArrow.InputEnded:Connect(function(inputObject)
			
			if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
			
				scrollLeft()
				
			end
			
		end))
		
		table.insert(EggPhone.tempConnections, rightArrow.InputEnded:Connect(function(inputObject)
			
			if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
			
				scrollRight()
				
			end
			
		end))
		
		table.insert(EggPhone.tempConnections, UserInput.InputEnded:Connect(function(inputObject)
			
			if inputObject.KeyCode == Enum.KeyCode.ButtonA then
				
				EggPhone.Bindable:Fire(function(object)
					
					object:SetPage(2)
					
				end)
				
			end
			
		end))
		
	end
	
	setEgg()
	
end

local function openAllScreen(EggPhone, toInit)
	
	loadingBackground.Visible = false
	glowingBackground.Visible = false
	background.Visible = true
	
	mainScreen.Visible = false
	allScreen.Visible = true
	
	EggPhone.DisplayEggs = Eggs
	
	local pageMax = 18
	local pages = math.ceil(#EggPhone.DisplayEggs / pageMax)
	local page = 1
	
	local function fitFrame(frame, egg, camera, connections)
		
		egg.EggModel.Parent = frame
		egg.TextureId = egg.EggModel.Mesh.TextureId
		egg.EggModel.Mesh.TextureId = not egg.Unlocked and "" or egg.TextureId
		egg.EggModel.Position = Vector3.new()
		frame.isLocked.Visible = not egg.Unlocked
		local eggModel = egg.EggModel
		
		local isGameEgg = false
		local gameData = Games[game.GameId] or nil
		if gameData then
			for _,_egg in pairs(gameData.Eggs) do
				if _egg == egg then
					isGameEgg = true
				end
			end
		end
		
		if isGameEgg then
			
			local clone = egg.EggModel:Clone()
			clone.Mesh.TextureId = ""
			clone.Color = Color3.new(0,1,1)
			clone.Transparency = 1.2
			clone.Name = "Particle"
			clone.Parent = egg.EggModel
			local position = clone.Position
			
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
			local tween = TweenService:Create(
				clone,
				tweenInfo,
				{Size = clone.Size * 1.3, Position = position, Transparency = 0.5, Color = Color3.new(198/255, 255/255, 252/255)}	
			)
			tween:Play()
			
		end
		
		table.insert(connections, frame.Parent.ImageButton.InputBegan:Connect(function(inputObject)
		
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
				
				readyToSwitch = false
				local tweenInfo = TweenInfo.new(.2, Enum.EasingStyle.Quad)
				local tween = TweenService:Create(
					camera,
					tweenInfo,
					{FieldOfView=60}
				)
				tween:Play()
				
			end
			
		end))
	
		table.insert(connections, frame.Parent.ImageButton.InputEnded:Connect(function(inputObject)
		
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Gamepad1 then

				readyToSwitch = false
				local tweenInfo = TweenInfo.new(.2)
				local tween = TweenService:Create(
					camera,
					tweenInfo,
					{FieldOfView=70}
				)
				tween:Play()
				
			end
			
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.KeyCode == Enum.KeyCode.ButtonA then

				EggPhone.Bindable:Fire(function(object)
					object.DisplayEgg = tonumber(string.sub(eggModel.Name, 4))
					for _,connection in pairs(connections) do
						connection:Disconnect()
					end
					object:SetPage(1)
					
				end)
				
			end
		
		end))
		
	end
	
	local _connections = {}
	
	local function setPage()
		
		for _,connection in pairs(_connections) do
			
			connection:Disconnect()
			
		end
		
		previousPage.Visible = true
		previousHotKey.Visible = true
		nextPage.Visible = true
		nextHotKey.Visible = true
		
		if page == 1 then
			
			previousPage.Visible = false
			previousHotKey.Visible = false
			
		end
		
		if page == pages then
			
			nextPage.Visible = false
			nextHotKey.Visible = false
			
		end
		
		local eggNum = 0 + ((page - 1) * pageMax)
		
		for i = 1, 4 do
			
			local num = (i == 2 or i == 3) and 5 or 4
			
			for j = 1, num do
				
				local frame = eggLayer[i.."Frame"]["1Frame"][j.."Frame"].ViewportFrame
				frame.isLocked.Visible = false
				
				local camera = frame:FindFirstChild("Camera") or nil
				if not camera then
					camera = camera or workspace.Camera:Clone()
					camera.Parent = frame
					frame.CurrentCamera = camera
					camera.CFrame = CFrame.new(Vector3.new(3,0,0), Vector3.new(0,0,0)) 
				end
				camera.FieldOfView = 70
				
				if i == 1 and j == 1 then
					frame.Parent["ImageButton"].Selected = true
				end
				
				local existingEgg = frame:FindFirstChildWhichIsA("MeshPart") and frame:FindFirstChildWhichIsA("MeshPart") or frame:FindFirstChildWhichIsA("BasePart")
				if existingEgg then
					
					existingEgg.Parent = EggFolder
					for _,child in pairs(existingEgg:GetChildren()) do
						if child.Name == "Particle" then
							child:Destroy()
						end
					end
					
				end
				
				eggNum = eggNum + 1
				
				if EggPhone.DisplayEggs[eggNum] then
					
					fitFrame(frame, EggPhone.DisplayEggs[eggNum], camera, _connections)
					
				end
				
			end
			
		end
		
	end
	
	if toInit then
		
		local function scrollLeft()
			
			if page > 1 then
				
				page = page - 1
				setPage()
				
			end
			
		end
		
		local function scrollRight()
			
			if page < pages then
				
				page = page + 1
				setPage()
				
			end
			
		end
		
	
		table.insert(EggPhone.tempConnections, UserInput.InputEnded:Connect(function(inputObject)
			
			if inputObject.KeyCode == Enum.KeyCode.ButtonX or inputObject.KeyCode == Enum.KeyCode.Q then
				
				scrollLeft()
				
			elseif inputObject.KeyCode == Enum.KeyCode.ButtonY or inputObject.KeyCode == Enum.KeyCode.E then
				
				scrollRight()
				
			end
			
		end))
			
		table.insert(EggPhone.tempConnections, previousPage.InputEnded:Connect(function(inputObject)
			
			if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
			
				scrollLeft()
				
			end
			
		end))
		
		table.insert(EggPhone.tempConnections, nextPage.InputEnded:Connect(function(inputObject)
			
			if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Gamepad1 then
			
				scrollRight()
				
			end
			
		end))
		
	end
	
	setPage()
	
end

local EggPhone = {
	Bindable = Instance.new("BindableEvent"),
	Page = 0,
	tempConnections = {},
	Connections = {},
	GameData = Games[game.PlaceId] and Games[game.PlaceId] or Games[1],
	DisplayEggs = Eggs,
	DisplayEgg = 1,
	Enabled = false
}

function EggPhone:Open()
	
	screen.Parent = Players.LocalPlayer:FindFirstChild("PlayerGui") or script
	
	if screen.Parent == script then
		
		warn("[EGGPHONE] Could not locate Players StarterGui")
		
	end
	
	self.DisplayEgg = Games[game.PlaceId] and tonumber(string.sub(Games[game.PlaceId].Eggs[1].EggModel.Name, 4)) or 1
	
	self.Enabled = true
	screen.Enabled = true
	ui.Visible = true
	local current = "pc"
	local callback
	
	local function adaptInputScheme(lastInputType)
		
		if current ~= "pc" and lastInputType == Enum.UserInputType.MouseMovement or lastInputType == Enum.UserInputType.Keyboard then
			
			if callback then callback() callback = nil end
			
			current = "pc"
			
			nextHotKey.ImageTransparency = 0
			previousHotKey.ImageTransparency = 0
			leftHotKey.ImageTransparency = 0
			rightHotKey.ImageTransparency = 0
			
		elseif current ~= "xbox" and lastInputType == Enum.UserInputType.Gamepad1 then
			
			if callback then callback() callback = nil  end
			
			current = "xbox"
			
			nextHotKey.ImageTransparency = 0
			previousHotKey.ImageTransparency = 0
			leftHotKey.ImageTransparency = 0
			rightHotKey.ImageTransparency = 0
			
			local function toggle(bool)
			
				for _,child in pairs(ui:GetDescendants()) do
					
					if child.Name == "Gamepad" then
						
						child.Visible = bool
						
					end
					
				end
				
			end
			
			toggle(true)
			
			callback = function() toggle(false) end
			
		elseif current ~= "mobile" and lastInputType == Enum.UserInputType.Touch then
			
			if callback then callback() callback = nil end
			
			current = "mobile"
			
			nextHotKey.ImageTransparency = 1
			previousHotKey.ImageTransparency = 1
			leftHotKey.ImageTransparency = 1
			rightHotKey.ImageTransparency = 1
			
		end
		
	end
	
	table.insert(self.Connections, UserInput.LastInputTypeChanged:Connect(function(lastInputType)
		adaptInputScheme(lastInputType)
	end))
		
	adaptInputScheme(UserInput:GetLastInputType())
	
	if not startLoaded then
		
		startLoaded = true
		
 		local assets = EggFolder:GetChildren()
		assets[#assets + 1] = ui
		
		spawn(function()
			local success, _ = pcall(function()
				local startTime = tick()
				for i = 1, #Eggs do
					Eggs[i].Unlocked = Marketplace:PlayerOwnsAsset(Players.LocalPlayer, Eggs[i].AssetId)
					Eggs[i].TextureId = Eggs[i].EggModel["Mesh"].TextureId
				end
				print("[EGGPHONE] Assets completed in "..tick()-startTime)
				ContentProvider:PreloadAsync(assets)
				local totalTime = tick()-startTime
				
				isLoaded = true
				
				--We're showing off an animation ok im sorry its cool
				local forcedWait = 3-totalTime > 0 and 3-totalTime or 0
				
				
				if forcedWait ~= 0 then
					
					wait(forcedWait)
					
				end
				
				if self.Page == 0 then
					
					self:SetPage(1)
					
				end
			end)
		end)
			
		spawn(function()
			
			wait(5) --Maximum load time
			if isLoaded == false then
				isLoaded = true
				if self.Enabled == true and self.Page == 0 then
					self:SetPage(1)
				end
			end
			
		end)
		
	end
	
	if not isLoaded then
		
		self:SetPage(0)
		
	else
		
		self:SetPage(1)
		
	end
	
	table.insert(self.Connections, self.Bindable.Event:Connect(function(call)
		
		call(self)
		
	end))
	
	table.insert(self.Connections, allEggsButton.InputEnded:Connect(function(inputObject)

		if self.Page == 1 and (inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Gamepad1) then
			
			self:SetPage(2)
			
		end
		
	end))
	
	table.insert(self.Connections, CloseButton.InputEnded:Connect(function(inputObject)

		if (inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Gamepad1) then
			
			self:Close()
			
		end
		
	end))
	
	table.insert(self.Connections, UserInput.InputEnded:Connect(function(inputObject)
		
		if inputObject.KeyCode == Enum.KeyCode.ButtonB then
			
			self:Close()
			
		end
		
	end))
		
	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		table.insert(self.Connections, humanoid.Died:Connect(function()
			
			self:Close()
			
		end))
			
	end
	
end

function EggPhone:Close()
	
	self:SetPage(0)
	
	self.Enabled = false
	screen.Parent = script
	ui.Visible = false
	screen.Enabled = false
	
	for _,connection in pairs(self.Connections) do
		
		connection:Disconnect()
		
	end
	
	for _,connection in pairs(self.tempConnections) do
		
		connection:Disconnect()
		
	end
	
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:UnequipTools()
		end
	end
	
	for _,child in pairs(screen:GetDescendants()) do
		
		if child:IsA("BasePart") and string.lower(string.sub(child.Name, 1, 3)) == "egg" then
			
			child.Parent = EggFolder
			
		end
		
	end
	
end

function EggPhone:Update(pageChanged)
	
	if self.Page == 0 then
		
		openLoadingScreen(self, pageChanged)
		
	elseif self.Page == 1 then
		
		
		openMainScreen(self, pageChanged)
		
	else
		
		openAllScreen(self, pageChanged)
		
	end
	
end

function EggPhone:SetPage(pageNumber)
	
	TotalEggs.Text = Data(2).." / "..#Eggs
	
	local pageChanged = self.Page ~= pageNumber
	self.Page = pageNumber
	
	if pageChanged then
		
		for _,connection in pairs(self.tempConnections) do
			
			connection:Disconnect()
			
		end
		
	end
	
	self:Update(pageChanged)
	
end

return EggPhone