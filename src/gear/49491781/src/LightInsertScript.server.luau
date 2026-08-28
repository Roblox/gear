vChar = script.Parent
humanoid = vChar:FindFirstChild("Humanoid")
local co 
healing = humanoid:FindFirstChild("Healing")


local sign = -0.2


function reset()
	wait(10.0)
	if humanoid.Health > 70 then humanoid.Health = humanoid.Health - 50 end
	if humanoid.MaxHealth > 100 then humanoid.MaxHealth = 100 end
	healed = humanoid:FindFirstChild("Healing")
	if healed then healed:Remove() end
	field = vChar.Torso:FindFirstChild("Field")	
	if field then field:Remove() end
	script:Remove()
end


if humanoid ~= nil then 
	if humanoid.MaxHealth == 100 and humanoid.Health <= humanoid.MaxHealth then 
		humanoid.MaxHealth = 150 
		humanoid.Health = humanoid.Health + 50
		co = coroutine.create(reset)
		coroutine.resume(co)
	end
end
	
while healing do 	
	field = vChar.Torso:FindFirstChild("Field")	
	while field == nil do wait(1.0) field = vChar.Torso:FindFirstChild("Field") end	
	field.Transparency = field.Transparency + sign
	sign = sign * -1
	wait(1.0)
end