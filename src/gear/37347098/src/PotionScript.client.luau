local Tool = script.Parent;
local dancer = nil

enabled = true
function onActivated()
	if not enabled then return end
	enabled = false
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local torso = Tool.Parent:FindFirstChild("Torso")


	dancer = humanoid:LoadAnimation(Tool.wandswing1)
	Tool.DanceObject.Value = dancer
	dancer:Play()
	wait(3)
	dancer:Stop()
	dancer:remove()
	--root:remove()

	enabled = true
end

function onEquipped()
	--Tool.Handle.EquipSound:play()
end

function onUnequipped()
	--Tool.Handle.EquipSound:stop()
	if dancer ~= nil then
		dancer:Stop()
		dancer:remove()
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(OnUnequipped)
