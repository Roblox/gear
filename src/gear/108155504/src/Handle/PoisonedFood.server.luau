local PlayersService = Game:GetService('Players')

local Food = script.Parent
local lastHeal = tick()

Food.Touched:connect(function(otherPart)
	while true do
		for _, i in pairs(game.Players:GetPlayers()) do
			if i.Character and i.Character:FindFirstChild('Humanoid') and i.Character:FindFirstChild('Torso') then
				local dist = (i.Character.Torso.CFrame.p-Food.CFrame.p).magnitude
				if dist<5 then i.Character.Humanoid.Health=math.min(i.Character.Humanoid.Health+1, i.Character.Humanoid.MaxHealth)
				end
			end
		end
		wait(.5)
	end
	

end)
