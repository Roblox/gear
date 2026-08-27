--Made by Luckymaxer

Debris = game:GetService("Debris")

pcall(function()
	Camera = game:GetService("Workspace").CurrentCamera
	Camera.CameraType = Enum.CameraType.Custom
end)

Debris:AddItem(script, 2)