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

local topHint = script.Parent:FindFirstChild("topHint")
local bkg = script.Parent:FindFirstChild("Bkg")
local label = script.Parent:FindFirstChild("Label")

-- SETTINGS
local tweenTime = 0.3 -- animation time (seconds)
local topY = -50 -- top position (Y Offset)
local easing = "Back.easeInOut"
--

if(topHint~=nil) then
	topHint:Remove()
end

if(bkg~=nil) then
	bkg:TweenPosition(UDim2.new(bkg.Position.X.Scale,bkg.Position.X.Offset,bkg.Position.Y.Scale,topY),
		Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,tweenTime,true)
end

if(label~=nil) then
	label:TweenPosition(UDim2.new(label.Position.X.Scale,label.Position.X.Offset,label.Position.Y.Scale,topY),
		Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,tweenTime,true)
end

wait(tweenTime)
if(bkg~=nil) then bkg:Remove() end
if(label~=nil) then label:Remove() end

script.Disabled = true
