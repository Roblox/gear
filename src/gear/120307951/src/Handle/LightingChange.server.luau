local Handle = script.Parent

local Light = Handle:WaitForChild("PointLight",10)

local Sparkles = Handle:WaitForChild("Sparkles",10)

Sparkles.Changed:Connect(function(property)
	Light.Enabled = Sparkles.Enabled
end)