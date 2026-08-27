local Tool = script.Parent;

enabled = true

function onActivated()
	if not enabled  then
		return
	end

	enabled = false

	Tool.Handle.DrinkSound:Play()

	wait(1)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (Tool.Parent:FindFirstChild("RegenEffect") == nil) then
			local s = script.Parent.RegenEffect:Clone()
			s.Disabled = false
			s.Parent = Tool.Parent			
		end
	end

	wait(5)
	enabled = true
end

script.Parent.Activated:connect(onActivated)
