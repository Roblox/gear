local CAS, UIS = game:GetService'ContextActionService', game:GetService'UserInputService'

script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function() script.Parent.Input:FireServer('Mouse1', true, mouse.Hit) end)
	mouse.KeyDown:connect(function(key) script.Parent.Input:FireServer('Key', true, key) end)
	
	if UIS.TouchEnabled then
		CAS:BindActionToInputTypes(
			'Finnster_DualWield',
			function(name, state, input)
				if state == Enum.UserInputState.Begin then
					script.Parent.Input:FireServer('Key', true, 'q')
				end
			end,
			true,
			''
		)
		CAS:SetTitle('Finnster_DualWield', 'Dual Wield')
	end
end)

script.Parent.Unequipped:connect(function(mouse)
	if UIS.TouchEnabled then
		CAS:UnbindAction('Finnster_DualWield')
	end
end)