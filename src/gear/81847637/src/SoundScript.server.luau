--Stickmasterluke


sp=script.Parent
sword=sp.Handle


script.ChildAdded:connect(function(item)
	if item~=nil then
		local s=sword:FindFirstChild(item.Name)
		if s~=nil then
			s:Play()
		end
		item:remove()
	end
end)

