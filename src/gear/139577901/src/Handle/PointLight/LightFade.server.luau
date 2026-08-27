local Light = script.Parent
local TweenService = (game:FindService("TweenService") or game:GetService("TweenService"))
local LightFade = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)
local ColorCycle = {}
ColorCycle[#ColorCycle+1]=Color3.fromRGB(255,0,0)
ColorCycle[#ColorCycle+1]=Color3.fromRGB(0,255,0)
while Light do
	for _,Colors in pairs(ColorCycle) do
		local Tween = TweenService:Create(Light,LightFade,{Color = Colors})
		Tween:Play()
		Tween.Completed:Wait()
	end
end