local hum = script.Parent:FindFirstChild('Humanoid')
if not hum then return end

hum.WalkSpeed = 0
hum.PlatformStand = true

wait(2)

hum.WalkSpeed = 16
hum.PlatformStand = false