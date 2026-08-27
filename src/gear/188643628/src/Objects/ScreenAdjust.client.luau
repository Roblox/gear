--Made by Luckymaxer

wait()

ZoomGui = script.Parent
Scope = ZoomGui:WaitForChild("Scope")
Frame1 = ZoomGui:WaitForChild("Frame1")
Frame2 = ZoomGui:WaitForChild("Frame2")

function AdjustScreenSize()
	Scope.Position = UDim2.new(0.5, (-10 - (ZoomGui.AbsoluteSize.Y / 2)), 0, -10)
	Scope.Size = UDim2.new(0, (20 + ZoomGui.AbsoluteSize.Y), 0, (30 + ZoomGui.AbsoluteSize.Y), 1, 20)
	Frame1.Size = UDim2.new(0, (30 + ((ZoomGui.AbsoluteSize.X - ZoomGui.AbsoluteSize.Y) / 2)), 1, 30)
	Frame2.Size = UDim2.new(0, (30 + ((ZoomGui.AbsoluteSize.X - ZoomGui.AbsoluteSize.Y) / 2)), 1, 30)
	Frame2.Position = UDim2.new(1, (-10 - ((ZoomGui.AbsoluteSize.X - ZoomGui.AbsoluteSize.Y) / 2)), 0, -10)
end

ZoomGui.Changed:connect(function()
	AdjustScreenSize()
end)

AdjustScreenSize()