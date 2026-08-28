vChar = script.Parent
humanoid= vChar:FindFirstChild("Humanoid")

if humanoid then 
	humanoid.WalkSpeed = 2.0

	children = vChar:GetChildren()
	for i = 1, #children do 
		if children[i]:IsA("Tool") then 
			children[i].Parent = workspace
		end
	end	
end

wait(2.0)

humanoid.WalkSpeed = 16.0
script:Destroy() 
