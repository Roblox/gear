local Tool = script.Parent 
local Doll = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer 

local activeSound

local equipped

local assetAwarded = false

local chartGui  
local chartFrame 
local chartAxis 

local bars = {}

local axisImageAssets = {67748111, 67748179}

function returnToDefault()
	wait(4.0)
	Tool.GripPos = Vector3.new(0, 0, -1)    
end 

function drawChartInFace()
		
	if chartGui and chartGui.Parent == nil and vPlayer and vPlayer:FindFirstChild("PlayerGui") then 
		chartGui.Parent = vPlayer.PlayerGui
		if chartAxis then chartAxis.Image = "http://www.roblox.com/asset/?id=" .. axisImageAssets[math.random(1, #axisImageAssets)] end
		for i = 1, 11 do 
			local barImage = Instance.new("ImageLabel")
			barImage.Parent = chartFrame
			barImage.Name = "Bars"
			barImage.BackgroundTransparency = 0.0 
			barImage.Size = UDim2.new(0.07, 0, math.random()/5, 0)
			barImage.Position = UDim2.new(0.05 + i * 0.07, 0, 0.9, 0)
			barImage.Image = "http://www.roblox.com/asset/?id=67727216"
			table.insert(bars, barImage)
		end 
		local drawTime = 4.5 
		while drawTime > 0 do 
			for i = 1, #bars do 
				if bars[i] then 
					bars[i].Size = UDim2.new(bars[i].Size.X.Scale, 0, bars[i].Size.Y.Scale + (bars[i].Size.Y.Scale * math.random(0, 1)/6), 0)
					bars[i].Position = UDim2.new(bars[i].Position.X.Scale, 0, 1 - bars[i].Size.Y.Scale - 0.075, 0)
				end 
			end 
			wait(0.5) 
			drawTime = drawTime - wait(0.5)
		end 
		wait(3.0)
		if chartGui then chartGui.Parent = nil end 
		for i = 1, #bars do 
			if bars[i] then bars[i]:Destroy() end 
		end 
		bars = {}
	end 
end

function annoy()
	while equipped and myTorso and myHumanoid do 
		tick()				
		local randomElement = math.random(1, 100)			
		print(randomElement)
		if randomElement == 1 then
			--
			local AOE = Vector3.new(14, 14, 14)
			local players = game.Players:GetChildren() 
			for i = 1, #players do 
				if players[i] and players[i].Character and players[i].Character:FindFirstChild("Torso") then 
					local torso = players[i].Character.Torso 
					local distance = (torso.Position - myTorso.Position).magnitude
					if distance < 12 and vPlayer:FindFirstChild("Backpack") then 
						activeSound = Doll:FindFirstChild("HereTakeThis") 
						if activeSound then activeSound:Play() end
						local randomItem = vPlayer.Backpack:GetChildren()[math.random(1, #vPlayer.Backpack:GetChildren())]
						randomItem.Parent = game.Workspace
						if randomItem:FindFirstChild("Handle") then
							randomItem.Handle.Velocity = (torso.Position - myTorso.Position).unit * 30.0
						end 
					end 
				end
			end 
		elseif randomElement > 1 and randomElement < 4 and not assetAwarded then 
				-- Award asset 
				local asset = game:GetService("InsertService"):LoadAsset(19645489)
				asset = asset:GetChildren()[1] 
				asset.Parent = vPlayer.Backpack
				assetAwarded = true 
				activeSound = Doll:FindFirstChild("HereTakeThis") 
				if activeSound then activeSound:Play() end
		elseif randomElement > 4 and randomElement < 9 then 
			if myHumanoid then myHumanoid.Jump = true end 
			activeSound = Doll:FindFirstChild("WasThatApproved") 
			if activeSound then activeSound:Play() end 
		elseif randomElement > 9 and randomElement < 23 then 
			if myHumanoid then 
				local ratio = myHumanoid.Health/myHumanoid.MaxHealth 
				myHumanoid.MaxHealth = 270 
				while myHumanoid.MaxHealth < 270 do 
					myHumanoid.MaxHealth = 270
				end 
				myHumanoid.Health = ratio * 270
			end 
			activeSound = Doll:FindFirstChild("FinancialBlessing")
			if activeSound then activeSound:Play() end 
		elseif randomElement > 23 and randomElement < 60 then 	
			activeSound = Doll:FindFirstChild("LetMeShowYou")
			if activeSound then activeSound:Play() end 
			drawChartInFace()
		end 			
		wait(1.5)
	end 
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	tick()

	if math.random() < 0.5 then 
		Tool.GripPos = Vector3.new(1.5, 1.5, -2.75)	
	else 
		Tool.GripPos = Vector3.new(3, 1.8, -1.7)
	end 

	coroutine.resume(coroutine.create(returnToDefault))

	wait(6.0)
	Tool.Enabled = true 
end

function onEquipped()
	equipped = true
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	coroutine.resume(coroutine.create(annoy))
	
	if vPlayer and vPlayer:FindFirstChild("PlayerGui") and vPlayer.PlayerGui:FindFirstChild("ChartGui") == nil then
		chartGui = Instance.new("ScreenGui")
		chartGui.Name = "ChartGui"	 

		chartFrame = Instance.new("Frame")
		chartFrame.Parent = chartGui 
		chartFrame.Style = Enum.FrameStyle.RobloxRound 
		chartFrame.Size = UDim2.new(0, 600, 0, 600)
		chartFrame.Position = UDim2.new(0.5, -300, 0.5, -300)
		chartFrame.BackgroundTransparency = 1.0 

		chartAxis = Instance.new("ImageLabel")
		chartAxis.Parent = chartFrame 
		chartAxis.Size = UDim2.new(1, 0, 1, 0)
		chartAxis.Position = UDim2.new(0, 0, 0, 0)
		chartAxis.BackgroundTransparency = 1.0
		chartAxis.Image = "http://www.roblox.com/asset/?id=67727637"
	end 
end

function onUnequipped()
	if activeSound then activeSound:Stop() end
	if chartGui then chartGui:Destroy() end 
	equipped = false 	
	myHumanoid.Health = myHumanoid.Health/myHumanoid.MaxHealth * 100 
	myHumanoid.MaxHealth = 100
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)