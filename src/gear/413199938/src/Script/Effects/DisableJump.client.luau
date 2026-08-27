--Made by Luckymaxer

Debris = game:GetService("Debris")

Owner = script:FindFirstChild("Owner")

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

if not Owner or not Owner.Value or not Owner.Value.Parent then
	DestroyScript()
	return
end

Owner = Owner.Value

Owner.Changed:connect(function(Property)
	if Property == "Parent" and not Owner.Parent or not Owner.Parent.Parent then
		DestroyScript()
		return
	end
end)

Humanoid = script:WaitForChild("Humanoid")

Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	end
end)