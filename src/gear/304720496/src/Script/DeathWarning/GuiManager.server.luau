--Made by Luckymaxer

Gui = script.Parent
Frame = Gui:FindFirstChild("Frame")
Image = Gui:FindFirstChild("Image")
Counter = Gui:FindFirstChild("Count")

Debris = game:GetService("Debris")

LastChange = 0

Counter.Changed:connect(function()
	local Now = tick()
	LastChange = Now
	local Count = Counter.Value
	Frame:ClearAllChildren()
	Frame.Size = UDim2.new(1, 0, 1, 0)
	Gui.Size = UDim2.new((0.7 * Count), 0, 0.7, 0)
	local FrameSize = (1 / Count)
	for ii = 1, Count do
		local NewImage = Image:Clone()
		NewImage.Size = UDim2.new(FrameSize, 0, 1, 0)
		NewImage.Position = UDim2.new((FrameSize * (ii - 1)), 0, 0, 0)
		NewImage.Visible = true
		NewImage.Parent = Frame
	end
	if Count < Counter.MaxValue then
		wait(40)
		if LastChange == Now and Counter.Value < Counter.MaxValue then
			Counter.Value = 0
		end
	end
	if Counter.Value == 0 and Gui.Parent then
		Gui:Destroy()
	end
end)