local Tool = script.Parent
Tool.Enabled = true
local Players = game:GetService'Players'

GetCharacterFromPart = function(part)
	local current = part
	local character = nil
	while true do
		for i, child in next, current:GetChildren() do
			if child:IsA'Humanoid' then
				character = current
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
	
	return character, character and Players:GetPlayerFromCharacter(character)
end

Tool.Equipped:Connect(function(mouse)
	mouse.Icon = 'rbxasset://textures/GunCursor.png'
	
	mouse.Button1Down:Connect(function()
		local hit = mouse.Target
		local char = GetCharacterFromPart(hit)
		
		if char then
			Tool.SwapWith:FireServer(char)
			
			mouse.Icon = 'rbxasset://textures/GunWaitCursor.png'
			Tool.Enabled = false
			wait(2)
			mouse.Icon = 'rbxasset://textures/GunCursor.png'
			Tool.Enabled = true
		end
	end)
end)