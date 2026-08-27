--Stickmasterluke


sp=script.Parent
handle=sp.Handle


script.ChildAdded:connect(function(item)
	if item~=nil then
		local s=handle:FindFirstChild(item.Name)
		if s~=nil then
			s:Play()
		end
		item:remove()
	end
end)

