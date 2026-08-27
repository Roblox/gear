local Tool = script.Parent;

enabled = true

function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	Tool.Handle.DrinkSound:Play()

	wait(1)
	
	local h = Tool.Parent:FindFirstChildOfClass("Humanoid")
	if (h ~= nil) then
		if (Tool.Parent:FindFirstChild("SpeedEffect") == nil) then
			local s = script.Parent.SpeedEffect:Clone()
			s.Disabled = false
			s.Parent = Tool.Parent			
		end
	end

	wait(45)
	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)
