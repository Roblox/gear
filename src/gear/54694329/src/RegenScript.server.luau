Tool = script.Parent

vCharacter = Tool.Parent
myHumanoid = vCharacter:FindFirstChild("Humanoid")

if Tool.Name == "SummerSword" and myHumanoid then 
	while true do 
		if myHumanoid then
			if (myHumanoid.Health + 2) <= myHumanoid.MaxHealth then 
				myHumanoid.Health = myHumanoid.Health + 2			
			end
		end
		wait(1.0)
	end
end

if Tool.Name == "AllSeasonsSword" then 
	-- 5 hp regen per second
	while true do
		if myHumanoid then
			if (myHumanoid.Health + 5) <= myHumanoid.MaxHealth then
				myHumanoid.Health = myHumanoid.Health + 5 
			end
		end
		wait(1.0)
	end
end
