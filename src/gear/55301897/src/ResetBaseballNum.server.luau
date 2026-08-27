local Tool = script.Parent

local baseballsRemaining

function resetBaseballNumber(child)
	if (child.Name == "Giant Baseball") then
		baseballsRemaining = Tool:FindFirstChild("BaseballsRemaining")
		if not baseballsRemaining then return end
		baseballsRemaining.Value = baseballsRemaining.Value + 1
	end
end

game.Workspace.ChildRemoved:connect(resetBaseballNumber)