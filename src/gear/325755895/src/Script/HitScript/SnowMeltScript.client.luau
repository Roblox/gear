--Made by Luckymaxer

Frame = script.Parent
Delay = script:WaitForChild("Delay")
wait(Delay.Value)
local TimeToFade = 1
local FadeRate = 0.025
local OrigTransparency = 0
for i = 1, (TimeToFade / FadeRate) do
	wait(FadeRate)
	for ii, vv in pairs(Frame:GetChildren()) do
		if vv:IsA("GuiObject") then
			vv.ImageTransparency = (OrigTransparency + (i / (TimeToFade / FadeRate)))
			vv.Position = (vv.Position + UDim2.new(0, 0, 0, math.random(0, 4)))
			vv.Size = (vv.Size + UDim2.new(0, 0, 0, math.random(0, 2)))
		end
	end
end