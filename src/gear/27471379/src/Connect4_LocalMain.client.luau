local clicks = 0
local con = nil

script.Parent.Equipped:connect(function(mouse)
	script.Name = "TicTac_LocalMain_Selected"
	--when clicked look for an opponent
	con = mouse.Button1Down:connect(function()
		--check for a humanoid
		--OR hack for quick elimination of possible "no mouse.Target" condition
		local humanoid = (mouse.Target or game.Workspace).Parent:FindFirstChild("Humanoid")
		if (humanoid) then
			local torso = humanoid.Parent:FindFirstChild("Torso")
			if torso then
				if humanoid then
					--check if the humanoid belongs to a player
					local player = game.Players:playerFromCharacter(humanoid.Parent)
					if player then
						--replicate the opponent value to the server sided script
						script.Parent.Opponent.Value = player
						--
						clicks = clicks + 1
						script.Name = tostring(clicks)
					end
				end
			end
		end
	end)
end)

script.Parent.Unequipped:connect(function()
	if con then
		con:disconnect()
		con = nil
	end
	script.Name = "TicTac_LocalMain_NotSelected"
end)
