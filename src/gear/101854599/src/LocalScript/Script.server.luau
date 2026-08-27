--Stickmasterluke


sp=script.Parent

fadetime=10
rate=.75

frames=fadetime/rate
for frame=1,frames do
	sp.Transparency=((frame/frames)*.5)+.25
	wait(rate)
end
sp:remove()


