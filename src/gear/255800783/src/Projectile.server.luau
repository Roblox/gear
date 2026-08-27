local Projectile = script.Parent
local Heartbeat = game:GetService("RunService").Heartbeat

while Heartbeat:wait() do
	Projectile.CFrame = CFrame.new(Projectile.Position, Projectile.Position + Projectile.Velocity) * CFrame.Angles(0, 0, math.pi/2)
end
