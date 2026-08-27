----------------------------------------------------------------------------
-------- cleans up the opponent's stuff if the player leaves

game.Players.PlayerRemoving:Connect(function(p)
	if p == script.Challenger.Value then
		script.Cleanup.Value:Destroy()
		script:Destroy()
	end
end)
		