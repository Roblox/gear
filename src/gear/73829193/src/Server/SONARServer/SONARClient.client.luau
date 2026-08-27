local Tint = script:WaitForChild("SONARTint",10)

local TintFound = workspace.CurrentCamera:FindFirstChild(Tint.Name)

if TintFound then return end

Tint.Parent = workspace.CurrentCamera