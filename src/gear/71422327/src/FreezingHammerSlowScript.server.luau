local vCharacter = script.Parent
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local duration = 3.5 

if myHumanoid then 
	myHumanoid.WalkSpeed = 10.0
	wait(duration)
	myHumanoid.WalkSpeed = 16.0
end 

wait(1.0)
script:Remove() 
