--Made by Stickmasterluke

sp=script.Parent

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

local storeweld=waitfor(sp,"StoreWeld")

sp.Equipped:connect(function()
	if storeweld then
		storeweld.Parent=sp
	end
end)

storeweld.Parent=sp

