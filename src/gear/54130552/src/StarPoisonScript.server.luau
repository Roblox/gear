local char = script.Parent
local humanoid = char:FindFirstChild("Humanoid")

local duration = 5

if char and humanoid then
	player = game.Players:GetPlayerFromCharacter(char)
	if player then 
		sg = Instance.new("ScreenGui")
		sg.Name = "SG"
		sg.Parent = player.PlayerGui

		image = Instance.new("ImageLabel")
		image.Name = "Starfish"
		image.Parent = sg
		image.Image = "http://www.roblox.com/asset/?id=54056513"
		image.Size = UDim2.new(1, 0, 1, 0)
		image.BackgroundTransparency = 1.0
	end
	while duration > 0 do 
		duration = duration - 1
		humanoid:TakeDamage(5)
		wait(1.0)
	end
	if sg then sg:Destroy() end
end

wait(4.0)
script:Destroy()
