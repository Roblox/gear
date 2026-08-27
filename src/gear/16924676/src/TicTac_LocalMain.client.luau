local clicks = 0
local con = nil

local ChooseOpponent = script.Parent:WaitForChild("ChooseOpponent")

script.Parent.Equipped:Connect(function(mouse)
	script.Name = "TicTac_LocalMain_Selected"
	--when clicked look for an opponent
	con = mouse.Button1Down:Connect(function()
		--check for a humanoid
		--OR hack for quick elimination of possible "no mouse.Target" condition
		--print(mouse.Target)
		local humanoid = mouse.Target and mouse.Target.Parent:FindFirstChildOfClass("Humanoid")
		local torso = humanoid and (humanoid.Parent:FindFirstChild("Torso") or humanoid.Parent:FindFirstChild("UpperTorso"))
		if torso and (torso.Position - script.Parent.Handle.Position).Magnitude < 16 then
			if humanoid then
				--check if the humanoid belongs to a player
				local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
				if player then
					--replicate the opponent value to the server sided script
					--script.Parent.Opponent.Value = player
					ChooseOpponent:FireServer(player)
					
					--
					clicks = clicks + 1
					script.Name = tostring(clicks)
				end
			end
		end
	end)
end)

script.Parent.Unequipped:Connect(function()
	if con then
		con:Disconnect()
		con = nil
	end
	script.Name = "TicTac_LocalMain_NotSelected"
end)
