local myCamera = game.Workspace.CurrentCamera

while true do
	wait()
	script.Parent.TransmitCameraCFrame:FireServer(myCamera.CoordinateFrame)
end