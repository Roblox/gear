-- Script that will be inserted into the target character for damage over time 

function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do wait(1.0) print("Waiting") end
	print("Found Child")
end

waitForChild(script, "Poison")
waitForChild(script, "creator")
poison = script:FindFirstChild("Poison")

local poisonDuration = poison.Value.Y
local poisonDamage = poison.Value.X

print("Poison Tag missing")



tag = script:FindFirstChild("creator")
tag.Parent = script.Parent:FindFirstChild("Humanoid")

torso = script.Parent:FindFirstChild("Torso")

if torso:FindFirstChild("Smoke") == nil then
	smoke = Instance.new("Smoke")
	smoke.RiseVelocity = 0.1
	smoke.Size = 0.1
	smoke.Color = Color3.new(0.0, 0.9, 0.0)
	smoke.Parent = torso
	smoke.Opacity = 0.2
	smoke.Enabled = true
end


humanoid = script.Parent:FindFirstChild("Humanoid")

while poisonDuration > 0 do 	
		humanoid:TakeDamage(poisonDamage)		
		poisonDuration = poisonDuration - 1
		script.Poison.Value = Vector3.new(script.Poison.Value.X, script.Poison.Value.Y - 1, 0)
		poisonDuration = script.Poison.Value.Y
		wait(1.0)	
end

smoke:Remove()
tag:Remove()

wait(1.0)
script:Remove()