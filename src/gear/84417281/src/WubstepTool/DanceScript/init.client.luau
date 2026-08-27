--Rescripted by Luckymaxer

Character = script.Parent
Humanoid = Character:WaitForChild("Humanoid")

DanceAnim = script:WaitForChild("DanceAnim")

Humanoid.WalkSpeed = 0

DanceAnim = Humanoid:LoadAnimation(script.DanceAnim)
DanceAnim:Play() 

wait(8.0)
DanceAnim:Stop() 
Humanoid.WalkSpeed = 16

wait(4.0)

script:Destroy()