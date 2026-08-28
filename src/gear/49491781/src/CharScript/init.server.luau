local vChar = script.Parent
local torso = vChar.Torso
buff = vChar.Humanoid:FindFirstChild("Buff")
numChar = script.NumChar

buffDuration = 35 -- Number of seconds the buff should last

sign = -0.2
local co

humanoid = vChar:FindFirstChild("Humanoid")

if humanoid ~= nil then 	
	maximumHealth = humanoid.MaxHealth + numChar.Value * 40
	if maximumHealth < 800 and humanoid.Health <= humanoid.MaxHealth then 		
		percentage = humanoid.Health/humanoid.MaxHealth			
		humanoid.MaxHealth = (humanoid.MaxHealth * 1.5) + numChar.Value * 40
		humanoid.Health = percentage * humanoid.MaxHealth
	else 
		percentage = humanoid.Health/humanoid.MaxHealth	
		humanoid.MaxHealth = 800
		humanoid.Health = humanoid.MaxHealth * percentage
	end	
	
end



while buff do 

field = vChar:FindFirstChild("Field") 
while field == nil do wait(1.0) field  = vChar:FindFirstChild("Field") buffDuration = buffDuration - 1 end
 
if buffDuration  < 7 then	
	field.Transparency = field.Transparency + sign
	sign = sign * -1
end

if buffDuration <= 0 then 	
	percentage = humanoid.Health/humanoid.MaxHealth 
	humanoid.MaxHealth = 100
	humanoid.Health = percentage * humanoid.MaxHealth
	if field then field:Remove() end	
	if buff then buff:Remove() end	
	buffDuration = 35
	script:Remove()	
end

buffDuration = buffDuration - 1
wait(1.0)
end

