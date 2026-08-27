local SPEED_INCREASE = 12

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local MyCharacter = nil
local MyHumanoid = nil

function OnEquipped(mouse)
	if not MyCharacter and not MyHumanoid then
		MyCharacter = Tool.Parent
		MyHumanoid = MyCharacter and MyCharacter:FindFirstChild('Humanoid')
		if MyHumanoid then
			MyHumanoid.WalkSpeed = MyHumanoid.WalkSpeed + SPEED_INCREASE
		end
	end
end

function OnUnequipped()
	if MyHumanoid then
		MyHumanoid.WalkSpeed = MyHumanoid.WalkSpeed - SPEED_INCREASE
	end
	MyCharacter = nil
	MyHumanoid = nil
end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
