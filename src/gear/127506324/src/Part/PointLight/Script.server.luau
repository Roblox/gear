while true do
	script.Parent.Brightness = 5+(math.cos(tick())*2)
	script.Parent.Range = 10+(math.sin(tick())*4)
	wait()
end