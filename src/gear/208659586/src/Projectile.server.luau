local Projectile = script.Parent
local Heartbeat = game:GetService("RunService").Heartbeat

while Heartbeat:Wait() do
	Projectile.CFrame = CFrame.new(Projectile.Position, Projectile.Position + Projectile.Velocity)
end
