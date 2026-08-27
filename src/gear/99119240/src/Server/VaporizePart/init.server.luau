local Object = script.Parent

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local DisintegrateParticle = script:WaitForChild("Disintegreate",10)

	Object.Anchored = true
		spawn(function()
			DisintegrateParticle.Parent = Object
			DisintegrateParticle.Color = ColorSequence.new(Object.Color)
			DisintegrateParticle.Enabled = true
			for i=0,1,.01 do
				Object.Transparency = i
				DisintegrateParticle.Transparency = NumberSequence.new(i,1)
				Services.RunService.Heartbeat:Wait()
			end
		Object:Destroy()
	end)

