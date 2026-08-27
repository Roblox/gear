--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Camera = game:GetService("Workspace").CurrentCamera
Player = Players.LocalPlayer

PlayerMouse = Player:GetMouse()

Camera.FieldOfView = 70
Player.CameraMode = Enum.CameraMode.Classic
PlayerMouse.Icon = ""

Debris:AddItem(script, 2)