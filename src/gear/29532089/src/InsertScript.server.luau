local humanoid = script.Parent:FindFirstChild("Humanoid")

local walkSpeed = 16
local pbWalkSpeed = 8
humanoid.WalkSpeed = pbWalkSpeed
humanoid:TakeDamage(-10)

wait(10)

print("fast")

humanoid.WalkSpeed = walkSpeed
script:remove()