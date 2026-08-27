--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
SpecialEnabled = Tool:WaitForChild("SpecialEnabled")
SpecialEnabled.Value = true

SpecialEnabled.Changed:connect(function()
	if not SpecialEnabled.Value then
		wait(15)
		SpecialEnabled.Value = true
	end
end)