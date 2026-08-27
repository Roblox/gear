local laughAni= Instance.new("Animation")
	laughAni.AnimationId = "http://www.roblox.com/Asset?ID=86258575"

local player = game.Players.LocalPlayer
local character = player.Character
 


local startTime= time()
local hum=script.Parent:FindFirstChild('Humanoid')
local animTrack=hum:LoadAnimation(laughAni)
local ltime=script:FindFirstChild("laughTime")
while not ltime do
	ltime=script:FindFirstChild("laughTime")
	wait()
end
animTrack:Play()

while(time()-startTime<ltime.Value) do
	if hum then 
		hum.Jump=false 
		hum.Sit=true 
	end
	wait(.3)

	if hum then 
		hum.Sit=false 
		hum.Jump=true 
	end
	wait(.2)
	hum:TakeDamage(5)
end

if hum then 
	hum.Sit=false 
	hum.Jump=false
end

animTrack:Stop()

print("stopped laughing")

script:Destroy()
