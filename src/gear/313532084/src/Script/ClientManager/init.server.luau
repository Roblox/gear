--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Destroying = false

Values = {}

for i, v in pairs(script:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Value")) then
		Values[v.Name] = v
	end
end

function DestroyScript()
	if Destroying then
		return
	end
	local GlitchFixer = script:FindFirstChild("GlitchFixer")
	if Creator and Creator:IsA("Player") and GlitchFixer then
		local Locations = {Creator:FindFirstChild("PlayerGui"), Creator:FindFirstChild("Backpack"), Creator.Character}
		for i, v in pairs(Locations) do
			if v and v.Parent then
				local GlitchFixerCopy = GlitchFixer:Clone()
				GlitchFixerCopy.Disabled = false
				GlitchFixerCopy.Parent = v
			end
		end
	end
	Debris:AddItem(script, 0.5)
	Destroying = true
end

if not Values.Creator or not Values.Tool or not Values.Enabled then
	DestroyScript()
	return
end

Creator = Values.Creator.Value
Tool = Values.Tool.Value
Enabled = Values.Enabled

if not Creator or not Creator.Parent or not Creator:IsA("Player") or not Creator.Character or not Creator.Character.Parent or not Tool or not Tool.Parent or not Enabled.Value then
	DestroyScript()
	return
end

Creator.Changed:connect(function(Property)
	if not Creator.Parent or not Creator.Character or not Creator.Character.Parent then
		DestroyScript()
	end
end)

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		DestroyScript()
	end
end)

Enabled.Changed:connect(function()
	if not Enabled.Value then
		DestroyScript()
	end
end)