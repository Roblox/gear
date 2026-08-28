local Tool = script.Parent;
local dancer = nil

enabled = true
function Activated()
	if not enabled then return end
	enabled = false
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local torso = Tool.Parent:FindFirstChild("Torso")


	dancer = humanoid:LoadAnimation(Tool.xswordfast3)
	Tool.DanceObject.Value = dancer
	dancer:Play(nil, nil, 2.5) --Fix implemented by Luckymaxer
	wait(1.5)
	dancer:Stop()
	dancer:remove()
	--root:remove()
	wait(.5)

	enabled = true
end

function Equipped()
	--Tool.Handle.EquipSound:play()
end

function Unequipped()
	--Tool.Handle.EquipSound:stop()
	if dancer ~= nil then
		dancer:Stop()
		dancer:remove()
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
