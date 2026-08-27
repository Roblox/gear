local Tool = script.Parent
local Brain = Tool.Handle

Tool.Enabled = true

local myCharacter
local numberOfBrains 
local screenGui
local buzzer 

local brainCFrame

local summoner 

function onActivated()	
	if not Tool.Enabled then return end
	numberOfBrains = Tool:FindFirstChild("NumberOfBrains")
	if numberOfBrains then
		if numberOfBrains.Value <= 0 then 
			buzzer = Tool:FindFirstChild("NoBrainsBuzzer")
			if buzzer then buzzer:Play() end
		return end
	end	
	numberOfBrains.Value = numberOfBrains.Value - 1	
	Tool.Enabled = false	
	myCharacter = Tool.Parent
	local myTorso = myCharacter:FindFirstChild("Torso") or myCharacter:FindFirstChild("UpperTorso")
	if not myTorso then return end
	local myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myPlayer then return end
	
	local clonedBrain = Brain:Clone()

	clonedBrain.Transparency = 0.5
	
	bodyGyro = Instance.new("BodyGyro")	
	bodyGyro.P = 10000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)	
	bodyGyro.cframe = (myTorso.CFrame + (myTorso.CFrame.lookVector * 2.0)) * CFrame.Angles(-math.pi/2, 0, 0)
	bodyGyro.Parent = clonedBrain

	clonedBrain.Parent = Workspace
	clonedBrain.CanCollide = true
	Brain.Transparency = 1.0
	
	local cloneScript = Tool.SummonScript:Clone()
	cloneScript.Parent = clonedBrain	

	summoner = cloneScript:FindFirstChild("Summoner")
	if summoner then summoner.Value = myCharacter end 

	cloneScript.Disabled = false	
	
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = myPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = clonedBrain	
	
	wait(2.0)
	Brain.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
	myCharacter = Tool.Parent  
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)

	numberOfBrains = Tool:FindFirstChild("NumberOfBrains")	
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TrapsGui"
	if myPlayer then
		screenGui.Parent = myPlayer.PlayerGui
	end	
	frame = Instance.new("Frame")
	frame.Name = "TrapContainer"
	frame.Position = UDim2.new(0, 0, 0.75, 0)
	frame.Size = UDim2.new(0, 75, 0, 75)
	frame.Parent = screenGui
	frame.BackgroundTransparency = 1.0

	image = Instance.new("ImageLabel")
	image.Name = "Brain"
	image.Image = "http://www.roblox.com/asset/?id=64570445"
	image.Parent = frame
	image.Size = UDim2.new(0, 75, 0, 75)
	image.BackgroundTransparency = 1.0

	text = Instance.new("TextLabel")
	if numberOfBrains then text.Text = numberOfBrains.Value end

	numberOfBrains.Changed:connect(function() text.Text = numberOfBrains.Value end)
	text.Position = UDim2.new(0.75, 0, 0.75, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.Parent = frame
	text.BackgroundTransparency = 1.0
	text.TextColor = BrickColor.new("Bright red")
	text.FontSize = 7	 	
end

function onUnequipped()
	Brain.Transparency = 0.0
	if screenGui then screenGui:Destroy() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
