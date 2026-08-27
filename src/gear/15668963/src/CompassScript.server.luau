local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	Tool.Handle.OpenSound:play()
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		local s = script.Parent.CompassEffect:Clone()
		s.Disabled = false
		s.Parent = Tool.Parent			
	end


	wait(3)

	enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
