script.Parent.TransmitCameraCFrame.OnServerEvent:connect(function(client, cf)
	if client.Character == script.Parent.Parent then
		script.CameraCFrame.Value = cf
	end
end)