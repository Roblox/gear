local Tool = script.Parent 
local Globe = Tool.Handle

local vCharacter 
local myTorso
local myHumanoid 
local vPlayer

local globeGui 
local playerGui

local debris = game:GetService("Debris")

local globeSound

local snowAssets = {66868846, 66868857, 66868867, 66868876}

local gravImages = {}

local globeAnim

Tool.Enabled = true 

function onActivated() 
	if Tool.Enabled == false then 
		return 
	end 
	
	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 
	
	globeSound = Globe:FindFirstChild("GlobeSound")
	if globeSound then globeSound:Play() end

	globeAnim = myHumanoid:LoadAnimation(Tool.GlobeAnim)
	if globeAnim then globeAnim:Play() end
	
	if globeGui then 
		for a = 1, 3 do			
			for i = 1, math.random(1, 12) do 
				local snow = Instance.new("ImageLabel")
				snow.Parent = globeGui 
				snow.Name = "Snow Flakes"
				snow.Position = UDim2.new(math.random(), 0, 0, 0)
				local randSize = math.random(-32, 32) 
				snow.Size = UDim2.new(0, 48 + randSize, 0, 48 + randSize)
				local asset = math.random(1, #snowAssets)
				if asset == #snowAssets then snow.Size = UDim2.new(0, 16, 0, 16) end 
				snow.Image = "http://www.roblox.com/asset/?id=" .. snowAssets[asset]
				snow.BackgroundTransparency = 1.0
				table.insert(gravImages, snow)
			end 
			wait(0.1)
		end 
	end 
	wait(0.1)
	Tool.Enabled = true 
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer then
		playerGui = vPlayer:FindFirstChild("PlayerGui")
		if playerGui and playerGui:FindFirstChild("GlobeGui") == nil then 
			globeGui = Instance.new("ScreenGui")
			globeGui.Parent = playerGui 
			globeGui.Name = "GlobeGui"
		end 
	end 
end 

function onUnequipped()
	if globeGui then globeGui:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

coroutine.resume(coroutine.create(function() 
	while true do 
		if gravImages and #gravImages > 0 then 
			for i = 1, #gravImages do 
				if gravImages[i] and gravImages[i].Position.Y.Scale > 1.0 then 
					gravImages[i]:Remove()
					table.remove(gravImages, i)
				end 
				if gravImages[i] then 	
					sign = math.random(-1, 1)
					gravImages[i].Position = UDim2.new(gravImages[i].Position.X.Scale + (sign * math.random()/100), 0, gravImages[i].Position.Y.Scale + 0.0096, 0)
				end 
			end 
		end 
		wait()
	end
end))