local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(-0.857, -0.514, -0)
	Tool.GripPos = Vector3.new(-0.35, -0.45, -1.62)
	Tool.GripRight = Vector3.new(0, 0, -1)
	Tool.GripUp = Vector3.new(-0.514, 0.857, 0)


	Tool.Handle.DrinkSound:Play()

	wait(.8)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (h.MaxHealth > h.Health + 1.6) then
			h.Health = h.Health + 1.6
		else	
			h.Health = h.MaxHealth
		end
	end

	Tool.GripForward = Vector3.new(0.1, -0.6, -0.1)
	Tool.GripPos = Vector3.new(0.1, -0.6, -0.1)
	Tool.GripRight = Vector3.new(0, 0, -1)
	Tool.GripUp = Vector3.new(0,1,0)


	enabled = true

end

function onEquipped()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
