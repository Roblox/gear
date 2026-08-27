local Human = script.Parent
local Percent = script:WaitForChild("Percentage")
local Duration = script:WaitForChild("Duration")
local Delta = Human.WalkSpeed * Percent.Value

Human.WalkSpeed = Human.WalkSpeed - Delta
wait(Duration.Value)
Human.WalkSpeed = Human.WalkSpeed + Delta

game:GetService("Debris"):AddItem(script, 0)
