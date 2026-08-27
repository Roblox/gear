local Tool = script.Parent
local Trap = Tool.Handle

Tool.Enabled = true

local myCharacter
local numberOfTraps 
local screenGui
local buzzer = Tool.NoTrapsBuzzer

local trapCFrame

local storeWeld = Trap:FindFirstChild("FireWeld") 
while storeWeld == nil do wait() storeWeld = Trap:FindFirstChild("FireWeld") end

function onActivated()	
	if not Tool.Enabled then return end
	numberOfTraps = Tool:FindFirstChild("NumberOfTraps")
	if numberOfTraps then
		if numberOfTraps.Value <= 0 then 
			if buzzer then buzzer:Play() end
		return end
	end	
	numberOfTraps.Value = numberOfTraps.Value - 1	
	Tool.Enabled = false	
	myCharacter = Tool.Parent
	local myTorso = myCharacter:FindFirstChild("Torso")
	if not myTorso then return end
	local myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myPlayer then return end
	
	local Clonedtrap = Trap:Clone()
	
	bodyGyro = Instance.new("BodyGyro")	
	bodyGyro.P = 10000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)	
	bodyGyro.cframe = (myTorso.CFrame + (myTorso.CFrame.lookVector * 2.0)) * CFrame.Angles(-math.pi/2, 0, 0)
	bodyGyro.Parent = Clonedtrap

	Clonedtrap.Parent = Workspace
	Clonedtrap.CanCollide = true
	Trap.Transparency = 1.0
	
	local CloneScript = Tool.TrapScript:Clone()
	CloneScript.Parent = Clonedtrap
	CloneScript.Disabled = false	
	
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = myPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = Clonedtrap
	
	wait(2.0)
	Trap.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
	myCharacter = Tool.Parent  
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)

	numberOfTraps = Tool:FindFirstChild("NumberOfTraps")	
	
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
	image.Name = "Trap"
	image.Image = "http://www.roblox.com/asset/?id=59712249"
	image.Parent = frame
	image.Size = UDim2.new(0, 75, 0, 75)
	image.BackgroundTransparency = 1.0

	text = Instance.new("TextLabel")
	text.Text = numberOfTraps.Value

	numberOfTraps.Changed:connect(function() text.Text = numberOfTraps.Value end)
	text.Position = UDim2.new(0.75, 0, 0.75, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.Parent = frame
	text.BackgroundTransparency = 1.0
	text.TextColor = BrickColor.new("Bright red")
	text.FontSize = 7

	checkWeld = Trap:FindFirstChild("FireWeld")
	if checkWeld == nil then checkWeld = storeWeld:Clone() checkWeld.Parent = Trap end 	
end

function onUnequipped()
	Trap.Transparency = 0.0
	if screenGui then screenGui:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
