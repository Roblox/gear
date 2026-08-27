local function waitForChild(parent, childName)
	local child = parent:findFirstChild(childName)
	if child then return child end
	while true do
		child = parent.ChildAdded:wait()
		if child.Name==childName then return child end
	end
end

local Tool = script.Parent
waitForChild(Tool,"ScreenshotGui")
waitForChild(Tool.ScreenshotGui,"FlashFrame")
waitForChild(Tool.ScreenshotGui,"ScreenshotFrame")
waitForChild(Tool.ScreenshotGui.ScreenshotFrame, "ScreenshotText")
local gui = Tool.ScreenshotGui
local flashStep = 0.05

local active = false
Tool.Activated:connect(function()
	if active then return end
	active = true

	local camera = game.Workspace.CurrentCamera
	local cframe = game.Workspace.CurrentCamera.CoordinateFrame
	local player = game.Players:GetPlayerFromCharacter(Tool.Parent)

	local cameraShot = game.Workspace:FindFirstChild("OwnerCameraShotRef")
	if not cameraShot then
		local newCameraShot = Instance.new("Model")
		newCameraShot.Name = "OwnerCameraShotRef"
		local cameraPos = Instance.new("Vector3Value")
		cameraPos.Name = "CameraPos"
		cameraPos.Value = Vector3.new(cframe.p.x,cframe.p.y,cframe.p.z)

		local cameraFocus = Instance.new("Vector3Value")
		cameraFocus.Name = "CameraFocus"
		cameraFocus.Value = game.Workspace.CurrentCamera.Focus.p
		
		cameraPos.Parent = newCameraShot
		cameraFocus.Parent = newCameraShot

		newCameraShot.Parent = game.Workspace

		local serverScript = Tool.UpdateServerCamera:clone()
		serverScript.Parent = newCameraShot
		serverScript.Disabled = false
	else
		if cameraShot:FindFirstChild("CameraPos") then
			cameraShot.CameraPos.Value = Vector3.new(game.Workspace.CurrentCamera.CoordinateFrame.p.x,game.Workspace.CurrentCamera.CoordinateFrame.p.y,game.Workspace.CurrentCamera.CoordinateFrame.p.z)
		end
		if cameraShot:FindFirstChild("CameraFocus") then
			cameraShot.CameraFocus.Value = game.Workspace.CurrentCamera.Focus.p
		end
	end

	gui.FlashFrame.BackgroundTransparency = 0
	while gui.FlashFrame.BackgroundTransparency < 1 do
		gui.FlashFrame.BackgroundTransparency = gui.FlashFrame.BackgroundTransparency + flashStep
		wait(0.03)
	end

	active = false
end)

function setupGui()
	local player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if gui and player and player:FindFirstChild("PlayerGui") then
		gui.Parent = player.PlayerGui
		gui.FlashFrame.Visible = true
		gui.ScreenshotFrame.Visible = true
	end
end

function destroyGui()
	gui.FlashFrame.Visible = false
	gui.ScreenshotFrame.Visible = false
end

Tool.Equipped:connect(function(mouse)
	setupGui()
end)

Tool.Unequipped:connect(function()
	destroyGui()
end)