local Light = script.Parent
local TweenService = (game:FindService("TweenService") or game:GetService("TweenService"))
local LightFade = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,.5)
local ColorCycle = {}
ColorCycle[#ColorCycle+1] = Color3.fromRGB(0,0,0)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(255,255,255)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(255,0,0)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(255,176,0)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(0,255,0)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(0,0,255)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(102, 51, 0)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(170,0,170)
ColorCycle[#ColorCycle+1] = Color3.fromRGB(255, 85, 255)

while Light do
	for _,Colors in pairs(ColorCycle) do
		local Tween = TweenService:Create(Light,LightFade,{Color = Colors})
		Tween:Play()
		Tween.Completed:Wait()
	end
end