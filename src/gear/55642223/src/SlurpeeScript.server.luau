local Tool = script.Parent;

enabled = true


function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(0, 0.4472, -0.8944)
	Tool.GripPos = Vector3.new(1.5, -0.5, -0.1)
	Tool.GripRight = Vector3.new(1.0, 0.0, 0.0)
	Tool.GripUp = Vector3.new(0, 0.8944, 0.4472)


	Tool.Handle.DrinkSound:Play()

	wait(2.0)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (Tool.Parent:FindFirstChild("SpeedEffect") == nil) then
			local s = script.Parent.SpeedEffect:Clone()
			s.Disabled = false
			s.Parent = Tool.Parent			
		end
	end


	Tool.GripForward = Vector3.new(-0.6, 0.8, 0.0)
	Tool.GripPos = Vector3.new(0.2, -0.2,0)
	Tool.GripRight = Vector3.new(0.8, 0.6, 0.0)
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)


	wait(30)
	enabled = true

end



script.Parent.Activated:connect(onActivated)

