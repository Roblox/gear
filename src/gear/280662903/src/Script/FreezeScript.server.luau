--Made by Luckymaxer

Object = script:WaitForChild("Object")

Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Character = script.Parent
Humanoid = Character:WaitForChild("Humanoid")

if not Object.Value or not Object.Value.Parent then
	DestroyScript()
	return
end

function DestroyScript()
	EnableControllability()
	Debris:AddItem(script, 0.5)
	return
end

function DisableControllability()
	Humanoid.AutoRotate = false
	Humanoid.WalkSpeed = 0
	DisableJump = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" then
			Humanoid.Jump = false
		end
	end)
end

function EnableControllability()
	Humanoid.AutoRotate = true
	Humanoid.WalkSpeed = 16
	for i, v in pairs({ObjectChanged, DisableJump}) do
		if v then
			v:disconnect()
		end
	end
end

ObjectChanged = Object.Value.Changed:connect(function(Property)
	if not Object.Value or not Object.Value.Parent then
		DestroyScript()
		return
	end
end)

DisableControllability()