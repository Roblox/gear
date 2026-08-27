--Much efficient way to hide the backpack without causing lag

local StarterGui = game:GetService("StarterGui")

local PlayerCamera = workspace.CurrentCamera

local rService = game:GetService("RunService")

repeat
	PlayerCamera.CameraType = Enum.CameraType.Custom
	PlayerCamera.FieldOfView = 70
	PlayerCamera.CameraSubject = game.Players.LocalPlayer.Character
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	rService.RenderStepped:Wait()
until not script or not StarterGui
