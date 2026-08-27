-- This script's job is to destroy previous topHint instance (if exists) and clone and run a new _topHint script (naming it "topHint")
-- When this script is finished, it disables and resets itself.

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

waitForChild(script, "Label")
waitForChild(script, "Time")
waitForChild(script, "Width")
waitForChild(script.Parent, "_topHint")
waitForChild(script.Parent._topHint, "Label")
waitForChild(script.Parent._topHint, "HideTime")
waitForChild(script.Parent._topHint, "Width")

local width = 0.55--script.Width.Value
--width = math.min(0.55,width/script.Parent.AbsoluteSize.X)

local quickReplace = true

-- If there's already an instance, do you quickly replace the text and width (true), or animate out then in? (false)

if (script.Parent:FindFirstChild("topHint")~=nil) then
	-- If there's already an instance...
	if(quickReplace) then
		-- If quickReplace is true...
		local bkg = script.Parent.Bkg
		local label = script.Parent.Label
		local ys = bkg.Position.Y.Scale
		local yo = bkg.Position.Y.Offset
		bkg.Position = UDim2.new((1 - width)/2,0, ys, yo)
		bkg.Size = UDim2.new(width,0, 0, 40)
		label.Text = script.Label.Value
		script.Parent.topHint.HideTime.Value = time() + script.Time.Value
	else
		-- If quickReplace is false...
		script.Parent.Delete.Disabled = false
		-- Wait for instance to be removed
		waitForNoChild(script.Parent, "topHint")
		waitForNoChild(script.Parent, "Bkg")
		waitForNoChild(script.Parent, "Label")
	end
else
	-- There's no previous instance.
	-- Clone and enable a new instance
	local topHint = script.Parent._topHint:Clone()
	topHint.Parent = script.Parent
	topHint.Name = "topHint"
	topHint.Label.Value = script.Label.Value
	topHint.HideTime.Value = time() + script.Time.Value
	topHint.Width.Value = width
	topHint.Disabled = false
end

script.Disabled = true
