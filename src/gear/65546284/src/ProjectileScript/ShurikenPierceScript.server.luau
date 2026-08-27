local vCharacter = script.Parent
local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

if myTorso == nil or myHumanoid == nil then 
	script:Remove()
end

local duration = 7.0

while duration > 0 do 
	myHumanoid:TakeDamage(4.0)
	duration = duration - wait(1.0)
	wait(1.0)
end

wait(1.0)

script:Remove()
