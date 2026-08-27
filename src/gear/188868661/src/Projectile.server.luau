local Part = script.Parent
local Heartbeat = game:GetService("RunService").Heartbeat

while Heartbeat:wait() do
	Part.CFrame = CFrame.new(Part.Position, Part.Position + Part.Velocity)
end
