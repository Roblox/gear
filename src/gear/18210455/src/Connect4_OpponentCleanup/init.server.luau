----------------------------------------------------------------------------
-------- cleans up the opponent's stuff if the player leaves

game.Players.ChildRemoved:connect(function(p)
	if p == script.Challenger.Value then
		script.Cleanup.Value:remove()
		script:remove()
	end
end)
		