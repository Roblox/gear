local playerGui = script.Parent
if playerGui == nil then script:Remove() end
local player = playerGui.Parent

local spamAssets = {65545966, 65545985, 65546005, 65546027} 

tick()

local spamGui

local spamImg = Instance.new("ImageLabel")
spamImg.Active = true 
spamImg.Image = "http://www.roblox.com/asset/?id=" .. spamAssets[math.random(1, #spamAssets)]
spamImg.BackgroundTransparency = 1.0
spamImg.Size = UDim2.new(0, 750, 0, 200)
spamImg.Position = UDim2.new(0.5, -275, 0.5, -100)

local tImage = Instance.new("ImageLabel")
tImage.Active = true 
tImage.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=250&y=250&Format=Png&username=" .. player.Name
tImage.Size = UDim2.new(0, 250, 0, 250)
tImage.Position = UDim2.new(0.5, -500, 0.5, -100)
tImage.BackgroundTransparency = 1.0

local textBtn = Instance.new("TextButton")
textBtn.Active = true 
textBtn.Text = "Delete Comment"
textBtn.Font = Enum.Font.Arial
textBtn.FontSize = Enum.FontSize.Size18
textBtn.TextColor3 = Color3.new(0, 0, 255/255) 
textBtn.BackgroundTransparency = 1.0
textBtn.Size = UDim2.new(0, 150, 0, 40)
textBtn.Position = UDim2.new(0.5, 325, 0.5, 65)

if playerGui:FindFirstChild("SpamGui") and #playerGui.SpamGui:GetChildren() < 1 then 
	spamGui = playerGui.SpamGui
	spamImg.Parent = spamGui
	tImage.Parent = spamGui
	textBtn.Parent = spamGui
else 
	spamGui = Instance.new("ScreenGui")
	spamGui.Name = "SpamGui"
	spamGui.Parent = playerGui	
	spamImg.Parent = spamGui
	tImage.Parent = spamGui
	textBtn.Parent = spamGui
end

textBtn.MouseButton1Click:connect(function()
	if textBtn then textBtn:Destroy() end 
	if spamImg then spamImg:Destroy() end
	if tImage then tImage:Destroy() end
	if spamGui then spamGui:Destroy() end
	if script then script:Destroy() end
end)



