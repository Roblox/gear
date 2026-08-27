--Made by Luckymaxer

Humanoid = script.Parent

Debris = game:GetService("Debris")

Duration = script:FindFirstChild("Duration")

BaseWalkSpeed = 16

function DestroyScript()
	Debris:AddItem(script, 1)
end

if not Duration or not Humanoid:IsA("Humanoid") then
	DestroyScript()
	return
end

Humanoid.WalkSpeed = (BaseWalkSpeed * 2)

wait(Duration.Value)

Humanoid.WalkSpeed = BaseWalkSpeed

DestroyScript()