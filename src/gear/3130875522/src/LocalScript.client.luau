-- // Created by StarWars
local Tool = script.Parent

local Remotes = Tool:WaitForChild("Remotes")
local ServerControls = Remotes:WaitForChild("ServerControls")

Tool.Equipped:Connect(function(Mouse)
	
	local Debounce = false
	Mouse.Button1Up:Connect(function()
		if Debounce then return end
		
		Debounce = true
		ServerControls:InvokeServer("FireClick")
		
		wait(2)
		Debounce = false
	end)
end)