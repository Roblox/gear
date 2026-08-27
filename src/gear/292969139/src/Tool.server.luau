local Tool = script.Parent
local Handle = Tool.Handle

Tool.Activated:connect(function()
	Handle.Parent = workspace
	Handle.Alpaca.Disabled = false
	Tool:Destroy()
end)