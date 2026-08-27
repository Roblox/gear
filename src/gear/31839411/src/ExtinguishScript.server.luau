local bubble = script.Parent

bubble.Touched:connect(function(part)
	parts = part:GetChildren()
	for i = 1, #parts do
		if parts[i].className == "Fire" then
			parts[i].Enabled = false
		end
	end
	bubble:remove()
end)

