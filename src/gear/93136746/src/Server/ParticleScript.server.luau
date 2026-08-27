--Rescripted by Luckymaxer

Particle = script.Parent

local Light = script.Parent.Parent:FindFirstChildOfClass("PointLight")

Duration = Particle:WaitForChild("Duration")

wait(Duration.Value)

Light.Enabled = false
Particle.Enabled = false
