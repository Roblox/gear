local Duration =  script:WaitForChild("Duration").Value

local RunService = (game:FindService("RunService") or game:GetService("RunService"))

local Camera = workspace.CurrentCamera

local rad,sin = math.rad,math.sin

local Angle = 0

local Seed = Random.new()

local Current_Time = 0

warn(Duration)
repeat
	Camera.CFrame = Camera.CFrame * CFrame.Angles(0,0,rad(Angle))
	Angle = Angle + 5
	Current_Time = Current_Time + RunService.RenderStepped:Wait()
until Current_Time >= Duration

Camera.CFrame = Camera.CFrame * CFrame.Angles(0,0,0)