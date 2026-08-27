vCharacter = script.Parent

myHumanoid = vCharacter:FindFirstChild("Humanoid")

myTorso = vCharacter:FindFirstChild("Torso")

local duration = 6
if vCharacter ~= nil and myHumanoid ~= nil and myTorso ~= nil then
	smoke = myTorso:FindFirstChild("Smoke")
	myHumanoid.WalkSpeed = -16
	while duration > 0 do 
		duration = duration - 1
		myHumanoid:TakeDamage(5)
		wait(1.0)
	end	
	if smoke then smoke:Remove() end
	myHumanoid.WalkSpeed = 16
end

wait(2)
script:Remove() 
