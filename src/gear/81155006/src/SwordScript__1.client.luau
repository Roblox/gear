local UIS, CAS = game:GetService'UserInputService', game:GetService'ContextActionService'

script.Parent.Equipped:connect(function(mouse)
	mouse.KeyDown:connect(function(key) script.Parent.Input:Fire('Key', true, key) end)
	
	if UIS.TouchEnabled then
		local out2 = false
		local detatched = false
		CAS:BindActionToInputTypes(
			'MoreElegantBlase_UnsheathSecond',
			function(action, state, input)
				if state == Enum.UserInputState.Begin and not detatched then
					script.Parent.Input:FireServer('Key', true, 'q')
					
					if out2 then
						out2 = false
						CAS:SetTitle('MoreElegantBlase_UnsheathSecond', 'Unsheath')
					else
						out2 = true
						CAS:SetTitle('MoreElegantBlase_UnsheathSecond', 'Sheath')
						
						
						CAS:SetTitle('MoreElegantBlade_Disconnect', 'Disconnect')
						detatched = false
					end
				end
			end,
			true,
			''
		)
		CAS:BindActionToInputTypes(
			'MoreElegantBlade_Disconnect',
			function(action, state, input)
				if state == Enum.UserInputState.Begin and out2 then
					if not detatched then
						detatched = true
						CAS:SetTitle('MoreElegantBlade_Disconnect', 'Connect')
						script.Parent.Input:FireServer('Key', true, 'x')
					else
						detatched = false
						CAS:SetTitle('MoreElegantBlade_Disconnect', 'Disconnect')
						script.Parent.Input:FireServer('Key', true, 'e')
					end
				end
			end,
			true,
			''
		)
		
		
		CAS:SetTitle('MoreElegantBlase_UnsheathSecond', 'Unsheath')
		CAS:SetTitle('MoreElegantBlade_Disconnect', 'Disconnect')
	end
end)

script.Parent.Unequipped:connect(function()
	CAS:UnbindAction'MoreElegantBlase_UnsheathSecond'
	CAS:UnbindAction'MoreElegantBlade_Disconnect'
end)