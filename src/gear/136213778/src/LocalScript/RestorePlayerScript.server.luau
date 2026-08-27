local Humanoid = script.Parent
wait(8)
if Humanoid then
	Humanoid.WalkSpeed = 16
end

script:Destroy()
script.Parent = nil