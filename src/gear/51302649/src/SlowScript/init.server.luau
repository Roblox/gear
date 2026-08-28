vChar = script.Parent
myHumanoid = vChar:FindFirstChild("Humanoid")

slow = script.Slow

if myHumanoid then 
	myHumanoid.WalkSpeed = 16 - slow.Value
	wait(3.0)
	myHumanoid.WalkSpeed = 16 
end

wait(1.0)
script:Remove() 
