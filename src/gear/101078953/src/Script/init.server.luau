--Stickmasterluke was here last


sp=script.Parent

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	sp.GripForward = Vector3.new(0,-.759,-.651)
	sp.GripPos = Vector3.new(1.5,-.5,.3)
	sp.GripRight = Vector3.new(1,0,0)
	sp.GripUp = Vector3.new(0,.651,-.759)


	sp.Handle.DrinkSound:Play()

	wait(3)

	local s=script.EnergyScript:clone()
	s.Parent=sp.Parent
	s.Disabled=false

	sp.GripForward = Vector3.new(-.976,0,-0.217)
	sp.GripPos = Vector3.new(0.03,0,0)
	sp.GripRight = Vector3.new(.217,0,-.976)
	sp.GripUp = Vector3.new(0,1,0)

	wait(1)
	sp:remove()

end

function onEquipped()
	sp.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
