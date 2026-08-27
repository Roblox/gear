--Made by Luckymaxer

Camera = game:GetService("Workspace").CurrentCamera

Rate = (1 / 60)

Shake = {Movement = 80, Rate = 0.001}

local CoordinateFrame = Camera.CoordinateFrame
local Focus = Camera.Focus
while true do
	local CameraRotation = Camera.CoordinateFrame - Camera.CoordinateFrame.p
	local CameraScroll = (CoordinateFrame.p - Focus.p).magnitude
	local NewCFrame = CFrame.new(Camera.Focus.p) * CameraRotation * CFrame.fromEulerAnglesXYZ((math.random(-Shake.Movement, Shake.Movement) * Shake.Rate), (math.random(-Shake.Movement, Shake.Movement) * Shake.Rate), 0)
	CoordinateFrame = NewCFrame * CFrame.new(0, 0, CameraScroll)
	Camera.CoordinateFrame = CoordinateFrame
	wait(Rate)
end