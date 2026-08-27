function waitForChild(instance, name)
	while not instance:FindFirstChild(name) do
		instance.ChildAdded:wait()
	end
end

function waitForNoChild(instance, name)
	while instance:FindFirstChild(name) do
		instance.ChildRemoved:wait()
	end
end

function waitForAnyChild(instance)
	while not instance:GetChildren()[1] do
		instance.ChildAdded:wait()
	end
end

-- This script creates the graphics for the new topHint, and animates it.
-- Before calling this script, we've already made sure: there's no other "topHint", "Bkg", and "Label"
-- Then, if time~=0, it waits "time" and then calls "Remove" script

waitForChild(script, "Label")
waitForChild(script, "HideTime")
waitForChild(script, "Width")

local container = script.Parent
local labelText = script.Label.Value
local hideTime = script.HideTime.Value
local width = script.Width.Value

-- SETTINGS
local tweenTime = 0.3 -- animation time (seconds)
local topY = -50
local bottomY = 10
local easing = "Sine.easeInOut"
--

local bkg = Instance.new("Frame")
bkg.Parent = container
bkg.Name = "Bkg"
bkg.Position = UDim2.new((1 - width)/2,0, ys, yo)
bkg.Size = UDim2.new(width,0, 0, 40)
bkg.Style = "RobloxRound"

function destroy()
	script.Parent.Delete.Disabled = false
end

local label = Instance.new("TextButton")
label.Parent = container
label.Name = "Label"
label.BackgroundTransparency = 1
label.FontSize = "Size14"
label.Position = UDim2.new((1 - width)/2,0, 0, topY)
label.Size = UDim2.new(width,0, 0, 40)
label.Text = labelText
label.TextColor3 = Color3.new(1, 1, 1)
label.MouseButton1Click:connect(destroy)

bkg:TweenPosition(UDim2.new(bkg.Position.X.Scale,bkg.Position.X.Offset,bkg.Position.Y.Scale,bottomY),
		Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,tweenTime,true)

label:TweenPosition(UDim2.new(label.Position.X.Scale,label.Position.X.Offset,label.Position.Y.Scale,bottomY),
		Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,tweenTime,true)

if(hideTime~=0) then
	while(time() < hideTime) do wait(0.1) end
	destroy()
end