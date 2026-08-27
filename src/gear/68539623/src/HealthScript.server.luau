--Made by Luckymaxer

Tool = script.Parent

ShieldActive = Tool:WaitForChild("ShieldActive")

LastValue = ShieldActive.Value

ShieldActive.Changed:connect(function()
	if Humanoid then
		if ShieldActive.Value == 0 and Humanoid.MaxHealth > 100 then 
			ratio = Humanoid.Health / Humanoid.MaxHealth 
			Humanoid.Health = ratio * 100
			Humanoid.MaxHealth = 100	
		elseif ShieldActive.Value == 1 then
			ratio = Humanoid.Health / Humanoid.MaxHealth
			Humanoid.MaxHealth = 175		
			wait(0.2)
			Humanoid.Health = Humanoid.Health + (ratio * 75)
		end
	end
end)

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
end

Tool.Equipped:connect(Equipped)