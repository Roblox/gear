while not script.Parent:FindFirstChild('TargetModel') do
	script.Parent.ChildAdded:wait()
end

local Target = script.Parent.TargetModel.Value

local hum = Target:FindFirstChild('Humanoid')
if hum then
	for i = 1, 17 do
		hum:TakeDamage(2)
		wait(0.07)
	end
end
