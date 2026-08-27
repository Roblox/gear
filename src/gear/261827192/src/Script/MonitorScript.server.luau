--Made by Luckymaxer

Value = script.Parent

Debris = game:GetService("Debris")

function DestroyModel()
	Debris:AddItem(Value, 0.5)
end

if not Value.Value then
	DestroyModel()
	return
end

Value.Changed:connect(function()
	if not Value.Value or not Value.Value.Parent then
		DestroyModel()
	end
end)

Value.Value.Changed:connect(function()
	if not Value.Value or not Value.Value.Parent then
		DestroyModel()
	end
end)