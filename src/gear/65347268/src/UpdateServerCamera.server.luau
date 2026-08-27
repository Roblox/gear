local function waitForChild(parent, childName)
	local child = parent:findFirstChild(childName)
	if child then return child end
	while true do
		child = parent.ChildAdded:wait()
		if child.Name == childName then return child end
	end
end

local camRef = script.Parent

waitForChild(camRef,"CameraPos")
waitForChild(camRef,"CameraFocus")
local camPos = camRef.CameraPos
local camFocus = camRef.CameraFocus

local debounce = false
function updateServerCamera()
	if debounce then return end
	debounce = true
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
		game.Workspace.CurrentCamera.CoordinateFrame = CFrame.new(camPos.Value,camFocus.Value)
		game.Workspace.CurrentCamera.Focus = CFrame.new(camFocus.Value)
	debounce = false
end

updateServerCamera()
camFocus.Changed:connect(updateServerCamera)
