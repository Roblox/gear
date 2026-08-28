vCharacter = script.Parent
myHumanoid = vCharacter:FindFirstChild("Humanoid")
myTorso = vCharacter:FindFirstChild("Torso")



local count = 5

while myHumanoid and count > 0 do 	
		print(count)
		myHumanoid:TakeDamage(10)
		count = count - 1
		wait(1.0)
end

if myTorso then 
	fire = myTorso:FindFirstChild("Fire")
	if fire then fire:Remove() end
end

wait(1.0)

script:Remove()
	
