local block = script:WaitForChild'Block'.Value

block.Touched:connect(function(hit)
	script.Report:FireServer(block.CFrame, hit)
end)