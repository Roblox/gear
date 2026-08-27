--clean up the plane if the creator leaves
if script.Parent.creator.Value then
	game.Players.ChildRemoved:connect(function(p)
		if script.Parent.creator.Value.Parent == nil then
			script.Parent.Parent:remove()
		end
	end)
end
