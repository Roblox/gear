--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players.LocalPlayer
Camera = game:GetService("Workspace").CurrentCamera

function DestroyScript()
	Debris:AddItem(script, 1)
	return
end

Player.CameraMode = Enum.CameraMode.Classic
Camera.FieldOfView = 70

DestroyScript()