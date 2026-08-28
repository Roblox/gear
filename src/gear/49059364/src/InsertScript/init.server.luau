local Snake = script.Parent

bodyForce = Instance.new("BodyForce")
bodyForce.force = Vector3.new(0.0, 196.1 * Snake:GetMass(), 0.0)
bodyForce.Parent = Snake

local perpVelocity
local sign = 1 

function onTouch(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	if humanoid ~= nil then 
		tag = Snake:FindFirstChild("creator")
		if tag then tag.Parent = humanoid end
		humanoid:TakeDamage(8)
		snakeBV = Snake:FindFirstChild("SnakeBV")
		if snakeBV then snakeBV:Remove() end
		newScript = script:FindFirstChild("PoisonScript")
		if newScript and humanoid:FindFirstChild("PoisonScript") == nil then 
			newScript.Parent = humanoid
			newScript.Disabled = false
		end	

		wait(1.0)
		if humanoid then tag = humanoid:FindFirstChild("creator") end
		if tag then tag:Remove() end
		if Snake then Snake:Remove() end
	end	
end

Snake.Touched:connect(onTouch)

snakeVelocity = Snake:FindFirstChild("snakeBV").velocity
print("SnakeVelocity")
if snakeVelocity then 
	print("Perp Velocity")
	perpVelocity = snakeVelocity.unit:Cross(Vector3.new(0, 1, 0))
end

while Snake do 
	snakeVelocity = Snake:FindFirstChild("snakeBV")	
	if sign == -1 then snakeVelocity.velocity = snakeVelocity.velocity + (perpVelocity * 3.0 * sign)
	else snakeVelocity.velocity = snakeVelocity.velocity + (perpVelocity * 1.5 * sign) end
	sign = sign * -1	
	wait(1.0)
end

