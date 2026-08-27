local Tool = script.Parent
local Egg = Tool.Handle

Tool.Enabled = true

local myCharacter
local myHumanoid
local numberOfEggs 
local screenGui
local buzzer 

local eggCFrame = CFrame.new(10.0158854, 11.9400072, 0.32186985, 0.0164276138, -0.99986428, 0, 0, 0, 1, -0.99986428, -0.0164276138, 0)

local summoner 

function onActivated()	
	if not Tool.Enabled then return end
	numberOfEggs = Tool:FindFirstChild("NumberOfEggs")
	if numberOfEggs then
		if numberOfEggs.Value <= 0 then 
			buzzer = Tool:FindFirstChild("NoEggsBuzzer")
			if buzzer then buzzer:Play() end
		return end
	end	
	numberOfEggs.Value = numberOfEggs.Value - 1		
	myCharacter = Tool.Parent
	local myTorso = myCharacter:FindFirstChild("Torso") or myCharacter:FindFirstChild("UpperTorso")
	if not myTorso then return end
	local myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myPlayer then return end
	print(myHumanoid)
	if myHumanoid == nil then return end
	Tool.Enabled = false	
	local clonedEgg = Egg:Clone()

	clonedEgg.Transparency = 0.2

	local target = myHumanoid.TargetPoint 
	local direction = ((target - Egg.Position).unit + Vector3.new(0, 0.25, 0)).unit

	clonedEgg.Velocity = direction * 25.0

	local float = Instance.new("BodyForce")
	float.Parent = clonedEgg
	float.force = Vector3.new(0, clonedEgg:GetMass() * workspace.Gravity * 0.95, 0)
	
	bodyGyro = Instance.new("BodyGyro")	
	bodyGyro.P = 10000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)	
	bodyGyro.cframe = eggCFrame
	bodyGyro.Parent = clonedEgg

	clonedEgg.Parent = Workspace
	clonedEgg.CanCollide = true
	Egg.Transparency = 1.0
	
	local cloneScript = Tool.SummonScript:Clone()
	cloneScript.Parent = clonedEgg	

	summoner = cloneScript:FindFirstChild("Summoner")
	if summoner then summoner.Value = myCharacter end 

	cloneScript.Disabled = false	
	
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = myPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = clonedEgg	
	
	wait(4.0)
	Egg.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
	myCharacter = Tool.Parent  
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	numberOfEggs = Tool:FindFirstChild("NumberOfEggs")	
	
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
	image.Name = "Egg"
	image.Image = "http://www.roblox.com/asset/?id=69464626"
	image.Parent = frame
	image.Size = UDim2.new(0, 75, 0, 75)
	image.BackgroundTransparency = 1.0

	text = Instance.new("TextLabel")
	if numberOfEggs then text.Text = numberOfEggs.Value end

	numberOfEggs.Changed:connect(function() text.Text = numberOfEggs.Value end)
	text.Position = UDim2.new(0.75, 0, 0.75, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.Parent = frame
	text.BackgroundTransparency = 1.0
	text.TextColor = BrickColor.new("Bright red")
	text.FontSize = 7	 	
end

function onUnequipped()
	Egg.Transparency = 0.0
	if screenGui then screenGui:Destroy() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
