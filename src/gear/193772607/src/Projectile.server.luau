local heartbeat = game:GetService("RunService").Heartbeat
local part = script.Parent

while true do
	part.CFrame = CFrame.new(part.Position, part.Position + part.Velocity)
	heartbeat:wait()
end