--Stickmasterluke was here last. ;D   mMMmmm

local Tool = script.Parent;

enabled = true

extra=100


function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(0.675, -0.675, -0.3)
	Tool.GripPos = Vector3.new(0.4, -0.59, 1.1)
	Tool.GripRight = Vector3.new(0.212, -0.212, 0.954)
	Tool.GripUp = Vector3.new(0.707, 0.707, 0)


	Tool.Handle.DrinkSound:Play()

	wait(.8)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		h.MaxHealth=h.MaxHealth+extra
		h.Health=h.Health+extra
		wait(.6)
		Tool:remove()
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
