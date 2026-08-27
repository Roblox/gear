local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(0.989, 0.148, -0)
	Tool.GripPos = Vector3.new(0.5, -0.75, 1.55)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(-0.148, 0.989, -0)


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

	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripPos = Vector3.new(0.5, -0.2, -0)
	Tool.GripRight = Vector3.new(0, 0, -1)
	Tool.GripUp = Vector3.new(0, 1, 0)


	enabled = true

end

function onEquipped()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
