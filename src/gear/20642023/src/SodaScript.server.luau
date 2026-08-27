local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(-0, -0.836, -0.549)
	Tool.GripPos = Vector3.new(1.4, -0.4, 0.3)
	Tool.GripRight = Vector3.new(0.996, -0.0509, 0.0776)
	Tool.GripUp = Vector3.new(0.0928, 0.547, -0.832)


	Tool.Handle.DrinkSound:Play()

	wait(3)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (Tool.Parent:FindFirstChild("SpeedEffect") == nil) then
			local s = script.Parent.SpeedEffect:Clone()
			s.Disabled = false
			s.Parent = Tool.Parent			
		end
	end


	Tool.GripForward = Vector3.new(-.976,0,-0.217)
	Tool.GripPos = Vector3.new(0.2,-.1,0)
	Tool.GripRight = Vector3.new(.217,0,-.976)
	Tool.GripUp = Vector3.new(0,1,0)


	wait(60)
	enabled = true

end



script.Parent.Activated:connect(onActivated)

