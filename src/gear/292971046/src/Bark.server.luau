local tool = script.Parent
local sound = tool.Handle.Bark

tool.Activated:connect(function()
	if tool.Enabled then
		
		tool.Enabled = false
		sound:Play()
		
		wait(2)
		
		tool.Enabled = true
	end
end)

