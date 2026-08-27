local equipped = false

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

script.Parent.Equipped:connect(function(mouse)
	equipped = true
	mouse.KeyDown:connect(function(key) script.Parent.Input:FireServer(key, true) end)
	mouse.KeyUp:connect(function(key) script.Parent.Input:FireServer(key, false) end)
end)

script.Parent.Unequipped:connect(function()
	equipped = false
end)

script.Parent.StartGuiEvents.OnClientEvent:connect(function(gui)
	gui.MainFrame.ThrowPlane.MouseButton1Down:connect(function()
		script.Parent.GuiEvent:FireServer('ThrowPlane', 'Button1Down')
	end)
end)

game:GetService'UserInputService'.InputChanged:connect(function(input)
	if input.UserInputType.Name == 'Gamepad1' then
		if input.KeyCode.Name == 'Thumbstick1' then
			script.Parent.GamepadInput:FireServer('ThumbstickMovement', input.Position)
		elseif input.KeyCode.Name == 'R2' then
			script.Parent.GamepadInput:FireServer('Acceleration', input.Position.Z)
		end
	end
end)