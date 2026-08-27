-- Code for a Clam Trap, based on code for the Korblox Tripmine.

-- Variables for the tool and its handle
local Tool = script.Parent
local Clam = Tool.Handle

Tool.Enabled = true

local myCharacter
local numberOfTraps 
local screenGui
local buzzer = Tool.NoTrapsBuzzer

local clamCFrame

-- Runs when tool is activated
function onActivated()
	-- Don't forget to check to make sure that the tool isn't still reloading!
	if not Tool.Enabled then return end

	-- Check to make sure the user hasn't already used all of his traps...
	numberOfTraps = Tool:FindFirstChild("NumberOfTraps")
	if numberOfTraps then
		if numberOfTraps.Value <= 0 then 
			if buzzer then buzzer:Play() end
		return end
	end
	
	numberOfTraps.Value = numberOfTraps.Value - 1
	-- And make sure the tool does know it has to reload for next time.
	Tool.Enabled = false

	-- Get variables for the tool's creator character and player, and make sure the character is still alive (?)
	myCharacter = Tool.Parent
	local myTorso = myCharacter:FindFirstChild("Torso")
	if not myTorso then return end
	local myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myPlayer then return end

	-- Strategy: Create a clone and let it do all the dirty work. Make the "actual" clam invisible (and unusable) for a while.
	local ClonedClam = Clam:Clone()
	
	bodyGyro = Instance.new("BodyGyro")	
	bodyGyro.P = 10000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)
	--bodyGyro.cframe = ClonedClam.CFrame * CFrame.Angles(-math.pi/2, 0, 0)
	bodyGyro.cframe = (myTorso.CFrame + (myTorso.CFrame.lookVector * 2.0)) * CFrame.Angles(-math.pi/2, 0, 0)
	bodyGyro.Parent = ClonedClam

	ClonedClam.Parent = Workspace
	ClonedClam.CanCollide = true
	Clam.Transparency = 1.0

	-- Add a script to make the new, cloned clam work as a trap.
	CloneScript = Tool.TrapScript:Clone()
	CloneScript.Parent = ClonedClam
	CloneScript.Disabled = false	

	-- Also add a creator tag so the player gets his kill(s), if any, on the leaderboard
	Tag = Instance.new("ObjectValue")
	Tag.Value = myPlayer
	Tag.Name = "creator"
	Tag.Parent = ClonedClam
	
	-- After the reload time, make sure the clam is visible again, and let the user use it.
	wait(2.0)
	Clam.Transparency = 0.0
	Tool.Enabled = true
end

-- Runs when tool is equipped; creates the GUI that tells the user how many traps they have left.
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
	image.Image = "http://www.roblox.com/asset/?id=54031132"
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
	
end

-- Runs when tool is unequipped
function onUnequipped()
	Clam.Transparency = 0.0
	if screenGui then screenGui:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
