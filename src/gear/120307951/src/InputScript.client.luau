local CAS, UIS = game:GetService'ContextActionService', game:GetService'UserInputService'

script.Parent.Equipped:Connect(function(mouse)
	mouse.Button1Down:Connect(function() script.Parent.Input:FireServer('Button1', true, mouse.Hit) end)
	mouse.Button1Up:Connect(function() script.Parent.Input:FireServer('Button1', true, mouse.Hit) end)
	mouse.KeyDown:Connect(function(key) script.Parent.Input:FireServer('Key', true, key) end)
	
	if UIS.TouchEnabled then
		local down = false
		CAS:BindActionToInputTypes(
			'NoirPeri_LightsOut',
			function(name, state, input)
				if state == Enum.UserInputState.Begin and not down then
					script.Parent.Input:FireServer('Key', true, 'q')
					
					CAS:GetButton('NoirPeri_LightsOut').ImageColor3 = Color3.new(1/2, 1/2, 1/2)
					down = true
					delay(30, function()
						CAS:GetButton('NoirPeri_LightsOut').ImageColor3 = Color3.new(1, 1, 1)
						down = false
					end)
				end
			end,
			true,
			''
		)
		CAS:SetTitle('NoirPeri_LightsOut', 'Lights out')
	end
	
	UIS.InputBegan:Connect(function(input)
		pcall(function()
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				if input.KeyCode == Enum.KeyCode.ButtonB then
					if input.UserInputState == Enum.UserInputState.Begin then
						script.Parent.Input:Fire('Button1', true, mouse.Hit)
					else
						script.Parent.Input:Fire('Button1', false, mouse.Hit)
					end
				elseif input.KeyCode == Enum.KeyCode.ButtonX then
					if input.UserInputState == Enum.UserInputState.Begin then
						script.Parent.Input:Fire('Key', true, 'q')
					end
				end
			end
		end)
	end)
end)

script.Parent.Unequipped:Connect(function()
	if UIS.TouchEnabled then
		CAS:UnbindAction'NoirPeri_LightsOut'
	end
end)

local DirectionRemote = script.Parent:WaitForChild("MouseInput",10)

function DirectionRemote.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end