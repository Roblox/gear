local CAS, UIS = game:GetService'ContextActionService', game:GetService'UserInputService'

script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function() script.Parent.Input:FireServer('Mouse1', true, mouse.Hit.p) end)
	mouse.Button1Up:connect(function() script.Parent.Input:FireServer('Mouse1', false, mouse.Hit.p) end)
	mouse.KeyDown:connect(function(key) script.Parent.Input:FireServer('KeyDown', key) end)
	
	if UIS.TouchEnabled then
		CAS:BindActionToInputTypes(
			'TwinKodachi_DualWeild',
			function(action, state, input)
				if state == Enum.UserInputState.Begin then
					script.Parent.Input:FireServer('KeyDown', 'q')
				end
			end,
			true,
			''
		)
		CAS:SetTitle('TwinKodachi_DualWeild', 'Dual Weild')
	end
end)

script.Parent.Unequipped:connect(function()
	if UIS.TouchEnabled then
		CAS:UnbindAction('TwinKodachi_DualWeild')
	end
end)