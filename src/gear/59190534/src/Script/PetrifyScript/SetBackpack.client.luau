--Made by Luckymaxer

StarterGui = game:GetService("StarterGui")
Debris = game:GetService("Debris")

Boolean = script:FindFirstChild("Boolean")
if Boolean then
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, Boolean.Value)
end

Debris:AddItem(script, 2)