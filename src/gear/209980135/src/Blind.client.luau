local Char = script.Parent
local Player = game:GetService("Players"):GetPlayerFromCharacter(Char)

if Player then
	local sg = Instance.new("ScreenGui")
	
	local blind = Instance.new("Frame")
	blind.Size = UDim2.new(2, 0, 2, 0)
	blind.Position = UDim2.new(-0.5, 0, -0.5, 0)
	blind.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
	blind.Parent = sg
	
	sg.Parent = Player.PlayerGui
	
	wait(3)
	
	while blind.BackgroundTransparency < 1 do
		local dt = wait()
		blind.BackgroundTransparency = blind.BackgroundTransparency + (dt * 0.5)
	end
	
	sg:Destroy()
end

game:GetService("Debris"):AddItem(script)