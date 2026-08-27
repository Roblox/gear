wait(0.5)
script.Parent.CamFocus.Changed:connect(function()
	local o = script.Parent.CamFocus.Value
	if o then
		wait()
		game.Workspace.CurrentCamera.CameraType = 1
		game.Workspace.CurrentCamera.CameraSubject = o
	else
		wait()
		game.Workspace.CurrentCamera.CameraType = 5	
		game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid	
	end
end)