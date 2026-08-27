local Alpaca = script.Parent

local originSize = Alpaca.Size
local originScale = Alpaca.Mesh.Scale


Alpaca.CanCollide = true
Alpaca.Rumble:play()
Alpaca.Grow:play()

for i = 1, 12, 0.1 do
	local cf = Alpaca.CFrame
	
	Alpaca.Size = originSize * i
	Alpaca.Mesh.Scale = originScale * i
	
	Alpaca.CFrame = cf

	Alpaca.Grow.Pitch = 2.2 - i / 100 * 2
	
	for _, Sound in pairs(Alpaca:GetChildren()) do
		if Sound:IsA("Sound") and not(Sound == Alpaca.Rumble or Sound == Alpaca.Grow) then
			Sound.Pitch = 1.3 - i / 100 * 1.05
		end
	end
	wait()
end


for i = Alpaca.Rumble.Volume, 0, -0.1 do
	Alpaca.Rumble.Volume = i
	Alpaca.Grow.Volume = i

	wait()
end

Alpaca.Rumble:stop()
Alpaca.Grow:stop()