--Made by Luckymaxer

Camera = game:GetService("Workspace").CurrentCamera

Debris = game:GetService("Debris")

Duration = script:WaitForChild("Duration")

while Duration and Duration.Parent and Duration.Value > 0 do
	local CameraRotation = Camera.CoordinateFrame - Camera.CoordinateFrame.p
	local CameraScroll = (Camera.CoordinateFrame.p - Camera.Focus.p).magnitude
	local NewCFrame = CFrame.new(Camera.Focus.p) * CameraRotation * CFrame.fromEulerAnglesXYZ((math.random(-10, 10) / 40), (math.random(-10, 10) / 40), 0)
	Camera.CoordinateFrame = NewCFrame * CFrame.new(0, 0, CameraScroll)
	Duration.Value = (Duration.Value - 0.1)
	wait(.1)
end

Debris:AddItem(script, 1)