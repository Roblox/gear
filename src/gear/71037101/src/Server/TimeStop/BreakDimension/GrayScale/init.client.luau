--Time stop visual effect
--Made by TakeoHonorable

local GrayScale,Duration = script:WaitForChild("GrayScale"),script:WaitForChild("Duration")

local Services = {
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
}

GrayScale.Parent = workspace.CurrentCamera
local InTween = Services.TweenService:Create(GrayScale,TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Saturation = -1})
InTween:Play()
InTween.Completed:Wait()
wait(Duration.Value)
Services.TweenService:Create(GrayScale,TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Saturation = 0}):Play()