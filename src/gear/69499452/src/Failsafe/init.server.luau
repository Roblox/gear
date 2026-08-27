while not script:FindFirstChild("Humanoid") do
	script.ChildAdded:wait()
end
script.Humanoid.Value.Died:connect(function()
	script.Model.Value:Destroy()
end)