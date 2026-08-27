local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(-0.97, 1.02e-005, -0.243)
	Tool.GripPos = Vector3.new(-0.2, 0, -1.23)
	Tool.GripRight = Vector3.new(0.197, 0.581, -0.79)
	Tool.GripUp = Vector3.new(-0.141, 0.814, 0.563)


	Tool.Handle.EatSound:Play()

	wait(.8)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (h.MaxHealth > h.Health + 1.6) then
			h.Health = h.Health + 1.6
		else	
			h.Health = h.MaxHealth
		end
	end

	Tool.GripForward = Vector3.new(1, 0, -0)
	Tool.GripPos = Vector3.new(-0.2, 0, -0.3)
	Tool.GripRight = Vector3.new(0,-1, 0)
	Tool.GripUp = Vector3.new(0,0,1)


	enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
