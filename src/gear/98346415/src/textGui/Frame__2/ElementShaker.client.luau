local Element = script.Parent

local ShakeSpeed = .05

local ShakeAmount = 5

local StartPosition=Element.Position

while true do
	local angle= math.random()*math.pi*2
	Element:TweenPosition(StartPosition+UDim2.new(0,math.cos(angle)*ShakeAmount,0,math.sin(angle)*ShakeAmount), "Out", "Quad", ShakeSpeed, true)
	wait(ShakeSpeed+.01)
end