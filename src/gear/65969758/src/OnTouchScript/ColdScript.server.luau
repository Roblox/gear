vCharacter = script.Parent
myHumanoid = vCharacter:FindFirstChild("Humanoid")
myTorso = vCharacter:FindFirstChild("Torso")

local count = 5
while myHumanoid and count > 0 do 			
		myHumanoid:TakeDamage(7)
		myHumanoid.WalkSpeed = myHumanoid.WalkSpeed - 8.0
		count = count - 1
		wait(1.0)
end

if (myHumanoid.WalkSpeed + 8.0) < 20.0 then 
	myHumanoid.WalkSpeed = myHumanoid.WalkSpeed + 8.0 
else
	myHumanoid.WalkSpeed = 16.0
end

if myTorso then 
	fire = myTorso:FindFirstChild("Ice")
	if fire then fire:Remove() end
end
wait(1.0)

script:Remove()
	
