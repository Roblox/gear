function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local ScreenGui = script.Parent
local Frame = waitForChild(ScreenGui, "MessageFrame")
local OKButton = waitForChild(Frame, "OKButton")
local MessageText = waitForChild(Frame, "MessageText")

OKButton.MouseButton1Click:connect(function() ScreenGui:Remove() end)
