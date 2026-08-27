local Tool = script.Parent
local Eye = Tool.Handle

Tool.Enabled = true

local vCharacter
local myHumanoid
local myTorso

local launchAnim

local activeEyes = {}
local currentEye = 0
local numberOfEyes 

local camera

local screenGui 

local debris = game:GetService("Debris")

function seeAll(key)
	local eyeCount = 0
	key = key:lower()
	if #activeEyes > 0 and camera then
		if key == "q" then 
			if currentEye + 1 > #activeEyes then currentEye = 0 end 
			camera.CameraSubject = activeEyes[currentEye + 1]
			currentEye = currentEye + 1
			camera.CameraType = 4
		elseif key == "e" then 
			if currentEye - 1 < 1 then currentEye = #activeEyes end 
			camera.CameraSubject = activeEyes[currentEye - 1]
			currentEye = currentEye - 1
			camera.CameraType = 4
		elseif key == "x" then 
			if camera then 
				camera.CameraSubject = vCharacter
				camera.CameraType = 5
			end
		elseif key == "t" then 			
			for i = 1, #activeEyes do
				local e = Instance.new("Explosion")
				e.Parent = game.Workspace
				e.BlastPressure = 1000000
				e.BlastRadius = 2.0 
				e.Position = activeEyes[i].Position
				debris:AddItem(e,  1.5)
				activeEyes[i]:Remove()
				activeEyes[i] = nil 
				eyeCount = eyeCount + 1
			end	
			numberOfEyes = Tool:FindFirstChild("NumberOfEyes")
			if numberOfEyes then numberOfEyes.Value = numberOfEyes.Value + eyeCount end 
		end
	end
end

function attach(eye, hit)
	if hit and hit.Parent ~= vCharacter and hit.Parent ~= Tool then 
		Weld = Instance.new("Weld")
		Weld.Name = "EyeWeld"
		Weld.Part0 = hit
		Weld.Part1 = eye
		Weld.C1 = eye.CFrame:inverse() * hit.CFrame
		Weld.Parent = eye
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	numberOfEyes = Tool:FindFirstChild("NumberOfEyes")
	if numberOfEyes then
		if numberOfEyes.Value <= 0 then 			
		return end
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	if myHumanoid == nil or myTorso == nil then 
		return 
	end

	local target = myHumanoid.TargetPoint
	launchAnim = myHumanoid:LoadAnimation(Tool.LaunchAnim)
	if launchAnim then
		launchAnim:Play()
	end  

	wait(0.2)

	numberOfEyes =  Tool:FindFirstChild("NumberOfEyes")
	if numberOfEyes then numberOfEyes.Value = numberOfEyes.Value - 1 end

	local eClone = Eye:Clone()
	eClone.CanCollide = true
	eClone.Parent = game.Workspace	
	eClone.Velocity = myTorso.CFrame.lookVector * 30.0
	eClone.Mesh.Scale = eClone.Mesh.Scale * 0.25
	table.insert(activeEyes, eClone)
	eClone.Touched:connect(function(hit) attach(eClone, hit) end)	
	
	camera = game.Workspace.CurrentCamera		

	wait(1.0)
	Tool.Enabled = true
end

function onEquipped(mouse)
	if mouse then 
		mouse.KeyDown:connect(seeAll)
	end
	myCharacter = Tool.Parent  
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)

	numberOfEyes = Tool:FindFirstChild("NumberOfEyes")	
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EyesGui"
	if myPlayer then
		screenGui.Parent = myPlayer.PlayerGui
	end	
	frame = Instance.new("Frame")
	frame.Name = "EyeContainer"
	frame.Position = UDim2.new(0, 0, 0.75, 0)
	frame.Size = UDim2.new(0, 75, 0, 75)
	frame.Parent = screenGui
	frame.BackgroundTransparency = 1.0

	image = Instance.new("ImageLabel")
	image.Name = "Eye"
	image.Image = "http://www.roblox.com/asset/?id=59803382"
	image.Parent = frame
	image.Size = UDim2.new(0, 75, 0, 75)
	image.BackgroundTransparency = 1.0

	text = Instance.new("TextLabel")
	text.Text = numberOfEyes.Value

	numberOfEyes.Changed:connect(function() text.Text = numberOfEyes.Value end)
	text.Position = UDim2.new(0.75, 0, 0.75, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.Parent = frame
	text.BackgroundTransparency = 1.0
	text.TextColor = BrickColor.new("Bright green")
	text.FontSize = 7

	frame2 = Instance.new("Frame")
	frame2.Name = "Container2"
	frame2.Position = UDim2.new(0, 0, 0.63, 0)
	frame2.Size = UDim2.new(0, 100, 0, 300)
	frame2.Parent = screenGui
	frame2.BackgroundTransparency = 1.0

	image2 = Instance.new("ImageLabel")
	image2.Name = "Instructions"
	image2.Image = "http://www.roblox.com/asset/?id=59804020"
	image2.Parent = frame2
	image2.Size = UDim2.new(0,250, 0, 75)
	image2.BackgroundTransparency = 1.0

end

function onUnequipped()
	if launchAnim then launchAnim:Stop() end
	if camera then camera.CameraSubject = vCharacter end 
	for i = 1, #activeEyes do 
		debris:AddItem(activeEyes[i], 2)
	end
	activeEyes = {}
	numberOfEyes = Tool:FindFirstChild("NumberOfEyes")
	if numberOfEyes then numberOfEyes.Value = 5 end
	if screenGui then screenGui:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
