--Stickmasterluke


sp=script.Parent

rate=1/30

tweentime=1

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end

flakes=waitfor(sp,"Flakes")
flakes2=waitfor(sp,"Flakes2")
frost=waitfor(sp,"Frost")

flakes.Visible=true
flakes2.Visible=true
frost.Visible=true

delay(0,function()
	while true do
		tweentime=.5+(math.random()*.25)
		flakes.Position=UDim2.new(0,0,-.33,0)
		flakes:TweenPosition(UDim2.new(-.25,0,0,0),"Out","Linear",tweentime,true)
		wait(tweentime)
	end
end)

while true do
	tweentime2=.5+(math.random()*.25)
	flakes2.Position=UDim2.new(0,0,-.166666,0)
	flakes2:TweenPosition(UDim2.new(-.125,0,0,0),"Out","Linear",tweentime2,true)
	wait(tweentime2)
end
