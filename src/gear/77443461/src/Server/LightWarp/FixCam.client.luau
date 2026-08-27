local Camera = workspace.CurrentCamera
local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
}

repeat
	Camera.CameraSubject = game.Players.LocalPlayer.Character
	Camera.CameraType = Enum.CameraType.Custom
	Services.RunService.RenderStepped:Wait()
until not script

