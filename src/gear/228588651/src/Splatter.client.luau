local Splatters = {
	225903962,
	225904058,
	225904105,
	225904147,
	225904216,
}

local RenderStepped = game:GetService("RunService").RenderStepped

function getSplatter()
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://"..Splatters[math.random(1, #Splatters)]
	image.Size = UDim2.new(0.9, 0, 0.9, 0)
	image.Position = UDim2.new(0.1 * math.random(), 0, 0.1 * math.random(), 0)
	
	return image
end

local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local SG = Instance.new("ScreenGui")
SG.Parent = PlayerGui

local Splatter = getSplatter()
Splatter.Parent = SG

local T = tick()
while true do
	RenderStepped:wait()
	
	local now = tick()
	local dt = now - T
	T = now
	
	Splatter.Position = Splatter.Position + UDim2.new(0, 0, 0.05 * dt, 0)
	Splatter.ImageTransparency = Splatter.ImageTransparency + 0.25 * dt
	
	if Splatter.ImageTransparency >= 1 then
		SG:Destroy()
		break
	end
end

game:GetService("Debris"):AddItem(script, 0)
