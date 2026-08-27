local part = script.Parent
local hb = game:GetService("RunService").Heartbeat

while hb:wait() do
	part.CFrame = CFrame.new(part.Position, part.Position + part.Velocity)
end
