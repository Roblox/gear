local stampGui = script.Parent
local insertPanel = stampGui.InsertPanel
local stamperPanel = stampGui.StamperPanel

local itemPreview = insertPanel.ItemPreview

function handleResize()
	wait() -- neccessary to insure heartbeat happened
	itemPreview.LargePreview.Size = UDim2.new(1,0,0,itemPreview.AbsoluteSize.X)
	itemPreview.LargePreview.Position = UDim2.new(0.5,-itemPreview.LargePreview.AbsoluteSize.X/2,0,0)
	itemPreview.TextPanel.Position = UDim2.new(0,0,0,itemPreview.LargePreview.AbsoluteSize.Y)
	itemPreview.TextPanel.Size = UDim2.new(1,0,0,itemPreview.AbsoluteSize.Y - itemPreview.LargePreview.AbsoluteSize.Y)
end

stampGui.Changed:connect(function(prop)
	if prop == "AbsoluteSize" then
		handleResize()
	end
end)

handleResize()