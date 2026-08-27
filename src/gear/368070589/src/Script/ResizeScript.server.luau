--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

--ResizeModule = require(201433042)
ResizeModule = require(game.ReplicatedStorage.ScaleModule.MainModule)

DelayWait = script:FindFirstChild("Delay")
Duration = script:FindFirstChild("Duration")

function DestroyScript()
	Debris:AddItem(script, 1)
end

if not Humanoid or not Duration then
	DestroyScript()
	return
end

if DelayWait then
	wait(DelayWait.Value)
end

local ResizeData = ResizeModule.ScaleCharacter(Character, 1.75, {ScaleTools = true, ScaleHats = true, ScaleBack = {Delay = Duration.Value}})
ResizeData.StateChanged.Changed:connect(function(State)
	if not State then
		Humanoid.WalkSpeed = 18
	else
		Humanoid.WalkSpeed = 16
		DestroyScript()
	end
end)