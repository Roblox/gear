local Tool = script.Parent;
local dancer = nil

local hasRiddleSkull = false

enabled = true
function onActivated()
	if not enabled then return end
	enabled = false
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local torso = Tool.Parent:FindFirstChild("Torso")

	local vCharacter = Tool.Parent
	if vCharacter ~= nil and vCharacter.Name ~= "Backpack" then
		--local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		--if vPlayer ~= nil then
--			if (vPlayer.Backpack:FindFirstChild("RiddlingSkull") ~= nil) then hasRiddleSkull = true
			if vCharacter:FindFirstChild("RiddlingSkull") ~= nil then hasRiddleSkull = true
			else hasRiddleSkull = false end
		--end
	end

	dancer = humanoid:LoadAnimation(Tool.staffspin)
	Tool.DanceObject.Value = dancer
	dancer:Play()
	if hasRiddleSkull then wait(2) dancer:Play() wait(2) dancer:Play() wait(1)
	else wait(1) end
	dancer:Stop()
	dancer:remove()
	--root:remove()
	wait(.3)
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
