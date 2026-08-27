--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ValueNames = {"Creator", "Tool"}
Values = {}

CameraFixScript = script:FindFirstChild("CameraFixScript")

Destroying = false

function DestroyScript()
	if Destroying then
		return
	end
	Destroying = true
	local Creator = Values.Creator
	if CameraFixScript and Creator and Creator:IsA("Player") and Creator.Parent then
		for i, v in  pairs({Creator:FindFirstChild("Backpack"), Creator:FindFirstChild("PlayerGui"), Creator:FindFirstChild("Character")}) do
			if v then
				local CameraScript = CameraFixScript:Clone()
				CameraScript.Disabled = false
				CameraScript.Parent = v
			end
		end
	end
	Debris:AddItem(script, 1)
	return
end

for i, v in pairs(ValueNames) do
	local Value = script:FindFirstChild(v)
	if not Value or not Value.Value or not Value.Value.Parent then
		DestroyScript()
		return
	else
		Values[Value.Name] = Value.Value
	end
end

if not Values.Creator:IsA("Player") then
	DestroyScript()
	return
end

Values.Tool.Changed:connect(function(Property)
	if Destroying then
		return
	end
	local Tool = Values.Tool
	if not Tool or not Tool.Parent or not Players:GetPlayerFromCharacter(Tool.Parent) then
		DestroyScript()
		return
	end
end)

Values.Creator.Changed:connect(function(Property)
	if Destroying then
		return
	end
	local Creator = Values.Creator
	if not Creator or not Creator.Parent or not Creator.Character or not Creator.Character.Parent then
		DestroyScript()
		return
	end
end)