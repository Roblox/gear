-- Injection Script that reduces the character's speed 

local Tool = script.Parent 

local walkSpeed = Tool:FindFirstChild("Humanoid").WalkSpeed 

local count = 0

for j = walkSpeed, 0, -2 do
	if count < 5 then
		Tool:FindFirstChild("Humanoid").WalkSpeed = walkSpeed - j
		wait(1.0)
		count = count + 1	
	end
end

Tool:FindFirstChild("Humanoid").WalkSpeed = 16.0

wait(2.0)

script:Remove()
