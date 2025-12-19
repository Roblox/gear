function Touched(part)
	script.Parent.GlassBreak:Play()
	con:disconnect()
end



con = script.Parent.Touched:connect(Touched)

wait(30)
script.Parent:Destroy()