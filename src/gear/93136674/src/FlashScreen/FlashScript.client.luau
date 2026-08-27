local Length=.25
local StartTime=time()
local MinTransparency=.6

while time()-StartTime<Length do
	script.Parent.Frame.Transparency=MinTransparency+(((time()-StartTime)/Length)*(1-MinTransparency))
	wait()
end

script.Parent:Destroy()
