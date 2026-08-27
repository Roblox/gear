--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChildOfClass("Humanoid")

Debris = game:GetService("Debris")

ResizeModule = require(201433042)

Duration = script:FindFirstChild("Duration")

function DestroyScript()
	Debris:AddItem(script, 1)
end

if not Humanoid or not Duration then
	DestroyScript()
	return
end

local ResizeData = ResizeModule.ScaleCharacter(Character, 0.5, {ScaleTools = true, ScaleHats = true, ScaleBack = {Delay = Duration.Value}})
ResizeData.StateChanged.Changed:Connect(function(State)
	if not State then
		Humanoid.WalkSpeed = 26
	else
		Humanoid.WalkSpeed = 16
		DestroyScript()
	end
end)