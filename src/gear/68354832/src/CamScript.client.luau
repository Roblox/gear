local playerGui = script.Parent 
local player = playerGui.Parent 

local character = player.Character 
local humanoid 
if character then 
	humanoid = character:FindFirstChild("Humanoid")
	if humanoid then humanoid.WalkSpeed = 10.0 end
end

local fogImageId = 68343786 

local snowAssets = {68343851, 68343876, 68343890}

local sg = Instance.new("ScreenGui")
sg.Parent = playerGui 
sg.Name = "Blizzard"

local fogFrame = Instance.new("Frame")
fogFrame.BackgroundTransparency = 1.0
fogFrame.Size = UDim2.new(1, 0, 1, 0)
fogFrame.Position = UDim2.new(0, 0, 0 ,0)
fogFrame.Parent = sg

local fogImage = Instance.new("ImageLabel")
fogImage.BackgroundTransparency = 1.0
fogImage.Size = UDim2.new(1, 0, 1, 0)
fogImage.Position = UDim2.new(0, 0, 0, 0)
fogImage.Parent = fogFrame 
fogImage.Image = "http://www.roblox.com/asset/?id=" ..  fogImageId 
fogImageZIndex = 1.0

local gravImages = {}

coroutine.resume(coroutine.create(function() 
	while sg do 
		for a = 1, 3 do                
			for i = 1, math.random(8, 15) do 
				local snow = Instance.new("ImageLabel") 
				snow.Parent = fogFrame
				snow.Name = "Snow Flakes" 
				snow.Position = UDim2.new(math.random(), 0, 0, 0) 
				local randSize = math.random(-32, 32) 
				snow.Size = UDim2.new(0, 32 + randSize, 0, 32 + randSize) 
				local asset = math.random(1, #snowAssets) 				
				snow.Image = "http://www.roblox.com/asset/?id=" .. snowAssets[asset] 
				snow.BackgroundTransparency = 1.0 
				snow.ZIndex = 3.0
				table.insert(gravImages, snow) 
			end 
			wait(0.1) 
		end 
		wait(1.25)
	end 
end))

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
					gravImages[i].Position = UDim2.new(gravImages[i].Position.X.Scale + (sign * math.random()/50), 0, gravImages[i].Position.Y.Scale + 0.0096, 0) 
				end 
			end 
		end 
		wait() 
	end 
end))

coroutine.resume(coroutine.create(function()
	local duration = 2.75 
	local camera = game.Workspace.CurrentCamera 
	camera.CameraType = 1	
	while duration > 0 do		
		camera.CoordinateFrame = camera.CoordinateFrame * CFrame.Angles(math.random(), math.random(), math.random())
		duration = duration - wait(0.25)
		wait(0.25)
	end 
	camera.CameraType = 5 
end))

wait(5.0)

if sg then sg:Remove() end 
gravImages = {}
if humanoid then humanoid.WalkSpeed = 16.0 end

wait(3.0)
script:Remove()