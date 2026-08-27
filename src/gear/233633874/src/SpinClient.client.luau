local Char = script.Parent
local Root = Char:WaitForChild("HumanoidRootPart")
local Human = Char:WaitForChild("Humanoid")

local RenderStepped = game:GetService("RunService").RenderStepped

local WalkSpeedDelta = Human.WalkSpeed
Human.WalkSpeed = Human.WalkSpeed - WalkSpeedDelta

local TimeToStop = tick() + 2
while tick() < TimeToStop do
	RenderStepped:wait()
	
	Root.CFrame = Root.CFrame * CFrame.Angles(0, 0.25, 0)
end

Human.WalkSpeed = Human.WalkSpeed + WalkSpeedDelta

game:GetService("Debris"):AddItem(script, 0)