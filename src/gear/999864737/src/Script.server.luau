local Tool = script.Parent
local Handle = Tool.Handle
local Effect = Tool.Effect

function Equipped()	
	Effect.Transparency = 0.65
end

function Unequipped()
	Effect.Transparency = 1
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

Tool:GetPropertyChangedSignal("CanBeDropped"):Connect(function()
	Tool.CanBeDropped = false
end)