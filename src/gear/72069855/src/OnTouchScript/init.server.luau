local arrow = script.Parent
		

local damage = 50

function onTouch(hit)	
	if hit and hit.Parent then
		print(hit.Name)
		local vChar = hit.Parent
		local humanoid = vChar:FindFirstChild("Humanoid")
		if vChar:IsA("Hat") and vChar.Parent then 
			humanoid = vChar.Parent:FindFirstChild("Humanoid")
		end 	
		if humanoid ~= nil then 
			tag = arrow:FindFirstChild("creator")
			if tag then tag.Parent = humanoid end
			if hit.Name == "Head" then damage = 100 end
			humanoid:TakeDamage(damage)
			damage = 45

			fire = arrow:FindFirstChild("Fire")
			if fire then 
				fire.Parent = vChar.Torso
				newScript = script.BurnScript
				newScript.Parent = vChar
				newScript.Disabled = false
			end
		end
		arrow:Remove()
	end
end

arrow.Touched:connect(onTouch)