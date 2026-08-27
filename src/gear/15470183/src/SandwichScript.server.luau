local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(0.675, -0.675, -0.3)
	Tool.GripPos = Vector3.new(0.1, -0.85, 1.2)
	Tool.GripRight = Vector3.new(0.212, -0.212, 0.954)
	Tool.GripUp = Vector3.new(0.707, 0.707, 0)


	Tool.Handle.DrinkSound:Play()

	wait(3)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (h.MaxHealth > h.Health + 5) then
			h.Health = h.Health + 5
		else	
			h.Health = h.MaxHealth
		end
	end

	Tool.GripForward = Vector3.new(-0.976,0,-0.217)
	Tool.GripPos = Vector3.new(0, -0.4, 0)
	Tool.GripRight = Vector3.new(0.217,0,-0.976)
	Tool.GripUp = Vector3.new(0,1,0)


	enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
