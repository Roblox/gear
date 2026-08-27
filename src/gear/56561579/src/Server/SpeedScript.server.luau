local Character = script.Parent
local Humanoid = Character:FindFirstChild("Humanoid")
if Humanoid then
	Humanoid.WalkSpeed = 0
	wait(4)
	Humanoid.WalkSpeed = 16
end
script:Destroy()
