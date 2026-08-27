function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do print("roped waiting for " .. child) wait() end
	return parent[child]
end

local handle = WaitForChild(script.Parent,'Handle')

script.Parent.Grip = CFrame.new(1.40000021, 1.96000028, -1.4000001, 1, 0, 0, 0, 1, -3.9340253e-007, 0, 3.9340253e-007, 1)

handle.Size = Vector3.new(0.2, 4.89, 6.08)