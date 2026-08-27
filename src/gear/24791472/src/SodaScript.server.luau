local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(-0.958, -0.287, -0)
	Tool.GripPos = Vector3.new(-0.5, -0.3, -1.3)
	Tool.GripRight = Vector3.new(0, 0, -1)
	Tool.GripUp = Vector3.new(-0.287, 0.958, -0)


	Tool.Handle.DrinkSound:Play()

	wait(1)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (Tool.Parent:FindFirstChild("SpeedEffect") == nil) then
			local s = script.Parent.SpeedEffect:Clone()
			s.Disabled = false
			s.Parent = Tool.Parent			
		end
	end


	Tool.GripForward = Vector3.new(-1, 0,-0)
	Tool.GripPos = Vector3.new(0.2,-.1,0)
	Tool.GripRight = Vector3.new(0,0,-1)
	Tool.GripUp = Vector3.new(0,1,0)


	wait(60)
	enabled = true

end



script.Parent.Activated:connect(onActivated)

