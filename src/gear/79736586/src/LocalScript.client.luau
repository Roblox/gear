local animations = {}
local tool = script.Parent

local remoteConnections = {}

tool.Equipped:connect(function(mouse)
	for i,con in next, remoteConnections do
		con:disconnect()
	end
	animations = {}
	
	--
	remoteConnections.SetIcon = tool.SetIcon.OnClientEvent:connect(function(icon)
		mouse.Icon = icon
	end)
	remoteConnections.Animate = tool.Animate.OnClientEvent:connect(function(name, action) print(name,action)
		local track = animations[name] or (tool.Parent and tool.Parent:FindFirstChild'Humanoid' and tool:FindFirstChild(name) and tool.Parent.Humanoid:LoadAnimation(tool[name]))
		
		if track then
			animations[name] = track
			
			if action == 'Play' then
				track:Play()
			elseif action == 'Stop' then
				track:Stop()
			end
		end
	end)
	
	mouse.KeyDown:connect(function(key)
		if key == ' ' then
			tool.Jump:FireServer(true)
		end
	end)
	mouse.KeyUp:connect(function(key)
		if key == ' ' then
			tool.Jump:FireServer(false)
		end
	end)
	
	mouse.Button1Down:connect(function() tool.MouseDown:FireServer() end)
	mouse.Button1Up:connect(function() tool.MouseUp:FireServer() end)
end)

tool.Unequipped:connect(function()
	for name, track in next, animations do
		track:Stop()
	end
end)