--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

SpecialReady = Tool:WaitForChild("SpecialReady")

SpecialReady.Value = true

SpecialReady.Changed:connect(function()
	if not SpecialReady.Value then
		wait(40)
		SpecialReady.Value = true
	end
end)