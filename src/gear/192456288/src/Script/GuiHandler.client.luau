--Made by Luckymaxer

ScreenGui = script.Parent
ScrollingFrame = ScreenGui:WaitForChild("ScrollingFrame")

ServerControl = ScreenGui:WaitForChild("ServerControl").Value

FrameSize = ScrollingFrame.Position

ScrollingFrame.Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X - ScrollingFrame.AbsoluteSize.X - FrameSize.X.Offset), 0, (ScreenGui.AbsoluteSize.Y - ScrollingFrame.AbsoluteSize.Y - FrameSize.Y.Offset))

LastFrame = nil

function InvokeServer(Mode, Value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(Mode, Value)
	end)
	return ServerReturn
end

function SelectFrame(Frame)
	if LastFrame then
		LastFrame.Frame.BackgroundTransparency = LastFrame.Copy.BackgroundTransparency
		LastFrame.Frame.BackgroundColor3 = LastFrame.Copy.BackgroundColor3
	end
	if Frame then
		LastFrame = {Frame = Frame, Copy = Frame:Clone()}
		InvokeServer("SetIndex", {Index = ((LastFrame.Frame:FindFirstChild("Index") and LastFrame.Frame:FindFirstChild("Index").Value) or 1)})
		Frame.BackgroundTransparency = 0.75
		Frame.BackgroundColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
	end
end

FrameInformation = InvokeServer("GetIndex")

for i, v in pairs(ScrollingFrame:GetChildren()) do
	if v:IsA("GuiButton") then
		local Index = v:FindFirstChild("Index")
		if Index and Index.Value == FrameInformation.Index then
			SelectFrame(v)
		end
		v.MouseButton1Down:connect(function()
			SelectFrame(v)
		end)
	end
end

ScreenGui.Changed:connect(function(Property)
	if Property == "AbsoluteSize" or Property == "AbsolutePosition" then
		ScrollingFrame.Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X - ScrollingFrame.AbsoluteSize.X - FrameSize.X.Offset), 0, (ScreenGui.AbsoluteSize.Y - ScrollingFrame.AbsoluteSize.Y - FrameSize.Y.Offset))
	end
end)