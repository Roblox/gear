local Tool = script.Parent
local humanoid = nil

function onEquipped()

	humanoid = Tool.Parent:FindFirstChild("Humanoid")

end

function onUnequipped()

	if humanoid ~= nil then
		if Tool.DanceObject.Value ~= nil then
			Tool.DanceObject.Value:Stop()
			Tool.DanceObject.Value:remove()
		end
	end

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
