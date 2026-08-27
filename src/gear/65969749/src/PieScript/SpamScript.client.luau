local vCharacter = script.Parent 

local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

local playerGui
local spamGui

local spamFrame 

local piePatch 

local imageAssets = {65951551, 65951575, 65951591}

tick()

if vPlayer then 
	playerGui = vPlayer:FindFirstChild("PlayerGui")
	if playerGui then 
		spamGui = playerGui:FindFirstChild("SpamGui")
		if spamGui == nil then 
			spamGui = Instance.new("ScreenGui")
			spamGui.Name = "SpamGui"
			spamGui.Parent = playerGui

			spamFrame = Instance.new("Frame")
			spamFrame.Name = "SpamFrame"
			spamFrame.Parent = spamGui 
			spamFrame.Size = UDim2.new(1, 0, 1, 0)
			spamFrame.Position = UDim2.new(0, 0, 0, 0)
			spamFrame.BackgroundTransparency = 1.0 

			piePatch = Instance.new("ImageLabel")
			piePatch.Size = UDim2.new(0, 256, 0, 256)
			piePatch.Position = UDim2.new(math.random() , 0, math.random(), 0)
			piePatch.Image = "http://www.roblox.com/asset/?id=" .. imageAssets[math.random(1, #imageAssets)]
			piePatch.BackgroundTransparency = 1.0
			piePatch.Parent = spamFrame 
		else 
			spamFrame = spamGui:FindFirstChild("SpamFrame")
			piePatch = Instance.new("ImageLabel")
			piePatch.Size = UDim2.new(0, 256, 0, 256)
			piePatch.Position = UDim2.new(math.random() , 0, math.random(), 0)
			piePatch.Image = "http://www.roblox.com/asset/?id=" .. imageAssets[math.random(1, #imageAssets)]
			piePatch.BackgroundTransparency = 1.0
			piePatch.Parent = spamFrame 
		end
	end
end


wait(4.0)
if piePatch then piePatch:Remove() end 
script:Remove() 

