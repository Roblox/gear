local part = script.Parent
local heartbeat = game:GetService("RunService").Heartbeat

while true do
	part.CFrame = CFrame.new(part.Position, part.Position + part.Velocity)
	heartbeat:wait()
end