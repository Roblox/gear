--Made by Luckymaxer

Humanoid = script.Parent
OriginalWalkSpeed = Humanoid.WalkSpeed
Humanoid.WalkSpeed = 0
wait(10)
Humanoid.WalkSpeed = OriginalWalkSpeed

script:Destroy()