local vCharacter = script.Parent
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local duration = 4

if myHumanoid then 
	while duration > 0 do
		myHumanoid:TakeDamage(8)
		duration = duration - 1
		wait(1)
	end
end

wait(1.0)
script:Remove()
