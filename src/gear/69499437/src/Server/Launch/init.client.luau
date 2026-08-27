	--[[local Camera = workspace.CurrentCamera
	for i=1,5,1 do
		Camera.CFrame = CFrame.new(i,i,i)
	end]]
	script.Parent.Velocity = script:WaitForChild("Direction").Value
