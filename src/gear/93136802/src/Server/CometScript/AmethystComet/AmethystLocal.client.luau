local Character = script.Parent

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
}

repeat
	for _,forces in pairs(Character:GetDescendants()) do
		if forces:IsA("BodyMover") then
			forces:Destroy()
		end
	end
	Services.RunService.RenderStepped:Wait()
until not script or not script.Parent