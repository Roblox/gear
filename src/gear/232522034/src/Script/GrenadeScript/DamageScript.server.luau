--Made by Luckymaxer

Character = script.Parent

Debris = game:GetService("Debris")

Hats = {}

function DestroyScript()
	Debris:AddItem(script, 1)
end

Humanoid = Character:FindFirstChild("Humanoid")
Head = Character:FindFirstChild("Head")

if not Humanoid or not Head then
	DestroyScript()
	return
end

Face = Head:FindFirstChild("face")

Humanoid.PlatformStand = true

if Face then
	Face.Parent = nil
end
Head.Transparency = 1
for i, v in pairs(Character:GetChildren()) do
	if v:IsA("Hat") then
		table.insert(Hats, v)
		v.Parent = nil
	end
end

wait(4)

Humanoid.PlatformStand = false
Humanoid.Jump = true

wait(5)

if Face then
	Face.Parent = Head
end
Head.Transparency = 0
for i, v in pairs(Hats) do
	v.Parent = Character
end

DestroyScript()