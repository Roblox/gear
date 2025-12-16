local cam = game.Workspace.CurrentCamera
for i = 1, 5 do
wait()
local cam_rot = cam.CoordinateFrame - cam.CoordinateFrame.p --* CFrame.fromEulerAnglesXYZ(math.random(-10, 10)/10, math.random(-10, 10)/10, 0)
local cam_scroll = (cam.CoordinateFrame.p - cam.Focus.p).magnitude
local ncf = CFrame.new(cam.Focus.p)*cam_rot*CFrame.fromEulerAnglesXYZ(math.random(-10, 10)/40, math.random(-10, 10)/40, 0)
cam.CoordinateFrame = ncf*CFrame.new(0, 0, cam_scroll)
end
script:remove()
