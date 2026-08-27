--Stickmasterluke


sp=script.Parent


function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end



local h=waitfor(sp.Parent,"Humanoid")

for i=1,10 do
	h.Sit=true
	wait(1)
end

sp:remove()
