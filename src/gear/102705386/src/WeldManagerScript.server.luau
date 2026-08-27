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

while true do
	local t1,t2=wait(1/30)
	storeweld.C0=CFrame.new(0,2.6+(math.sin(t2*.5)*.15),0)*CFrame.Angles(0,t2%(math.pi*2),0)
end

