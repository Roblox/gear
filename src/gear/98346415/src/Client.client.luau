local Tool = script.Parent

local Remote = Tool:WaitForChild("Remote")

local Mouse = game.Players.LocalPlayer:GetMouse()


Tool.Activated:Connect(function()
	Remote:FireServer(Mouse.Hit.p)
end)