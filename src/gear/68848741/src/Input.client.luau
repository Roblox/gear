local UIS, CAS = game:GetService'UserInputService', game:GetService'ContextActionService'
local GamepadButtonConnection

script.Parent.Equipped:connect(function(mouse)
	mouse.KeyDown:connect(function(key) script.Parent.KeyDown:FireServer(key, mouse.Hit.p) end)
	mouse.Button1Down:connect(function(...) script.Parent.Mouse1Down:FireServer() end)
	
	if UIS.TouchEnabled then
		local tossEnabled = true
		CAS:BindActionToInputTypes(
			'SpectralSword_Toss',
			function(name, state, input)
				if tossEnabled and state == Enum.UserInputState.Begin then
					tossEnabled = false
					spawn(function()
						script.Parent.KeyDown:FireServer('q', script.Parent.Parent.HumanoidRootPart.CFrame*Vector3.new(0, 0, -32))
						
						local button = CAS:GetButton('SpectralSword_Toss')
						button.ImageColor3 = Color3.new(1/2, 1/2, 1/2)
						wait(7)
						button.ImageColor3 = Color3.new(1, 1, 1)
						tossEnabled = true
					end)
				end
			end,
			true,
			''
		)
		local terrorEnabled = true
		CAS:BindActionToInputTypes(
			'SpectralSword_Terror',
			function(name, state, input)
				if terrorEnabled and state == Enum.UserInputState.Begin then
					terrorEnabled = false
					spawn(function()
						script.Parent.KeyDown:FireServer('e')
						
						local button = CAS:GetButton'SpectralSword_Terror'
						button.ImageColor3 = Color3.new(1/2, 1/2, 1/2)
						wait(45)
						button.ImageColor3 = Color3.new(1,1,1)
						terrorEnabled = true
					end)
				end
			end,
			true,
			''
		)
		CAS:SetTitle('SpectralSword_Toss', 'Toss')
		CAS:SetTitle('SpectralSword_Terror', 'Terror')
	end
	
	-- Gamepad support
	local GPButtons = {
		ButtonB = false, -- Slash
		ButtonX = false, -- Throw
		ButtonY = false -- Terror
	}
	
	GamepadButtonConnection = UIS.InputChanged:connect(function(input)
		pcall(function() -- This will break until gamepad support is enabled
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				local button = input.KeyCode.Name
				
				if GPButtons[button] ~= nil then
					local currentDown = input.Position.Z > 0.5
					
					if GPButtons[button] ~= currentDown then
						GPButtons[button] = currentDown
						
						if currentDown then
							if button == 'ButtonB' then
								script.Parent.Mouse1Down:FireServer()
							elseif button == 'ButtonX' then
								script.Parent.KeyDown:FireServer('q', script.Parent.Parent.HumanoidRootPart.CFrame*Vector3.new(0, 0, -32))
							elseif button == 'ButtonY' then
								script.Parent.KeyDown:FireServer('e')
							end
						end
					end
				end
			end
		end)
	end)
end)

script.Parent.Unequipped:connect(function()
	if UIS.TouchEnabled then
		CAS:UnbindAction('SpectralSword_Toss')
		CAS:UnbindAction('SpectralSword_Terror')
	end
	
	if GamepadButtonConnection then GamepadButtonConnection:disconnect() end
end)