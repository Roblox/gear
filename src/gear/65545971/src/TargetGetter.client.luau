local Tool = script.Parent

local Mouse
local TargetedPart

function onActivated()
	if Mouse then
		TargetedPart = Tool:FindFirstChild("TargetedPart")
		if TargetedPart then
			TargetedPart.Value = Mouse.Target
		end
	end
end

function onEquipped(mouse)
	if mouse then Mouse = mouse end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)