local Tool = script.Parent

local r = (game:FindService("RunService") or game:GetService("RunService"))

local Angle = Tool:WaitForChild("Angle")

while Angle do
	if workspace.CurrentCamera then
		Angle.Value = workspace.CurrentCamera.CoordinateFrame.lookVector
	end
	r.RenderStepped:Wait()
end

