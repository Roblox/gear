--Made by Luckymaxer

Debris = game:GetService("Debris")

function DestroyScript()
	Debris:AddItem(script, 3)
end

DestroyScript()

PartValue = script:WaitForChild("PartValue").Value
CFrameValue = script:WaitForChild("CFrameValue").Value

PartValue.CFrame = CFrameValue