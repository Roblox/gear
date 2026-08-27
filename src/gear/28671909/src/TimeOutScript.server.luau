local humanoid = script.Parent:FindFirstChild("Humanoid")
local Torso = script.Parent:FindFirstChild("Torso") or script.Parent:FindFirstChild("UpperTorso")
if Torso then
	humanoid.Sit = true
	Torso.Anchored = true
	wait(8)
	humanoid.Sit = false
	Torso.Anchored = false
end

script:Destroy()