zombie = script.Parent
local zombieHumanoid = zombie.Humanoid

omnom = Instance.new("Sound") 
omnom.Parent = zombie
omnom.Volume = 1 
omnom.SoundId = "http://www.roblox.com/asset/?id=35971877" 
omnom.Name = "Omnomnom" 

if zombieHumanoid then 
	zombieHumanoid.MaxHealth = 250
	zombieHumanoid.Health = 250

	wait(0.25)
	zombieHumanoid.Health = 250

	zombieHumanoid.WalkSpeed = 18.0
	
	neck = zombie.Torso.Neck
	neck.Part0 = zombie.Head
	neck.Part1 = zombie.Torso
end

local zombieLife = 60

local attacking = false
local enemy

local zombieOwner = zombie:FindFirstChild("Owner").Value	

function blow(hit)
	if hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid ~= nil and humanoid ~= zombieOwner and humanoid ~= zombieHumanoid and hit.Parent.Name ~= "Zombie" then 
			omnom:Play()
			humanoid:TakeDamage(20)	
		end
	end
end

connection = zombie.Torso.Touched:connect(blow)

while zombieLife > 0 do

	zombieOwner = zombie:FindFirstChild("Owner").Value	
	
	attacked = zombieOwner:GetChildren()	
	if #attacked > 1 or attacking == true then 
		if enemy == nil then 
			for i = 1, #attacked do 
				if attacked[i].Name == "creator" then 
					print(attacked[i])
					enemy =  attacked[i].Value 
					enemy = enemy.Character
				end
			end
		end
		if enemy then 
			print("Found enemy")
			attacking = true
			zombieHumanoid:MoveTo(enemy.Torso.Position, enemy.Torso)			
		else 
			attacking = false
		end	

	elseif zombieHumanoid and zombieOwner ~= nil then 
		distance = (zombieOwner.Parent.Torso.Position - zombie.Torso.Position).magnitude
		if distance > 5.0 then
			zombieHumanoid:MoveTo(zombieOwner.Parent.Torso.Position + (zombie.Torso.Position - zombieOwner.Parent.Torso.Position).unit * math.random(2, 7), zombieOwner.Parent.Torso)
		end
	else
		print("No owner")
	end
	wait(1.0)		
	zombieLife = zombieLife - 1
end

zombie:Remove()
