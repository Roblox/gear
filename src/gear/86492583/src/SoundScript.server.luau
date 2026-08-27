--Stickmasterluke


sp=script.Parent


function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end

firesound=waitfor(sp,"FireSound")
handle=waitfor(sp,"Handle")
sound=waitfor(handle,"FireSound")

firesound.Changed:connect(function()
	sound:Play()
end)


