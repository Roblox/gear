--Made by Luckymaxer

Rate = (1 / 60)
while true do
	local Camera = game:GetService("Workspace").CurrentCamera
	local CameraRotation = Camera.CoordinateFrame - Camera.CoordinateFrame.p
	local CameraScroll = (Camera.CoordinateFrame.p - Camera.Focus.p).magnitude
	local NewCFrame = CFrame.new(Camera.Focus.p) * CameraRotation * CFrame.Angles((math.random(-10, 10) / 40), (math.random(-10, 10) / 40), 0)
	Camera.CoordinateFrame = NewCFrame * CFrame.new(0, 0, CameraScroll)
	wait(Rate)
end