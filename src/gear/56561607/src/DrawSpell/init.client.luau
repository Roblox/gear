---------CHECKS/VARIABLES-------------------
local Tool = script.Parent
local myCharacter = Tool.Parent
if not myCharacter then script:Remove() end
local  Torso = myCharacter:FindFirstChild("Torso")
local RightArm = myCharacter:FindFirstChild("Right Arm")
local myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
if not (myPlayer and Torso and RightArm) then script:Remove() end

local myHumanoid
local TargetPoint

local myMouse = Tool.Mouse.Value
if not myMouse then script:Remove() end

if not Tool.Enabled then script:Remove() end

Tool.Enabled = false

local key = "f"
if Tool:FindFirstChild("SpellKey") then
	key = Tool.SpellKey.Value
end

local moveConnection
local upConnection

local DingSound = Tool:FindFirstChild("DingSound")
local ShotSound = Tool:FindFirstChild("ShotSound")
if ShotSound then print "ShotSound exists" end

local buttonUpdateConnections = {}

local RightShoulder = Torso:FindFirstChild("Right Shoulder")

local XOffset
local YOffset

local NewShoulder = Instance.new("Weld")
NewShoulder.Name = "Right Shoulder"	--LOL HAX
NewShoulder.Part0 = Torso
NewShoulder.Part1 = RightArm
NewShoulder.C0 = CFrame.new(1, 0.5, 0)
NewShoulder.C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(-math.pi/2, 0, 0)
-- (That CFrame is the standard "weapon equipped" position, w/ weld location at the shoulder.)

NewShoulder.Parent = Torso
if RightShoulder then RightShoulder.Parent = nil end

local SpellScript

local ScreenGui = Tool.WizardWandSpellGui:Clone()
ScreenGui.Parent = myPlayer.PlayerGui
local Frame = ScreenGui.SpellFrame
local Background = Frame.SpellBackground
local Button1 = Frame.Button1
local Button2 = Frame.Button2
local Button3 = Frame.Button3
local Button4 = Frame.Button4
local Button5 = Frame.Button5
local Button6 = Frame.Button6
local Button7 = Frame.Button7

local prevButton = nil
local finalButton

local initialBackgroundImage

local Buttons = {
	Button1, Button2, Button3,
	Button4, Button5, Button6,
	Button7}

local initialButtonImages = {
	Button1.Image, Button2.Image, Button3.Image,
	Button4.Image, Button5.Image, Button6.Image,
	Button7.Image}

local glowingButtonImages = {
	"http://www.roblox.com/asset/?id=56484059",
	"http://www.roblox.com/asset/?id=56485109",
	"http://www.roblox.com/asset/?id=56484129",
	"http://www.roblox.com/asset/?id=56484170",
	"http://www.roblox.com/asset/?id=56484211",
	"http://www.roblox.com/asset/?id=56484252",
	"http://www.roblox.com/asset/?id=56484282"}


-- Change buttons' positions and the overall background image based on spell chosen, which we determine from Tool.SpellKey
-- ...
-- For now:
if key == "f" then
	Button1.Position = UDim2.new(0, 258, 0, 346)
	Button2.Position = UDim2.new(0, 82, 0, 320)
	Button3.Position = UDim2.new(0, 201, 0, 220)
	Button4.Position = UDim2.new(0, 277, 0, 148)
	Button5.Position = UDim2.new(0, 109, 0, 103)
	Button6.Position = UDim2.new(0, 246, 0, 27)
	Button7.Visible = false
	finalButton = Button6
	Background.Image = "http://www.roblox.com/asset/?id=56478450"
elseif key == "x" then
	Button1.Position = UDim2.new(0, 15, 0, 101)
	Button2.Position = UDim2.new(0, 216, 0, -7)
	Button3.Position = UDim2.new(0, 414, 0, 106)
	Button4.Position = UDim2.new(0, 415, 0, 324)
	Button5.Position = UDim2.new(0, 216, 0, 433)
	Button6.Position = UDim2.new(0, 11, 0, 323)
	Button7.Position = UDim2.new(0, 215, 0, 215)
	finalButton = Button7
	Background.Image = "http://www.roblox.com/asset/?id=56479374"
else	-- key == "e"
	Button1.Position = UDim2.new(0, 130, 0, 220)
	Button2.Position = UDim2.new(0, 75, 0, 312)
	Button3.Position = UDim2.new(0, 314, 0, 253)
	Button4.Position = UDim2.new(0, 174, 0, 118)
	Button5.Position = UDim2.new(0, 316, 0, 142)
	Button6.Visible = false
	Button7.Visible = false
	finalButton = Button5
	Background.Image = "http://www.roblox.com/asset/?id=56479482"
end

initialBackgroundImage = Background.Image

---------FUNCTIONS-------------
function moveArmWithMouse()
	LookVector = Torso.CFrame.lookVector
	XOffset = (myMouse.X - Frame.AbsolutePosition.X - 175) / 175
	YOffset = (myMouse.Y - Frame.AbsolutePosition.Y - 175) / 175
	NewShoulder.C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(-math.pi/2 + math.atan(YOffset/2), math.atan(XOffset/2), 0)
end

function moveArmWithMouseOnButton(x, y)
	LookVector = Torso.CFrame.lookVector
	XOffset = (x - Frame.AbsolutePosition.X - 175) / 175
	YOffset = (y - Frame.AbsolutePosition.Y - 175) / 175
	NewShoulder.C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(-math.pi/2 + math.atan(YOffset/2), math.atan(XOffset/2), 0)
end

-- This function updates the background to its spell-ready version.
function updateBackground()
	if (key == "f") then Background.Image = "http://www.roblox.com/asset/?id=56478556"
	elseif (key == "x") then Background.Image = "http://www.roblox.com/asset/?id=56479425"
	else	--[[key == "e"]] Background.Image = "http://www.roblox.com/asset/?id=56479531"
	end
end

function endDrawing()
	-- Erase the Gui...
	ScreenGui:Remove()
	-- Re-enable the tool...
	Tool.Enabled = true
	-- Change grip back to normal...
	Tool.GripForward = Vector3.new(0, -1, 0)
	Tool.GripPos = Vector3.new(0, 0.02, -0.58)
	Tool.GripRight = Vector3.new(-1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	-- And replace the shoulder.
	if RightShoulder then
		RightShoulder.Parent = Torso
		NewShoulder.Parent = nil
	end
	script:Remove()
end

function castSpell()
	if (key == "f") then SpellScript = script:FindFirstChild("FireScript")
	elseif (key == "x") then SpellScript = script:FindFirstChild("IceScript")
	else	--[[key == "e"]] SpellScript = script:FindFirstChild("PoisonScript")
	end

	if ShotSound then ShotSound:Play() end
	if SpellScript then
		SpellScript = SpellScript:Clone()
		SpellScript.Parent = Tool
		SpellScript.Disabled = false
	end

	endDrawing()
end

-- This function, combined with a bunch of event connections, ensures that all the buttons are traversed,
--  in order, before the spell is cast.
function buttonUpdate(currButtonIndex, idealPrevButtonIndex)
	if prevButton == Buttons[idealPrevButtonIndex] then
		if DingSound then DingSound:Play() end
		local currButton = Buttons[currButtonIndex]
		local newLabel = Instance.new("ImageLabel")
		newLabel.Size = currButton.Size
		newLabel.Position = currButton.Position
		newLabel.BackgroundTransparency = 1.0
		newLabel.Image = glowingButtonImages[currButtonIndex]
		currButton:Remove()
		newLabel.Parent = Frame
		prevButton = currButton
		if prevButton == finalButton then
			updateBackground()
			upConnection:disconnect()
			for i = 1, #buttonUpdateConnections do
				buttonUpdateConnections[i]:disconnect()
			end
			myMouse.Button1Up:connect(castSpell)
		end
	end
end

--------CONNECTIONS------------------------
buttonUpdateConnections[1] = Button1.MouseEnter:connect(function() buttonUpdate(1, 0) end)
for i = 2, #Buttons do
	buttonUpdateConnections[i] = Buttons[i].MouseEnter:connect(function() buttonUpdate(i,i-1) end)
end
for i = 1, #Buttons do
	Buttons[i].MouseButton1Up:connect(endDrawing)
	Buttons[i].MouseMoved:connect(moveArmWithMouseOnButton)
end
moveConnection = myMouse.Move:connect(moveArmWithMouse)
upConnection = myMouse.Button1Up:connect(endDrawing)

Tool.Unequipped:connect(endDrawing)