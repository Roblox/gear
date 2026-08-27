local equipped = false
local setIconCon
local Players = game:GetService'Players'

local getCharacterFromPart = function(part)
	local current = part
	local character = nil
	local humanoid = nil
	while true do
		for i, child in next, current:GetChildren() do
			if child:IsA'Humanoid' then
				character = current
				humanoid = child
				break
			end
		end
		
		if character then
			break
		else
			current = current.Parent
			
			if not current or current == game then
				break
			end
		end
	end
	
	return character, character and Players:GetPlayerFromCharacter(character), humanoid
end

script.Parent.Equipped:connect(function(mouse)
	equipped = true
	mouse.Button1Down:connect(function() script.Parent.Input:FireServer('Mouse1', true, mouse.Hit.p, mouse.Target) end)
	mouse.Button1Up:connect(function() script.Parent.Input:FireServer('Mouse1', false, mouse.Hit.p) end)
	mouse.KeyDown:connect(function(key) script.Parent.Input:FireServer('Key', true, key) end)
	mouse.KeyUp:connect(function(key) script.Parent.Input:FireServer('Key', false, key) end)
	
	setIconCon = script.Parent.SetIcon.OnClientEvent:connect(function(icon)
		mouse.Icon = icon
	end)
	
	
	CAS,UIS = game:GetService'ContextActionService',game:GetService'UserInputService'
	if UIS.TouchEnabled then
		CAS:BindActionToInputTypes(
			'TrenchWarfareShotgun_Reload',
			function()
				script.Parent.Input:FireServer('Key', true, 'r')
			end,
			true,
			''
		)
		CAS:SetTitle('TrenchWarfareShotgun_Reload', 'Reload')
	end
	while equipped do
		script.Parent.Input:FireServer('MouseMove', mouse.Hit.p, mouse.Target)
		wait(1/20)
	end
end)
script.Parent.Unequipped:connect(function()
	equipped = false
	
	if setIconCon then setIconCon:disconnect() end
	
	if CAS then CAS:UnbindAction('TrenchWarfareShotgun_Reload') end
end)