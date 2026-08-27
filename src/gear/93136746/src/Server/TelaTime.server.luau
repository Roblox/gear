--Changes the time to
local Services = {
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
}

local DefaultTime = Services.Lighting.ClockTime

local Tween = TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local Lighting_Tween = Services.TweenService:Create(Services.Lighting,Tween,{ClockTime = 18})
Lighting_Tween:Play();Lighting_Tween.Completed:Wait()

wait(2)

Lighting_Tween = Services.TweenService:Create(Services.Lighting,Tween,{ClockTime = DefaultTime})
Lighting_Tween:Play();Lighting_Tween.Completed:Wait()
script:Destroy()