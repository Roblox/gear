local Portal = script.Parent

local Tool = script:WaitForChild("Tool").Value

local Creator = script:WaitForChild("Creator").Value

Tool.Changed:Connect(function(property)
	if not Tool.Parent then
		Portal:Destroy()
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	if player == Creator then
		Portal:Destroy()
	end
end)