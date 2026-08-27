local Tool = script.Parent
local Apple = Tool.Handle

Tool.Enabled = true

local myCharacter
local myHumanoid
local numberOfApples 
local screenGui
local buzzer

function poison(apple, humanoid)	
	if apple and humanoid and humanoid.Parent then 				
		if humanoid ~= nil and myHumanoid ~= nil then 			
			if Tool:FindFirstChild("PoisonScript") and not humanoid.Parent:FindFirstChild("PoisonScript") and apple then 								
				local character = humanoid.Parent 
				local rightArm = character:FindFirstChild("Right Arm") 
				
				if rightArm and apple then 
					local rightWeld = Instance.new("Weld") 
					rightWeld.Part0 = rightArm 
					rightWeld.Part1 = apple
					rightWeld.Parent = rightArm
					rightWeld.C1 = CFrame.new(Vector3.new(0, 1.25, 0))
	
					apple.Transparency = 0.0
			
					if apple:FindFirstChild("BG") then 
						apple.BG:Remove() 
					end
			
					apple.Parent = character
					apple.Name = "Apple"
				end
				
				local poisonScript = Tool.PoisonScript:Clone()
				poisonScript.Parent = humanoid.Parent 
				poisonScript.Disabled = false	
				
				if numberOfApples then numberOfApples.Value = numberOfApples.Value + 1 end
			end
		end
	end
end

function checkAOE(apple)
	local AOE = Vector3.new(7, 7, 7) 
	while apple do 		
		local parts = game.Workspace:FindPartsInRegion3(Region3.new(apple.Position - AOE, apple.Position + AOE), nil, 100)
		for i = 1, #parts do 
			if parts[i] and parts[i].Parent then 
				if parts[i].Parent then 
					local humanoid = parts[i].Parent:FindFirstChild("Humanoid")
					if humanoid then 
						poison(apple, humanoid)
						return 
					end
				end
			end
		end		
		wait(1.0)
	end
end

function onActivated()	
	if not Tool.Enabled then return end
	numberOfApples = Tool:FindFirstChild("NumberOfApples")

	if numberOfApples then
		if numberOfApples.Value <= 0 then 
			buzzed = Tool:FindFirstChild("NoApplesBuzzer")
			if buzzer then buzzer:Play() end
		return end
	end	

	numberOfApples.Value = numberOfApples.Value - 1	
	Tool.Enabled = false	
	myCharacter = Tool.Parent
	local myTorso = myCharacter:FindFirstChild("Torso")
	if not myTorso then return end
	local myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myPlayer then return end

	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then return end
	
	local clonedApple = Apple:Clone()
	
	bodyGyro = Instance.new("BodyGyro")	
	bodyGyro.Name = "BG"
	bodyGyro.P = 10000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)	
	bodyGyro.cframe = (myTorso.CFrame + (myTorso.CFrame.lookVector * 2.0)) * CFrame.Angles(-math.pi/2, 0, 0)
	bodyGyro.Parent = clonedApple

	clonedApple.Parent = Workspace
	clonedApple.CanCollide = true
	clonedApple.Transparency = 0.85
	Apple.Transparency = 1.0		
	
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = myPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = clonedApple

	wait(2.0)
	coroutine.resume(coroutine.create(function() checkAOE(clonedApple) end)) 		
	wait(2.0)
	Apple .Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
	myCharacter = Tool.Parent  
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	numberOfApples = Tool:FindFirstChild("NumberOfApples")	
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AppleGui"
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
	image.Name = "Apple"
	image.Image = "http://www.roblox.com/asset/?id=64429011"
	image.Parent = frame
	image.Size = UDim2.new(0, 75, 0, 75)
	image.BackgroundTransparency = 1.0

	text = Instance.new("TextLabel")
	text.Text = numberOfApples.Value

	numberOfApples.Changed:connect(function() text.Text = numberOfApples.Value end)
	text.Position = UDim2.new(0.75, 0, 0.75, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.Parent = frame
	text.BackgroundTransparency = 1.0
	text.TextColor = BrickColor.new("Bright red")
	text.FontSize = 7
end

function onUnequipped()
	Apple.Transparency = 0.0
	if screenGui then screenGui:Remove() end
	if buzzer then buzzer:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
