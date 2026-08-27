function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		wait()
	end 
	return parent:FindFirstChild(instance)
end 

local sGui = script.Parent 

local frame = waitForChild(sGui, "Challenge Frame") 
local button = waitForChild(frame, "Challenge Button") 

local accepted = waitForChild(script, "Accept") 

button.MouseButton1Click:connect(function()
	print("Accept!")
	accepted.Value = true 

	wait(3.0)

	if sGui then sGui:Destroy() end 
end) 


